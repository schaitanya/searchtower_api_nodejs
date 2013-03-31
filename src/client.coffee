https        =  require 'https'
queryString  =  require 'qs'
request      =  require 'request'
conf         =  require './config/config'
_            =  require 'underscore'
fs           =  require 'fs'

_.templateSettings = 
  interpolate : /\{\{(.+?)\}\}/g

class Response

  constructor: (res, body) ->
    @code = res.statusCode
    @data = body

module.exports = class Client

  ###
    Constructor
    parameters:
      apiId   required
      apiKey  required
  ###
  constructor: (host, apiId, apiKey) ->
    throw "Requires host, apiId and apiKey" unless apiId or apiKey or host
    @server = "https://#{apiId}:#{apiKey}@#{host}"

  ###
    route:
      method
      uri
    data:
      additional: params to add to URI
      body: request body
      qs: querystring
  ###
  request: (route, data, callback) ->
    data.body = _.omit data.body, '_name' if typeof data.body is 'object'
    opts = 
      url: @server + route.uri
      method:  route.method
      body: data.body || ''
      qs: data.qs || ''
      json: true
      strictSSL:  false
    request opts, (err, response, body) =>
      @_response err, response, body, (err, body) =>
        callback err, body

  ###
    getUserAccess
      Gets the list of users with any access on the index
  ###
  getUserAccess: (data, callback) ->
    throw "requires index name" unless data.index?
    route = conf.get('routes:getUserAceess')
    route.uri = _.template route.uri, { index: data.index }
    @request route, data, (err, body) ->
      callback err, body

  ###
    updateUserAccess
      Updates user access on index
  ###
  updateUserAccess: (data, callback) ->
    throw "requires index name" unless data.index?
    route = conf.get('routes:updateUserAccess')
    route.uri = _.template route.uri, { index: data.index }
    @request route, data, (err, body) ->
      callback err, body

  ###
    deleteUserAccess
      Deletes an user`s access on index
  ###
  deleteUserAccess: (data, callback) ->
    throw "requires index name" unless data.index?
    route = conf.get('routes:deleteUserAccess')
    route.uri = _.template route.uri, { index: data.index }
    @request route, data, (err, body) ->
      callback err, body

  ###
    createIndex:
      Create a new Index
  ###
  createIndex: (data, callback) ->
    throw "required fields missing" unless data.body.name?
    route = conf.get('routes:createIndex')
    @request route, data, (err, body) ->
      callback err, body

  ###
    updateIndex:
      Update an Index
  ###
  updateIndex: (data, callback) ->
    throw "requires index name" unless data.index?
    route = conf.get('routes:updateIndex')
    route.uri = _.template route.uri, { index: data.index }
    @request route, data, (err, body) ->
      callback err, body

  ###
    listIndexes
      List all indexes
  ###
  listIndexes: (data, callback) ->
    @request conf.get('routes:listIndex'), {}, (err, body) ->
      callback err, body

  ###
    Get Index
    data:
      name: Required
  ###
  getIndex: (data, callback) ->
    throw "requires index name" unless data.index?
    route = conf.get 'routes:getIndex'
    route.uri = _.template route.uri, { index: data.name }
    @request route, data, (err, body) ->
      callback err, body

  ###
    delete:
      deletes your mom
  ###
  deleteIndex: (data, callback) ->
    throw "requires index name" unless data.index?
    route = conf.get('routes:deleteIndex')
    route.uri  = _.template route.uri, { index: data.name }
    @request route, data, (err, body) ->
      callback err, body

  ###
    addDocument:
      upload a doc
  ###
  addDocument:  (data, callback) ->
    throw "required index and document name" unless data.index? and data.name?
    route = conf.get('routes:addDocument')
    route.uri  = _.template route.uri, { index: data.index, name: encodeURIComponent(data.name) }
    route.url = @server + route.uri
    route.strictSSL =  false

    fs.stat data.body, (error, stat) =>
      return callback error, null if error
      opts = 
        url:  @server + route.uri
        method: 'PUT'
        strictSSL:  false
        headers:
          'Content-Length': stat.size

      fs.createReadStream(data.body).pipe request opts, (err, response, body) =>
        @_response err, response, body, (err, body) =>
          callback err, body


  ###
    listAction -> List all Documents
    params:
      index (required)
  ###
  listDocuments: (data, callback) ->
    throw "required index name" unless  data.index?
    route = conf.get('routes:listDocuments')
    route.uri  = _.template route.uri, {  index: data.index }
    @request  route, data, (err, body) ->
      callback  err,  body

  ###
    checkDocument
  ###
  checkDocument: (data, callback) ->
    throw "requires both index and document name" unless data.index? and data.name?
    route = conf.get('routes:downloadDocument')
    route.uri = _.template route.uri, { index: data.index, name: encodeURIComponent(data.name) }
    route.url = @server + route.uri
    route.method = "HEAD"
    route.strictSSL =  false

    request route, (error, response, body) ->
      return callback true, null if error or response.statusCode isnt 200
      return callback null, null, response.headers

  ###
    downloadDocument
  ###
  downloadDocument: (writeStream, data, callback) ->
    throw "requires both index and document name" unless data.index? and data.name?
    route = conf.get('routes:downloadDocument')
    route.uri = _.template route.uri, { index: data.index, name: encodeURIComponent(data.name) }
    route.url = @server + route.uri
    route.strictSSL =  false
    req = request route
    req.pipe writeStream

    req.on 'error', (error) ->
      callback error, null

    req.on 'end', ->
      callback null, null

  ###
    deleteDocument
  ###
  deleteDocument: (data, callback)  ->
    throw "required index and document name" unless data.index? and data.name?
    route = conf.get('routes:deleteDocument')
    route.uri = _.template route.uri, { index: data.index, name: encodeURIComponent(data.name) }
    @request route, data, (err, body) ->
      callback err, body

  ###
    restoreDocument
  ###
  restoreDocument: (data, callback) ->
    throw "requires index and document names" unless data.index? and data.name?
    route = conf.get('routes:restoreDocument')
    route.uri = _.template route.uri, { index: data.index, name: data.name }
    @request route, data, (err, body) ->
      callback err, body

  ###
    documentDetails
  ###
  documentDetails:  (data, callback) ->
    throw "required index and document name" unless data.index? and data.name?
    route = conf.get 'routes:documentDetails'
    route.uri  = _.template route.uri, { index: data.index, name: encodeURIComponent(data.name) }
    @request route, data, (err, body) ->
      callback err, body

  ###
    Search Action
    data : 
      name Required
      qs/body : Either one not both
    callback: callback fn
  ###
  search: (data, callback) ->
    throw "required fields missing" unless data.index? and (data.qs? or data.body?)
    route = conf.get('routes:search')
    route.uri = _.template route.uri, { index: data.index }
    route.method = if data.qs then 'GET' else 'POST'
    @request route, data, (err, body) ->
      callback err, body

  ###
    Create Folder
    required:
      content-type: searchtower/folder
      content-size: 0
  ###
  createFolder: (data, callback) ->
    throw "required index and document name" unless data.index? and data.name?
    route = conf.get('routes:addDocument')
    route.uri = _.template route.uri, { index: data.index, name: encodeURIComponent(data.name + '/') }
    opts =
      strictSSL:  false
      url:  @server + route.uri
      method: 'PUT'
      headers:
        'content-type': 'searchtower/folder'
        'content-size': 0
    request opts, (err, response, body) =>
      @_response err, response, body, (err, body) =>
        callback err, body

  ###
    Add Url to "remote" index
  ###
  addRemoteFile:  (data, callback) ->
    throw "required index and url" unless data.index? and data.url?
    route = conf.get('routes:addDocument')
    route.uri = _.template(route.uri, { index: data.index, name: encodeURIComponent(data.url) }) + "?url=#{encodeURIComponent data.url}"
    route.method = "PUT"
    @request route, data, (err, cb) ->
      callback err, cb    

  _response: (err, response, body, callback) ->
    return callback err, null if err
    resp = new Response(response, body)
    return callback resp, null if response.statusCode isnt 200
    return callback null, resp if response.statusCode is 200