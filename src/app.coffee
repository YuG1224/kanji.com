express = require "express"
http = require "http"
path = require "path"
# moment = require "moment"
config = require "./config"
fs = require "fs"

app = express()
server = http.createServer app

app.set "port", config.port

# URLルーティング
route = require "./routes"
app.get "/", route.index

# APIルーティング
files = []
for val in fs.readdirSync "#{__dirname}/routes/v0"
  files.push val.replace /\.js$/, ""
for val in files
  api = require "#{__dirname}/routes/v0/#{val}"
  if api.index then app.get "/v0/#{val}", api.index
  if api.new then app.get "/v0/#{val}/new", api.new
  if api.create then app.post "/v0/#{val}", api.create
  if api.show then app.get "/v0/#{val}/:id", api.show
  if api.edit then app.get "/v0/#{val}/:id/edit", api.edit
  if api.update then app.put "/v0/#{val}/:id", api.update
  if api.destroy then app.delete "/v0/#{val}/id", api.destroy

app.use express.static "../client"

server.listen app.get("port"), ->
  console.log "Server listen on port #{app.get('port')}"
  return
