#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
crate_dir="$(cd "${script_dir}/.." && pwd)"
lib_rs="${crate_dir}/src/lib.rs"
target_dir="${CARGO_TARGET_DIR:-target}"

tmp_lib_rs="$(mktemp "${TMPDIR:-/tmp}/bdkffi-lib.rs.XXXXXX")"
cp "${lib_rs}" "${tmp_lib_rs}"

# Always restore the original `src/lib.rs` on exit so the temporary visibility
# change never sticks around in the working tree after the docs build finishes.
cleanup() {
  cp "${tmp_lib_rs}" "${lib_rs}"
  rm -f "${tmp_lib_rs}"
}
trap cleanup EXIT

# Rustdoc only emits module pages for publicly reachable modules. For the docs
# build, temporarily rewrite the top-level `mod foo;` lines into `pub mod foo;`.
awk '
  BEGIN {
    pattern = "^(bitcoin|descriptor|electrum|error|esplora|keys|kyoto|macros|store|tx_builder|types|wallet)$"
  }
  {
    if ($0 ~ /^mod [a-z_]+;$/) {
      module = $0
      sub(/^mod /, "", module)
      sub(/;$/, "", module)
      if (module ~ pattern) {
        print "pub mod " module ";"
        next
      }
    }
    print
  }
' "${tmp_lib_rs}" > "${lib_rs}"

cd "${crate_dir}"
cargo doc --no-deps

mkdir -p "${target_dir}/doc"
printf '%s\n' '<meta http-equiv="refresh" content="0; url=bdkffi/index.html">' > "${target_dir}/doc/index.html"
printf 'Documentation built at %s/doc/\n' "${target_dir}"
