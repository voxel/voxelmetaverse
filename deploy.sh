#!/bin/sh -x
git checkout gh-pages
git merge -X theirs master -m "Merge master"
browserify test.coffee -t coffeeify > bundle.js
git commit bundle.js -m "Regenerate bundle.js"
git checkout master
