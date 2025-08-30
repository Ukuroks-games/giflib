LIBNAME = giflib

PACKAGE_NAME = $(LIBNAME).zip

ifeq ($(OS),Windows_NT)
	CP = xcopy /y /-y /s /e
    MV = move /y /-y
	RM = del /q /s
else
	CP = cp -rf
	MV = mv -f
	RM = -rf
endif

BUILD_DIR = build

RBXM_BUILD = $(LIBNAME).rbxm

SOURCES =	src/gif.luau	\
			src/gifFrame.luau	\
			src/init.luau

TEST_SOURCES =	tests/test.client.luau	\
				tests/combine.client.luau
$(BUILD_DIR): 
	mkdir $@

./Packages: wally.toml
	wally install

NPM_ROOT = $(shell npm root)

$(NPM_ROOT)/.bin/moonwave:
	npm i moonwave@latest


$(BUILD_DIR)/html: $(NPM_ROOT)/.bin/moonwave moonwave.toml $(SOURCES)
	$(NPM_ROOT)/.bin/moonwave build --out-dir $@

docs: $(BUILD_DIR)/html

configure: clean-build $(BUILD_DIR) wally.toml $(SOURCES)
	$(CP) src/* $(BUILD_DIR)
	$(CP) wally.toml $(BUILD_DIR)/

package: configure $(SOURCES)
	wally package --output $(PACKAGE_NAME) --project-path $(BUILD_DIR)

publish: configure $(SOURCES)
	wally publish --project-path $(BUILD_DIR)

lint:
	selene src/ tests/

$(RBXM_BUILD): library.project.json	$(SOURCES)
	rojo build library.project.json --output $@

rbxm: clean-rbxm $(RBXM_BUILD)

tests.rbxl: ./Packages tests.project.json $(SOURCES) $(TEST_SOURCES)
	rojo build tests.project.json --output $@

tests: clean-tests tests.rbxl

sourcemap.json: ./Packages tests.project.json
	rojo sourcemap tests.project.json --output $@

# Re gen sourcemap
sourcemap: clean-sourcemap sourcemap.json


clean-sourcemap: 
	$(RM) sourcemap.json

clean-rbxm:
	$(RM) $(RBXM_BUILD)

clean-tests:
	$(RM) tests.rbxl

clean-build:
	$(RM) $(BUILD_DIR)

clean: clean-tests clean-build clean-rbxm clean-sourcemap
	$(RM) $(PACKAGE_NAME) ./Packages
