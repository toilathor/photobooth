.PHONY: frame-preview analyze test format format-check verify build-web-wasm test-web-mobile publish-web

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

build-web-wasm:
	@$(FLUTTER) build web --wasm --web-define=FLAVOR=personal

test-web-mobile:
	@bash scripts/test_mobile_web.sh

publish-web:
	@bash scripts/publish_web.sh $(TAG) $(PUSH)

frame-preview:
	@bash scripts/frame_preview.sh
