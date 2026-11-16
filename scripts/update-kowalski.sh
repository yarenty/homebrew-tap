#!/usr/bin/env bash
# Point Formula/kowalski.rb at the latest kowalski release (or the tag given as $1):
# version, download links and the checksums published beside each archive.
set -euo pipefail

formula="$(dirname "$0")/../Formula/kowalski.rb"
tag="${1:-$(gh api repos/yarenty/kowalski/releases/latest -q .tag_name)}"
version="${tag#v}"
current="$(sed -n 's/^  version "\(.*\)"$/\1/p' "${formula}")"
if [[ "${current}" == "${version}" ]]
then
  echo "kowalski formula already at ${version}"
  exit 0
fi

base="https://github.com/yarenty/kowalski/releases/download/${tag}"
for target in aarch64-apple-darwin x86_64-apple-darwin aarch64-unknown-linux-gnu x86_64-unknown-linux-gnu
do
  sum="$(curl -fsSL "${base}/kowalski-${target}.tar.gz.sha256" | awk '{print $1}')"
  if [[ "${#sum}" -ne 64 ]]
  then
    echo "no checksum for ${target} in ${tag}" >&2
    exit 1
  fi
  # the sha256 line directly under this target's url line
  awk -v t="kowalski-${target}.tar.gz" -v s="${sum}" '
    hit { sub(/sha256 "[0-9a-f]*"/, "sha256 \"" s "\""); hit = 0 }
    index($0, t) { hit = 1 }
    { print }' "${formula}" >"${formula}.tmp"
  mv "${formula}.tmp" "${formula}"
done
sed -i.bak -e "s|^  version \".*\"|  version \"${version}\"|" \
  -e "s|/releases/download/v[^/]*/|/releases/download/${tag}/|" "${formula}"
rm "${formula}.bak"
echo "kowalski formula: ${current} -> ${version}"
