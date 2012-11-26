# restify = require 'restify'
class Response

  constructor: (res, body) ->
    @code = res.statusCode
    @message = "Noice"
    @data = body

  # error:   ->
  #   console.log 'ERR'
  #   @code = res.statusCode
  #   @message = body

  # success: ->
  #   console.log 'success'
  #   @code = res.statusCode
  #   @message = body

module.exports = exports = Response    