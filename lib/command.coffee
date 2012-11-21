#!/usr/bin/env node

taste = require './taste'
optimist = require('optimist')
argv = optimist
  .usage('♬♬♩♩♬♩ taste - play a random loved track of a friend ♬♩♬♩♩♬\nUsage: $0 [arg]')
  .alias('u', 'user')
  .describe('u', 'use friend')
  .argv

if (optimist.argv.h) or (optimist.argv.help)
  optimist.showHelp()
  process.exit 0

exports.run = ->
  taste.setup ->
    taste.random() unless argv.u
    taste.run(argv.u) if argv.u

# vim:ft=coffee ts=2 sw=2 et :
