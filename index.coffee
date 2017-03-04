noflo = require 'noflo'
trace = require('noflo-runtime-base').trace

unless noflo.isBrowser()
  baseDir = __dirname
else
  baseDir = '/canadianness'

spellingData = require './spellingdata.json'
listData = {"eh": 11, "eh!": 11}

canadianness = (args, cb) ->
  spellingData = args['spelling']
  wordsData = args['words']
  # debugging [optional]
  debug = args['debug'] or false
  contentData = args['content']

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

      instance.start()

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
        cb emotionData, scoreData

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

canadianness {spelling: spellingData, words: listData, content: 'eh', debug: true}, (score, emotion) ->
  console.log score, emotion
