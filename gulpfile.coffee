gulp = require "gulp"
coffee = require "gulp-coffee"
del = require "del"
runSequence = require "run-sequence"
nodemon = require "nodemon"

gulp.task "clean", (done) ->
  del ["./server/*"], done

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

gulp.task "coffee", ["coffee:app", "coffee:routes", "coffee:v0"]

gulp.task "watch", () ->
  gulp.watch ["./src/*.coffee"], ["coffee:app"]
  gulp.watch ["./src/**/*.coffee"], ["coffee:v0"]

gulp.task "generate", (done) ->
  runSequence "clean", "coffee", done

gulp.task "nodemon", () ->
  nodemon
    script: "./server/app.js"
    env:
      NODE_ENV: "development"

gulp.task "preview", ["watch"], (done) ->
  runSequence "generate", "nodemon", done
