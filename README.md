# Coffee->JSHint

Runs your CoffeeScript source through [JSHint](http://www.jshint.com/) to check for errors.

## Usage

To check some files:

    make
    ./cli.js file1.coffee file2.coffee ...

To recursively check all `.coffee` files in a directory (excluding those in any `node_modules` subdirs):

    ./scripts/find-and-hint.sh <dir to search>

To use as a git pre-commit hook to check all the files in a repo before you commit, put something like this in `.git/hooks/pre-commit`:

```bash
# Allows us to read user input below, assigns stdin to keyboard
# http://stackoverflow.com/questions/3417896/how-do-i-prompt-the-user-from-within-a-commit-msg-hook
exec < /dev/tty

# Run Coffee->JSHint
path/to/coffee-jshint/scripts/find-and-hint.sh .
if [ $? -ne 0 ]; then
  read -p "Would you like to ignore JSHint warnings and commit anyway? (y/n) " choice
  case "$choice" in
    [yY] ) exit 0;;
    [nN] ) exit 1;;
    * ) exit 1;;
  esac
fi
```
