# Kubernetes Configuration: ConfigMaps and Secrets

**Difficulty:** Intermediate
**Estimated Time:** 35 minutes
**Prerequisites:** Kubernetes cluster running, kubectl installed, completed k8s-deployments.md and k8s-services.md exercises

> **Quick Navigation:** [Instructions](#instructions) | [Hints](#hints) | [Solution](#solution)

## Objective

Learn how to manage application configuration using ConfigMaps and Secrets, inject configuration into pods via environment variables and volume mounts, and understand best practices for sensitive data. By the end of this exercise, you'll be able to decouple configuration from container images.

## Instructions

### Part 1: Creating ConfigMaps

1. Create a ConfigMap from literal values:
```bash
kubectl create configmap app-config \
  --from-literal=APP_ENV=production \
  --from-literal=LOG_LEVEL=info \
  --from-literal=MAX_CONNECTIONS=100
```

2. View the ConfigMap:
```bash
kubectl get configmap app-config
kubectl describe configmap app-config
```

3. View the ConfigMap in YAML format:
```bash
kubectl get configmap app-config -o yaml
```

4. Create a ConfigMap from a file:
```bash
cat > app.properties <<EOF
database.host=postgres.default.svc.cluster.local
database.port=5432
database.name=myapp
cache.enabled=true
cache.ttl=3600
EOF

kubectl create configmap app-properties --from-file=app.properties
```

5. Create a ConfigMap from a directory:
```bash
mkdir config-files
echo "server { listen 80; }" > config-files/nginx.conf
echo "worker_processes 4;" > config-files/nginx-main.conf

kubectl create configmap nginx-config --from-file=config-files/
```

6. Create a ConfigMap from YAML:
```bash
cat > configmap.yaml <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: web-config
data:
  index.html: |
    <!DOCTYPE html>
    <html>
    <head><title>ConfigMap Demo</title></head>
    <body><h1>Hello from ConfigMap!</h1></body>
    </html>
  app.json: |
    {
      "name": "web-app",
      "version": "1.0.0",
      "features": ["auth", "api", "ui"]
    }
EOF

kubectl apply -f configmap.yaml
```

### Part 2: Using ConfigMaps as Environment Variables

7. Create a deployment that uses ConfigMap as environment variables:
```bash
cat > deployment-env.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-with-env
spec:
  replicas: 1
  selector:
    matchLabels:
      app: env-demo
  template:
    metadata:
      labels:
        app: env-demo
    spec:
      containers:
      - name: app
        image: busybox
        command: ["sh", "-c", "env && sleep 3600"]
        env:
        - name: APP_ENV
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: APP_ENV
        - name: LOG_LEVEL
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: LOG_LEVEL
        envFrom:
        - configMapRef:
            name: app-config
EOF

kubectl apply -f deployment-env.yaml
```

8. Verify the environment variables are set:
```bash
kubectl logs $(kubectl get pods -l app=env-demo -o jsonpath='{.items[0].metadata.name}') | grep -E "APP_ENV|LOG_LEVEL|MAX_CONNECTIONS"
```

### Part 3: Mounting ConfigMaps as Volumes

9. Create a deployment that mounts ConfigMap as a volume:
```bash
cat > deployment-volume.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-with-volume
spec:
  replicas: 1
  selector:
    matchLabels:
      app: volume-demo
  template:
    metadata:
      labels:
        app: volume-demo
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        volumeMounts:
        - name: config-volume
          mountPath: /usr/share/nginx/html
        - name: properties-volume
          mountPath: /etc/config
      volumes:
      - name: config-volume
        configMap:
          name: web-config
      - name: properties-volume
        configMap:
          name: app-properties
EOF

kubectl apply -f deployment-volume.yaml
```

10. Verify the files are mounted:
```bash
kubectl exec $(kubectl get pods -l app=volume-demo -o jsonpath='{.items[0].metadata.name}') -- ls -la /usr/share/nginx/html
kubectl exec $(kubectl get pods -l app=volume-demo -o jsonpath='{.items[0].metadata.name}') -- cat /usr/share/nginx/html/index.html
kubectl exec $(kubectl get pods -l app=volume-demo -o jsonpath='{.items[0].metadata.name}') -- cat /etc/config/app.properties
```

11. Expose the deployment and test:
```bash
kubectl expose deployment app-with-volume --port=80 --name=config-service
kubectl run test-pod --image=busybox --rm -it --restart=Never -- wget -qO- http://config-service
```

### Part 4: Creating and Using Secrets

12. Create a Secret from literal values:
```bash
kubectl create secret generic db-credentials \
  --from-literal=username=admin \
  --from-literal=password=super-secret-password
```

13. View the Secret (note: values are base64 encoded):
```bash
kubectl get secret db-credentials
kubectl describe secret db-credentials
kubectl get secret db-credentials -o yaml
```

14. Decode a secret value:
```bash
kubectl get secret db-credentials -o jsonpath='{.data.password}' | base64 --decode
echo ""
```

15. Create a Secret from files:
```bash
echo -n "my-api-key-12345" > api-key.txt
echo -n "my-secret-token-67890" > token.txt

kubectl create secret generic api-secrets \
  --from-file=api-key=api-key.txt \
  --from-file=token=token.txt
```

16. Create a TLS Secret:
```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout tls.key -out tls.crt \
  -subj "/CN=example.com/O=example"

kubectl create secret tls tls-secret --cert=tls.crt --key=tls.key
```

17. Create a Docker registry Secret:
```bash
kubectl create secret docker-registry my-registry-secret \
  --docker-server=docker.io \
  --docker-username=myuser \
  --docker-password=mypassword \
  --docker-email=myemail@example.com
```

### Part 5: Using Secrets in Pods

18. Create a deployment that uses Secrets as environment variables:
```bash
cat > deployment-secrets.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-with-secrets
spec:
  replicas: 1
  selector:
    matchLabels:
      app: secret-demo
  template:
    metadata:
      labels:
        app: secret-demo
    spec:
      containers:
      - name: app
        image: busybox
        command: ["sh", "-c", "env && sleep 3600"]
        env:
        - name: DB_USERNAME
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: username
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: password
        - name: API_KEY
          valueFrom:
            secretKeyRef:
              name: api-secrets
              key: api-key
EOF

kubectl apply -f deployment-secrets.yaml
```

19. Verify the secrets are available (but don't log them in production!):
```bash
kubectl exec $(kubectl get pods -l app=secret-demo -o jsonpath='{.items[0].metadata.name}') -- env | grep -E "DB_|API_KEY"
```

### Part 6: Mounting Secrets as Volumes

20. Create a deployment that mounts Secrets as volumes:
```bash
cat > deployment-secret-volume.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-with-secret-volume
spec:
  replicas: 1
  selector:
    matchLabels:
      app: secret-volume-demo
  template:
    metadata:
      labels:
        app: secret-volume-demo
    spec:
      containers:
      - name: app
        image: busybox
        command: ["sh", "-c", "ls -la /etc/secrets && cat /etc/secrets/username && sleep 3600"]
        volumeMounts:
        - name: secret-volume
          mountPath: /etc/secrets
          readOnly: true
      volumes:
      - name: secret-volume
        secret:
          secretName: db-credentials
EOF

kubectl apply -f deployment-secret-volume.yaml
```

21. Verify the secret files are mounted:
```bash
kubectl logs $(kubectl get pods -l app=secret-volume-demo -o jsonpath='{.items[0].metadata.name}')
kubectl exec $(kubectl get pods -l app=secret-volume-demo -o jsonpath='{.items[0].metadata.name}') -- ls -la /etc/secrets
```

### Part 7: Updating ConfigMaps and Secrets

22. Update a ConfigMap:
```bash
kubectl create configmap app-config \
  --from-literal=APP_ENV=staging \
  --from-literal=LOG_LEVEL=debug \
  --from-literal=MAX_CONNECTIONS=50 \
  --dry-run=client -o yaml | kubectl apply -f -
```

23. Check if pods see the updated values (environment variables don't update automatically):
```bash
kubectl logs $(kubectl get pods -l app=env-demo -o jsonpath='{.items[0].metadata.name}') | grep APP_ENV
```

24. Restart the deployment to pick up new values:
```bash
kubectl rollout restart deployment app-with-env
kubectl rollout status deployment app-with-env
```

25. Verify the new values:
```bash
kubectl logs $(kubectl get pods -l app=env-demo -o jsonpath='{.items[0].metadata.name}') | grep APP_ENV
```

26. Update a ConfigMap used as a volume (these update automatically after a delay):
```bash
kubectl create configmap web-config \
  --from-literal=index.html='<html><body><h1>Updated Content!</h1></body></html>' \
  --dry-run=client -o yaml | kubectl apply -f -
```

27. Wait a moment and check the updated content:
```bash
sleep 10
kubectl exec $(kubectl get pods -l app=volume-demo -o jsonpath='{.items[0].metadata.name}') -- cat /usr/share/nginx/html/index.html
```

### Part 8: Cleanup

28. Delete all resources:
```bash
kubectl delete deployment app-with-env app-with-volume app-with-secrets app-with-secret-volume
kubectl delete service config-service
kubectl delete configmap app-config app-properties nginx-config web-config
kubectl delete secret db-credentials api-secrets tls-secret my-registry-secret
rm -rf config-files app.properties api-key.txt token.txt tls.key tls.crt
```

29. Verify cleanup:
```bash
kubectl get configmaps
kubectl get secrets
kubectl get deployments
```

## Expected Output

**After creating ConfigMap (step 2):**
```
Name:         app-config
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
APP_ENV:
----
production
LOG_LEVEL:
----
info
MAX_CONNECTIONS:
----
100
```

**After viewing ConfigMap YAML (step 3):**
```yaml
apiVersion: v1
data:
  APP_ENV: production
  LOG_LEVEL: info
  MAX_CONNECTIONS: "100"
kind: ConfigMap
metadata:
  name: app-config
  namespace: default
```

**After checking environment variables (step 8):**
```
APP_ENV=production
LOG_LEVEL=info
MAX_CONNECTIONS=100
```

**After mounting ConfigMap (step 10):**
```html
<!DOCTYPE html>
<html>
<head><title>ConfigMap Demo</title></head>
<body><h1>Hello from ConfigMap!</h1></body>
</html>
```

**After decoding secret (step 14):**
```
super-secret-password
```

## Verification Steps

- ConfigMaps should be created and viewable with kubectl
- Environment variables from ConfigMaps should appear in pod logs
- ConfigMap files should be accessible at mount paths
- Secrets should be base64 encoded in YAML output
- Secret values should be available as environment variables
- Secret files should be mounted with correct permissions (0400)
- Updating ConfigMaps used as volumes should eventually reflect in pods
- Updating ConfigMaps used as env vars requires pod restart

## Hints

<details>
<summary>Hint 1: ConfigMap Not Found</summary>

If a pod fails with "ConfigMap not found", ensure:
1. The ConfigMap exists:
```bash
kubectl get configmap <name>
```

2. The ConfigMap is in the same namespace as the pod:
```bash
kubectl get configmap -n <namespace>
```

3. The key names in the ConfigMap match what's referenced in the pod spec.
</details>

<details>
<summary>Hint 2: Environment Variables Not Updating</summary>

Environment variables from ConfigMaps/Secrets are set at pod creation time. To update:
1. Update the ConfigMap/Secret
2. Restart the pods:
```bash
kubectl rollout restart deployment <deployment-name>
```

Volume-mounted ConfigMaps update automatically (with a delay), but env vars don't.
</details>

<details>
<summary>Hint 3: Secret Values Not Showing</summary>

Secret values are base64 encoded. To decode:
```bash
kubectl get secret <name> -o jsonpath='{.data.<key>}' | base64 --decode
```

In pods, secrets are automatically decoded when used as env vars or mounted files.
</details>

<details>
<summary>Hint 4: Permission Denied on Secret Files</summary>

Secret files are mounted with restrictive permissions (0400) by default. This is intentional for security. If you need different permissions, use:
```yaml
volumes:
- name: secret-volume
  secret:
    secretName: my-secret
    defaultMode: 0440
```
</details>

---

## Solution

<details>
<summary>Click to reveal solution</summary>

The complete solution involves creating ConfigMaps and Secrets, then using them in pods via environment variables and volume mounts. Key concepts:

**ConfigMaps:**
- Store non-sensitive configuration data
- Can be created from literals, files, or directories
- Can be consumed as environment variables or mounted as files
- Updates to volume-mounted ConfigMaps propagate automatically

**Secrets:**
- Store sensitive data (passwords, tokens, keys)
- Values are base64 encoded (not encrypted!)
- Should be used with RBAC and encryption at rest
- Can be consumed as environment variables or mounted as files
- Mounted secret files have restrictive permissions

**Best Practices:**
- Use ConfigMaps for non-sensitive configuration
- Use Secrets for sensitive data
- Mount as volumes when possible (allows updates without restart)
- Use environment variables for simple key-value pairs
- Never commit secrets to version control
- Use external secret management (Vault, AWS Secrets Manager) for production
- Enable encryption at rest for secrets in etcd

**Update Behavior:**
- Env vars: Require pod restart to update
- Volume mounts: Update automatically (kubelet sync period ~60s)
- Immutable ConfigMaps/Secrets: Cannot be updated (better for performance)

See the instructions above for complete command sequences.
</details>

## Additional Resources

- [ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/)
- [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
- [Configure Pods Using ConfigMaps](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/)
- [Distribute Credentials Securely Using Secrets](https://kubernetes.io/docs/tasks/inject-data-application/distribute-credentials-secure/)

