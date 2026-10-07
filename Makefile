.PHONY: analyze test format format-check verify test-web-mobile deploy-web

FLUTTER ?= fvm flutter
DART ?= fvm dart

analyze:
	@$(FLUTTER) analyze

test:
	@$(FLUTTER) test

format:
	@$(DART) format lib test

format-check:
	@$(DART) format --output=none --set-exit-if-changed lib test

verify: format-check analyze test

test-web-mobile:
	@bash scripts/test_mobile_web.sh

deploy-web:
	@bash scripts/deploy_web.sh
