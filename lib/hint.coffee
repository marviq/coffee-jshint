fs = require 'fs'
CoffeeScript = require 'coffee-script'
_ = require 'underscore'
jshint = require('jshint').JSHINT

#console.log jshint.data() # full report

options = [
  'node'
  'undef'
  #'unused'
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
optionsObj = {}
optionsObj[opt] = true for opt in options

hintFiles = (coffeePaths, log) ->
  noErrors = true
  _.each coffeePaths, (path) ->
    errors = hintOneFile path
    if errors?
      console.log formatErrors path, errors if log
      noErrors = false
  if log
    if noErrors
      console.log "No JSHint errors found!"
    else
      console.log "--------------------------------"
  noErrors

hintOneFile = (coffeePath) ->
  coffeeSource = fs.readFileSync coffeePath
  csOptions = sourceMap: true, filename: coffeePath
  {js, v3SourceMap, sourceMap} = CoffeeScript.compile coffeeSource.toString(), csOptions
  unless jshint js, optionsObj
    errors = _.chain(jshint.errors)
      # Convert errors to use coffee source locations instead of js locations
      .map((error) ->
        [line, col] = sourceMap.sourceLocation [error.line, error.character]
        _.extend error, line: line + 1, character: col + 1
      )
      # Get rid of errors that don't apply to coffee very well
      .filter((error) -> error.reason not in errorsToSkip)
      .value()
    errors if errors.length > 0

formatErrors = (path, errors) ->
  "--------------------------------\n" +
  "#{path}\n" +
  _(errors)
    .map (error) ->
      "#{error.line}:#{error.character}: #{error.reason}"
    .join('\n')

module.exports = hintFiles
