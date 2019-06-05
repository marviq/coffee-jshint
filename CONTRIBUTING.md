# Contributing to `coffee-jshint`

## Prerequisites

  * [npm and node](https://nodejs.org/en/download/)
  * [git flow](https://github.com/nvie/gitflow/wiki/Installation)
  * [jq](https://stedolan.github.io/jq/download/)
  * Some form of [make](https://en.wikipedia.org/wiki/Make_%28software%29)


## Setup

Clone this repository somewhere, switch to it, then:

```bash
git config commit.template ./.gitmessage
git checkout master
git checkout develop
git flow init -d
( cd ./.git/hooks && ln -s ../../.git-hooks/git-hook-on-npm-lockfile-change.sh post-checkout )
( cd ./.git/hooks && ln -s ../../.git-hooks/git-hook-on-npm-lockfile-change.sh post-merge )
npm run refresh
```

This will:

  * Set up [a helpful reminder](.gitmessage) of how to make [a good commit message](#commit-message-format-discipline).  If you adhere to this, then a
    detailed, meaningful [CHANGELOG](./CHANGELOG.md) can be constructed automatically;
  * Ensure you have local `master` and `develop` branches tracking their respective remote counterparts;
  * Set up the git flow [branching model](#branching-model) with default branch names;
  * Set up two [git hooks](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks) to ensure that your `node_modules` will be synced with the
    [`package-lock.json`](https://docs.npmjs.com/files/package-lock.json) dependency tree definition whenever a `git merge` or -`checkout` causes it to
    change;
  * Install all required dependencies, pruned and deduplicated;


## Build

```bash
make
```


## Commit

### Branching Model

This project uses [`git flow`](https://github.com/nvie/gitflow#readme).  Here's a quick [cheat sheet](http://danielkummer.github.io/git-flow-cheatsheet/).


### Commit Message Format Discipline

This project uses [`conventional-changelog/standard-version`](https://github.com/conventional-changelog/standard-version) for automatic versioning and
[CHANGELOG](./CHANGELOG.md) management.

To make this work, _please_ ensure that your commit messages adhere to the
[Commit Message Format](https://github.com/bcoe/conventional-changelog-standard/blob/master/convention.md#commit-message-format).  Setting your `git config`
to have the `commit.template` as referenced below will help you with [a detailed reminder](.gitmessage) of how to do this on every `git commit`.

```bash
git config commit.template ./.gitmessage
```


## Release / Hotfix

The steps layed out here are for the greater part oriented towards doing a regular release. To do a _hotfix_ release instead, just write `hotfix` wherever
(and _everywhere_) any of the steps below say `release`.

  * Ensure that you're up to scratch:

    ```bash
    git checkout master
    git pull
    git checkout develop
    git pull
    ```

  * Determine what your next [semver](https://docs.npmjs.com/getting-started/semantic-versioning#semver-for-publishers) _`<version>`_ should be:

      * For a regular release this should be based on the changes already in `develop` since the previous release or hotfix.
      * For a hotfix release this should be based on the changes you envision doing for this hotfix; but if you foresee it being anything other than a
        patch-level bump, you should probably reconsider wether this should _really_ be a hotfix.

    ```bash
    version="<version>"
    ```

  * Create and checkout a `release/v`_`<version>`_ branch off of `develop`:

    ```bash
    git flow release start "v${version}"
    ```

  * Push this branch upstream.

    ```bash
    git push --set-upstream origin "release/v${version}"
    ```

  * If this is a _hotfix_, now is a good time to first go and code the hotfix changes; If this is a regular release, just move on to the next step.

    As soon as the hotfix is ready and tested, it's time to move on the next step too.

  * Let the usual acceptance process take its course. If any changes are needed, code them in, test, rinse & repeat the previous step until everything is
    indeed _accepted_.

  * Bump the package's `.version`, update the [CHANGELOG](./CHANGELOG.md), commit these, and tag the commit as `v`_`<version>`_:

    ```bash
    npm run release
    ```

    or

    ```bash
    npm run hotfix
    ```

  * If all is well, this new `.version` **should** be identical to your intended _`<version>`_:

    ```bash
    jq ".version == \"${version}\"" package.json
    ```

    _If this is not the case_, then either your assumptions about what changed are wrong, or (at least) one of your commits did not adhere to the
    [Commit Message Format Discipline](#commit-message-format-discipline); **Abort the release, and sort it out first.**

  * Ensure the `npm run release` commit and tag are pushed upstream too:

    ```bash
    git push --follow-tags
    ```

    This will also ensure that the `git flow release finish ...` below will be able to delete the release branch without error.

  * Merge `release/v`_`<version>`_ back into both `develop` and `master`, checkout `develop` and delete `release/v`_`<version>`_:

    ```bash
    git flow release finish -n "v${version}"
    ```

    Note that contrary to vanilla `git flow`, the merge commit into `master` will _not_ have been tagged (that's what the
    [`-n`](https://github.com/nvie/gitflow/wiki/Command-Line-Arguments#git-flow-release-finish--fsumpkn-version) was for).  This is done because
    `npm run release` has already tagged its own commit.

    I believe that in practice, this won't make a difference for the use of `git flow`; and ensuring it's done the other way round instead would render the
    use of `conventional-changelog` impossible.

  * Delete `release/v`_`<version>`_ upstream too:

    ```bash
    git push origin --delete "release/v${version}"
    ```

  * Finally, ensure that all other affected branches are pushed upstream:

    ```bash
    git push origin master
    git push origin develop
    ```


## Publish

### To NPM

```bash
git checkout v<version>
npm publish
git checkout develop
```

### On GitHub

```bash
git push --follow-tags --all
```

  * Go to [https://github.com/marviq/coffee-jshint/releases](https://github.com/marviq/coffee-jshint/releases);
  * Click the `Draft a new release` button;
  * Select the appropriate `v`_`<version>`_ tag from the dropdown menu;
  * You could enter a title and some release notes here; at the very least include a link to the corresponding section in the [CHANGELOG](./CHANGELOG.md) as:
    ```markdown
    [Change log](CHANGELOG.md# ... )
    ```
  * Click the `Publish release` button;
