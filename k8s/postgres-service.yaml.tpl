apiVersion: v1
kind: Service
metadata:
  name: retail-postgres
  namespace: tbb
spec:
  selector:
    app: retail-postgres
  ports:
    - name: postgres
      port: 5432
      targetPort: 5432
