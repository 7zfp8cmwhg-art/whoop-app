#!/bin/sh
# Typpruefung von AtlasBand.swift ohne Xcode: Band-Teil (bis zur Capacitor-Bruecke) plus
# AtlasSeqBuf aus AtlasGeo.swift, gegen kleine UIKit-Stubs (ios_stubs.swift). Aufruf: sh tests/swift/typecheck.sh
set -e
D=$(cd "$(dirname "$0")" && pwd); A="$D/../../ios/App/App"; T=$(mktemp -d)
awk '/^\/\/ MARK: Bruecke zur Web-App/{exit} {print}' "$A/AtlasBand.swift" | grep -v '^import UIKit\|^import Capacitor\|^import CoreMotion' > "$T/band.swift"
s=$(grep -n 'class AtlasSeqBuf' "$A/AtlasGeo.swift" | cut -d: -f1)
{ echo 'import Foundation'; awk -v s="$s" 'NR>=s{print; if(/^}/)exit}' "$A/AtlasGeo.swift"; } > "$T/seqbuf.swift"
swiftc -typecheck "$D/ios_stubs.swift" "$T/seqbuf.swift" "$T/band.swift" && echo "Swift-Typpruefung: ok"
