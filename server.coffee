fs = require "fs"
path = require "path"
qs = require "querystring"

express = require "express"
kue = require "kue"
form = require('connect-form')

# require "./ircposter"

jobs = kue.createQueue()
app = express.createServer()

app.configure ->
  app.use form
    keepExtensions: true
    uploadDir: __dirname + '/public/img'
  app.use express.static __dirname + '/public'


app.get "/photos", (req, res) ->
  res.header('Content-Type', 'text/html')
  res.end '''
  <form action="" method="post" accept-charset="utf-8"  enctype="form-data/multipart">
  <input type="file" name="picdata" />
  <input type="hidden" name="foo" value="bar" />
  <p><input type="submit" value="Continue &rarr;"></p>
  </form>
  '''

app.post "/upload", (req, res) ->

  req.form.complete (err, fields, files) ->
    if err then throw err


    fields.caption = qs.unescape fields.caption
    fields.url = "http://#{ req.headers.host }/img/#{ path.basename files.picdata.path }"
    fields.title = "#{ fields.nick } is  posting '#{ fields.caption }' to #{ fields.channel }@#{ fields.network } #{ fields.url }"

    console.log fields.title

    job = jobs.create "irc-#{ fields.network.toLowerCase() }", fields
    job.save()

    res.end(fields.url)



app.listen 1337

kue.app.listen(3000)
