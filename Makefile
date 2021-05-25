ACCOUNT_NUMBER := $(shell aws sts get-caller-identity --output text --query 'Account')
GIT_HASH := $(shell git rev-parse --short HEAD)
LOCAL_TAG_NAME = rearc/app
LOCAL_TAG_NAME_FULL = $(LOCAL_TAG_NAME):$(GIT_HASH)
REMOTE_TAG_NAME = "$(ACCOUNT_NUMBER).dkr.ecr.us-east-1.amazonaws.com/$(LOCAL_TAG_NAME_FULL)"

bootstrap:
	cd terraform/iam && \
	terraform init && \
	terraform apply -auto-approve && \
	cd ../vpc && \
	terraform init && \
	terraform apply -var 'port=3000' -auto-approve && \
	cd ../ecs && \
	terraform init && \
	terraform apply -var 'repo_name=$(LOCAL_TAG_NAME)' -var 'git_hash=$(GIT_HASH)' -var 'port=3000' -auto-approve

build:
	docker build -t "$(LOCAL_TAG_NAME_FULL)" . && \
	docker tag "$(LOCAL_TAG_NAME_FULL)" "$(REMOTE_TAG_NAME)"

login:
	aws ecr get-login-password \
	--region us-east-1 | docker login \
	--username AWS \
	--password-stdin "$(ACCOUNT_NUMBER).dkr.ecr.us-east-1.amazonaws.com"

publish: build login
	docker push "$(REMOTE_TAG_NAME)" && \
	cd terraform/ecs && \
	terraform apply -var 'repo_name=$(LOCAL_TAG_NAME)' -var 'git_hash=$(GIT_HASH)' -var 'port=3000' -auto-approve

everything: bootstrap publish
