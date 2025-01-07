# Hashicorp Vault Configuration
Configure HCP Vault

### Secure AWS Credentials in Gitlab CI/CD with Terraform
Configure Hashicorp Vault to dynamically generate short-lived credentials for Gitlab CI/CD deployment to AWS.

For the full implementation refer to this [Hashicorp Vault Part 2 - Secure AWS Credentials in Gitlab CI/CD with Terraform]()

### Prerequisites

- [Terraform](https://www.terraform.io/).
- [Vault CLI](https://developer.hashicorp.com/vault/docs/install/install-binary).
- A working AWS Account. You can sign up for a [free tier](https://aws.amazon.com/free/).
- A running Vault environment. This is covered in part one of this article [Managing Application Secrets with Hashicorp Vault](https://medium.com/@calvineotieno010/managing-application-secrets-with-hashicorp-vault-8efb5e1d87fd).


### Usage

Create Terraform `terraform.tfvars` file with values that match your environment.

```sh
gitlab_pipeline_aws_assume_role="arn:aws:iam::<AWS_ACCOUNT_ID>:role/gitlab-pipeline-aws-assume-role"
vault_endpoint = "VAULT_ENDPOINT"
vault_token = "VAULT_TOKEN"
remote_state = {
  eks = {
    bucket               = "<REMOTE_BUCKET>"
    key                  = "<REMOTE_STATE_KEY>"
    region               = "<REMOTE_STATE_REGION>"
    workspace_key_prefix = "<REMOTE_STATE_WORKSPACE_KEY_PREFIX>"
    dynamodb_table       = "<REMOTE_STATE_DYNAMODB_TABLE>"
  }
}
```

Then run

```bash
terraform plan -out=vaultconfig.out
terraform apply vaultconfig.out
```

Sample `gitlab-ci.yml` file

```yaml
image: bash

stages:
  - test
  - plan
  - deploy

variables:
  TERRAFORM_VERSION: 1.5.3
  VAULT_VERSION: 1.13.1
  TF_VAR_pipeline_vault_role: recipe-app-api-proxy-pipeline
  TF_VAR_pipeline_vault_backend: recipe-app-api-proxy-aws

.id_tokens: &id_tokens
  id_tokens:
   VAULT_ID_TOKEN:
    aud: $VAULT_ADDR

.setup-builder: &setup_builder
  extends: .id_tokens
  image: europe-west4-docker.pkg.dev/nsw-production-environment/infrastructure/infrastructure-helm3:latest
  before_script:
    - apk --update add curl unzip bash
    - cd /usr/local/bin/
    - curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_386.zip --output terraform.zip
    - unzip terraform.zip
    - curl https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_386.zip --output vault.zip
    - unzip vault.zip
    - cd -
    - terraform version
    - vault version
    - export VAULT_TOKEN="$(vault write -field=token auth/jwt/login role=$TF_VAR_pipeline_vault_role jwt=$VAULT_ID_TOKEN)"

vault_auth:
  stage: test
  <<: *setup_builder
  script:
    - vault token lookup

plan:
  stage: plan
  artifacts:
    paths:
      - terraform/project/
    expire_in: 1 day
  <<: *setup_builder
  script:
    # Now use the VAULT_TOKEN to provide child token and execute Terraform in AWS env
    - cd terraform
    - export TF_VAR_vault_addr=$VAULT_ADDR
    - vault token lookup
    - terraform init
    - terraform plan

apply:
  stage: deploy
  when: manual
  <<: *setup_builder
  script:
    # Now use the VAULT_TOKEN to provide child token and execute Terraform in AWS env
    - cd terraform
    - export TF_VAR_vault_addr=$VAULT_ADDR
    - terraform init
    - terraform apply -auto-approve

destroy:
  stage: deploy
  when: manual
  <<: *setup_builder
  script:
    # Now use the VAULT_TOKEN to provide child token and execute Terraform in AWS env
    - cd terraform
    - export TF_VAR_vault_addr=$VAULT_ADDR
    - terraform init
    - terraform destroy -auto-approve
```

## Authors and Maintainers

* Calvine Otieno /[Calvine Otieno](https://github.com/NYARAS)
