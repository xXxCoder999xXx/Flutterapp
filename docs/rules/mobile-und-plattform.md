---
paths:
  - "android/**"
  - "ios/**"
---

# Mobile und Plattform – Regeln für diese Pfade

Gilt zusätzlich zu `AGENTS.md`. Plattformdateien sind Infrastruktur-Code: Änderungen nur per PR, mit Begründung.

## Secrets und Signatur

- Keine Signierschlüssel, Keystore-Passwörter oder API-Schlüssel in `android/`, `ios/` oder sonstwo im Repository. Die Release-Signatur kommt in Phase 4 per ADR (Keystore als Plattform-Secret, nie als Datei im Repo).
- `key.properties`, `*.jks`, `*.keystore`, `*.p12`, `*.mobileprovision` sind per `.gitignore` gesperrt und werden nie committet.

## Netz und Härtung

- HTTPS-only: `android:usesCleartextTraffic="false"` im Release-Manifest; ATS unter iOS ohne Ausnahmen. Die Entwicklungs-Ausnahme für den lokalen identity-service-Stack lebt ausschließlich in der Debug-Variante (`src/debug/`), niemals im Release.
- Minimale Berechtigungen: Jede neue Permission im Manifest bzw. in der `Info.plist` ist eine Angriffsfläche und wird im PR begründet. Keine Permission „für später".
- Plattform-Kanäle (MethodChannel) sind eine Systemgrenze: Alle Daten von der nativen Seite werden validiert, bevor sie in die App-Logik laufen.
- WebView, Deep Links und URL-Handling sind Angriffsfläche: Aufnahme nur nach Bedarf, mit Validierung und Begründung im PR.

## Plattform-Realität

- iOS wird lokal nicht gebaut (Windows-Entwicklungsrechner). Die iOS-Verifikation läuft über den macOS-CI-Runner (zunächst `--no-codesign` als Kompilierbeweis). Änderungen an `ios/` werden deshalb besonders sorgfältig gelesen, weil kein lokaler Lauf sie prüft.
- Generierte Plattformdateien (durch `flutter create` / `flutter pub get`) werden nicht von Hand „optimiert"; gezielte Änderungen sind erlaubt, aber als solche im PR erkennbar.
