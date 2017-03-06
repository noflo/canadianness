noflo = require 'noflo'

unless noflo.isBrowser()
  baseDir = __dirname
else
  baseDir = '/canadianness'

defaultSpellingData = require './spellingdata.json'
defaultWords = {"eh": 11, "eh!": 11}

canadianness = (contentData, options, callback) ->
  spellingData = options.spelling or defaultSpellingData
  wordsData = options.words or defaultWords
  # debugging [optional]
  debug = options.debug or false

  componentName = 'canadianness/Canadianness'
  inputs =
    words: wordsData
    spelling: spellingData
    content: contentData

  wrapperFunction = noflo.asCallback componentName
  wrapperFunction inputs, (err, results) ->
    return callback err, results

# Expose function as public API
module.exports = canadianness

# ## Command-line program
main = () ->
  content = process.argv[2]

  options =
    spelling: null
    words: null    
    debug: true    

  canadianness content, options, (err, results) ->
    if err
      console.error err
      process.exit 1
    console.log results.score, results.emotion

# Only run main if we are not imported as a module
if not module.parent
  main()
