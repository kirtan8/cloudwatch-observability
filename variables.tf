variable "cluster_name" {
  default = "devops-cluster"
}

variable "region" {
  default = "ap-south-1"
}

variable "account_id" {
  default = "976193256461"
}

variable "oidc_provider_url" {
  default = "oidc.eks.ap-south-1.amazonaws.com/id/<OIDC_ID>"  # Replace <OIDC_ID>
}
