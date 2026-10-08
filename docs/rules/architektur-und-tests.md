---
paths:
  - "lib/**"
  - "test/**"
  - "pubspec.yaml"
---

# Architektur und Tests – Regeln für diese Pfade

Gilt zusätzlich zu `AGENTS.md`.

## Schichten und Code

- Dependency Rule (maschinell geprüft durch den Architekturtest):
  - `domain`: reines Dart – kein `package:flutter*`, keine Drittpakete, keine Imports aus anderen Schichten.
  - `application`: darf nur `domain` importieren; definiert Ports als abstrakte Klassen.
  - `infrastructure`: implementiert Ports; darf `application`, `domain` und freigegebene Pakete importieren.
  - `presentation`: Widgets und State; darf `application` und `domain` importieren, nie `infrastructure`.
  - `main.dart` ist die Composition Root: nur Verdrahtung, keine Fachlogik.
- Einen Schichtverstoß nie dadurch „lösen", dass der Architekturtest angepasst wird.
- Erweiterung statt Modifikation: Erst fragen „Welcher Port, welche Registrierung, welcher Erweiterungspunkt?", dann bestehenden Code anfassen.
- Bordmittel zuerst: State Management mit ChangeNotifier/ValueNotifier. Kein Paket für eine einzelne Funktion; Pakete nur per ADR.
- Compiler-Härtung ist Repo-Regel (`analysis_options.yaml`). Lints nie per `// ignore:` entfernen, ohne dass ich es freigebe; dann mit Begründungskommentar.
- Kommentare und Doku-Kommentare auf Deutsch. Sie erklären das **Warum** und nennen bei Sicherheitsbezug die Regel.
- Fehler: fail closed, keine Stacktraces oder Systeminterna in der Oberfläche. Keine sensiblen Daten in Logs; niemals Tokens, Passwörter oder personenbezogene Daten.
- Konfiguration: Endpunkte und Varianten über `--dart-define` von außen, nie als harte Default-Secrets. Komfortausgaben nur in Debug-Builds (`kDebugMode`), nie im Release.

## Tests

- Test-first: Tests vor oder parallel zum Feature.
- Ebenen: Unit (domain/application, keine externen Abhängigkeiten) · Widget (presentation) · Architektur (Quelltext-Scan) · Integration gegen den echten identity-service-Stack (ab Phase 5).
- Missbrauchsfälle aus dem Threat Modeling werden Testfälle; Fail-closed-Pfade explizit testen.
- Neue Test-Bibliotheken nur per ADR (minimale Abhängigkeiten).
