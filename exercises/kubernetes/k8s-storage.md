# Kubernetes Storage: PersistentVolumes and PersistentVolumeClaims

**Difficulty:** Intermediate
**Estimated Time:** 35 minutes
**Prerequisites:** Kubernetes cluster running, kubectl installed, completed k8s-deployments.md exercise

> **Quick Navigation:** [Instructions](#instructions) | [Hints](#hints) | [Solution](#solution)

## Objective

Learn how to manage persistent storage in Kubernetes using PersistentVolumes (PV), PersistentVolumeClaims (PVC), and StorageClasses. By the end of this exercise, you'll understand how to provide durable storage for stateful applications that survives pod restarts and rescheduling.

## Instructions

### Part 1: Understanding Storage Concepts

Before we begin, let's understand the key concepts:
- **PersistentVolume (PV)**: A piece of storage in the cluster provisioned by an administrator or dynamically
- **PersistentVolumeClaim (PVC)**: A request for storage by a user
- **StorageClass**: Defines different classes of storage with different performance characteristics
- **Volume**: A directory accessible to containers in a pod (ephemeral or persistent)

### Part 2: Creating a PersistentVolume (Static Provisioning)

1. Create a PersistentVolume using hostPath (for local testing):
```bash
cat > pv-hostpath.yaml <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-hostpath
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath:
    path: /tmp/k8s-pv-data
    type: DirectoryOrCreate
EOF

kubectl apply -f pv-hostpath.yaml
```

2. View the PersistentVolume:
```bash
kubectl get pv
kubectl describe pv pv-hostpath
```

### Part 3: Creating a PersistentVolumeClaim

3. Create a PersistentVolumeClaim to request storage:
```bash
cat > pvc-hostpath.yaml <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-hostpath
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
  storageClassName: manual
EOF

kubectl apply -f pvc-hostpath.yaml
```

4. View the PVC and verify it's bound to the PV:
```bash
kubectl get pvc
kubectl describe pvc pvc-hostpath
kubectl get pv
```

The PV status should change from "Available" to "Bound".

### Part 4: Using PVC in a Pod

5. Create a pod that uses the PVC:
```bash
cat > pod-with-pvc.yaml <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: pod-with-storage
spec:
  containers:
  - name: app
    image: busybox
    command: ["sh", "-c", "echo 'Hello from persistent storage!' > /data/message.txt && cat /data/message.txt && sleep 3600"]
    volumeMounts:
    - name: persistent-storage
      mountPath: /data
  volumes:
  - name: persistent-storage
    persistentVolumeClaim:
      claimName: pvc-hostpath
EOF

kubectl apply -f pod-with-pvc.yaml
```

6. Verify the pod is running and check the logs:
```bash
kubectl get pods
kubectl logs pod-with-storage
```

7. Write some data to the persistent volume:
```bash
kubectl exec pod-with-storage -- sh -c "echo 'Data persists across pod restarts' > /data/persistent.txt"
kubectl exec pod-with-storage -- sh -c "date >> /data/persistent.txt"
kubectl exec pod-with-storage -- cat /data/persistent.txt
```

### Part 5: Testing Data Persistence

8. Delete the pod:
```bash
kubectl delete pod pod-with-storage
```

9. Create a new pod using the same PVC:
```bash
cat > pod-with-pvc-2.yaml <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: pod-with-storage-2
spec:
  containers:
  - name: app
    image: busybox
    command: ["sh", "-c", "sleep 3600"]
    volumeMounts:
    - name: persistent-storage
      mountPath: /data
  volumes:
  - name: persistent-storage
    persistentVolumeClaim:
      claimName: pvc-hostpath
EOF

kubectl apply -f pod-with-pvc-2.yaml
```

10. Verify the data persisted:
```bash
kubectl exec pod-with-storage-2 -- cat /data/persistent.txt
kubectl exec pod-with-storage-2 -- cat /data/message.txt
```

You should see the data from the previous pod!

### Part 6: Using PVC in a Deployment

11. Create a deployment with persistent storage:
```bash
cat > deployment-with-pvc.yaml <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: web-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: manual
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: web-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath:
    path: /tmp/k8s-web-data
    type: DirectoryOrCreate
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-with-storage
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web-storage
  template:
    metadata:
      labels:
        app: web-storage
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: web-content
          mountPath: /usr/share/nginx/html
      volumes:
      - name: web-content
        persistentVolumeClaim:
          claimName: web-pvc
EOF

kubectl apply -f deployment-with-pvc.yaml
```

12. Wait for the deployment to be ready:
```bash
kubectl rollout status deployment web-with-storage
```

13. Add custom content to the persistent volume:
```bash
kubectl exec $(kubectl get pods -l app=web-storage -o jsonpath='{.items[0].metadata.name}') -- sh -c "echo '<h1>Persistent Web Content</h1>' > /usr/share/nginx/html/index.html"
```

14. Expose the deployment and test:
```bash
kubectl expose deployment web-with-storage --port=80 --name=web-storage-service
kubectl run test-pod --image=busybox --rm -it --restart=Never -- wget -qO- http://web-storage-service
```

15. Delete the pod and verify content persists:
```bash
kubectl delete pod $(kubectl get pods -l app=web-storage -o jsonpath='{.items[0].metadata.name}')
kubectl wait --for=condition=ready pod -l app=web-storage --timeout=60s
kubectl run test-pod --image=busybox --rm -it --restart=Never -- wget -qO- http://web-storage-service
```

### Part 7: Dynamic Provisioning with StorageClass

16. Check available StorageClasses:
```bash
kubectl get storageclass
```

For kind clusters, you should see a "standard" StorageClass.

17. Create a PVC that uses dynamic provisioning:
```bash
cat > pvc-dynamic.yaml <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-dynamic
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
  storageClassName: standard
EOF

kubectl apply -f pvc-dynamic.yaml
```

18. Watch the PVC get automatically bound to a dynamically created PV:
```bash
kubectl get pvc pvc-dynamic -w
```
Press Ctrl+C after it's bound.

19. View the automatically created PV:
```bash
kubectl get pv
```

### Part 8: Access Modes and Volume Types

20. Create PVs with different access modes:
```bash
cat > pv-access-modes.yaml <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-read-write-once
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce  # Can be mounted read-write by a single node
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath:
    path: /tmp/k8s-rwo
    type: DirectoryOrCreate
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-read-only-many
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadOnlyMany  # Can be mounted read-only by many nodes
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath:
    path: /tmp/k8s-rom
    type: DirectoryOrCreate
EOF

kubectl apply -f pv-access-modes.yaml
```

21. View all PVs with their access modes:
```bash
kubectl get pv -o custom-columns=NAME:.metadata.name,CAPACITY:.spec.capacity.storage,ACCESS-MODES:.spec.accessModes,STATUS:.status.phase
```

### Part 9: Volume Expansion

22. Check if the StorageClass allows volume expansion:
```bash
kubectl get storageclass standard -o yaml | grep allowVolumeExpansion
```

23. If supported, expand a PVC (this may not work with hostPath volumes):
```bash
kubectl patch pvc pvc-dynamic -p '{"spec":{"resources":{"requests":{"storage":"3Gi"}}}}'
```

24. Check the PVC status:
```bash
kubectl get pvc pvc-dynamic
```

### Part 10: Reclaim Policies

25. Understand reclaim policies:
- **Retain**: PV is kept when PVC is deleted (manual cleanup required)
- **Delete**: PV is automatically deleted when PVC is deleted
- **Recycle**: PV is scrubbed and made available again (deprecated)

26. Test the Retain policy:
```bash
kubectl delete pvc pvc-hostpath
kubectl get pv pv-hostpath
```

The PV should show status "Released" (not "Available").

27. Manually reclaim the PV:
```bash
kubectl delete pv pv-hostpath
```

### Part 11: Cleanup

28. Delete all resources:
```bash
kubectl delete deployment web-with-storage
kubectl delete service web-storage-service
kubectl delete pod pod-with-storage-2
kubectl delete pvc web-pvc pvc-dynamic
kubectl delete pv web-pv pv-read-write-once pv-read-only-many
rm -f pv-hostpath.yaml pvc-hostpath.yaml pod-with-pvc.yaml pod-with-pvc-2.yaml deployment-with-pvc.yaml pvc-dynamic.yaml pv-access-modes.yaml
```

29. Verify cleanup:
```bash
kubectl get pv
kubectl get pvc
kubectl get deployments
```

## Expected Output

**After creating PV (step 2):**
```
NAME          CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   AGE
pv-hostpath   1Gi        RWO            Retain           Available           manual         5s
```

**After creating PVC (step 4):**
```
NAME           STATUS   VOLUME        CAPACITY   ACCESS MODES   STORAGECLASS   AGE
pvc-hostpath   Bound    pv-hostpath   1Gi        RWO            manual         5s
```

**After pod writes data (step 7):**
```
Data persists across pod restarts
Mon Jan 19 18:30:00 UTC 2026
```

**After recreating pod (step 10):**
```
Data persists across pod restarts
Mon Jan 19 18:30:00 UTC 2026
```
(Same data from previous pod!)

**After dynamic provisioning (step 19):**
```
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                 STORAGECLASS   AGE
pvc-12345678-abcd-1234-abcd-123456789abc   2Gi        RWO            Delete           Bound    default/pvc-dynamic   standard       10s
```

## Verification Steps

- PVs should be created and show "Available" status
- PVCs should bind to PVs and show "Bound" status
- Pods should successfully mount PVCs
- Data written to PVs should persist across pod deletions
- Dynamic provisioning should automatically create PVs
- Different access modes should be supported
- Reclaim policies should behave as expected

## Hints

<details>
<summary>Hint 1: PVC Not Binding</summary>

If a PVC stays in "Pending" status, check:
1. Is there a PV with matching StorageClass?
```bash
kubectl get pv
kubectl get pvc <pvc-name> -o yaml
```

2. Does the PV have enough capacity?
3. Do the access modes match?
4. Is the PV already bound to another PVC?

For dynamic provisioning, ensure the StorageClass exists:
```bash
kubectl get storageclass
```
</details>

<details>
<summary>Hint 2: Pod Can't Mount Volume</summary>

If a pod fails to mount a volume, check:
```bash
kubectl describe pod <pod-name>
```

Look for events like:
- "FailedMount": PVC doesn't exist or isn't bound
- "FailedAttachVolume": Volume can't be attached to node

Ensure:
- PVC exists and is bound
- Access mode is compatible with pod's node
- Only one pod uses ReadWriteOnce volumes
</details>

<details>
<summary>Hint 3: Data Not Persisting</summary>

If data doesn't persist:
1. Verify you're using a PVC (not emptyDir or hostPath directly)
2. Check the PV reclaim policy (should be Retain or Delete, not Recycle)
3. Ensure the PVC is bound to the same PV:
```bash
kubectl get pvc <pvc-name> -o yaml | grep volumeName
```

4. For hostPath volumes in kind, data is on the node, not the host
</details>

<details>
<summary>Hint 4: Understanding Access Modes</summary>

Access modes:
- **ReadWriteOnce (RWO)**: Volume can be mounted read-write by a single node
  - Use for: Single-pod applications, databases
- **ReadOnlyMany (ROX)**: Volume can be mounted read-only by many nodes
  - Use for: Shared configuration, static content
- **ReadWriteMany (RWX)**: Volume can be mounted read-write by many nodes
  - Use for: Shared storage (requires NFS, CephFS, etc.)
  - Not supported by hostPath or most cloud providers' default storage

Note: Access modes are about node access, not pod access!
</details>

---

## Solution

<details>
<summary>Click to reveal solution</summary>

**Key Concepts:**

1. **Static Provisioning**: Admin creates PVs, users create PVCs that bind to them
2. **Dynamic Provisioning**: PVCs automatically create PVs using StorageClasses
3. **Binding**: PVCs bind to PVs based on StorageClass, capacity, and access modes
4. **Lifecycle**: PV → Available → Bound → Released → (Reclaimed or Deleted)

**Best Practices:**

- Use dynamic provisioning in production (with cloud storage)
- Set appropriate reclaim policies (Delete for dynamic, Retain for important data)
- Use StorageClasses to define different storage tiers (SSD, HDD, etc.)
- Set resource requests and limits for storage
- Use ReadWriteOnce for most applications (better performance)
- Use StatefulSets for applications needing stable storage
- Back up important data (PVs can be lost!)
- Monitor storage usage and set up alerts

**Common Patterns:**

- **Databases**: Use StatefulSets with PVC templates
- **Shared Config**: Use ConfigMaps or ReadOnlyMany PVs
- **Logs**: Use emptyDir or send to external logging system
- **Temporary Data**: Use emptyDir (deleted with pod)
- **User Uploads**: Use ReadWriteMany PVs or object storage (S3)

**Storage Types by Provider:**

- **AWS**: EBS (RWO), EFS (RWX)
- **GCP**: Persistent Disk (RWO), Filestore (RWX)
- **Azure**: Azure Disk (RWO), Azure Files (RWX)
- **On-Prem**: NFS (RWX), Ceph (RWX), Local (RWO)

See the instructions above for complete command sequences.
</details>

## Additional Resources

- [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
- [Storage Classes](https://kubernetes.io/docs/concepts/storage/storage-classes/)
- [Dynamic Volume Provisioning](https://kubernetes.io/docs/concepts/storage/dynamic-provisioning/)
- [Configure a Pod to Use a PersistentVolume](https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/)

