conf = require 'nconf'

conf.defaults

  # Server Parameters
  server:
    ip:      "api.dev-st.info"
    port:    8080

  # Routes
  routes:
    search: 
      uri:  "/v1/search/"
      method: "POST"
    listIndex:
      uri:  "/v1/indexes"
      method: "GET"
    createIndex:
      uri:  "/v1/indexes"
      method: "POST"
    getIndex:
      uri:  "/v1/indexes/"
      method: "GET"
    updateIndex:
      uri:  "/v1/indexes/"
      method: "PUT"
    deleteIndex:
      uri:  "/v1/indexes/"
      method: "DELETE"
    addDocument:
      uri:  "/v1/documents/"
      method: "PUT"
    listDocuments:
      uri:  "/v1/documents/"
      method: "GET"
    deleteDocument:
      uri:  "/v1/documents/"
      method: "DELETE"
    documentDetails:
      uri:  "/v1/search/"
      method: "GET"
    downloadDocument:
      uri:  "/v1/documents/"
      method: "GET"
    getUserAceess:
      uri:  "/v1/indexes/"
      method: "GET"
    updateUserAccess:
      uri:  "/v1/indexes/"
      method: "PUT"
    deleteUserAccess:
      uri:  "/v1/indexes/"
      method: "DELETE"

module.exports = conf