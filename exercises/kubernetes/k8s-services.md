# Kubernetes Services: Exposing and Discovering Applications

**Difficulty:** Beginner
**Estimated Time:** 30 minutes
**Prerequisites:** Kubernetes cluster running, kubectl installed, completed k8s-deployments.md exercise

> **Quick Navigation:** [Instructions](#instructions) | [Hints](#hints) | [Solution](#solution)

## Objective

Learn how to expose Kubernetes applications using Services, understand different Service types (ClusterIP, NodePort, LoadBalancer), and test service discovery. By the end of this exercise, you'll understand how Services provide stable networking for dynamic pod sets.

## Instructions

### Part 1: Creating a Deployment to Expose

1. Create a deployment that we'll expose with services:
```bash
kubectl create deployment web-app --image=nginx:alpine --replicas=3
```

2. Verify the deployment and pods:
```bash
kubectl get deployments
kubectl get pods -o wide
```

Note the pod IPs - they're internal and ephemeral.

### Part 2: ClusterIP Service (Internal Access)

3. Expose the deployment with a ClusterIP service (default type):
```bash
kubectl expose deployment web-app --port=80 --target-port=80 --name=web-service
```

4. View the service:
```bash
kubectl get services
```

5. Describe the service to see endpoints:
```bash
kubectl describe service web-service
```

6. Get the service endpoints (pod IPs):
```bash
kubectl get endpoints web-service
```

7. Test the service from within the cluster using a temporary pod:
```bash
kubectl run test-pod --image=busybox --rm -it --restart=Never -- wget -qO- http://web-service
```

8. Test service discovery using DNS:
```bash
kubectl run test-pod --image=busybox --rm -it --restart=Never -- nslookup web-service
```

### Part 3: NodePort Service (External Access)

9. Create a NodePort service from YAML:
```bash
cat > nodeport-service.yaml <<EOF
apiVersion: v1
kind: Service
metadata:
  name: web-nodeport
spec:
  type: NodePort
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
EOF
```

10. Apply the NodePort service:
```bash
kubectl apply -f nodeport-service.yaml
```

11. View the service:
```bash
kubectl get service web-nodeport
```

12. Get the node IP (for kind cluster):
```bash
kubectl get nodes -o wide
```

13. Test access via NodePort (use localhost for kind):
```bash
curl http://localhost:30080
```

### Part 4: LoadBalancer Service (Cloud/MetalLB)

14. Create a LoadBalancer service:
```bash
cat > loadbalancer-service.yaml <<EOF
apiVersion: v1
kind: Service
metadata:
  name: web-loadbalancer
spec:
  type: LoadBalancer
  selector:
    app: web-app
  ports:
  - port: 8080
    targetPort: 80
EOF
```

15. Apply the LoadBalancer service:
```bash
kubectl apply -f loadbalancer-service.yaml
```

16. View the service (note: external IP may be pending in kind):
```bash
kubectl get service web-loadbalancer
```

Note: In kind clusters without MetalLB, the EXTERNAL-IP will show `<pending>`. In cloud environments (AWS, GCP, Azure), this would provision a real load balancer.

### Part 5: Service Discovery and DNS

17. Create a second deployment in a different namespace:
```bash
kubectl create namespace test-ns
kubectl create deployment backend --image=nginx:alpine --replicas=2 -n test-ns
kubectl expose deployment backend --port=80 -n test-ns
```

18. Test cross-namespace service discovery:
```bash
kubectl run test-pod --image=busybox --rm -it --restart=Never -- nslookup backend.test-ns.svc.cluster.local
```

19. Test accessing the service from default namespace:
```bash
kubectl run test-pod --image=busybox --rm -it --restart=Never -- wget -qO- http://backend.test-ns.svc.cluster.local
```

### Part 6: Service with Session Affinity

20. Create a service with session affinity (sticky sessions):
```bash
cat > sticky-service.yaml <<EOF
apiVersion: v1
kind: Service
metadata:
  name: web-sticky
spec:
  type: ClusterIP
  sessionAffinity: ClientIP
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 80
EOF
```

21. Apply the service:
```bash
kubectl apply -f sticky-service.yaml
```

22. Test that requests from the same client go to the same pod:
```bash
kubectl run test-pod --image=busybox --rm -it --restart=Never -- sh -c "for i in 1 2 3 4 5; do wget -qO- http://web-sticky | grep 'Server address'; done"
```

### Part 7: Headless Service (Direct Pod Access)

23. Create a headless service (no cluster IP):
```bash
cat > headless-service.yaml <<EOF
apiVersion: v1
kind: Service
metadata:
  name: web-headless
spec:
  clusterIP: None
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 80
EOF
```

24. Apply the headless service:
```bash
kubectl apply -f headless-service.yaml
```

25. Query DNS to see individual pod IPs:
```bash
kubectl run test-pod --image=busybox --rm -it --restart=Never -- nslookup web-headless
```

### Part 8: Testing Service Load Balancing

26. Add a custom index page to identify pods:
```bash
kubectl exec -it $(kubectl get pods -l app=web-app -o jsonpath='{.items[0].metadata.name}') -- sh -c "echo 'Pod 1' > /usr/share/nginx/html/index.html"
kubectl exec -it $(kubectl get pods -l app=web-app -o jsonpath='{.items[1].metadata.name}') -- sh -c "echo 'Pod 2' > /usr/share/nginx/html/index.html"
kubectl exec -it $(kubectl get pods -l app=web-app -o jsonpath='{.items[2].metadata.name}') -- sh -c "echo 'Pod 3' > /usr/share/nginx/html/index.html"
```

27. Test load balancing by making multiple requests:
```bash
kubectl run test-pod --image=busybox --rm -it --restart=Never -- sh -c "for i in 1 2 3 4 5 6; do wget -qO- http://web-service; echo ''; done"
```

You should see responses from different pods.

### Part 9: Cleanup

28. Delete all services and deployments:
```bash
kubectl delete service web-service web-nodeport web-loadbalancer web-sticky web-headless
kubectl delete deployment web-app
kubectl delete namespace test-ns
```

29. Verify cleanup:
```bash
kubectl get services
kubectl get deployments
```

## Expected Output

**After creating ClusterIP service (step 4):**
```
NAME          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
kubernetes    ClusterIP   10.96.0.1       <none>        443/TCP   1d
web-service   ClusterIP   10.96.123.45    <none>        80/TCP    5s
```

**After describing service (step 5):**
```
Name:              web-service
Namespace:         default
Labels:            app=web-app
Selector:          app=web-app
Type:              ClusterIP
IP Family Policy:  SingleStack
IP Families:       IPv4
IP:                10.96.123.45
Port:              <unset>  80/TCP
TargetPort:        80/TCP
Endpoints:         10.244.1.5:80,10.244.1.6:80,10.244.2.4:80
...
```

**After NodePort service (step 11):**
```
NAME           TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
web-nodeport   NodePort   10.96.234.56    <none>        80:30080/TCP   10s
```

**After testing ClusterIP (step 7):**
```html
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
...
```

**After DNS lookup (step 8):**
```
Server:    10.96.0.10
Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local

Name:      web-service
Address 1: 10.96.123.45 web-service.default.svc.cluster.local
```

**After load balancing test (step 27):**
```
Pod 1
Pod 2
Pod 3
Pod 1
Pod 2
Pod 3
```

## Verification Steps

- ClusterIP service should be accessible from within the cluster
- NodePort service should be accessible from the host machine
- Service DNS names should resolve correctly
- Endpoints should match the pod IPs
- Load balancing should distribute requests across pods
- Cross-namespace service discovery should work with FQDN
- Headless service should return individual pod IPs
- After cleanup, no services (except kubernetes) should remain

## Hints

<details>
<summary>Hint 1: Service Not Accessible</summary>

If you can't access a service, check:
1. Service exists and has endpoints:
```bash
kubectl get service <service-name>
kubectl get endpoints <service-name>
```

2. Pods are running:
```bash
kubectl get pods -l app=<app-label>
```

3. Service selector matches pod labels:
```bash
kubectl describe service <service-name>
kubectl get pods --show-labels
```
</details>

<details>
<summary>Hint 2: No Endpoints</summary>

If a service has no endpoints, the selector doesn't match any pods. Check:
```bash
kubectl describe service <service-name>  # Look at Selector
kubectl get pods --show-labels           # Look at pod labels
```

The selector must match the pod labels exactly.
</details>

<details>
<summary>Hint 3: NodePort Not Accessible</summary>

For kind clusters, use `localhost` instead of the node IP:
```bash
curl http://localhost:30080
```

Make sure the NodePort is in the valid range (30000-32767).

If using Docker Desktop, ensure the port is exposed in your cluster configuration.
</details>

<details>
<summary>Hint 4: DNS Not Working</summary>

If DNS lookups fail, check CoreDNS is running:
```bash
kubectl get pods -n kube-system -l k8s-app=kube-dns
```

The DNS name format is:
- Same namespace: `<service-name>`
- Different namespace: `<service-name>.<namespace>`
- FQDN: `<service-name>.<namespace>.svc.cluster.local`
</details>

---

## Solution

<details>
<summary>Click to reveal solution</summary>

Here's the complete sequence of commands:

```bash
# Create deployment
kubectl create deployment web-app --image=nginx:alpine --replicas=3
kubectl get deployments
kubectl get pods -o wide

# Create ClusterIP service
kubectl expose deployment web-app --port=80 --target-port=80 --name=web-service
kubectl get services
kubectl describe service web-service
kubectl get endpoints web-service

# Test from within cluster
kubectl run test-pod --image=busybox --rm -it --restart=Never -- wget -qO- http://web-service
kubectl run test-pod --image=busybox --rm -it --restart=Never -- nslookup web-service

# Create NodePort service
cat > nodeport-service.yaml <<EOF
apiVersion: v1
kind: Service
metadata:
  name: web-nodeport
spec:
  type: NodePort
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
EOF

kubectl apply -f nodeport-service.yaml
kubectl get service web-nodeport
curl http://localhost:30080

# Create LoadBalancer service
cat > loadbalancer-service.yaml <<EOF
apiVersion: v1
kind: Service
metadata:
  name: web-loadbalancer
spec:
  type: LoadBalancer
  selector:
    app: web-app
  ports:
  - port: 8080
    targetPort: 80
EOF

kubectl apply -f loadbalancer-service.yaml
kubectl get service web-loadbalancer

# Test cross-namespace discovery
kubectl create namespace test-ns
kubectl create deployment backend --image=nginx:alpine --replicas=2 -n test-ns
kubectl expose deployment backend --port=80 -n test-ns
kubectl run test-pod --image=busybox --rm -it --restart=Never -- nslookup backend.test-ns.svc.cluster.local
kubectl run test-pod --image=busybox --rm -it --restart=Never -- wget -qO- http://backend.test-ns.svc.cluster.local

# Create service with session affinity
cat > sticky-service.yaml <<EOF
apiVersion: v1
kind: Service
metadata:
  name: web-sticky
spec:
  type: ClusterIP
  sessionAffinity: ClientIP
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 80
EOF

kubectl apply -f sticky-service.yaml

# Create headless service
cat > headless-service.yaml <<EOF
apiVersion: v1
kind: Service
metadata:
  name: web-headless
spec:
  clusterIP: None
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 80
EOF

kubectl apply -f headless-service.yaml
kubectl run test-pod --image=busybox --rm -it --restart=Never -- nslookup web-headless

# Test load balancing
kubectl exec -it $(kubectl get pods -l app=web-app -o jsonpath='{.items[0].metadata.name}') -- sh -c "echo 'Pod 1' > /usr/share/nginx/html/index.html"
kubectl exec -it $(kubectl get pods -l app=web-app -o jsonpath='{.items[1].metadata.name}') -- sh -c "echo 'Pod 2' > /usr/share/nginx/html/index.html"
kubectl exec -it $(kubectl get pods -l app=web-app -o jsonpath='{.items[2].metadata.name}') -- sh -c "echo 'Pod 3' > /usr/share/nginx/html/index.html"

kubectl run test-pod --image=busybox --rm -it --restart=Never -- sh -c "for i in 1 2 3 4 5 6; do wget -qO- http://web-service; echo ''; done"

# Cleanup
kubectl delete service web-service web-nodeport web-loadbalancer web-sticky web-headless
kubectl delete deployment web-app
kubectl delete namespace test-ns
kubectl get services
```

**Explanation:**
- Services provide stable networking for dynamic pod sets
- ClusterIP (default) exposes service only within the cluster
- NodePort exposes service on each node's IP at a static port
- LoadBalancer provisions an external load balancer (cloud only)
- Service selectors match pod labels to route traffic
- DNS provides service discovery using service names
- Endpoints are automatically updated as pods come and go
- Session affinity ensures requests from same client go to same pod
- Headless services return pod IPs instead of a cluster IP
- Services load balance across healthy pods automatically
</details>

## Additional Resources

- [Kubernetes Services](https://kubernetes.io/docs/concepts/services-networking/service/)
- [Service Types](https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types)
- [DNS for Services and Pods](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/)

