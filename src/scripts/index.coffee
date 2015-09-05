window.jQuery = window.$ = require "jquery"
require "bootstrap"
Q = require "q"
Promise = Q.Promise
Vue = require "vue"
mapsapi = require("google-maps-api")("AIzaSyDRRQHimqeSQZe57OAY9brwi8zAkM7RPJE")
rq = require "request-promise"

googleMaps = {}
map = null

window.VM = new Vue
  el: "#main > .tool"
  data:
    tool:
      budget: null
      seatingCapacity: null
      standingCapacity: null
      address: null
    latlng: null
    places: {}
  created: () ->
    # 初期化処理
    # 1. google maps api 準備
    # 2. map生成
    # 3. 場所を取得
    # 4. 現在位置を取得
    # 4. 現在位置に移動
    Promise.resolve()
      .then mapsapi
      .then (maps) ->
        googleMaps = maps
        return
      .then @initMap
      .then @getQuery
      .then @getPlaces
      .then (places) =>
        for val in places
          @places[val._id] = val
          @setMarkers val
        return
      # .then @getCurrentPosition
      # .then @setCenter
      .catch (err) ->
        console.log err


    @$watch "tool", () ->
      Promise.resolve()
        .then @deletePlaces
        .then @getQuery
        .then (qs) =>
          if qs.lat and qs.lng
            @setCenter [+qs.lat, +qs.lng]
          return qs
        .then @getPlaces
        .then (places) =>
          for val in places
            @places[val._id] = val
            @setMarkers val
          return
        .catch (err) ->
          console.log err
    , deep: true

  methods:
    # 現在位置の取得
    getCurrentPosition: () ->
      return new Promise (resolve, reject) ->
        navgeo = navigator?.geolocation
        if navgeo
          done = (pos) ->
            latlng = [pos.coords.latitude, pos.coords.longitude]
            resolve latlng
            return
          fail = (err) ->
            reject err
            return
          options =
            enableHighAccuracy: true
            timeout: 1000 * 30
          navgeo.getCurrentPosition done, fail, options
        else
          reject()
    initMap: () ->
      return new Promise (resolve, reject) ->
        mapOptions =
          center: new googleMaps.LatLng 35.681452, 139.766170
          disableDefaultUI: true
          mapTypeId: googleMaps.MapTypeId.ROADMAP
          scaleControl: true
          zoom: 14
          zoomControl: false
          zoomControlOptions:
            style: googleMaps.ZoomControlStyle.SMALL
            position: googleMaps.ControlPosition.RIGHT_BOTTOM
        mapCanvas = document.querySelector("#main > .map_canvas")
        map = new googleMaps.Map mapCanvas, mapOptions
        resolve()
    setCenter: (latlng) ->
      return new Promise (resolve, reject) ->
        map.setCenter new googleMaps.LatLng latlng[0], latlng[1]
        resolve()
    getQuery: () ->
      return new Promise (resolve, reject) =>
        qs = {}
        if @tool.seatingCapacity
          qs.seatingCapacity = @tool.seatingCapacity
        if @tool.standingCapacity
          qs.standingCapacity = @tool.standingCapacity
        if @tool.budget
          qs.budget = @tool.budget
        if @tool.address
          geocoder = new googleMaps.Geocoder()
          geocoder.geocode address: @tool.address, (res, status) ->
            if status is googleMaps.GeocoderStatus.OK
              loc = res[0].geometry.location
              qs.lat = loc.lat()
              qs.lng = loc.lng()
              resolve qs
            else
              console.log "Didn't get geocode."
              reject()
        else
          resolve qs
    getPlaces: (qs) ->
      options =
        url: "#{location.origin}/v0/places"
        methods: "GET"
        qs: if qs then qs else {}
        transform: (body, res) ->
          return JSON.parse body
      return rq(options)
    deletePlaces: () ->
      return new Promise (resolve, reject) =>
        for key, val of @places
          if val.marker then val.marker.setMap null
          if val.infoWindow then val.infoWindow.close()
        @places = []
        resolve()
    setMarkers: (place) ->
      return new Promise (resolve, reject) =>
        markerOptions =
          _id: place._id
          map: map
          position: new googleMaps.LatLng place.lat, place.lng
          draggable: false
        marker = new googleMaps.Marker markerOptions
        @places[place._id].marker = marker
        googleMaps.event.addListener marker, "click", () ->
          VM.showWindow @_id
        reject()
    showWindow: (_id) ->
      val = @places[_id]
      if val.infoWindow
        val.infoWindow.close()
      else
        content = """
          <div class='infoWindow'>
          #{val.name}<br>
          #{val.address}<br>
          <a href='tel:#{val.phone}'>#{val.phone}</a><br>
          <a href='mailto:#{val.email}'>#{val.email}</a><br>
          <a href='#{val.url}' target='_blank'>#{val.url}</a><br>
          <img src='#{val.image}'>
          </div>
        """
        val.infoWindow = new googleMaps.InfoWindow
          content: content
          maxWidth: 300
        val.infoWindow.open map, val.marker
