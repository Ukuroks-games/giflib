LIBNAME = giflib

PACKAGE_NAME = $(LIBNAME).zip

ifeq ($(OS),Windows_NT)
	CP = xcopy /y /-y /s /e
    MV = move /y /-y
	RM = del /q /s
else
	CP = cp -rf
	MV = mv -f
	RM = rm -rf
endif

BUILD_DIR = build

RBXM_BUILD = $(LIBNAME).rbxm

$(BUILD_DIR): 
	mkdir $@

./Packages: wally.toml
	wally install

lint:
	selene src/ tests/

include Makefiles/docs.mk
include Makefiles/rbxm.mk
include Makefiles/sources.mk
include Makefiles/tests.mk
include Makefiles/sourcemap.mk
include Makefiles/clean.mk
include Makefiles/package.mk
	
aftman-install: aftman.toml
	aftman install

.PHONY:	\
	clean	clean-package	clean-sourcemap	clean-rbxm	clean-test	\
	sourcemap	\
	rbxm	\
	lint	\
	package	\
	publish	configure	\
	docs	docs-dev	\
	aftman-install
