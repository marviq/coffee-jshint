hint = require './lib/hint'

coffeePaths = process.argv[2..]
if hint coffeePaths, true
  process.exit 0
else
  process.exit 1

