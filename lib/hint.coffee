fs = require 'fs'
CoffeeScript = require 'coffee-script'
_ = require 'underscore'
jshint = require('jshint').JSHINT

defaultOptions = [
  'undef'
  # options to relax for cs
  'eqnull'
  'expr'
  'shadow'
  'sub'
]
errorsToSkip = [
  "Did you mean to return a conditional instead of an assignment?"
  "Confusing use of '!'."
]

# If log is true, prints out results after processing each file
hintFiles = (paths, config, log) ->
  options = buildTrueObj(
    if config.withDefaults then _.union config.options, defaultOptions else options)
  _.map paths, (path) ->
    errors = hint fs.readFileSync(path), options, buildTrueObj config.globals
    if log and errors.length > 0
      console.log "--------------------------------"
      console.log formatErrors path, errors
    errors

hint = (coffeeSource, options, globals) ->
  csOptions = sourceMap: true, filename: "doesn't matter"
  {js, v3SourceMap, sourceMap} = CoffeeScript.compile coffeeSource.toString(), csOptions
  if jshint js, options, globals
    []
  else if not jshint.errors?
    console.log "jshint didn't pass but returned no errors"
    []
  else
    _.chain(jshint.errors)
      # Convert errors to use coffee source locations instead of js locations
      .map((error) ->
        [line, col] = sourceMap.sourceLocation [error.line - 1, error.character - 1]
        _.extend error, line: line + 1, character: col + 1
      )
      # Get rid of errors that don't apply to coffee very well
      .filter((error) -> error.reason not in errorsToSkip)
      .value()

formatErrors = (path, errors) ->
  "#{path}\n" +
  _(errors)
    .map (error) ->
      "#{error.line}:#{error.character}: #{error.reason}"
    .join('\n')

buildTrueObj = (keys) ->
  _.object keys, (true for i in [0..keys.length])

module.exports = hintFiles
