variable "location" {
  description = "Azure 리전 — Container Apps 지원 리전."
  type        = string
  default     = "koreacentral"
}

variable "resource_group_name" {
  description = "이 데모 전용 리소스 그룹(통째 destroy 가능). deploy-azure.yml 의 RG 와 일치해야 한다."
  type        = string
  default     = "harness-rg"
}

variable "name_prefix" {
  description = "리소스 이름 접두사(제네릭)."
  type        = string
  default     = "harness"
}

variable "container_app_name" {
  description = "deploy-azure.yml 의 APP 값과 일치해야 한다."
  type        = string
  default     = "harness-container-app"
}

variable "app_port" {
  description = "컨테이너가 listen 하는 포트(Dockerfile EXPOSE 와 일치). ingress target_port."
  type        = number
  default     = 8000
}

variable "acr_sku" {
  type    = string
  default = "Basic"
}

variable "placeholder_image" {
  description = "최초 apply 시 올릴 자리표시 이미지(실이미지는 deploy-azure 가 ACR 빌드 후 교체)."
  type        = string
  default     = "mcr.microsoft.com/k8se/quickstart:latest"
}

variable "tags" {
  type = map(string)
  default = {
    project  = "harness-demo"
    owner    = "facilitator"
    teardown = "yes"
  }
}
