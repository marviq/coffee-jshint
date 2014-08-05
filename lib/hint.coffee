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
  'multistr'
]
errorsToSkip = [
  "Did you mean to return a conditional instead of an assignment?"
  "Confusing use of '!'."
  "Wrap the /regexp/ literal in parens to disambiguate the slash operator."
  "Creating global 'for' variable. Should be 'for (var"
  "Missing '()' invoking a constructor." # covered by coffeelint rule non_empty_constructor_needs_parens
]

# If log is true, prints out results after processing each file
hintFiles = (paths, config, log) ->
  if config.jshintrc
    data = fs.readFileSync(config.jshintrc, {encoding: "utf8"})
    jsonData = JSON.parse(removeComments(data))

    if jsonData.globals
      globals = jsonData.globals
      delete jsonData.globals;

    options = jsonData
  else
    globals = splitArgs config.globals
    splittedOptions = splitArgs config.options
    options = buildTrueObj(
      if (not config['default-options-off'])
      then _.union splittedOptions, defaultOptions
      else splittedOptions)

  _.map paths, (path) ->
    try
      source = fs.readFileSync(path)
    catch err
      if config.verbose then console.log "Error reading #{path}"
      return []
    errors = hint source, options, buildTrueObj globals
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
      # Last jshint.errors item could be null if it bailed because too many errors
      .compact()
      # Convert errors to use coffee source locations instead of js locations
      .map (error) ->
        try [line, col] = sourceMap.sourceLocation [error.line - 1, error.character - 1]
        _.extend error,
          line: if line? then line + 1 else '?'
          character: if col? then col + 1 else '?'
      # Get rid of errors that don't apply to coffee very well
      .filter (error) ->
        not _.any errorsToSkip, (to_skip) -> error.reason.indexOf(to_skip) >= 0
      .value()

formatErrors = (path, errors) ->
  "#{path}\n" +
  _(errors)
    .map (error) ->
      "#{error.line}:#{error.character}: #{error.reason}"
    .join('\n')

buildTrueObj = (keys) ->
  _.object keys, (true for i in [0..keys.length])

removeComments = (str = "") ->
  str = str.replace(/\/\*(?:(?!\*\/)[\s\S])*\*\//g, "");
  str = str.replace(/\/\/[^\n\r]*/g, ""); # Everything after '//'
  return str;

splitArgs = (strList) -> strList?.split(',') ? []

module.exports = hintFiles
