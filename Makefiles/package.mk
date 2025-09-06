
$(BUILD_DIR)/wally.toml:	$(BUILD_DIR)	wally.toml
	$(CP) wally.toml $(BUILD_DIR)/wally.toml

MV_SOURCES:	$(BUILD_DIR)	$(SOURCES)
	$(CP) src/* $(BUILD_DIR)/

package:	clean-package	clean-build	$(PACKAGE_NAME)


$(PACKAGE_NAME):	MV_SOURCES	$(BUILD_DIR)/wally.toml
	wally package --output $(PACKAGE_NAME) --project-path $(BUILD_DIR)

publish:	clean-build	MV_SOURCES	$(BUILD_DIR)/wally.toml
	wally publish --project-path $(BUILD_DIR)
