# Recherche WHOOP 5/MG BLE (Checkpoint)

## Q1 Overnight / Drain
- Strap logs ~1 Hz to ~14 d flash without phone (kenkofit-joe.duckdns.org/architecture; NOOP README). Drain triggers there: on connect, ~15 min timer while connected, foreground (90 s cooldown), strap event (90 s), manual. Save chunk BEFORE ack. Connect handshake once per connection (more than 2x jams strap). Medium.
- whoop-vault daemon drains every 10 min; ~120 chunks/s, ~50 KB/s (github.com/Sophonbot0/whoop-vault). wearable5 FINDINGS s10: official app history round ~600 s; s17: re-read ~120x realtime; 4 KB page ~13.6 s of data.
- NOOP iOS: state-restoration hooks exist, live iPhone BLE "still being validated" (github.com/NoopApp/noop). NOOP issue ryanbr/noop#324: overnight disconnect on iOS 26.5, morning sync drains. No source found on live-HR keeping app awake.
## Q2 Protocol
- hello 0x91 (body 01) -> 0x22 GET_DATA_RANGE -> 0x16 SEND_HISTORICAL, ~120 ms apart; HISTORY_END = meta 0x31 sub 2 (type 49); ack 0x17 = 01 + 8-byte token (github.com/ribhupanwar/whoop-mg-client; judes.club/writing/cracking-the-whoop-5-bluetooth-protocol). No ack -> stops after 1 chunk / resends. Some drain first sends ENTER_HIGH_FREQ_SYNC (96) (judes.club). ABORT_HISTORICAL_TRANSMITS exists (wearable5 s10). Realtime-HR-off requirement: not found. Ack only moves read pointer; whoop-rs says sync never deletes data.
## Q3 BP: no project reads BP from band. WHOOP: cuff calibration (3 readings, recalibrate ~30 d), estimate from overnight PPG/HR/HRV (whoop.com/thelocker/blood-pressure-insights). Band vs cloud: not found.
## Q4 ECG: wearable5 s9: R16 (500 samples) / R17 (100 i16); scale and rate unestablished. Start/stop cmds 123/124/139 not confirmed (123 = SELECT_WRIST).
## Q5 v18 (type 0x2F, 112 B): steps u16 @49 (accumulate deltas), SpO2 candidate byte @82, HR @14, accel f32 @37/41/45 (g) in r22 variant; skin temp 0.01 C (vault). Strain: server-side at WHOOP; open models: wearable5 DS-E (EW minutes >94 bpm), NOOP Edwards/Banister TRIMP, whoop-vault.
## Q6 0x6B=107 ENABLE_OPTICAL_DATA (wearable5 s19). Slowing history: not documented; s17 notes ~245 pages/h trimmed vs ~3600 pages/h after raw capture.
