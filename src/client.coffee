https        =  require 'https'
queryString  =  require 'qs'
request      =  require 'request'
Response     =  require './response'
conf         =  require './config/config'
nconf        =  require 'nconf'
_            =  require 'underscore'
fs           =  require 'fs'

module.exports = class Client

  constructor: (appId, appKey) ->
    throw "Requires both appId and appKey" unless appId or appKey
    @server = "http://#{appId}:#{appKey}@" + conf.get('server:ip') + ":" + conf.get('server:port')

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
    request opts, (err, response, body) ->
      return callback err, null if err
      resp = new Response(response, body)
      return callback resp, null if response.statusCode isnt 200
      return callback null, resp if response.statusCode is 200

  ###
    Get Index
    data:
      name: Required
  ###
  getIndex: (data, callback) ->
    route = conf.get 'routes:getIndex'
    route.uri += data.name
    @request route, data, (err, cb) ->
      callback err, cb

  ###
    create:
      Create a new Index
  ###
  createIndex: (data, callback) ->
    throw "required fields missing" unless data.body.name
    route = conf.get('routes:createIndex')
    @request route, data, (err, cb) ->
      callback err, cb

  ###
    update:
      Update Index
  ###
  updateIndex: (data, callback) ->
    route = conf.get('routes:updateIndex')
    route.uri += data.name 
    @request route, data, (err, cb) ->
      callback err, cb

  ###
    delete:
      deletes your mom
  ###
  deleteIndex: (data, callback) ->
    route = conf.get('routes:deleteIndex')
    route.uri += data.name
    @request route, data, (err, cb) ->
      callback err, cb

  ###
    List Action -> List all indexes
  ###
  listIndexes: (data, callback) ->
    @request conf.get('routes:listIndex'), {}, (err, cb) ->
      callback err, cb

  ###
    addDocument:
      upload a doc
  ###
  addDocument:  (data, callback) ->
    throw "required index and document name" unless data.index || data.name
    route = conf.get('routes:addDocument')
    route.uri += "#{data.index}/" + encodeURIComponent "#{data.name}"
    fs.stat data.body, (error, stat) =>
      return callback error, null if error
      opts = 
        url:  @server + route.uri
        method: 'PUT'
        headers:
          'Content-Length': stat.size

      fs.createReadStream(data.body).pipe request opts, (err, resp, body) =>
        callback err, body


  ###
    listAction -> List all Documents
    params:
      index (required)
  ###
  listDocuments: (data, callback) ->
    throw "required index name" unless  data.index
    route = conf.get('routes:listDocuments')
    route.uri  +=  data.index
    @request  route, data, (err, cb) ->
      callback  err,  cb


  ###
    deleteDocument
  ###
  deleteDocument: (data, callback)  ->
    throw "required index and document name" unless data.index || data.name
    route = conf.get('routes:deleteDocument')
    route.uri += "#{data.index}/#{encodeURIComponent(data.name)}"
    opts = 
      url:  @server + route.uri
      method: route.method
      body: data.body
    request opts, (err, response, body) ->
      callback  err,  body

  ###
    documentDetails
  ###
  documentDetails:  (data, callback) ->
    throw "required index and document name" unless data.index || data.name
    route = conf.get 'routes:documentDetails'
    route.uri  += "#{data.index}/" + encodeURIComponent(data.name) + "?details"
    opts =
      url:  @server + route.uri
      method: route.method
      body: data.body
    request opts, (err, response, body) ->
      callback  err,  body

  ###
    Search Action
    data : 
      name Required
      qs/body : Either one not both
    callback: callback fn
  ###
  search: (data, callback) ->
    throw "required fields missing" unless data.name || data.qs || data.body
    throw "query and body detected, only one not both" if data.qs && data.body
    route = conf.get('routes:search')
    route.uri += data.index
    @request route, data, (err, cb) ->
      callback err, cb