# 진행자 Azure 환경 — Terraform

`deploy-azure.yml`(진행자용)이 배포하는 Azure 리소스를 코드로 고정한다. 컴퓨트는 VM이 아니라
**Azure Container Apps**(서버리스 컨테이너, scale-to-zero)라서 유휴 비용이 없고 start/stop 관리가 없다.

## 무엇을 만드나 (전용 RG `harness-rg` 안)
- **ACR**(`harnessacr<suffix>`, Basic): 진행자 OIDC 로 `az acr build` 한 이미지를 저장. admin 계정 끔.
- **Log Analytics + Container Apps Environment**(`harness-aca-env`): 앱 실행 환경/로그.
- **Container App**(`harness-container-app`): 외부 HTTPS ingress(`target_port=8000`), 시스템 관리
  아이덴티티 + **AcrPull**(레지스트리 비밀번호 저장 없음), `min_replicas=0`(scale-to-zero).
- **아이덴티티**(OIDC 앱·federated credential·RG 범위 Contributor)는 `scripts/bootstrap-identity.sh`(az).

전부 **전용 리소스 그룹**(`harness-rg`) 안에 있어 `terraform destroy` 한 번으로 정리된다.

## 사전 조건
- `az login` + 구독 선택(`az account set --subscription <id>`)
- 역할 부여 권한(Owner/User Access Administrator) — role_assignment(AcrPull) 생성에 필요.

## 적용
```bash
terraform init
terraform apply     # 승인 후 생성(과금 시작). 최초엔 자리표시 이미지로 뜨고, deploy-azure 가 실이미지로 교체.
```
`deploy-azure.yml`의 `RG`/`APP` 값이 출력의 `resource_group_name`/`container_app_name`과 같은지 확인
(기본값 `harness-rg`/`harness-container-app`). ACR 이름은 전역 유일이라 워크플로가 `az acr list`로 자동 해석한다.

## 배포 흐름
`prod` 푸시 → deploy-azure → OIDC 로그인 → `az acr build`(ACR 빌드) → `az containerapp update`(이미지 교체)
→ 스모크(ingress FQDN). ingress `target_port`가 앱 포트(8000)와 어긋나면 502(의도된 버그 시연).

## 정리(세션 후, 과금 중단)
```bash
terraform destroy          # 또는 scripts/teardown-azure.sh (RG 통째 삭제)
```

## 나중에 build-up
- **스케일/리비전**: `max_replicas`↑, `revision_mode="Multiple"`로 blue-green.
- **커스텀 도메인·인증서**: Container Apps Environment 에 추가.
- **상태 원격화**: 팀 공유가 필요하면 `backend "azurerm"`(스토리지 계정)로 state 이전.
