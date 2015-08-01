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

gulp.task "coffee", ["coffee:app"]

gulp.task "watch", () ->
  gulp.watch ["./src/*.coffee"], ["coffee:app"]

gulp.task "generate", (done) ->
  runSequence "clean", "coffee", done

gulp.task "nodemon", () ->
  nodemon
    script: "./src/app.coffee"
    env:
      NODE_ENV: "development"

gulp.task "preview", ["watch"], (done) ->
  runSequence "generate", "nodemon", done
