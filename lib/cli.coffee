hintFiles = require("./lib-js/hint")
argv = require("optimist")
  .options(
    'options':
      alias: 'o'
      describe: 'comma separated list of JSHint options to turn on'
    'defaults-options-off':
      type: 'boolean'
      describe: 'turns off default options'
    'globals':
      alias: 'g'
      describe: 'comma separated list of global variable names to permit'
  ).argv

coffeePaths = argv._

splitArgs = (strList) -> strList?.split(',') ? []

errors = hintFiles(coffeePaths, 
  options: splitArgs argv.options
  withDefaults: (not argv['default-options-off'])
  globals: splitArgs argv.globals
, true)
if errors.length is 0
  process.exit 0
else
  process.exit 1
