apiVersion: v1
kind: Service
metadata:
  name: retail-postgres
  namespace: ${namespace}
spec:
  selector:
    app: retail-postgres
  ports:
    - name: postgres
      port: 5432
      targetPort: 5432
