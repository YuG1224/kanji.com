exports.index = (req, res) ->
  res.locals.lang = "ja"
  res.locals.title = "kanji.com"
  res.render "index",
    pretty: true
