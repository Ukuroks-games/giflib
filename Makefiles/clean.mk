

clean-sourcemap:
	$(RM) sourcemap.json

clean-rbxm:
	$(RM) $(RBXM_BUILD)

clean-tests:
	$(RM) tests.rbxl

clean-build:
	$(RM) $(BUILD_DIR)

clean-package:
	$(RM) $(PACKAGE_NAME) ./Packages

clean:	clean-tests	clean-build	clean-rbxm	clean-sourcemap	clean-package
