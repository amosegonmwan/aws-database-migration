
check:
	@echo "Running terraform checks"
	@terraform init
	@terraform fmt
	@terraform validate
	@echo "Your code is good to go!"
plan: check
	@echo "Running terraform plan"
	@terraform plan -out=tfplan
test: check
	@echo "Running tfsec test"
	@tfsec 
apply: check
	@echo "Running terraform apply"
	@terraform apply -auto-approve
destroy: check
	@echo "Running terraform destroy"
	@terraform destroy -auto-approve