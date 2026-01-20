# Kubernetes Basics: Working with Pods

**Difficulty:** Beginner
**Estimated Time:** 25 minutes
**Prerequisites:** Kubernetes cluster running (kind cluster from this playground), kubectl installed

> **Quick Navigation:** [Instructions](#instructions) | [Hints](#hints) | [Solution](#solution)

## Objective

Learn the fundamental Kubernetes commands for creating pods, viewing pod logs, and executing commands inside pods. By the end of this exercise, you'll understand pod lifecycle management and basic troubleshooting techniques.

## Instructions

### Part 1: Creating Your First Pod

1. Create a simple nginx pod using kubectl run:
```bash
kubectl run my-nginx --image=nginx:latest --port=80
```

2. Verify the pod is running:
```bash
kubectl get pods
```

3. Get detailed information about the pod:
```bash
kubectl describe pod my-nginx
```

4. View the pod's YAML definition:
```bash
kubectl get pod my-nginx -o yaml
```

### Part 2: Creating a Pod from YAML

5. Create a YAML file for a pod running a simple web server:
```bash
cat > my-pod.yaml <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: web-pod
  labels:
    app: web
    tier: frontend
spec:
  containers:
  - name: nginx
    image: nginx:alpine
    ports:
    - containerPort: 80
EOF
```

6. Apply the YAML file to create the pod:
```bash
kubectl apply -f my-pod.yaml
```

7. List all pods with labels:
```bash
kubectl get pods --show-labels
```

8. Filter pods by label:
```bash
kubectl get pods -l app=web
```

### Part 3: Viewing Pod Logs

9. View logs from the my-nginx pod:
```bash
kubectl logs my-nginx
```

10. Follow logs in real-time (press Ctrl+C to stop):
```bash
kubectl logs -f my-nginx
```

11. If a pod has multiple containers, specify the container name:
```bash
kubectl logs my-nginx -c nginx
```

### Part 4: Executing Commands in Pods

12. Execute a simple command in the pod:
```bash
kubectl exec my-nginx -- nginx -v
```

13. Open an interactive shell inside the pod:
```bash
kubectl exec -it my-nginx -- /bin/bash
```

14. Inside the pod, explore the filesystem:
```bash
ls /usr/share/nginx/html/
cat /usr/share/nginx/html/index.html
exit
```

15. Execute a command to check the pod's environment:
```bash
kubectl exec my-nginx -- env
```

### Part 5: Port Forwarding and Testing

16. Forward a local port to the pod:
```bash
kubectl port-forward my-nginx 8080:80
```

17. In another terminal, test the connection:
```bash
curl http://localhost:8080
```

18. Stop the port-forward with Ctrl+C in the first terminal.

### Part 6: Cleanup

19. Delete the pods:
```bash
kubectl delete pod my-nginx
kubectl delete pod web-pod
```

20. Verify the pods are deleted:
```bash
kubectl get pods
```

## Expected Output

**After creating the pod (step 2):**
```
NAME       READY   STATUS    RESTARTS   AGE
my-nginx   1/1     Running   0          10s
```

**After describing the pod (step 3):**
```
Name:             my-nginx
Namespace:        default
Priority:         0
Service Account:  default
Node:             kind-worker/172.18.0.3
Start Time:       Mon, 19 Jan 2026 10:30:00 -0800
Labels:           run=my-nginx
Status:           Running
IP:               10.244.1.5
...
```

**After viewing logs (step 9):**
```
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
...
2026/01/19 18:30:00 [notice] 1#1: start worker processes
```

**After port-forward and curl (step 17):**
```html
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
...
```

## Verification Steps

- `kubectl get pods` should show pods in Running status
- `kubectl describe pod` should show detailed pod information including events
- `kubectl logs` should display container output
- `kubectl exec` commands should execute successfully inside the pod
- Port forwarding should allow access to the pod from localhost
- After cleanup, `kubectl get pods` should show no pods or "No resources found"

## Hints

<details>
<summary>Hint 1: Pod Not Starting</summary>

If the pod is stuck in Pending or ImagePullBackOff status, check the events:
```bash
kubectl describe pod my-nginx
```

Look at the Events section at the bottom for error messages. Common issues:
- Image pull errors: Check image name and internet connectivity
- Resource constraints: Check if cluster has enough resources
</details>

<details>
<summary>Hint 2: Cannot Execute Commands</summary>

The `kubectl exec` command only works on running pods. Verify the pod status:
```bash
kubectl get pods
```

If the pod is not Running, check the logs and events:
```bash
kubectl logs my-nginx
kubectl describe pod my-nginx
```
</details>

<details>
<summary>Hint 3: Port Forward Not Working</summary>

Make sure:
1. The pod is in Running status
2. The container port matches the port in the pod spec (80 for nginx)
3. No other process is using port 8080 on your machine

Try a different local port:
```bash
kubectl port-forward my-nginx 8081:80
```
</details>

<details>
<summary>Hint 4: YAML File Errors</summary>

If applying the YAML file fails, check:
- Indentation is correct (YAML is whitespace-sensitive)
- No tabs are used (use spaces only)
- All required fields are present

Validate the YAML:
```bash
kubectl apply -f my-pod.yaml --dry-run=client
```
</details>

---

## Solution

<details>
<summary>Click to reveal solution</summary>

Here's the complete sequence of commands:

```bash
# Create a pod using kubectl run
kubectl run my-nginx --image=nginx:latest --port=80

# Verify the pod is running
kubectl get pods

# Get detailed information
kubectl describe pod my-nginx

# View YAML definition
kubectl get pod my-nginx -o yaml

# Create a pod from YAML file
cat > my-pod.yaml <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: web-pod
  labels:
    app: web
    tier: frontend
spec:
  containers:
  - name: nginx
    image: nginx:alpine
    ports:
    - containerPort: 80
EOF

# Apply the YAML
kubectl apply -f my-pod.yaml

# List pods with labels
kubectl get pods --show-labels

# Filter by label
kubectl get pods -l app=web

# View logs
kubectl logs my-nginx

# Follow logs (Ctrl+C to stop)
kubectl logs -f my-nginx

# Execute a command
kubectl exec my-nginx -- nginx -v

# Open interactive shell
kubectl exec -it my-nginx -- /bin/bash
# Inside the pod:
ls /usr/share/nginx/html/
cat /usr/share/nginx/html/index.html
exit

# Check environment variables
kubectl exec my-nginx -- env

# Port forward to the pod
kubectl port-forward my-nginx 8080:80 &

# Test the connection
curl http://localhost:8080

# Stop port-forward
pkill -f "port-forward my-nginx"

# Cleanup
kubectl delete pod my-nginx
kubectl delete pod web-pod

# Verify deletion
kubectl get pods
```

**Explanation:**
- `kubectl run` creates a pod with a single container
- `kubectl get pods` lists all pods in the current namespace
- `kubectl describe` shows detailed information including events
- `kubectl logs` displays container stdout/stderr
- `kubectl exec` runs commands inside a container
- `-it` provides an interactive terminal
- `kubectl port-forward` creates a tunnel from localhost to the pod
- `kubectl delete` removes resources
- Labels help organize and filter resources
- YAML files provide declarative configuration
</details>

## Additional Resources

- [Kubernetes Pods](https://kubernetes.io/docs/concepts/workloads/pods/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Debugging Pods](https://kubernetes.io/docs/tasks/debug/debug-application/debug-pods/)

# TEST MODIFICATION Tue Jan 20 10:17:06 EET 2026
# SELECTIVE TEST MODIFICATION Tue Jan 20 10:17:06 EET 2026
