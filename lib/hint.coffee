CoffeeScript    = require( 'coffeescript' )
fs              = require( 'fs' )
jshint          = require( 'jshint' ).JSHINT
_               = require( 'underscore' )

defaultOptions  = [

    'undef'

    ##  options to relax for cs
    ##
    'eqnull'
    'expr'
    'shadow'
    'sub'
    'multistr'
]

errorsToSkip    = [
    'Did you mean to return a conditional instead of an assignment?'
    'Confusing use of \'!\'.'
    'Wrap the /regexp/ literal in parens to disambiguate the slash operator.'
    'Creating global \'for\' variable. Should be \'for (var'
    'Missing \'()\' invoking a constructor.'    ##  covered by coffeelint rule non_empty_constructor_needs_parens
    'Bad number \'2e308\'.'
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

                ##  Get rid of errors that don't apply to coffee very well
                ##
                .filter( ( error ) -> not _.any( errorsToSkip, ( to_skip ) -> error.reason.indexOf( to_skip ) >= 0 ) )
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
