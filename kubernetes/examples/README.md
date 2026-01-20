# Kubernetes Example Manifests

This directory contains example Kubernetes manifests for learning and practicing Kubernetes concepts.

## Available Examples

### Workloads
- **deployment.yaml** - Example Deployment with 3 replicas, resource limits, and health checks

### Services
- **service-clusterip.yaml** - Internal service (ClusterIP) for cluster-internal communication
- **service-nodeport.yaml** - NodePort service exposing port 30080 on all nodes
- **service-loadbalancer.yaml** - LoadBalancer service (requires cloud provider or MetalLB)

### Configuration
- **configmap.yaml** - ConfigMap with key-value pairs and multi-line configuration files
- **secret.yaml** - Secret with base64-encoded sensitive data and usage examples

### Storage
- **persistentvolume.yaml** - PersistentVolume, PersistentVolumeClaim, and Pod using PVC

### Networking
- **ingress.yaml** - Ingress resources for HTTP routing (requires Ingress Controller)

## Usage

### Apply a single manifest:
```bash
kubectl apply -f deployment.yaml
```

### Apply all manifests:
```bash
kubectl apply -f .
```

### View resources:
```bash
kubectl get deployments
kubectl get services
kubectl get pods
kubectl get configmaps
kubectl get secrets
kubectl get pv,pvc
kubectl get ingress
```

### Delete resources:
```bash
kubectl delete -f deployment.yaml
# or delete all
kubectl delete -f .
```

## Notes

- These examples are designed to work with the kind cluster created by `setup-k8s.sh`
- Some resources (like LoadBalancer services) may require additional setup
- Ingress resources require an Ingress Controller to be installed
- Secrets contain example base64-encoded values for demonstration purposes
