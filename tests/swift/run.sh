#!/bin/sh
# Prueft den Protokollteil aus AtlasBand.swift (WProto, WReassembler) auf dem Mac
# mit den Referenzpaketen aus golden.json. Aufruf: sh tests/swift/run.sh
set -e
D=$(cd "$(dirname "$0")" && pwd); T=$(mktemp -d)
awk '/^enum WProto/{p=1} /^\/\/ MARK: Verbindung/{p=0} p' "$D/../../ios/App/App/AtlasBand.swift" > "$T/proto.swift"
printf 'import Foundation\n' | cat - "$T/proto.swift" "$D/main.swift" > "$T/all.swift"
swiftc -O "$T/all.swift" -o "$T/t" 2>&1 && "$T/t" "$D/golden.json"
