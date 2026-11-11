#!/bin/sh
# Build the release assets: EFI.zip and EFI-SHA256.txt, next to the repo root.
set -eu

cd "$(dirname "$0")/.."

[ -d EFI ] || { echo "EFI/ not found" >&2; exit 1; }

rm -f EFI.zip EFI-SHA256.txt

# No __MACOSX, no .DS_Store, no resource forks.
find EFI -name '.DS_Store' -delete
zip -rq EFI.zip EFI -x '*.DS_Store' -x '__MACOSX/*'
shasum -a 256 EFI.zip > EFI-SHA256.txt

echo "Built:"
ls -lh EFI.zip EFI-SHA256.txt
echo
cat EFI-SHA256.txt
echo
echo "Upload both files to the GitHub release."
