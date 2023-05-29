# Plan launches terraform plan
.PHONY: plan
plan:
	terraform init
	terraform plan

# Apply launches terraform apply
.PHONY: apply
apply:
	terraform init
	terraform apply

# Destroy deletes the provisioned resources
.PHONY: destroy
destroy:
	terraform init
	terraform destroy
