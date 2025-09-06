
BUILD_SOURCES = $(addprefix $(BUILD_DIR)/, $(notdir $(SOURCES)))

$(BUILD_DIR)/wally.toml:	$(BUILD_DIR)	wally.toml
	$(CP) wally.toml build/

MV_SOURCES:	$(BUILD_DIR)	$(SOURCES)
	$(CP) src/* $(BUILD_DIR)

$(BUILD_SOURCES):	MV_SOURCES

package:	clean-package	clean-build	$(PACKAGE_NAME)


$(PACKAGE_NAME):	$(BUILD_SOURCES)	$(BUILD_DIR)/wally.toml
	wally package --output $(PACKAGE_NAME) --project-path $(BUILD_DIR)

