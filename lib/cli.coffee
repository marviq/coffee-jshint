commander       = require( 'commander' )
_               = require( 'underscore' )
hintFiles       = require( './lib-js/hint' )

commander
    .storeOptionsAsProperties( false )
    .option(

        '-o, --options <option>[,...]'
        'comma separated list of JSHint options to turn on'
    )
    .option(

        '--default-options-off'
        'turns off default options'
    )
    .option(

        '-g, --globals <global>[,...]'
        'comma separated list of global variable names to permit'
    )
    .option(

        '-v, --verbose'
        'print more detailed output'
    )
    .version(

        require( './package.json' ).version
    )
    .arguments(

        '<filename.coffee...>'
    )
    .parse()


options     = commander.opts()

console.log( options )

splitArgs   = (strList) -> strList?.split(',') ? []


##  Filter out non-coffee paths.
##
{ coffee, other } = _.groupBy( commander.args, ( path ) -> if /.+\.coffee$/.test( path ) then 'coffee' else 'other' )

if ( options.verbose and other?.length > 0 )

    console.log( "Skipping files that don't end in .coffee:\n#{ other.join('\n') }" )


errors =
    hintFiles(

        coffee
     ,
        options:        splitArgs( options.options )
        withDefaults:   not( options.defaultOptionsOff )
        globals:        splitArgs( options.globals )
        verbose:        !!( options.verbose )

    ,
        true
    )

if _.flatten( errors ).length is 0

    process.exit( 0 )

else

    process.exit( 1 )
