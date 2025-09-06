

$(RBXM_BUILD): library.project.json	$(SOURCES)
	rojo build library.project.json --output $@

rbxm: clean-rbxm $(RBXM_BUILD)

