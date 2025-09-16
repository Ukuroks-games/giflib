

tests.rbxl: $(PackagesDir) tests.project.json $(SOURCES) $(TEST_SOURCES)
	rojo build tests.project.json --output $@

ALL_TESTS= \
	tests.rbxl

