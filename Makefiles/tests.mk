

tests.rbxl: tests.project.json	$(PackagesDir)	$(SOURCES)	$(TEST_SOURCES)
	rojo build $< --output $@

ALL_TESTS= \
	tests.rbxl

