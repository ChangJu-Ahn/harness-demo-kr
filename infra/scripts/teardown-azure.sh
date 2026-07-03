#!/usr/bin/env bash
# 진행자 전용 — 세션 후 Azure 데모 리소스 정리(과금 중단).
# 전용 RG(harness-rg)를 통째로 삭제하면 ACR/Log Analytics/ACA env/Container App 이 함께 사라진다.
# OIDC 앱 등록은 여러 데모에서 재사용하므로 기본 보존(지우려면 DELETE_APP=1).
set -uo pipefail
RG="${RG:-harness-rg}"
APP_DISPLAY="${APP_DISPLAY:-harness-demo-oidc}"

echo "[1/2] 리소스 그룹 통째 삭제: $RG (ACR/Log Analytics/ACA env/Container App)"
az group delete -n "$RG" --yes --no-wait 2>/dev/null || true

if [ "${DELETE_APP:-0}" = 1 ]; then
  echo "[2/2] OIDC 앱 삭제: $APP_DISPLAY (federated credential·client id 소멸 — 재사용 불가)"
  APP_ID=$(az ad app list --display-name "$APP_DISPLAY" --query "[0].appId" -o tsv 2>/dev/null)
  [ -n "${APP_ID:-}" ] && az ad app delete --id "$APP_ID" 2>/dev/null && echo "  삭제됨: $APP_ID" || echo "  (앱 없음/이미 삭제)"
else
  echo "[2/2] OIDC 앱 보존(재사용). 삭제하려면 DELETE_APP=1 로 재실행."
fi
echo "완료."
