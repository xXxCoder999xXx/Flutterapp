---
paths:
  - "lib/**"
  - "test/**"
  - "pubspec.yaml"
---

# Architektur und Tests – Regeln für diese Pfade

Gilt zusätzlich zu `AGENTS.md`.

## Schichten und Code

- Architektur nach ADR-002: Flutter-MVVM mit Clean-Grenzen und bedarfsgesteuerten Use Cases.
- Dependency Rule (maschinell geprüft durch den Architekturtest):
  - `ui`: feature-orientierte Views und ViewModels; darf `domain` und ein optionales `application` importieren, niemals `data`.
  - `domain`: immutable Modelle und abstrakte Repositories bei Bedarf; reines Dart ohne `package:flutter*`, Drittpakete oder Imports aus anderen Schichten.
  - `data`: Repository-Implementierungen und Services bei Bedarf; darf `domain` und freigegebene Pakete importieren, niemals `ui`.
  - `application`: nur für komplexe oder in mehreren ViewModels wiederholte Anwendungslogik; darf nur `domain` importieren. Reine Weiterleitungs-Use-Cases sind nicht zulässig.
  - `main.dart` ist die Composition Root: nur Verdrahtung, keine Fachlogik.
- Views enthalten keine Fach- oder Datenzugriffslogik. ViewModels besitzen den UI-State und kennen abstrakte Repositories, aber keine konkreten Services oder Repository-Implementierungen.
- Daten und Ereignisse folgen dem unidirektionalen Datenfluss. Verzeichnisse und Abstraktionen werden erst bei konkretem Bedarf angelegt.
- Einen Schichtverstoß nie dadurch „lösen", dass der Architekturtest angepasst wird.
- Erweiterung statt Modifikation: Erst fragen „Welcher Port, welche Registrierung, welcher Erweiterungspunkt?", dann bestehenden Code anfassen.
- Bordmittel zuerst: State Management mit ChangeNotifier/ValueNotifier. Kein Paket für eine einzelne Funktion; Pakete nur per ADR.
- Compiler-Härtung ist Repo-Regel (`analysis_options.yaml`). Lints nie per `// ignore:` entfernen, ohne dass ich es freigebe; dann mit Begründungskommentar.
- Kommentare und Doku-Kommentare auf Deutsch. Sie erklären das **Warum** und nennen bei Sicherheitsbezug die Regel.
- Fehler: fail closed, keine Stacktraces oder Systeminterna in der Oberfläche. Keine sensiblen Daten in Logs; niemals Tokens, Passwörter oder personenbezogene Daten.
- Konfiguration: Endpunkte und Varianten über `--dart-define` von außen, nie als harte Default-Secrets. Komfortausgaben nur in Debug-Builds (`kDebugMode`), nie im Release.

## Tests

- Test-first: Tests vor oder parallel zum Feature.
- Ebenen: Unit (domain/application, ViewModels, Repositories und Services ohne externe Systeme) · Widget (ui) · Architektur (Quelltext-Scan) · Integration gegen den echten identity-service-Stack (ab Phase 5).
- Missbrauchsfälle aus dem Threat Modeling werden Testfälle; Fail-closed-Pfade explizit testen.
- Neue Test-Bibliotheken nur per ADR (minimale Abhängigkeiten).
