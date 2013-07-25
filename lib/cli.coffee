_ = require "underscore"
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

splitArgs = (strList) -> strList?.split(',') ? []

# Filter out non-coffee paths
{coffee, other} = _(argv._).groupBy (path) ->
  if /.+\.coffee$/.test path then "coffee" else "other"
if other?.length > 0
  console.log "Skipping files that don't end in .coffee:\n" + other.join('\n')

errors = hintFiles(coffee,
  options: splitArgs argv.options
  withDefaults: (not argv['default-options-off'])
  globals: splitArgs argv.globals
, true)
if _.flatten(errors).length is 0
  process.exit 0
else
  process.exit 1
