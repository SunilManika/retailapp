# Deployment Steps on IBM Cloud Red Hat OpenShift

Assumptions:
- You have an OpenShift cluster and `oc` CLI configured.
- You have `podman` installed and logged in to Docker Hub (`docker.io/sunilmanika`).
- PostgreSQL storage is available via default StorageClass.

## 1. Build and Push Images with podman

From the project root:

```bash
# Backend
cd backend
podman build -t docker.io/sunilmanika/retail-backend:1.0.0 .
podman push docker.io/sunilmanika/retail-backend:1.0.0
cd ..

# Frontend
cd frontend
podman build -t docker.io/sunilmanika/retail-frontend:1.0.0 .
podman push docker.io/sunilmanika/retail-frontend:1.0.0
cd ..
```

## 2. Create OpenShift Project

```bash
oc new-project retail-demo
```

## 3. Create PostgreSQL Deployment and Service

```bash
oc apply -f k8s/postgres-deployment.yaml
oc apply -f k8s/postgres-service.yaml
```

Wait for the PostgreSQL pod to be `Running`.

## 4. Initialize the Database Schema and Seed Data

Copy `db/init.sql` into the postgres pod and run it:

```bash
# Get postgres pod name
PG_POD=$(oc get pods -l app=retail-postgres -o jsonpath='{.items[0].metadata.name}')

# Copy SQL file
oc cp db/init.sql $PG_POD:/tmp/init.sql

# Exec into pod to run psql
oc exec -it $PG_POD -- bash -c "psql -U retail_user -d retaildb -f /tmp/init.sql"
```

This creates tables, products, and ~50 users (user1..user50) with initial password placeholder
that is transparently migrated to bcrypt hashes on first login.

## 5. Create Backend Secrets and Config (Optional but Recommended)

For a quick demo, the manifests already include env vars inline.
For production, create Secrets/ConfigMaps and reference them from the backend Deployment.

## 6. Deploy Backend and Frontend

```bash
oc apply -f k8s/backend-deployment.yaml
oc apply -f k8s/backend-service.yaml

oc apply -f k8s/frontend-deployment.yaml
oc apply -f k8s/frontend-service.yaml
oc apply -f k8s/frontend-route.yaml
```

Optionally expose backend API via route:

```bash
oc apply -f k8s/backend-route.yaml
```

## 7. Get the Frontend URL

```bash
oc get route retail-frontend -o jsonpath='{.spec.host}{"\n"}'
```

Open the URL in a browser.

## 8. Login Credentials

Use any of the seeded demo users:

- Username: `user1` .. `user50`
- Password: `Password@123`

On first successful login, the plaintext password stored in PostgreSQL is migrated
to a bcrypt hash using bcryptjs in the backend.
