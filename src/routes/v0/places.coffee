Promise = require("q").Promise
mongojs = require "mongojs"
db = mongojs "kanji", ["places"]

getData = (c, s, l) ->
  return Promise (resolve, reject) ->
    db.places.find(c).sort(s).limit l, (err, res) ->
      if err then reject err else resolve res

# GET /v0/places
# 一覧取得
exports.index = (req, res) ->
  c = {}
  s = {}
  l = null
  query = req.query

  # 緯度経度で検索
  if query.lat and query.lng
    c.loc =
      "$nearSphere": [+query.lng, +query.lat]

  # 立席キャパで検索
  if query.standingCapacity
    c["standingCapacity.min"] =
      "$lte": +query.standingCapacity
    c["standingCapacity.max"] =
      "$gte": +query.standingCapacity

  # 着席キャパで検索
  if query.seatingCapacity
    c["seatingCapacity.min"] =
      "$lte": +query.seatingCapacity
    c["seatingCapacity.max"] =
      "$gte": +query.seatingCapacity

  # 予算で検索
  if query.budget
    c["budget"] =
      "$lte": +query.budget

  if query.sort
    s[query.sort] = 1

  if query.limit
    l = +query.limit

  getData(c, s, l)
    .then (data) ->
      res.status(200).send(data)
    .catch (err) ->
      console.error err.stack
      res.status(500).send(err)


# GET /v0/places/:id
# 一覧取得
exports.show = (req, res) ->
  c = {}
  s = {}
  l = null
  c._id = mongojs.ObjectId req.params.id

  getData(c, s, l)
    .then (data) ->
      console.log JSON.stringify data, null, 2
      res.status(200).send(data)
    .catch (err) ->
      console.error err.stack
      res.status(500).send(err)

# TODO
# POST /v0/places
# 登録

# TODO
# PUT /v0/places/:id
# 更新

# TODO
# DELETE /v0/places/:id
# 削除
