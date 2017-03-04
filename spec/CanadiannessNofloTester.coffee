Tester = require 'noflo-wrapper'
chai = require 'chai'

describe 'FindWords component', ->
  t = new Tester 'canadianness/FindWords', cache: false
  before (done) ->
    t.start (err, instance) ->
      return throw err if err
      done()

  describe 'with content eh', ->
    it 'should be find one `eh`', (done) ->
      # will only listen once and trigger after disconnect
      t.receive 'matches', (data) ->
        chai.expect(data).to.eql 'eh'
        done()

      t.ins.word.send 'eh'
      t.ins.surrounding.send false
      t.ins.content.send 'eh'

  describe 'with content that has no `eh`s', ->
    it 'should send an empty array', (done) ->
      t.receive 'matches', (data) ->
        chai.expect(data).to.eql []
        done()
      t.ins.word.send 'eh'
      t.ins.surrounding.send false
      t.ins.content.send 'A string without it is a sad string.'

  describe 'with content that has multiple `eh`s', ->
    it 'should send an array of ehs', (done) ->
      expect = ['Eh...', 'eh?', 'EH!']
      t.outs.matches.on 'ip', (ip) ->
        if ip.type is 'data'
          chai.expect(ip.data).to.eql expect.shift()
        if ip.type is 'closeBracket'
          done()

      t.ins.word.send 'eh'
      t.ins.surrounding.send true
      t.ins.content.send 'Eh... eh? EH!'
