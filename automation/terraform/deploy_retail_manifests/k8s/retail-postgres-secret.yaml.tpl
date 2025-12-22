apiVersion: v1
kind: Secret
metadata:
  name: retail-postgres-secret
  namespace: ${namespace}
type: Opaque
stringData:
  POSTGRES_DB: retaildb
  POSTGRES_USER: retail_user
  POSTGRES_PASSWORD: retail_password
