LIBNAME = giflib

PACKAGE_NAME = $(LIBNAME).zip

CP = cp -rf
MV = mv -f
RM = rm -rf

./build: 
	mkdir build
	
configure: ./build wally.toml src/*
	$(CP) src/* build/
	$(CP) wally.toml build/

package: configure
	wally package --output $(PACKAGE_NAME) --project-path build

publish: configure
	wally publish --project-path build

lint:
	selene src/ tests/

./Packages: wally.toml
	wally install

tests: ./Packages
	rojo build tests.project.json --output tests.rbxl

clean: 
	$(RM) build $(PACKAGE_NAME)
