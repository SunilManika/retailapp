apiVersion: v1
kind: ServiceAccount
metadata:
  name: retail
  namespace: ${namespace}
imagePullSecrets:
  - name: dockerhub-secret