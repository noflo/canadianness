canadianness = require '../index.js'
chai = require 'chai'

describe 'Javascript API', ->

  describe 'calling with sad content', ->
    content = 'life is hard and then you die, ...eh'
    it 'should return emotion=sadness', (done) ->
      canadianness content, {}, (err, result) ->
        chai.expect(err).to.not.exist
        chai.expect(result).to.include.keys ['emotion', 'score']
        chai.expect(result.emotion).to.equal 'sadness'
        chai.expect(result.score).to.be.above 5
        return done()
