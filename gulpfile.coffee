browserify = require "browserify"
coffee = require "gulp-coffee"
concat = require "gulp-concat"
del = require "del"
Filter = require "gulp-filter"
foreach = require "gulp-foreach"
gulp = require "gulp"
runSequence = require "run-sequence"
minifycss = require "gulp-minify-css"
nodemon = require "nodemon"
path = require "path"
stylus = require "gulp-stylus"
source = require "vinyl-source-stream"

gulp.task "clean", (done) ->
  del ["./client/*", "./server/*"], done

gulp.task "coffee:app", () ->
  gulp.src ["./src/*.coffee"]
    .pipe coffee()
    .pipe gulp.dest "./server"

gulp.task "coffee:routes", () ->
  gulp.src ["./src/routes/index.coffee"]
    .pipe coffee()
    .pipe gulp.dest "./server/routes/"

gulp.task "coffee:v0", () ->
  gulp.src ["./src/routes/v0/*.coffee"]
    .pipe coffee()
    .pipe gulp.dest "./server/routes/v0/"

gulp.task "coffee:scripts", () ->
  gulp.src ["./src/scripts/*.coffee"]
    .pipe foreach (stream, file) ->
      filename = path.basename file.path, ".coffee"
      return browserify
        entries: file.path
        extensions: [".coffee"]
        debug: true
      .bundle()
      .pipe source "#{filename}.js"
    .pipe gulp.dest "./client/js"

gulp.task "coffee", [
  "coffee:app"
  "coffee:routes"
  "coffee:v0"
  "coffee:scripts"
]

gulp.task "views", () ->
  gulp.src [
    "./src/views/*.jade"
    "./src/views/**/*.jade"
  ], base: "./src/views"
    .pipe gulp.dest "./server/views"

gulp.task "styles", () ->
  filter = Filter "**/*.styl", restore: true
  gulp.src [
    "./src/styles/*.styl"
    "./node_modules/bootstrap/dist/css/bootstrap.css"
  ]
  .pipe filter
  .pipe stylus()
  .pipe filter.restore
  .pipe concat "app.css"
  .pipe minifycss
    keepBreaks: true
  .pipe gulp.dest "./client/css"

gulp.task "watch", () ->
  gulp.watch ["./src/*.coffee"], ["coffee:app"]
  gulp.watch ["./src/**/*.coffee"], [
    "coffee:routes"
    "coffee:v0"
    "coffee:scripts"
  ]
  gulp.watch [
    "./src/views/*.jade"
    "./src/views/**/*.jade"
  ], ["views"]
  gulp.watch [
    "./src/styles/*.styl"
  ], ["styles"]

# vendor:fonts
gulp.task "vendor:fonts", () ->
  gulp.src [
    "./node_modules/bootstrap/dist/fonts/*"
  ]
  .pipe gulp.dest "./client/fonts"

# vendor
gulp.task "vendor", ["vendor:fonts"]

gulp.task "generate", (done) ->
  runSequence "clean",
    "vendor"
    "coffee"
    "views"
    "styles"
    done

gulp.task "nodemon", () ->
  nodemon
    script: "./server/app.js"
    env:
      NODE_ENV: "development"

gulp.task "preview", ["watch"], (done) ->
  runSequence "generate", "nodemon", done
