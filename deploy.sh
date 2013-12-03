#!/bin/sh -x
git checkout gh-pages
git merge master -m "Merge branch 'master' into gh-pages"
browserify test.coffee -t coffeeify > bundle.js
git commit bundle.js -m "Regenerate bundle.js using deploy.sh"
git checkout master
