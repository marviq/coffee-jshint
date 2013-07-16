hint = require("./lib-js/hint").hintFiles
argv = require("optimist")
  .options(
    'options':
      alias: 'o'
      describe: 'comma separated list of JSHint options to turn on'
    'defaults-options-off':
      type: 'boolean'
      describe: 'turns off default options'
  ).argv

coffeePaths = argv._
options = argv.options?.split(',') ? []

errors = hint coffeePaths, options, (not argv['default-options-off']), true
if errors.length is 0
  process.exit 0
else
  process.exit 1
