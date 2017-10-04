# Coffee->JSHint

[![npm version](https://badge.fury.io/js/coffee-jshint.svg)](https://badge.fury.io/js/coffee-jshint)
[![David dependency drift detection](https://david-dm.org/marviq/coffee-jshint.svg)](https://david-dm.org/marviq/coffee-jshint)

Runs your CoffeeScript source through [JSHint](http://www.jshint.com/) to check for errors.

**NOTE: As of version `1.0.0`, `coffee-jshint` changed its dependencies to be on [`coffeescript`](https://www.npmjs.com/package/coffeescript) in favor of the, now deprecated, [`coffee-script`](https://www.npmjs.com/package/coffee-script) name.**

## Installation

    npm install coffeescript -g // See package.json for supported versions (most)
    npm install coffee-jshint -g

## Usage

To check some files:

    coffee-jshint file1.coffee file2.coffee ...

### Options

JSHint takes [a bunch of options](http://www.jshint.com/docs/#options) that tell it various rules to enforce or relax.  Some of these don't make much sense to check for JS generated by the CoffeeScript compiler, so by default these options are turned on:

- **undef:** warns about use of undeclared variables
- **eqnull:** suppresses warnings about `== null`, which CoffeeScript uses in its generated JS
- **expr:** suppresses warnings about expressions in unexpected positions, which can only occur in generated JS when the CoffeeScript compiler does it on purpose
- **shadow:** suppresses warnings about variable shadowing, which is fine since CoffeeScript has sane scoping rules and generates safely scoped JS that uses shadowed variables
- **sub:** suppresses warnings about using bracket object lookup notation (`obj['field']`) when you could use dot notation (`obj.field`) since we're grown ups and can make our own decisions about what lookup syntax is best
- **multistr:** suppresses warnings about multiline strings, since CoffeeScript takes care of them

To turn on more options, you can use the `--options` or `-o` flag:

    coffee-jshint -o trailing,browser,sub file1.coffee file2.coffee ...

If you really must turn off some of the default options, use the `--default-options-off` flag (you can always use `--options` to turn some back on):

    coffee-jshint --default-options-off --options undef,eqnull ...

### Globals

You'll probably get a lot of complaints from Coffee->JSHint about undefined global variables like `console`, `$`, or `require`.  Depending on where you're running your code, you might want to allow a few global variables.  One easy way to handle this is to use JSHint's built in [environment options](http://www.jshint.com/docs/#environments).

For instance, if you're running your code using Node.js, then you'll want to turn on the `node` option.  It works like any other option:

    coffee-jshint -o node ...

If you have some globals that aren't covered by any of environments, well then you should probably check yo'self before you wreck yo'self.  But if you really want to turn off warnings for some global variables, Coffee->JSHint supports it using the `--globals` or `-g` option.  One use case is when using [Mocha](http://mochajs.org/), a testing library:

    coffee-jshint -o node --globals describe,it ...

### Shell scripting

Coffee->JSHint plays nicely with your favorite Unix utilities.  If you want to recursively search all the files in a directory, try piping in the results of a `find`.  Here's an example that also uses `grep` to filter out files in `node_modules/`:

    find . -type f -path "*.coffee" | grep -v "node_modules/" | xargs coffee-jshint

### Git hook

To use Coffee->JSHint as a git pre-commit hook to check changed files before you commit, put something like this in `.git/hooks/pre-commit`:

```bash
git diff --staged --name-only | xargs coffee-jshint
if [[ $? -ne 0 ]]; then
    echo 'WARNING: You are about to commit files with coffee-jshint warnings'
    exit 1
fi
```

This will take all the files you plan to commit changes to, run them through `coffee-jshint`, and exit with status code `1` if there are any warnings (which it will also print out).  If there are warnings, the commit will be aborted, but you can always do `git commit --no-verify` to bypass the hook.

## Contributing

### Prerequisites

  * [npm and node](https://nodejs.org/en/download/)
  * [jq](https://stedolan.github.io/jq/download/)
  * Some form of [make](https://en.wikipedia.org/wiki/Make_%28software%29)


### Setup

Clone this repository somewhere, switch to it, then:

```bash
$ git config commit.template ./.gitmessage
$ npm install
```

This will:

  * Set up [a helpful reminder](.gitmessage) of how to make [a good commit message](#commit-message-format-discipline).  If you adhere to this, then a
    detailed, meaningful [CHANGELOG](./CHANGELOG.md) can be constructed automatically;
  * Install all required dependencies;


### Build

```bash
make
```


### Commit

#### Commit Message Format Discipline

This project uses [`conventional-changelog/standard-version`](https://github.com/conventional-changelog/standard-version) for automatic versioning and
[CHANGELOG](./CHANGELOG.md) management.

To make this work, *please* ensure that your commit messages adhere to the
[Commit Message Format](https://github.com/bcoe/conventional-changelog-standard/blob/master/convention.md#commit-message-format).  Setting your `git config` to
have the `commit.template` as referenced below will help you with [a detailed reminder](.gitmessage) of how to do this on every `git commit`.

```bash
$ git config commit.template ./.gitmessage
```


### Release

  * Determine what your next [semver](https://docs.npmjs.com/getting-started/semantic-versioning#semver-for-publishers) `<version>` should be:

    ```bash
    $ version="<version>"
    ```

  * Bump the package's `.version`, update the [CHANGELOG](./CHANGELOG.md), commit these, and tag the commit as `v<version>`:

    ```bash
    $ npm run release
    ```

  * If all is well this new `version` **should** be identical to your intended `<version>`:

    ```bash
    $ jq ".version == \"${version}\"" package.json
    ```

    *If this is not the case*, then either your assumptions about what changed are wrong, or (at least) one of your commits did not adhere to the
    [Commit Message Format Discipline](#commit-message-format-discipline); **Abort the release, and sort it out first.**


### Publish

#### To NPM

```bash
$ npm publish
```

#### On GitHub

```bash
git push --follow-tags --all
```

  * Go to [https://github.com/marviq/coffee-jshint/releases](https://github.com/marviq/coffee-jshint/releases);
  * Click the `Draft a new release` button;
  * Select the appropriate `v<version>` tag from the dropdown menu;

  * You could enter a title and some release notes here; at the very least include a link to the corresponding section in the [CHANGELOG](./CHANGELOG.md) as:
    ```markdown
    [Change log](CHANGELOG.md# ... )
    ```
  * Click the `Publish release` button;


## ChangeLog

See [CHANGELOG](./CHANGELOG.md).


## License

[BSD-3-Clause](LICENSE)
