-include .env

arch								?= hybrid-cloud
export TF_VAR_region 				?= ${AWS_REGION}
export TF_VAR_deployment_account 	 = ${AWS_ACCOUNT}
export TF_VAR_arch 				 	 = ${arch}

ifeq ($(arch),hybrid-cloud)
TEST_SCRIPT := architectures/hybrid-cloud/tests/test-network-connectivity.sh
endif

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

test:
	@test -n "$(TEST_SCRIPT)" || (echo "No test script mapped for arch=$(arch)" && exit 1)
	bash "$(TEST_SCRIPT)"