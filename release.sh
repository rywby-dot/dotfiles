#!/bin/sh
# Build a release tarball for driftwm.
# Usage: ./release.sh
# Produces: driftwm-<version>-x86_64-linux.tar.gz

set -e

VERSION=$(grep '^version' Cargo.toml | head -1 | sed 's/.*"\(.*\)"/\1/')
ARCHIVE="driftwm-${VERSION}-x86_64-linux.tar.gz"
STAGING="driftwm-${VERSION}"

cargo build --release

rm -rf "$STAGING"
mkdir -p "$STAGING/wallpapers"

cp target/release/driftwm "$STAGING/"
cp resources/driftwm-session "$STAGING/"
cp resources/driftwm.desktop "$STAGING/"
cp resources/driftwm-portals.conf "$STAGING/"
cp config.reference.toml "$STAGING/config.reference.toml"
cp -r extras/wallpapers/. "$STAGING/wallpapers/"

tar czf "$ARCHIVE" "$STAGING"
rm -rf "$STAGING"

echo "Built $ARCHIVE ($(du -h "$ARCHIVE" | cut -f1))"
