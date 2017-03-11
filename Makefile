STAGE = _YOUR_STAGE_
S3_BUCKET = _YOUR_S3_BUCKET_
REGION = _YOUR_AWS_REGION_
STACK_NAME = cfn-ci-cd-demo

package:
	@[ -d .cfn ] || mkdir .cfn
	@aws cloudformation package \
		--template-file cfn.yml \
		--s3-bucket $(S3_BUCKET) \
		--output-template-file .cfn/packaged.yml \
		--region $(REGION)

deploy:
	@if [ -f params/param.$(STAGE).json ]; then \
		aws cloudformation deploy \
			--template-file .cfn/packaged.yml \
			--stack-name $(STACK_NAME)-$(STAGE) \
			--capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
			--parameter-overrides `cat params/param.$(STAGE).json | jq -r '.Parameters | to_entries | map("\(.key)=\(.value|tostring)") | .[]' | tr '\n' ' ' | awk '{print}'` \
			--no-execute-changeset \
			--region $(REGION); \
	else \
		aws cloudformation deploy \
			--template-file .cfn/packaged.yml \
			--stack-name $(STACK_NAME)-$(STAGE) \
			--capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
			--no-execute-changeset \
			--region $(REGION); \
	fi


all: package deploy

.PHONY: package deploy all
