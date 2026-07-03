#!/usr/bin/env bash
# 진행자 전용 — OIDC 아이덴티티 부트스트랩(az CLI).
# 이 테넌트는 Terraform azuread provider 경유 Graph 쓰기를 막으므로(403),
# 아이덴티티(앱·SP·federated credential·역할)는 az 로 만든다. 멱등(있으면 재사용).
# 한 앱(=하나의 AZURE_CLIENT_ID)에 여러 레포의 federated credential을 등록해,
# 템플릿에서 새로 뜬 데모 레포들이 같은 자격으로 prod 배포하도록 한다.
set -uo pipefail
APP_NAME="${APP_NAME:-harness-demo-oidc}"
# 이 앱을 신뢰할 레포들(공백 구분). 템플릿에서 새로 뜨는 데모 레포를 여기 추가한다.
REPOS="${REPOS:-hy2219/harness-demo-template hy2219/harness-demo}"
ENVIRONMENT="${ENVIRONMENT:-production}"
RG="${RG:-harness-rg}"
SUB="$(az account show --query id -o tsv)"
TEN="$(az account show --query tenantId -o tsv)"

APP_ID="$(az ad app list --display-name "$APP_NAME" --query '[0].appId' -o tsv)"
[ -z "$APP_ID" ] && APP_ID="$(az ad app create --display-name "$APP_NAME" --query appId -o tsv)"

az ad sp show --id "$APP_ID" >/dev/null 2>&1 || az ad sp create --id "$APP_ID" >/dev/null

for REPO in $REPOS; do
  SUBJECT="repo:${REPO}:environment:${ENVIRONMENT}"
  if az ad app federated-credential list --id "$APP_ID" --query "[?subject=='$SUBJECT'].subject" -o tsv | grep -q .; then
    echo "# federated-credential 존재(재사용): $SUBJECT"
  else
    CRED_NAME="gha-${ENVIRONMENT}-$(echo "$REPO" | tr '/' '-')"
    az ad app federated-credential create --id "$APP_ID" --parameters \
      "{\"name\":\"${CRED_NAME}\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"${SUBJECT}\",\"audiences\":[\"api://AzureADTokenExchange\"]}" >/dev/null
    echo "# federated-credential 생성: $SUBJECT (name=$CRED_NAME)"
  fi
done

az role assignment create --assignee "$APP_ID" --role Contributor \
  --scope "/subscriptions/${SUB}/resourceGroups/${RG}" >/dev/null 2>&1 || true

echo "AZURE_CLIENT_ID=$APP_ID"
echo "AZURE_TENANT_ID=$TEN"
echo "AZURE_SUBSCRIPTION_ID=$SUB"
echo "# 배선(각 레포 동일): for R in $REPOS; do gh secret set AZURE_CLIENT_ID -R \$R -b $APP_ID; done  (TENANT/SUBSCRIPTION 동일)"
