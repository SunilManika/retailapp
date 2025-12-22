apiVersion: apps/v1
kind: Deployment
metadata:
  name: retail-postgres
  namespace: ${namespace}
  labels:
    app: retail-postgres
spec:
  replicas: 1
  selector:
    matchLabels:
      app: retail-postgres
  template:
    metadata:
      labels:
        app: retail-postgres
    spec:
      serviceAccountName: retail
      imagePullSecrets:
        - name: dockerhub-secret
      securityContext:
        fsGroup: 26
      containers:
        - name: postgres
          image: docker.io/${docker_username}/retail-postgresql:1.0.0
          env:
            - name: POSTGRES_DB
              value: retaildb
            - name: POSTGRES_USER
              value: retail_user
            - name: POSTGRES_PASSWORD
              value: retail_password
            - name: PGDATA
              value: /var/lib/postgresql/data/pgdata
          resources:
            requests:
              cpu: "100m"
              memory: "256Mi"
            limits:
              cpu: "500m"
              memory: "1Gi"
          volumeMounts:
            - name: data
              mountPath: /var/lib/postgresql/data
          ports:
            - containerPort: 5432

      volumes:
        - name: data
          persistentVolumeClaim:
            claimName: retail-postgres-pvc
