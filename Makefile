# build *.coffee in lib/ to lib-js/
LIBS=$(shell find . -regex "^./lib\/.*\.coffee\$$" | sed s/\.coffee$$/\.js/ | sed s/lib/lib-js/)

build: $(LIBS) cli.js

lib-js/%.js : lib/%.coffee
	node_modules/coffee-script/bin/coffee --bare -c -o $(@D) $(patsubst lib-js/%,lib/%,$(patsubst %.js,%.coffee,$@))

cli.js: ./lib-js/cli.js
	echo "#!/usr/bin/env node" | cat - ./lib-js/cli.js > /tmp/cli.js
	mv /tmp/cli.js ./cli.js
	chmod +x ./cli.js

# TODO
test: build
	./cli.js test/input/*.coffee > test/output.out
	git status -- test/output.out
untest:
	git checkout test/output.out

publish:
	$(eval VERSION := $(shell grep version package.json | sed -ne 's/^[ ]*"version":[ ]*"\([0-9\.]*\)",/\1/p';))
	@echo \'$(VERSION)\'
	$(eval REPLY := $(shell read -p "Publish and tag as $(VERSION)? " -n 1 -r; echo $$REPLY))
	@echo \'$(REPLY)\'
	@if [[ $(REPLY) =~ ^[Yy]$$ ]]; then \
	    npm publish; \
	    git tag -a v$(VERSION) -m "version $(VERSION)"; \
	    git push --tags; \
	fi
