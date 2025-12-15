#!/usr/bin/env bash
set -euo pipefail

########################################
# GLOBAL VARIABLES
########################################
OC_TOKEN="${1:-}"
OC_SERVER="${2:-}"
DOCKER_USERNAME="${3:-}"
DOCKER_PASSWORD="${4:-}"

OPENSHIFT_VERSION="4.18.28"
JMETER_VERSION="5.6.3"

BACKEND_IMAGE="docker.io/${DOCKER_USERNAME}/retail-backend:1.0.0"
FRONTEND_IMAGE="docker.io/${DOCKER_USERNAME}/retail-frontend:1.0.0"
GITHUB_ZIP_URL="https://github.com/SunilManika/retailapp/archive/refs/heads/main.zip"
POSTGRES_LABEL="app=retail-postgres"
NAMESPACE="tbb"

JMETER_INSTALL_DIR="/opt/jmeter"
JMETER_HOME="${JMETER_INSTALL_DIR}/apache-jmeter-${JMETER_VERSION}"

########################################
# LOGGING FUNCTIONS
########################################
step()  { echo; echo "---- $* ----"; }
info()  { echo "[INFO]  $*"; }
error() { echo "[ERROR] $*" >&2; exit 1; }

########################################
# COMMAND EXECUTION WRAPPER
########################################
run_cmd() {
    local description="$1"
    shift
    local cmd="$*"

    info "$description"
    if ! output=$(eval "$cmd" 2>&1); then
        echo
        error "FAILED: $description"
        echo "-------- FAILURE OUTPUT --------"
        echo "$output"
        echo "--------------------------------"
        exit 1
    fi
}

########################################
# SPINNER
########################################
spinner() {
    local pid=$1
    local delay=0.15
    local spinstr='|/-\'
    echo -n " "
    while ps -p $pid > /dev/null 2>&1; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "     \b\b\b\b\b"
}

########################################
# INPUT VALIDATION
########################################
[[ -z "$OC_TOKEN" || -z "$OC_SERVER" || -z "$DOCKER_USERNAME" || -z "$DOCKER_PASSWORD" ]] && \
    error "Usage: $0 <OC_TOKEN> <OC_SERVER> <DOCKER_USERNAME> <DOCKER_PASSWORD>"

[[ $EUID -ne 0 ]] && \
    error "This script must be run as root."

########################################
# 1. INSTALL PREREQUISITES
########################################
step "Installing prerequisites"
run_cmd "Installing unzip, podman, and JDK" \
    "yum -y -q install unzip podman java-11-openjdk"

########################################
# 2. INSTALL OC CLI
########################################
step "Installing OpenShift CLI"
run_cmd "Downloading OpenShift CLI ${OPENSHIFT_VERSION}" \
    "wget -q https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/${OPENSHIFT_VERSION}/openshift-client-linux-${OPENSHIFT_VERSION}.tar.gz"

run_cmd "Extracting OpenShift CLI" \
    "tar -xzf openshift-client-linux-${OPENSHIFT_VERSION}.tar.gz"

run_cmd "Moving OC binaries" \
    "mv oc kubectl /usr/local/bin/"

########################################
# 3. INSTALL JMETER
########################################
step "Installing JMeter ${JMETER_VERSION}"

run_cmd "Creating JMeter install directory" \
    "mkdir -p $JMETER_INSTALL_DIR"

cd "$JMETER_INSTALL_DIR"

run_cmd "Downloading JMeter" \
    "wget -q https://dlcdn.apache.org/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.zip"

run_cmd "Unzipping JMeter" \
    "unzip -qo apache-jmeter-${JMETER_VERSION}.zip"

export JMETER_HOME="$JMETER_HOME"
export PATH="$JMETER_HOME/bin:$PATH"

########################################
# 4. DOWNLOAD APPLICATION CODE
########################################
step "Downloading application source"

cd /root
run_cmd "Downloading retailapp repo ZIP" \
    "wget -q $GITHUB_ZIP_URL -O main.zip"

run_cmd "Unzipping repo" \
    "unzip -qo main.zip"

APP_DIR="/root/retailapp-main"
cd "$APP_DIR"

########################################
# 4A. UPDATE YAMLs WITH USER'S DOCKER USERNAME
########################################
step "Updating Kubernetes YAMLs with Docker username"

run_cmd "Updating frontend-deployment.yaml" \
    "sed -i \"s/technologybuildingblocks/${DOCKER_USERNAME}/g\" k8s/frontend-deployment.yaml"

run_cmd "Updating backend-deployment.yaml" \
    "sed -i \"s/technologybuildingblocks/${DOCKER_USERNAME}/g\" k8s/backend-deployment.yaml"

########################################
# 5. REGISTRY LOGIN
########################################
step "Logging into Docker registry"

run_cmd "Podman login" \
    "podman login -u ${DOCKER_USERNAME} -p '${DOCKER_PASSWORD}' docker.io"

########################################
# 6. BUILD BACKEND IMAGE
########################################
step "Building backend image"

cd backend/
run_cmd "Building backend image" \
    "podman build -t $BACKEND_IMAGE . > /dev/null"

run_cmd "Pushing backend image" \
    "podman push $BACKEND_IMAGE > /dev/null"

########################################
# 7. BUILD FRONTEND IMAGE (INITIAL)
########################################
step "Building frontend image (initial)"

cd ../frontend/
run_cmd "Building initial frontend image" \
    "podman build -t $FRONTEND_IMAGE --build-arg VITE_API_BASE_URL='' . > /dev/null"

run_cmd "Pushing initial frontend image" \
    "podman push $FRONTEND_IMAGE > /dev/null"

########################################
# 8. LOGIN TO OPENSHIFT
########################################
step "Logging into OpenShift cluster"

run_cmd "oc login" \
    "oc login --token=$OC_TOKEN --server=$OC_SERVER"

########################################
# 8A. CREATE DOCKER REGISTRY SECRET
########################################
step "Creating Docker registry secret for image pulls"

run_cmd "Creating dockerhub-secret" \
    "oc create secret docker-registry dockerhub-secret \
        --docker-server=docker.io \
        --docker-username=$DOCKER_USERNAME \
        --docker-password=$DOCKER_PASSWORD \
        --docker-email=test123@test.com \
        -n $NAMESPACE || true"

########################################
# 9. CREATE NAMESPACE & APPLY SCC
########################################
step "Creating namespace and SCC"

run_cmd "Applying namespace" \
    "oc apply -f $APP_DIR/k8s/namespace.yaml"

run_cmd "Assigning SCC anyuid" \
    "oc adm policy add-scc-to-user anyuid -z tbb -n $NAMESPACE"

########################################
# 10. APPLY MANIFESTS
########################################
step "Deploying Kubernetes manifests"

run_cmd "oc apply all manifests" \
    "oc apply -f $APP_DIR/k8s/"

########################################
# 11. GET BACKEND ROUTE & REBUILD FRONTEND
########################################
step "Fetching backend route"

BACKEND_ROUTE=$(oc get route -n "$NAMESPACE" 2>/dev/null | grep retail-backend | awk '{print $2}' || true)

[[ -z "$BACKEND_ROUTE" ]] && error "Failed to retrieve backend route."

info "Backend route detected: $BACKEND_ROUTE"

step "Rebuilding frontend with backend route"

cd ../frontend/
run_cmd "Rebuilding frontend image" \
    "podman build -t $FRONTEND_IMAGE --build-arg VITE_API_BASE_URL=https://$BACKEND_ROUTE/api . > /dev/null"

run_cmd "Pushing rebuilt frontend image" \
    "podman push $FRONTEND_IMAGE > /dev/null"

########################################
# 12. ROLLOUT RESTART DEPLOYMENTS
########################################
step "ROLLING OUT UPDATED DEPLOYMENTS"

info "Restarting backend deployment..."
oc rollout restart deployment/retail-backend -n "$NAMESPACE" > /dev/null
(
    oc rollout status deployment/retail-backend -n "$NAMESPACE" > /dev/null
) &
spinner $!

info "Restarting frontend deployment..."
oc rollout restart deployment/retail-frontend -n "$NAMESPACE" > /dev/null
(
    oc rollout status deployment/retail-frontend -n "$NAMESPACE" > /dev/null
) &
spinner $!

########################################
# 13. LOAD DATABASE
########################################
step "Loading database"

cd "$APP_DIR"

info "Searching for PostgreSQL pod..."

POD=""
for i in {1..10}; do
    POD=$(oc get pod -n "$NAMESPACE" -l "$POSTGRES_LABEL" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)
    [[ -n "$POD" ]] && break
    info "Waiting for PostgreSQL pod..."
    sleep 5
done

[[ -z "$POD" ]] && error "PostgreSQL pod not found."

info "PostgreSQL pod found: $POD"

run_cmd "Copying SQL dump into pod" \
    "oc cp db/full_dump.sql -n $NAMESPACE $POD:/tmp/full_dump.sql"

run_cmd "Executing SQL import" \
    "oc exec -n $NAMESPACE $POD -- bash -c 'psql -U retail_user -d retaildb < /tmp/full_dump.sql'"

########################################
# COMPLETE
########################################
step "Deployment completed successfully."
info "Retail App deployed, JMeter installed, images built, manifests applied, rollouts restarted, and database loaded."
echo "Access the frontend application via the OpenShift route for 'retail-frontend' in the '$NAMESPACE' namespace."
# End of deploy.sh