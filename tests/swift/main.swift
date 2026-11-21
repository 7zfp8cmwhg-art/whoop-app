func hex(_ s: String) -> [UInt8] { var o: [UInt8] = []; var i = s.startIndex
  while i < s.endIndex { let j = s.index(i, offsetBy: 2); o.append(UInt8(s[i..<j], radix: 16)!); i = j }; return o }
func hx(_ b: [UInt8]) -> String { b.map { String(format: "%02x", $0) }.joined() }
var fail = 0, pass = 0
func ok(_ c: Bool, _ n: String) { if c { pass += 1 } else { fail += 1; print("FEHLER: " + n) } }
let G = try! JSONSerialization.jsonObject(with: Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))) as! [String: String]
// 1) Befehl wie der echte Mitschnitt (Hello, seq 1)
ok(hx(WProto.command(seq: 1, op: 0x91, payload: [1], gen: 5)!) == "aa0108000001e67123019101363e5c8d", "Hello-Rahmen")
ok(WProto.command(seq: 1, op: 0x19, payload: [], gen: 5) == nil, "gesperrter Befehl")
// 2) Jedes Referenzpaket: ganz, in Stuecken 1..244 Byte, und Rahmen neu gebaut = Original
for (k, v) in G.sorted(by: { $0.key < $1.key }) {
  let f = hex(v)
  for cs in [1, 7, 20, 64, 180, 244, f.count] {
    let r = WReassembler(gen: 5); var got: [[UInt8]] = []
    var o = 0; while o < f.count { got += r.feed(Array(f[o..<min(f.count, o + cs)])); o += cs }
    ok(got.count == 1 && r.dropped == 0, "\(k) Stueck \(cs): \(got.count) Rahmen, \(r.dropped) verworfen")
    if cs == f.count, let inner = got.first { ok(Array(WProto.frame(inner, gen: 5).dropFirst(8)) == Array(f.dropFirst(8)), "\(k) neu gebaut (Inhalt+CRC32; Kopf-Bytes 4-5 sind je Richtung verschieden: Band 01 00, Handy 00 01)") }
  }
}
// 3) Zwei Kanaele gemischt mit getrennten Puffern: nichts geht verloren; gemeinsamer Puffer verliert
let a = hex(G["real_r18_noop"]!), b = hex(G["synthetic_battery_event"]!)
let ra = WReassembler(gen: 5), rb = WReassembler(gen: 5), rs = WReassembler(gen: 5); var na = 0, nb = 0, ns = 0
for i in stride(from: 0, to: a.count, by: 31) { na += ra.feed(Array(a[i..<min(a.count, i + 31)])).count; ns += rs.feed(Array(a[i..<min(a.count, i + 31)])).count
  if i == 31 { nb += rb.feed(b).count; ns += rs.feed(b).count } }
ok(na == 1 && nb == 1, "getrennte Kanaele"); ok(ns < 2, "gemeinsamer Puffer zeigt den alten Fehler")
// 4) Kaputte Pruefsumme wird verworfen, folgender Rahmen bleibt lesbar
var bad = a; bad[40] ^= 0xFF; let rc = WReassembler(gen: 5); let n = rc.feed(bad + b).count
ok(n == 1 && rc.dropped == 1, "kaputter Rahmen verworfen, naechster gelesen")
// 5) 1000 Datensaetze am Stueck in 182-Byte-Stuecken
var big: [UInt8] = []; for _ in 0..<1000 { big += a }; let rbig = WReassembler(gen: 5); var nbig = 0
var o = 0; while o < big.count { nbig += rbig.feed(Array(big[o..<min(big.count, o + 182)])).count; o += 182 }
ok(nbig == 1000 && rbig.dropped == 0, "1000 Datensaetze: \(nbig)")
// 6) Quittung: Token unveraendert, Rahmen gueltig
let tok: [UInt8] = [1, 2, 3, 4, 5, 6, 7, 8]; let ack = WProto.batchAck(seq: 9, token: tok, gen: 5)
let ri = WReassembler(gen: 5).feed(ack); ok(ri.count == 1 && Array(ri[0][0..<4]) == [0x23, 9, 0x17, 1] && Array(ri[0][4..<12]) == tok, "Quittung")
print("Swift-Protokoll: \(pass) ok, \(fail) Fehler"); exit(fail == 0 ? 0 : 1)
