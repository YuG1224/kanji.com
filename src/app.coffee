express = require "express"
http = require "http"
path = require "path"
# moment = require "moment"
config = require "./config"

app = express()
server = http.createServer app

app.set "port", config.port

server.listen app.get("port"), ->
  console.log "Server listen on port #{app.get('port')}"
  return
