#!/usr/bin/env node

sys     = require 'util'
path    = require 'path'
_       = require 'underscore'
fs      = require 'fs'
colors  = require 'colors'
emoji   = require('emoji')

spotify    = require 'spotify'
spotscript = require 'spotify-node-applescript'
LastFmNode = require('lastfm').LastFmNode

_.mixin arbitrary: (data) ->
  [_.first(_.shuffle(data))]

class Taste
  constructor: ->
  setup: (cb) ->
    @config (config) =>
      @config = config.config
      @lastfm = new LastFmNode
        api_key: @config.api
        secret: @config.secret
      cb()
  config: (cb) ->
    fs.readFile path.join(process.env.HOME, '.taste.yml'), (err, text) ->
      throw err if err
      cb require('yaml').eval(text.toString())
  querySpotify: (artist, title, cb) ->
    spotify.search
      type: 'track'
      query: "#{artist} #{title}", (err, data) ->
        console.log err if err
        cb(data)
  queryFriends: (cb) ->
    @lastfm.request "user.getFriends",
      user: @config.user
      handlers:
        success: cb
        error: (error) ->
          console.log "Error: " + error.message
  queryLoved: (friend, cb) ->
    @lastfm.request "user.getLovedTracks",
      user: friend
      handlers:
        success: cb
        error: (error) ->
          console.log "Error: " + error.message
  play: (uri) ->
    spotscript.playTrack uri, (data) ->
  random: ->
    @queryFriends (data) =>
      _.each _.arbitrary(data.friends.user), (friend) =>
        @run friend.name
  run: (friend) ->
    @queryLoved friend, (data) =>
      _.each _.arbitrary(data.lovedtracks.track), (track) =>
        @querySpotify track.artist.name, track.name, (data) =>
          _.each _.arbitrary(data.tracks), (spot) =>
            return unless spot?
            console.log "🎵  ", "#{_.first(spot.artists)?.name} - #{spot.name}".green.bold, "(🏃 #{friend})".red.bold
            @play spot.href

module.exports = new Taste

# vim:ft=coffee ts=2 sw=2 et :
