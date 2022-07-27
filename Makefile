#╦  ╦╔═╗╦═╗╔═╗
#╚╗╔╝╠═╣╠╦╝╚═╗
# ╚╝ ╩ ╩╩╚═╚═╝
ROOT_DIR:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))
TERRAFORM = cd terraform && terraform
AUTHOR = cicdguy
APP_NAME = goodrx-api
DOCKER_IMAGE = ${AUTHOR}/${APP_NAME}
APP_VERSION = 1.0

.PHONY: list
list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

all: docker-publish tf-infra

.PHONY: docker-build docker-publish docker-run

#╔╦╗╔═╗╔═╗╦╔═╔═╗╦═╗
# ║║║ ║║  ╠╩╗║╣ ╠╦╝
#═╩╝╚═╝╚═╝╩ ╩╚═╝╩╚═
docker-build:
ifeq ($(APP_VERSION),latest)
	@docker build --rm --tag ${DOCKER_IMAGE}:latest .
else
	@docker build --rm --tag ${DOCKER_IMAGE}:latest .
	@docker build --rm --tag ${DOCKER_IMAGE}:$(APP_VERSION) .
endif

docker-publish: check-docker-env docker-build
	docker login --username "$(AUTHOR)" --password "${DOCKER_PASSWORD}"
ifeq ($(APP_VERSION),latest)
	@docker push ${DOCKER_IMAGE}:latest
else
	@docker push ${DOCKER_IMAGE}:$(APP_VERSION)
	@docker push ${DOCKER_IMAGE}:latest
endif

docker-run: docker-build
	@docker run --rm -p 80:80 ${DOCKER_IMAGE}:latest

#╔╦╗╔═╗╦═╗╦═╗╔═╗╔═╗╔═╗╦═╗╔╦╗
# ║ ║╣ ╠╦╝╠╦╝╠═╣╠╣ ║ ║╠╦╝║║║
# ╩ ╚═╝╩╚═╩╚═╩ ╩╚  ╚═╝╩╚═╩ ╩
.PHONY: tf-init tf-plan tf-apply tf-destroy tf-infra

tf-init:  
	@$(TERRAFORM) init -var "aws_access_key=${AWS_ACCESS_KEY_ID}" \
					   -var "aws_secret_key=${AWS_SECRET_ACCESS_KEY}" \
					   -var "app_name=$(APP_NAME)"

tf-plan: check-aws-env
	@$(TERRAFORM) plan -var "aws_access_key=${AWS_ACCESS_KEY_ID}" \
					   -var "aws_secret_key=${AWS_SECRET_ACCESS_KEY}" \
					   -var "app_name=$(APP_NAME)"

tf-apply: check-aws-env
	@$(TERRAFORM) apply -var "aws_access_key=${AWS_ACCESS_KEY_ID}" \
						-var "aws_secret_key=${AWS_SECRET_ACCESS_KEY}" \
						-var "app_name=$(APP_NAME)" \
						-auto-approve

tf-destroy: check-aws-env
	@$(TERRAFORM) destroy -var "aws_access_key=${AWS_ACCESS_KEY_ID}" \
						  -var "aws_secret_key=${AWS_SECRET_ACCESS_KEY}"

tf-fmt:
	@$(TERRAFORM) fmt .

tf-infra: tf-init tf-apply

#╔═╗╦ ╦╔═╗╔═╗╦╔═╔═╗
#║  ╠═╣║╣ ║  ╠╩╗╚═╗
#╚═╝╩ ╩╚═╝╚═╝╩ ╩╚═╝
check-aws-env: 
	@test -n "$(AWS_ACCESS_KEY_ID)" || (echo "AWS_ACCESS_KEY_ID env not set"; exit 1)
	@test -n "$(AWS_SECRET_ACCESS_KEY)" || (echo "AWS_SECRET_ACCESS_KEY env not set"; exit 1)

check-docker-env:
	@test -n "$(DOCKER_PASSWORD)" || (echo "DOCKER_PASSWORD env not set"; exit 1)