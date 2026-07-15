.PHONY: test-web-mobile deploy-web

test-web-mobile:
	@bash scripts/test_mobile_web.sh

deploy-web:
	@bash scripts/deploy_web.sh
