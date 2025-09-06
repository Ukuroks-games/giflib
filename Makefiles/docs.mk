
NPM_ROOT = $(shell npm root)
MOONWAVE_CMD = build

$(NPM_ROOT)/.bin/moonwave:
	npm i moonwave@latest


$(BUILD_DIR)/html: $(NPM_ROOT)/.bin/moonwave moonwave.toml $(SOURCES) $(BUILD_DIR)
	$(NPM_ROOT)/.bin/moonwave $(MOONWAVE_CMD) --out-dir $@

docs: $(BUILD_DIR)/html

docs-dev: clean-build
	make "MOONWAVE_CMD=dev" docs
