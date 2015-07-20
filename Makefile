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
