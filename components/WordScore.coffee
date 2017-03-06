# ## Import libraries
noflo = require 'noflo'
natural = require 'natural'
tokenizer = new natural.WordTokenizer()

# ## Component declaration
exports.getComponent = ->
  c = new noflo.Component
    description: 'Find how the input words compare against the list of weighted words'
    inPorts:
      list:
        datatype: 'array'
        description: 'list of words we will use with the list of content'
        control: true
        required: true
      content:
        datatype: 'string'
        description: 'the content which we will determine the score of'
        required: true
    outPorts:
      score:
        datatype: 'number'
        description: 'the resulting number of comparing the content with the list'
        required: true

  # ## Processing function
  #
  # To preserve streams, forward brackets from the primary inport to the output.
  c.forwardBrackets = {}

  c.process (input, output) ->

    # ### Receive input
    return unless input.hasStream 'content'
    return unless input.hasData 'list'
    content = input.getStream('content').filter((ip) -> ip.type is 'data').map((ip) -> ip.data)
    list = input.getData 'list'

    # there can be multiple pieces of content
    content = content.join('\n')

    # ### Component business logic
    # our base score we will send out
    score = 0

    # splits content into an array of words
    tokens = tokenizer.tokenize content

    # if the list has the word in it, return the score
    # otherwise, 0 points
    wordScore = (word) ->
      if list[word]?
        return list[word]
      else
        return 0

    # go through each of the comparisons in the list
    # if it is Canadian: 1, American: -1, British: .5, None: 0
    spellingScore = (word) ->
      for comparison in list
        if word not in comparison["American"]
          if word in comparison["Canadian"]
            return 1
          else if word in comparison["British"]
            return 0.5
        else
          return -1

      return 0

    # if it has this, it is a spelling list
    if list[0]?["Canadian"]?
      scoringFunction = spellingScore
    # otherwise it is an object list of words with scores
    else
      scoringFunction = wordScore

    # use this to singularize and pluralize each word
    nounInflector = new natural.NounInflector()

    # go through each item in contents
    for data in tokens
      plural = nounInflector.pluralize data
      singular = nounInflector.singularize data

      # if it is already plural or singular do not use it
      if plural isnt data
        score += scoringFunction plural
      if singular isnt data
        score += scoringFunction singular

      score += scoringFunction data

    # ### Send output
    output.sendDone score: score
