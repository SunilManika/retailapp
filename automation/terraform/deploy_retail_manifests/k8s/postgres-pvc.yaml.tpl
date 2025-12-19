apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: retail-postgres-pvc
  namespace: ${namespace}
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
