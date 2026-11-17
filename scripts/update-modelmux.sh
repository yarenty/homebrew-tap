#!/usr/bin/env bash
# Point Formula/modelmux.rb at the latest modelmux release (or the tag given as $1):
# version, download links and the checksum of each archive.
set -euo pipefail

formula="$(dirname "$0")/../Formula/modelmux.rb"
tag="${1:-$(gh api repos/yarenty/modelmux/releases/latest -q .tag_name)}"
version="${tag#v}"
current="$(sed -n 's|.*/releases/download/v\([^/]*\)/.*|\1|p' "${formula}" | head -n 1)"
if [[ "${current}" == "${version}" ]]
then
  echo "modelmux formula already at ${version}"
  exit 0
fi

base="https://github.com/yarenty/modelmux/releases/download/${tag}"
for target in aarch64-apple-darwin x86_64-apple-darwin aarch64-unknown-linux-gnu x86_64-unknown-linux-gnu
do
  sum="$(curl -fsSL "${base}/modelmux-${target}.tar.gz" | shasum -a 256 | awk '{print $1}')"
  if [[ "${#sum}" -ne 64 ]]
  then
    echo "no archive for ${target} in ${tag}" >&2
    exit 1
  fi
  # the sha256 line directly under this target's url line
  awk -v t="modelmux-${target}.tar.gz" -v s="${sum}" '
    hit { sub(/sha256 "[0-9a-f]*"/, "sha256 \"" s "\""); hit = 0 }
    index($0, t) { hit = 1 }
    { print }' "${formula}" >"${formula}.tmp"
  mv "${formula}.tmp" "${formula}"
done
sed -i.bak -e "s|/releases/download/v[^/]*/|/releases/download/${tag}/|" "${formula}"
rm "${formula}.bak"
echo "modelmux formula: ${current} -> ${version}"
