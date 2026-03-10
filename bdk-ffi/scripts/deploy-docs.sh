# This script will build the API docs website and push it to the gh-pages branch,
# publishing it automatically to https://bitcoindevkit.github.io/bdk-ffi/.

set -euo pipefail

just docs
cd ./target/doc/
git init .
git switch --create gh-pages
git add .
git commit --message "Deploy $(date +"%Y-%m-%d")"
git remote add upstream git@github.com:bitcoindevkit/bdk-ffi.git
git push upstream gh-pages --force
cd ..
