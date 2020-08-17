set -ex

THIS_DIR=$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)
TEMP_DIR="$(mktemp -d)"

cd "$TEMP_DIR"

wget https://registry.yarnpkg.com/fsevents/-/fsevents-1.2.11.tgz
wget https://registry.yarnpkg.com/fsevents/-/fsevents-2.1.2.tgz

tar xvf fsevents-1.2.11.tgz
cp -rf package copy

cp "$THIS_DIR"/fsevents-1.2.11.js copy/fsevents.js
cp "$THIS_DIR"/vfs.js copy/vfs.js
git diff --src-prefix=a/ --dst-prefix=b/ --ignore-cr-at-eol --full-index --no-index package copy > "$THIS_DIR"/fsevents-1.2.11.patch || true

rm -rf package copy

tar xvf fsevents-2.1.2.tgz
cp -rf package copy

cp "$THIS_DIR"/fsevents-2.1.2.js copy/fsevents.js
cp "$THIS_DIR"/vfs.js copy/vfs.js
git diff --src-prefix=a/ --dst-prefix=b/ --ignore-cr-at-eol --full-index --no-index package copy > "$THIS_DIR"/fsevents-2.1.2.patch || true

sed -i '' 's#a/package/#a/#' "$THIS_DIR"/fsevents-1.2.11.patch
sed -i '' 's#b/copy/#b/#' "$THIS_DIR"/fsevents-1.2.11.patch
sed -i '' 's#^--- #semver exclusivity ^1\'$'\n''--- #' "$THIS_DIR"/fsevents-1.2.11.patch

sed -i '' 's#a/package/#a/#' "$THIS_DIR"/fsevents-2.1.2.patch
sed -i '' 's#b/copy/#b/#' "$THIS_DIR"/fsevents-2.1.2.patch
sed -i '' 's#^--- #semver exclusivity ^2.1\'$'\n''--- #' "$THIS_DIR"/fsevents-2.1.2.patch

cat "$THIS_DIR"/fsevents-1.2.11.patch \
    "$THIS_DIR"/fsevents-2.1.2.patch \
  > "$TEMP_DIR"/fsevents.patch

node "$THIS_DIR/../createPatch.js" "$TEMP_DIR"/fsevents.patch "$THIS_DIR"/../../sources/patches/fsevents.patch.ts
