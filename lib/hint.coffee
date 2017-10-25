CoffeeScript    = require( 'coffeescript' )
csVersion       = require( 'coffeescript/package.json' ).version
fs              = require( 'fs' )
jshint          = require( 'jshint' ).JSHINT
semver          = require( 'semver' )
_               = require( 'underscore' )


##  Adapted from https://github.com/jshint/jshint/blob/1553e3af6d2453eb52507a2c97971094897794d3/src/jshint.js#L158
##
supplantRe      = /\{([^{}]*)\}/g
supplant        = ( str, args ) ->

    return str.replace( supplantRe, ( matched, argName ) ->

        argValue = args[ argName ]

        return switch ( typeof argValue )
            when 'number', 'string'
                argValue
            else
                matched
    )


defaultOptions  = [

    ##  http://jshint.com/docs/options/#enforcing-options
    ##
    'undef'     ##  http://jshint.com/docs/options/#undef

    ##  Options to relax for cs.
    ##
    ##  http://jshint.com/docs/options/#relaxing-options
    ##
    'eqnull'    ##  http://jshint.com/docs/options/#eqnull
    'expr'      ##  http://jshint.com/docs/options/#expr
    'loopfunc'  ##  http://jshint.com/docs/options/#loopfunc
    'multistr'  ##  http://jshint.com/docs/options/#multistr
    'shadow'    ##  http://jshint.com/docs/options/#shadow
    'sub'       ##  http://jshint.com/docs/options/#sub
]


##  Warnings / errors for which no relaxing options exist will be filtered away.
##
errorsToSkip                = {}
errorsToSkip[ error.code ]  = error for error in [

    ##  > Confusing use of '{a}'.
    ##
    code:           'W018'
    args:           a: '!'

,
    ##  > Unnecessary semicolon.
    ##
    code:           'W032'

,
    ##  > Bad number '{a}'.
    ##
    code:           'W045'
    args:           a: '2e308'

,
    ##  > Missing '()' invoking a constructor.
    ##
    ##  Note: covered by coffeelint rule non_empty_constructor_needs_parens
    ##
    code:           'W058'

,
    ##  > Creating global 'for' variable. Should be 'for (var {a} ...'.
    ##
    code:           'W088'
    args:            undefined     ##  because it don't matter what `{a}` is.

,
    ##  > Wrap the /regexp/ literal in parens to disambiguate the slash operator.
    ##
    ##  Note: removed from jshint as of version `2.4.1`.
    ##
    code:           'W092'

,
    ##  > Did you mean to return a conditional instead of an assignment?
    ##
    code:           'W093'

,
]


##  If log is true, prints out results after processing each file.
##
hintFiles = ( paths, config, log ) ->

    options = buildTrueObj(

        if config.withDefaults

            _.union( config.options, defaultOptions )

        else

            config.options
    )


    ##  Ensure a matching `esversion` is set, depending on whether this is `coffeescript@<2`.
    ##
    options.esversion = if semver.satisfies( csVersion, '<2' ) then 5 else 6


    return _.map( paths, ( path ) ->

        try

            source  = fs.readFileSync( path )

        catch err

            console.log( "Error reading #{path}" ) if config.verbose
            return []


        errors  = hint( source, options, buildTrueObj( config.globals ))

        if ( log and errors.length > 0 )

            console.log( '--------------------------------' )
            console.log( formatErrors( path, errors ))


        return errors
    )


hint = ( coffeeSource, options, globals ) ->

    csOptions =
        sourceMap:  true
        filename:   'doesn\'t matter'

    { js, v3SourceMap, sourceMap } = CoffeeScript.compile( coffeeSource.toString(), csOptions )

    return (

        if ( jshint( js, options, globals ) )

            []

        else if ( not jshint.errors? )

            console.log( 'jshint didn\'t pass but returned no errors' )
            []

        else

            ##  Last jshint.errors item could be null if it bailed because too many errors
            ##
            _.compact( jshint.errors )

                ##  Get rid of errors that don't apply to coffee very well
                ##
                .filter( ( error ) ->

                    skip = errorsToSkip[ error.code ]

                    return not( skip ) or ( skip.args and ( supplant( error.raw, skip.args ) isnt error.reason ))
                )

                ##  Convert errors to use coffee source locations instead of js locations
                ##
                .map( ( error ) ->

                    try [ line, col ] = sourceMap.sourceLocation( [ error.line - 1, error.character - 1 ] )

                    return _.extend(

                        error
                    ,
                        line:       if line? then line + 1 else '?'
                        character:  if col?  then col  + 1 else '?'
                    )
                )
    )


formatErrors = ( path, errors ) ->

    return (

        "#{path}\n" +
        errors
            .map( ( error ) -> "#{error.line}:#{error.character}: #{error.reason}" )
            .join( '\n' )
    )


buildTrueObj    = ( keys ) ->

    return _.object( keys, ( true for i in [ 0..keys.length ] ))


module.exports  = hintFiles
