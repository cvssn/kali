#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o verbose
set -o xtrace

PROJECT_ID="projectsigstore"
PROJECT_NUMBER="498091336538"
POOL_NAME="githubactions"
PROVIDER_NAME="sigstore-cosign"
LOCATION="global"
REPO="sigstore/cosign"
SERVICE_ACCOUNT_ID="github-actions-cosign"
SERVICE_ACCOUNT="${SERVICE_ACCOUNT_ID}@${PROJECT_ID}.iam.gserviceaccount.com"

# cria uma identidade workload caso não esteja presente
if ! (gcloud iam workload-identity-pools describe "${POOL_NAME}" --location=${LOCATION}); then
    gcloud iam workload-identity-pools create "${POOL_NAME}" \
        --project="${PROJECT_ID}" \
        --location="${LOCATION}" \
        --display-name="github actions pool"
fi

# cria um provedor de identidade de carga de trabalho, se não estiver presente
if ! (gcloud iam workload-identity-pools providers describe "${PROVIDER_NAME}" --location="${LOCATION}" --workload-identity-pool="${POOL_NAME}"); then
    gcloud iam workload-identity-pools providers create-oidc "${PROVIDER_NAME}" \
    --project="${PROJECT_ID}" \
    --location="${LOCATION}" \
    --workload-identity-pool="${POOL_NAME}" \
    --display-name="github actions provider cosign" \
    --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.aud=assertion.aud,attribute.repository=assertion.repository" \
    --issuer-uri="https://token.actions.githubusercontent.com"
fi

# cria uma conta de serviço se não estiver presente
if ! (gcloud iam service-accounts describe "${SERVICE_ACCOUNT}"); then
gcloud iam service-accounts create ${SERVICE_ACCOUNT_ID} \
    --description="conta de serviço para o github actions cosign" \
    --display-name="github actions cosign"
fi

# adicionar ligação é idempotente
gcloud iam service-accounts add-iam-policy-binding "${SERVICE_ACCOUNT}" \
    --project="${PROJECT_ID}" \
    --role="roles/iam.workloadIdentityUser" \
    --member="principalSet://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/${LOCATION}/workloadIdentityPools/${POOL_NAME}/attribute.repository/${REPO}"

# adicionar ligação é idempotente
# usado para iniciar a construção da nuvem
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --project="${PROJECT_ID}" \
    --role="roles/cloudbuild.builds.editor" \
    --member="serviceAccount:${SERVICE_ACCOUNT}"

# adicionar ligação é idempotente
# permissão necessária para rodar `gcloud builds`
# https://cloud.google.com/build/docs/securing-builds/configure-access-to-resources#granting_permissions_to_run_gcloud_commands
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --project="${PROJECT_ID}" \
    --role="roles/serviceusage.serviceUsageConsumer" \
    --member="serviceAccount:${SERVICE_ACCOUNT}"