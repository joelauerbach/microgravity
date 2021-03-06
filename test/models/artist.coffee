sinon = require 'sinon'
Backbone = require 'backbone'
Artist = require '../../models/artist'
{ fabricate } = require 'antigravity'

describe 'Artist', ->

  beforeEach ->
    sinon.stub Backbone, 'sync'
    @artist = new Artist fabricate 'artist'

  afterEach ->
    Backbone.sync.restore()

  describe '#imageUrl', ->

    it 'returns the replaced image url', ->
      @artist.set image_url: 'foo/bar/:version.jpg'
      @artist.imageUrl().should.equal 'foo/bar/medium.jpg'

  describe '#fetchArtworks', ->

    it 'fetches the artists artworks', (done) ->
      @artist.fetchArtworks success: (artworks) ->
        artworks.first().get('title').should.equal 'Arrghwork'
        done()
      Backbone.sync.args[0][2].success [fabricate 'artwork', title: 'Arrghwork']
      Backbone.sync.args[0][1].url.should.match /// /api/v1/artist/.*/artworks ///

  describe '#fetchRelatedArtists', ->

    it 'fetches the related artists', (done) ->
      @artist.fetchRelatedArtists success: (artists) ->
        artists.first().get('name').should.equal "Andy Bazqux"
        done()
      Backbone.sync.args[0][2].success [fabricate 'artist', name: 'Andy Bazqux']
      Backbone.sync.args[0][1].url.should.containEql 'layer/main/artists'

  describe '#defaultImageUrl', ->

    it 'defaults to tall if the image version exists', ->
      @artist.set image_url: 'cat/bitty/:version.jpg'
      @artist.set image_versions: [ 'tall', 'other' ]
      @artist.defaultImageUrl().should.equal 'cat/bitty/tall.jpg'

    it 'falls back to four_thirds (partner artist) if tall version not present', ->
      @artist.set image_url: 'cat/bitty/:version.jpg'
      @artist.set image_versions: [ 'four_thirds', 'other' ]
      @artist.defaultImageUrl().should.equal 'cat/bitty/four_thirds.jpg'
