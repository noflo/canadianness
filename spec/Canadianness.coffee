noflo = require 'noflo'

# if you want to run your tests on the browser builds using phantom
unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'canadianness'

spellingData = require '../spellingdata.json'

# how we test the components first, then the graph as a whole
# because then we do not have to
# figure out where along the graph the problem is
describe 'Canadianness graph', ->
  listData = {"eh": 11, "eh!": 11}

  c = null
  content = null
  spelling = null
  words = null
  emotion = null
  score = null

  # we are using this because we are waiting for both port event listeners
  # to receive data
  emotionData = null
  scoreData = null
  doDone = (done) ->
    # if both are set, it is done, so reset test state
    if scoreData? and emotionData?
      scoreData = null
      emotionData = null
      done()

  # we only need to load the graph once, so it is in the before
  before (done) ->
    @timeout 10*1000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'canadianness/Canadianness', (err, instance) ->
      return done err if err

      # but we need to access the instance elsewhere,
      # so it is assigned to the scoped variable
      c = instance

      # because it is a graph, we want to wait until it is ready
      c.once 'ready', ->
        c.start () ->
          # for asyncish
          setTimeout done, 1

  # before each test we want to attach all of the outports
  # (we also attach the inports here as well so the `before` is simpler)
  # and we want to detach the outports after each,
  # otherwise the event listeners in the test that ran before
  # would get triggered again
  beforeEach ->
    content = noflo.internalSocket.createSocket()
    spelling = noflo.internalSocket.createSocket()
    words = noflo.internalSocket.createSocket()
    c.inPorts.content.attach content
    c.inPorts.spelling.attach spelling
    c.inPorts.words.attach words

    emotion = noflo.internalSocket.createSocket()
    score = noflo.internalSocket.createSocket()
    c.outPorts.emotion.attach emotion
    c.outPorts.score.attach score
  afterEach ->
    c.outPorts.emotion.detach emotion
    c.outPorts.score.detach score

  describe 'content "A bunch of centers had a color cancelation."', ->
    it 'should be neutral, and uncanadian', (done) ->
      score.on 'data', (data) ->
        chai.expect(data).to.eql -3
        scoreData = data
        doDone done

      emotion.on 'data', (data) ->
        chai.expect(data).to.eql 'neutral'
        emotionData = data
        doDone done

      spelling.send spellingData
      words.send listData
      content.send 'A bunch of centers had a color cancelation.'

  describe 'content eh', ->
    it 'should be neutral, yet highly Canadian', (done) ->
      score.on 'data', (data) ->
        chai.expect(data).to.eql 11
        scoreData = data
        doDone done

      emotion.on 'data', (data) ->
        chai.expect(data).to.eql 'neutral'
        emotionData = data
        doDone done

      spelling.send spellingData
      words.send listData
      content.send 'eh'

  describe 'content "eh!"', ->
    it 'should be joyful, and canadian', (done) ->
      score.on 'data', (data) ->
        chai.expect(data).to.eql 11
        scoreData = data
        doDone done

      emotion.on 'data', (data) ->
        chai.expect(data).to.eql 'joy'
        emotionData = data
        doDone done

      spelling.send spellingData
      words.send listData
      content.send 'eh!'

describe 'WordScore component', ->
  listData = [{"Canadian":["calibre"],"British":["calibre"],"American":["caliber"],"Notes":""},{"Canadian":["caliper"],"British":["caliper"],"American":["caliper","calliper"],"Notes":""},{"Canadian":["cancellation"],"British":["cancellation"],"American":["cancelation"],"Notes":""},{"Canadian":["cancelled/cancelling"],"British":["cancelled/cancelling"],"American":["canceled/canceling"],"Notes":""},{"Canadian":["candour","candor"],"British":["candour"],"American":["candor"],"Notes":""},{"Canadian":["capitalize"],"British":["capitalise","capitalize"],"American":["capitalize"],"Notes":""},{"Canadian":["caramelize"],"British":["caramelise","caramelize"],"American":["caramelize"],"Notes":""},{"Canadian":["carburetor"],"British":["carburettor"],"American":["carburetor"],"Notes":""},{"Canadian":["catalogue"],"British":["catalogue"],"American":["catalog","catalogue"],"Notes":""},{"Canadian":["catalyze"],"British":["catalyse"],"American":["catalyze"],"Notes":""},{"Canadian":["categorization"],"British":["categorisation","categorization"],"American":["categorization"],"Notes":""},{"Canadian":["categorize"],"British":["categorise","categorize"],"American":["categorize"],"Notes":""},{"Canadian":["cauldron"],"British":["cauldron"],"American":["cauldron","caldron"],"Notes":""},{"Canadian":["cauterize"],"British":["cauterise","cauterize"],"American":["cauterize"],"Notes":""},{"Canadian":["centimetre"],"British":["centimetre"],"American":["centimeter"],"Notes":""},{"Canadian":["centre"],"British":["centre"],"American":["center"],"Notes":""},{"Canadian":["cesarean","caesarian"],"British":["caesarean"],"American":["cesarean","caesarean"],"Notes":""},{"Canadian":["cesium"],"British":["caesium"],"American":["cesium"],"Notes":""},{"Canadian":["characterize"],"British":["characterise","characterize"],"American":["characterize"],"Notes":""},{"Canadian":["checkered","chequered"],"British":["chequered"],"American":["checkered"],"Notes":""},{"Canadian":["cheque"],"British":["cheque"],"American":["check"],"Notes":"noun, meaning 'form of payment'; otherwise check"},{"Canadian":["chili"],"British":["chilli","chili"],"American":["chili","chile"],"Notes":""},{"Canadian":["cigarette"],"British":["cigarette"],"American":["cigarette","cigaret"],"Notes":""},{"Canadian":["cipher"],"British":["cipher","cypher"],"American":["cipher"],"Notes":""},{"Canadian":["civilization"],"British":["civilisation","civilization"],"American":["civilization"],"Notes":""},{"Canadian":["civilize"],"British":["civilise","civilize"],"American":["civilize"],"Notes":""},{"Canadian":["clamour","clamor"],"British":["clamour"],"American":["clamor"],"Notes":""},{"Canadian":["clangour","clangor"],"British":["clangour"],"American":["clangor"],"Notes":""},{"Canadian":["co-author","coauthor"],"British":["co-author"],"American":["coauthor"],"Notes":""},{"Canadian":["colonize"],"British":["colonise","colonize"],"American":["colonize"],"Notes":""},{"Canadian":["colour"],"British":["colour"],"American":["color"],"Notes":""},{"Canadian":["commercialize"],"British":["commercialise","commercialize"],"American":["commercialize"],"Notes":""},{"Canadian":["computerize"],"British":["computerise","computerize"],"American":["computerize"],"Notes":""},{"Canadian":["connection"],"British":["connection","connexion"],"American":["connection"],"Notes":""},{"Canadian":["conjuror","conjurer"],"British":["conjuror","conjurer"],"American":["conjuror","conjurer"],"Notes":"both spellings equally acceptable"},{"Canadian":["co-opt","coopt"],"British":["co-opt"],"American":["coopt"],"Notes":""},{"Canadian":["councillor","councilor"],"British":["councillor"],"American":["councilor"],"Notes":""},{"Canadian":["counselled/counselling"],"British":["counselled/counselling"],"American":["counseled/counseling"],"Notes":""},{"Canadian":["counsellor"],"British":["counsellor"],"American":["counselor"],"Notes":""},{"Canadian":["counter-attack"],"British":["counter-attack"],"American":["counterattack"],"Notes":""},{"Canadian":["cozy","cosy"],"British":["cosy"],"American":["cozy"],"Notes":""},{"Canadian":["criticize"],"British":["criticise"],"American":["criticize"],"Notes":""},{"Canadian":["crueller/cruellest"],"British":["crueller/cruellest"],"American":["crueler/cruelest"],"Notes":""},{"Canadian":["crystalline"],"British":["crystalline"],"American":["crystaline"],"Notes":""},{"Canadian":["crystallize"],"British":["crystallise","crystallize"],"American":["crystalize","crystallize"],"Notes":""},{"Canadian":["curb"],"British":["curb","kerb"],"American":["curb"],"Notes":"kerb only used for noun meaning 'edge of road' in UK; other meanings curb"},{"Canadian":["customize"],"British":["customise","customize"],"American":["customize"],"Notes":""},{"Canadian":[""],"British":[""],"American":[""],"Notes":""},{"Canadian":["abridgement","abridgment"],"British":["abridgement"],"American":["abridgment"],"Notes":""},{"Canadian":["acknowledgement","acknowledgment"],"British":["acknowledgement"],"American":["acknowledgment","acknowledgement"],"Notes":""},{"Canadian":["advertise"],"British":["advertise"],"American":["advertise","advertize"],"Notes":""},{"Canadian":["aegis","egis"],"British":["aegis"],"American":["egis"],"Notes":""},{"Canadian":["aeon","eon"],"British":["aeon"],"American":["eon"],"Notes":""},{"Canadian":["aesthetic","esthetic"],"British":["aesthetic"],"American":["esthetic","aesthetic"],"Notes":""},{"Canadian":["aging","ageing"],"British":["ageing","aging"],"American":["aging"],"Notes":""},{"Canadian":["airplane"],"British":["aeroplane"],"American":["airplane"],"Notes":""},{"Canadian":["aluminum"],"British":["aluminium"],"American":["aluminum"],"Notes":""},{"Canadian":["amid","amidst"],"British":["amid","amidst"],"American":["amid"],"Notes":""},{"Canadian":["amoeba"],"British":["amoeba"],"American":["ameba"],"Notes":""},{"Canadian":["among","amongst"],"British":["among","amongst"],"American":["among"],"Notes":""},{"Canadian":["amortization"],"British":["amortisation","amortization"],"American":["amortization"],"Notes":""},{"Canadian":["amortize"],"British":["amortise","amortize"],"American":["amortize"],"Notes":""},{"Canadian":["amphitheatre"],"British":["amphitheatre"],"American":["amphitheater"],"Notes":""},{"Canadian":["anaesthesia","anesthesia"],"British":["anaesthesia"],"American":["anesthesia"],"Notes":""},{"Canadian":["analogue","analog"],"British":["analogue"],"American":["analogue","analog"],"Notes":"analog when used as a technical term (i.e. not digital)"},{"Canadian":["analyze","analyse"],"British":["analyse"],"American":["analyze"],"Notes":""},{"Canadian":["anemia","anaemia"],"British":["anaemia"],"American":["anemia"],"Notes":""},{"Canadian":["anemic","anaemic"],"British":["anaemic"],"American":["anemic"],"Notes":""},{"Canadian":["annex"],"British":["annexe","annex"],"American":["annex"],"Notes":"noun meaning 'something added'; verb is always annex"},{"Canadian":["apologize"],"British":["apologise","apologize"],"American":["apologize"],"Notes":""},{"Canadian":["appal","appall"],"British":["appal"],"American":["appall"],"Notes":"appalled/appalling in all countries"},{"Canadian":["appetizer"],"British":["appetiser","appetizer"],"American":["appetizer"],"Notes":""},{"Canadian":["arbour","arbor"],"British":["arbour"],"American":["arbor"],"Notes":""},{"Canadian":["archaeology","archeology"],"British":["archaeology"],"American":["archeology","archaeology"],"Notes":""},{"Canadian":["ardour","ardor"],"British":["ardour"],"American":["ardor"],"Notes":""},{"Canadian":["artifact"],"British":["artefact"],"American":["artifact"],"Notes":""},{"Canadian":["armour","armor"],"British":["armour"],"American":["armor"],"Notes":""},{"Canadian":["authorize"],"British":["authorise","authorize"],"American":["authorize"],"Notes":""},{"Canadian":["axe"],"British":["axe"],"American":["ax"],"Notes":""},{"Canadian":[""],"British":[""],"American":[""],"Notes":""}]

  c = null
  content = null
  list = null
  score = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'canadianness/WordScore', (err, instance) ->
      return done err if err
      c = instance
      content = noflo.internalSocket.createSocket()
      list = noflo.internalSocket.createSocket()
      c.inPorts.content.attach content
      c.inPorts.list.attach list
      done()
  beforeEach ->
    score = noflo.internalSocket.createSocket()
    c.outPorts.score.attach score
  afterEach ->
    c.outPorts.score.detach score

  describe 'with content `ardour eh`', ->
    it 'should be Canadian', (done) ->
      score.on 'data', (data) ->
        chai.expect(data).to.eql 1
        done()

      list.send listData
      content.send 'ardour eh?'

  describe 'with content `ax`', ->
    it 'should be not Canadian', (done) ->
      score.on 'data', (data) ->
        chai.expect(data).to.eql -1
        done()

      list.send listData
      content.send 'ax'

describe 'FindWords component', ->
  c = null
  word = null
  surrounding = null
  content = null
  matches = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'canadianness/FindWords', (err, instance) ->
      return done err if err
      c = instance
      word = noflo.internalSocket.createSocket()
      content = noflo.internalSocket.createSocket()
      surrounding = noflo.internalSocket.createSocket()
      c.inPorts.word.attach word
      c.inPorts.content.attach content
      c.inPorts.surrounding.attach surrounding
      done()
  beforeEach ->
    matches = noflo.internalSocket.createSocket()
    c.outPorts.matches.attach matches
  afterEach ->
    c.outPorts.matches.detach matches

  describe 'with content eh', ->
    it 'should be find one `eh`', (done) ->
      matches.on 'data', (data) ->
        chai.expect(data).to.eql 'eh'
        done()

      word.send 'eh'
      surrounding.send false
      content.send 'eh'

  describe 'with content that has no `eh`s', ->
    it 'should send an empty array', (done) ->
      matches.on 'data', (data) ->
        chai.expect(data).to.eql []
        done()
      word.send 'eh'
      surrounding.send false
      content.send 'A string without it is a sad string.'

  describe 'with content that has multiple `eh`s', ->
    it 'should send an array of ehs', (done) ->
      expect = ['Eh...', 'eh?', 'EH!']
      matches.on 'ip', (ip) ->
        if ip.type is 'data'
          chai.expect(ip.data).to.eql expect.shift()
        if ip.type is 'closeBracket'
          done()

      word.send 'eh'
      surrounding.send true
      content.send 'Eh... eh? EH!'

describe 'DetermineEmotion component', ->
  c = null
  emotion = null
  content = null
  error = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'canadianness/DetermineEmotion', (err, instance) ->
      return done err if err
      c = instance
      content = noflo.internalSocket.createSocket()
      c.inPorts.content.attach content
      done()
  beforeEach ->
    emotion = noflo.internalSocket.createSocket()
    error = noflo.internalSocket.createSocket()
    c.outPorts.emotion.attach emotion
    c.outPorts.error.attach error
  afterEach ->
    c.outPorts.emotion.detach emotion
    c.outPorts.error.detach error

  describe 'with content eh', ->
    it 'should be neutral', (done) ->
      emotion.on 'data', (data) ->
        chai.expect(data).to.eql 'neutral'
        done()

      content.send new noflo.IP 'openBracket'
      content.send new noflo.IP 'data', 'eh'
      content.send new noflo.IP 'closeBracket'

  describe 'with content eh!', ->
    it 'should be joyful', (done) ->
      emotion.on 'data', (data) ->
        chai.expect(data).to.eql 'joy'
        done()

      content.send new noflo.IP 'openBracket'
      content.send new noflo.IP 'data', 'eh!'
      content.send new noflo.IP 'closeBracket'

  describe 'with content [eh?, eh!?, Eh?]', ->
    it 'should be amusement', (done) ->
      emotion.on 'data', (data) ->
        chai.expect(data).to.eql 'amusement'
        done()

      content.send new noflo.IP 'openBracket'
      content.send new noflo.IP 'data', 'eh?'
      content.send new noflo.IP 'data', 'eh!?'
      content.send new noflo.IP 'data', 'Eh?'
      content.send new noflo.IP 'closeBracket'
