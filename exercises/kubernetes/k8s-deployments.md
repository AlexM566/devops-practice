# Kubernetes Deployments: Scaling and Updates

**Difficulty:** Beginner
**Estimated Time:** 30 minutes
**Prerequisites:** Kubernetes cluster running, kubectl installed, completed k8s-pods.md exercise

> **Quick Navigation:** [Instructions](#instructions) | [Hints](#hints) | [Solution](#solution)

## Objective

Learn how to create and manage Kubernetes Deployments, scale applications, and perform rolling updates. By the end of this exercise, you'll understand how Deployments manage ReplicaSets and Pods to provide declarative updates and self-healing capabilities.

## Instructions

### Part 1: Creating Your First Deployment

1. Create a deployment using kubectl create:
```bash
kubectl create deployment nginx-deploy --image=nginx:1.21 --replicas=3
```

2. Verify the deployment is created:
```bash
kubectl get deployments
```

3. View the ReplicaSet created by the deployment:
```bash
kubectl get replicasets
```

4. View the pods created by the deployment:
```bash
kubectl get pods
```

5. Get detailed information about the deployment:
```bash
kubectl describe deployment nginx-deploy
```

### Part 2: Creating a Deployment from YAML

6. Create a YAML file for a more complex deployment:
```bash
cat > web-deployment.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  labels:
    app: web
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx:1.21-alpine
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "100m"
          limits:
            memory: "128Mi"
            cpu: "200m"
EOF
```

7. Apply the deployment:
```bash
kubectl apply -f web-deployment.yaml
```

8. Watch the deployment rollout:
```bash
kubectl rollout status deployment/web-app
```

9. View all resources created:
```bash
kubectl get all -l app=web
```

### Part 3: Scaling Deployments

10. Scale the nginx-deploy deployment to 5 replicas:
```bash
kubectl scale deployment nginx-deploy --replicas=5
```

11. Watch the pods being created:
```bash
kubectl get pods -w
```
Press Ctrl+C to stop watching.

12. Scale down to 2 replicas:
```bash
kubectl scale deployment nginx-deploy --replicas=2
```

13. Verify the scaling:
```bash
kubectl get deployment nginx-deploy
kubectl get pods
```

14. Scale using the YAML file (edit replicas to 4):
```bash
kubectl patch deployment web-app -p '{"spec":{"replicas":4}}'
```

15. Verify the change:
```bash
kubectl get deployment web-app
```

### Part 4: Rolling Updates

16. Update the nginx-deploy image to a newer version:
```bash
kubectl set image deployment/nginx-deploy nginx=nginx:1.22
```

17. Watch the rolling update in progress:
```bash
kubectl rollout status deployment/nginx-deploy
```

18. View the rollout history:
```bash
kubectl rollout history deployment/nginx-deploy
```

19. Check the ReplicaSets (you should see old and new):
```bash
kubectl get replicasets
```

20. Describe the deployment to see the update events:
```bash
kubectl describe deployment nginx-deploy
```

### Part 5: Rolling Back Updates

21. Perform another update (to a non-existent version to simulate a problem):
```bash
kubectl set image deployment/nginx-deploy nginx=nginx:broken-version
```

22. Watch the rollout (it will hang):
```bash
kubectl rollout status deployment/nginx-deploy
```
Press Ctrl+C after a few seconds.

23. Check the pods (some will be in ImagePullBackOff):
```bash
kubectl get pods
```

24. Roll back to the previous version:
```bash
kubectl rollout undo deployment/nginx-deploy
```

25. Verify the rollback:
```bash
kubectl rollout status deployment/nginx-deploy
kubectl get pods
```

26. Roll back to a specific revision:
```bash
kubectl rollout history deployment/nginx-deploy
kubectl rollout undo deployment/nginx-deploy --to-revision=1
```

### Part 6: Self-Healing

27. Delete one of the pods manually:
```bash
kubectl delete pod $(kubectl get pods -l app=nginx-deploy -o jsonpath='{.items[0].metadata.name}')
```

28. Immediately check the pods:
```bash
kubectl get pods -w
```
You'll see Kubernetes automatically creates a new pod to maintain the desired replica count. Press Ctrl+C to stop watching.

### Part 7: Cleanup

29. Delete the deployments:
```bash
kubectl delete deployment nginx-deploy
kubectl delete deployment web-app
```

30. Verify cleanup:
```bash
kubectl get deployments
kubectl get pods
```

## Expected Output

**After creating deployment (step 2):**
```
NAME           READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deploy   3/3     3            3           15s
```

**After viewing ReplicaSets (step 3):**
```
NAME                      DESIRED   CURRENT   READY   AGE
nginx-deploy-7d64c5d8f9   3         3         3       20s
```

**After scaling to 5 replicas (step 11):**
```
NAME                            READY   STATUS    RESTARTS   AGE
nginx-deploy-7d64c5d8f9-abc12   1/1     Running   0          2m
nginx-deploy-7d64c5d8f9-def34   1/1     Running   0          2m
nginx-deploy-7d64c5d8f9-ghi56   1/1     Running   0          2m
nginx-deploy-7d64c5d8f9-jkl78   1/1     Running   0          10s
nginx-deploy-7d64c5d8f9-mno90   1/1     Running   0          10s
```

**After rolling update (step 17):**
```
Waiting for deployment "nginx-deploy" rollout to finish: 1 out of 2 new replicas have been updated...
Waiting for deployment "nginx-deploy" rollout to finish: 1 old replicas are pending termination...
deployment "nginx-deploy" successfully rolled out
```

**After rollout history (step 18):**
```
deployment.apps/nginx-deploy
REVISION  CHANGE-CAUSE
1         <none>
2         <none>
```

## Verification Steps

- `kubectl get deployments` should show desired and current replica counts matching
- Scaling should increase/decrease the number of running pods
- Rolling updates should gradually replace old pods with new ones
- Rollback should restore the previous version
- Self-healing should automatically recreate deleted pods
- After cleanup, no deployments or pods should remain

## Hints

<details>
<summary>Hint 1: Deployment Not Ready</summary>

If the deployment shows fewer READY replicas than desired, check the pod status:
```bash
kubectl get pods
kubectl describe pod <pod-name>
```

Common issues:
- Image pull errors
- Insufficient cluster resources
- Container crashes (check logs with `kubectl logs`)
</details>

<details>
<summary>Hint 2: Scaling Not Working</summary>

Verify the scale command succeeded:
```bash
kubectl get deployment <deployment-name>
```

Check for events:
```bash
kubectl describe deployment <deployment-name>
```

If pods aren't being created, check cluster resources:
```bash
kubectl describe nodes
```
</details>

<details>
<summary>Hint 3: Rolling Update Stuck</summary>

If a rolling update hangs, check the new pods:
```bash
kubectl get pods
kubectl describe pod <new-pod-name>
```

Common issues:
- Bad image name/tag
- Container failing health checks
- Insufficient resources

To recover, roll back:
```bash
kubectl rollout undo deployment/<deployment-name>
```
</details>

<details>
<summary>Hint 4: Understanding ReplicaSets</summary>

Deployments create ReplicaSets, which create Pods. After an update, you'll see:
- Old ReplicaSet with 0 desired replicas (kept for rollback)
- New ReplicaSet with current desired replicas

View them:
```bash
kubectl get replicasets
```

Each ReplicaSet has a hash suffix that corresponds to the pod template.
</details>

---

## Solution

<details>
<summary>Click to reveal solution</summary>

Here's the complete sequence of commands:

```bash
# Create a deployment
kubectl create deployment nginx-deploy --image=nginx:1.21 --replicas=3

# Verify creation
kubectl get deployments
kubectl get replicasets
kubectl get pods

# Describe the deployment
kubectl describe deployment nginx-deploy

# Create deployment from YAML
cat > web-deployment.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  labels:
    app: web
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx:1.21-alpine
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "100m"
          limits:
            memory: "128Mi"
            cpu: "200m"
EOF

kubectl apply -f web-deployment.yaml
kubectl rollout status deployment/web-app
kubectl get all -l app=web

# Scale up
kubectl scale deployment nginx-deploy --replicas=5
kubectl get pods -w  # Ctrl+C to stop

# Scale down
kubectl scale deployment nginx-deploy --replicas=2
kubectl get deployment nginx-deploy

# Scale using patch
kubectl patch deployment web-app -p '{"spec":{"replicas":4}}'
kubectl get deployment web-app

# Rolling update
kubectl set image deployment/nginx-deploy nginx=nginx:1.22
kubectl rollout status deployment/nginx-deploy
kubectl rollout history deployment/nginx-deploy
kubectl get replicasets

# Simulate failed update
kubectl set image deployment/nginx-deploy nginx=nginx:broken-version
kubectl rollout status deployment/nginx-deploy  # Ctrl+C after a few seconds
kubectl get pods

# Rollback
kubectl rollout undo deployment/nginx-deploy
kubectl rollout status deployment/nginx-deploy

# Rollback to specific revision
kubectl rollout history deployment/nginx-deploy
kubectl rollout undo deployment/nginx-deploy --to-revision=1

# Test self-healing
kubectl delete pod $(kubectl get pods -l app=nginx-deploy -o jsonpath='{.items[0].metadata.name}')
kubectl get pods -w  # Watch new pod being created, Ctrl+C to stop

# Cleanup
kubectl delete deployment nginx-deploy
kubectl delete deployment web-app
kubectl get deployments
kubectl get pods
```

**Explanation:**
- Deployments manage ReplicaSets, which manage Pods
- `replicas` specifies the desired number of pod copies
- `kubectl scale` changes the replica count
- `kubectl set image` updates the container image
- Rolling updates gradually replace old pods with new ones
- `kubectl rollout undo` reverts to the previous version
- Deployments provide self-healing by maintaining desired state
- Resource requests/limits help Kubernetes schedule pods efficiently
- Labels and selectors connect Deployments to their Pods
</details>

## Additional Resources

- [Kubernetes Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [Performing a Rolling Update](https://kubernetes.io/docs/tutorials/kubernetes-basics/update/update-intro/)
- [kubectl rollout](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#rollout)

