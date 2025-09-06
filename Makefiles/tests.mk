
tests.rbxl: ./Packages tests.project.json $(SOURCES) $(TEST_SOURCES)
	rojo build tests.project.json --output $@

tests:	tests.rbxl
