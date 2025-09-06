
SOURCES =	src/gif.luau	\
			src/gifFrame.luau	\
			src/init.luau

TEST_SOURCES =	tests/test.client.luau	\
				tests/combine.client.luau


$(SOURCES) $(TEST_SOURCES): Makefiles/sources.mk
