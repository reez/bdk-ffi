#!/usr/bin/env bash

# Build the docs site and publish it to the gh-pages branch, which GitHub Pages
# serves at https://bitcoindevkit.github.io/bdk-ffi/.

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
crate_dir="$(cd "${script_dir}/.." && pwd)"
target_dir="${CARGO_TARGET_DIR:-target}"

case "${target_dir}" in
  /*) docs_dir="${target_dir}/doc" ;;
  *) docs_dir="${crate_dir}/${target_dir}/doc" ;;
esac

publish_dir="$(mktemp -d "${TMPDIR:-/tmp}/bdkffi-gh-pages.XXXXXX")"

cleanup() {
  rm -rf "${publish_dir}"
}
trap cleanup EXIT

bash "${script_dir}/build-docs.sh"

cp -R "${docs_dir}/." "${publish_dir}/"

cd "${publish_dir}"
git init --initial-branch gh-pages
git add .
git commit --message "Deploy $(date +"%Y-%m-%d")"
git remote add upstream git@github.com:bitcoindevkit/bdk-ffi.git
git push upstream gh-pages --force
