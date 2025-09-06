

sourcemap.json:	./Packages	tests.project.json
	rojo sourcemap tests.project.json --output $@

# Re gen sourcemap
sourcemap: sourcemap.json
