# ## Import libraries
noflo = require 'noflo'

# ## Helper functions
#
# Not NoFlo or even component-logic-specific, so nice to keep them separate

# Return all RegExp matches on a string
matchAll = (string, regexp) ->
  matches = []
  string.replace regexp, ->
    arr = [].slice.call arguments, 0
    extras = arr.splice -2
    arr.index = extras[0]
    arr.input = extras[1]
    matches.push arr
    return
  if matches.length then matches else []

# Extract the actual data of the match result
actualMatches = (matches) ->
  # because we want to send out an empty array if there are no matches
  return [[]] if matches.length is 0
  matches.map (match) -> match[0]

# ## Component declaration
exports.getComponent = ->
  c = new noflo.Component
    description: 'Find all of the instances of `word` in `content` and send them out in a stream'
    inPorts:
      content:
        datatype: 'string'
        description: 'the content which we look for a word in'
        required: true
      word:
        datatype: 'string' # could be array|string, which would be `all`
        description: 'the word we are looking for instances of'
        control: true
        required: true
      surrounding: # could use a regex but this is a specific case
        datatype: 'boolean'
        description: 'whether to get surrounding characters, symbols before and after until space'
        default: false # if nothing is sent to it, this is the default when `get`ting from it
        control: true
    outPorts:
      matches:
        datatype: 'string'
        description: 'the resulting findings as a stream of data packets'
        required: true

  # ## Processing function
  #
  # To preserve streams, forward brackets from the primary inport `content` to the output.
  c.forwardBrackets =
    content: 'matches'
  c.process (input, output) ->

    # ### Receiving input data
    #
    # We need both a `word`, and `content` to start processing
    # Since `word` is a control port, the latest value is kept, no need to continiously send
    return unless input.hasData 'word', 'content'
    [ word, content ] = input.getData 'word', 'content'

    # ### Component business logic
    #
    # since we are sending out multiple `data` IPs
    # we want to wrap them in brackets
    # TODO: make exception safe
    output.send matches: new noflo.IP 'openBracket', content

    # do our word processing
    r = /([.?!]*eh[.?!]*)/gi
    matches = matchAll content, r
    matches = actualMatches matches

    # ### Sending output
    #
    # for each of our matches, send them out
    for match in matches
      # if you just send content, it will automatically put it in a data ip
      # so this is the same as `output.send matches: new noflo.IP 'data', match`
      output.send matches: match

    # this is the same as doing `output.send` and then `output.done`
    output.sendDone matches: new noflo.IP 'closeBracket', content
