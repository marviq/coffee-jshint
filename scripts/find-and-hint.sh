DIR=`dirname $0`
find $1 -type f -path "*.coffee" ! -path "*node_modules*" \
  | xargs "$DIR/../cli.js" "${@:2}"
