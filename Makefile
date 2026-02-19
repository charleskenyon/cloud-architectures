-include .env

arch							?= hybrid-cloud
export TF_VAR_region 			?= eu-west-2
export TF_VAR_arch 				 = ${arch}

all: init validate plan

init:
	cd architectures/${arch}/terraform && terraform init -backend=false

validate:
	cd architectures/${arch}/terraform && terraform validate

plan: 
	cd architectures/${arch}/terraform && terraform plan -input=false \
		-out /tmp/plan.out;

apply: 
	cd architectures/${arch}/terraform && terraform apply -auto-approve

destroy: 
	cd architectures/${arch}/terraform && terraform destroy