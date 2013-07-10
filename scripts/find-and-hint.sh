DIR=`dirname $0`
if [ $# -eq 0 ]; then
  TO_SEARCH=.
else
  TO_SEARCH=$1
fi
find $TO_SEARCH -type f -path "*.coffee" ! -path "*node_modules*" \
  | xargs "$DIR/cli.js" --
