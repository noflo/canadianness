noflo = require 'noflo'
trace = require('noflo-runtime-base').trace

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

  # FIXME: use asCallback from NoFlo 0.8.2+
  loader = new noflo.ComponentLoader baseDir
  # project name / graph or component name
  loader.load 'canadianness/Canadianness', (err, instance) ->
    throw err if err

    if debug
      # instantiate our Tracer
      tracer = new trace.Tracer()

    instance.once 'ready', ->
      if debug
        tracer.attach instance.network

      instance.start () ->

      # outPorts
      score = noflo.internalSocket.createSocket()
      emotion = noflo.internalSocket.createSocket()

      # inPorts
      spelling = noflo.internalSocket.createSocket()
      words = noflo.internalSocket.createSocket()
      content = noflo.internalSocket.createSocket()

      # attach them
      instance.inPorts.content.attach content
      instance.inPorts.spelling.attach spelling
      instance.inPorts.words.attach words
      instance.outPorts.score.attach score
      instance.outPorts.emotion.attach emotion

      # scoped variables since we don't know which data comes in first
      scoreData = null
      emotionData = null

      # when we listen for data, we can call this
      # to check if both have received data
      # when they have, call the callback
      # and then, if we are debugging, write the trace
      # and log where we wrote it to
      finished = ->
        return unless scoreData? and emotionData?
        data = 
          score: scoreData
          emotion: emotionData
        return callback null, data, scoreData

        if debug
          tracer.dumpFile null, (err, f) ->
            throw err if err
            console.log 'Wrote flowtrace to', f

      # listen for data
      score.on 'data', (data) ->
        scoreData = data
        finished()

      emotion.on 'data', (data) ->
        emotionData = data
        finished()

      # send the data
      words.send wordsData
      spelling.send spellingData
      content.send contentData

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
