conf = require 'nconf'

conf.defaults

  # Server
  api:

    host: "api.searchtower.com"

  # Routes
  routes:

    #ACLS
    getUserAceess:
      uri:  "/v1/indexes/{{index}}/acl"
      method: "GET"
    updateUserAccess:
      uri:  "/v1/indexes/{{index}}/acl"
      method: "PUT"
    deleteUserAccess:
      uri:  "/v1/indexes/{{index}}/acl"
      method: "DELETE"

    #Indexes
    createIndex:
      uri:  "/v1/indexes"
      method: "POST"
    updateIndex:
      uri:  "/v1/indexes/{{index}}"
      method: "PUT"
    listIndex:
      uri:  "/v1/indexes"
      method: "GET"
    getIndex:
      uri:  "/v1/indexes/{{index}}"
      method: "GET"
    deleteIndex:
      uri:  "/v1/indexes/{{index}}"
      method: "DELETE"

    #Documents
    addDocument:
      uri:  "/v1/documents/{{index}}/{{name}}"
      method: "PUT"
    listDocuments:
      uri:  "/v1/documents/{{index}}"
      method: "GET"
    downloadDocument:
      uri:  "/v1/documents/{{index}}/{{name}}"
      method: "GET"
    deleteDocument:
      uri:  "/v1/documents/{{index}}/{{name}}"
      method: "DELETE"
    restoreDocument:
      uri: "/v1/documents/{{index}}/{{name}}/restore"
      method: 'POST'

    #Search
    documentDetails:
      uri:  "/v1/search/{{index}}/{{name}}"
      method: "GET"
    search: 
      uri:  "/v1/search/{{index}}"
      method: "POST"

module.exports = conf