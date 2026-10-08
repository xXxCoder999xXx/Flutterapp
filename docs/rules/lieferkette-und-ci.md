---
paths:
  - ".github/**"
  - "pubspec.yaml"
  - "pubspec.lock"
  - "analysis_options.yaml"
---

# Lieferkette und CI – Regeln für diese Pfade

Gilt zusätzlich zu `AGENTS.md`. Begründungen stehen in den ADRs und in den Kopfkommentaren der Workflow-Dateien.

## Workflows

- Baseline `permissions: contents: read`. Ein Job-Block **ersetzt** die Baseline (er erweitert sie nicht): `contents: read` dort wiederholen. Schreibrechte nur in einem eigenen Job mit kleinstem Scope.
- Checkout mit `persist-credentials: false`; `runs-on` versioniert (nie `-latest`); `timeout-minutes` setzen; kein Paket- oder Actions-Cache; kein `pull_request_target`; keine Secrets für Fork-PRs. Release-Workflows: `cancel-in-progress: false`.
- **Script Injection:** Vom Einreicher kontrollierter Text (PR-Titel und -Body, Branch-Name, Commit-Nachricht) niemals per `${{ ... }}` in ein `run:` einsetzen. Über `env:` übergeben und in der Shell als Daten lesen.
- **Action-Pins:** `uses: owner/repo@<volle 40-stellige SHA> # vX.Y.Z`. Die SHA wird ausschließlich aus dem offiziellen Repo per `git ls-remote` aufgelöst (gepeelte Tags `^{}`); Auflösungsdatum im Dateikopf vermerken. Nie Tags oder Branches, nie SHAs aus Gedächtnis oder Blog.
- **Job-Namen sind die Status-Check-Namen des Rulesets** (`Analyze & Test`, `Build (Android)`, `PR-Titel`): nie umbenennen ohne gleichzeitige Ruleset-Anpassung. Ein neuer Job wird erst bewusst als Required Check aufgenommen.
- **Schrittfolge** in `ci.yml` ist die Urteils-Hierarchie und bleibt: `flutter pub get --enforce-lockfile` → `dart format --set-exit-if-changed` → `flutter analyze --fatal-warnings` → `flutter test`. Folgestufen lösen nie still neu auf.
- Sicherheitswerkzeuge in der Pipeline sind fail-closed: Kann ein Werkzeug nicht arbeiten (keine Datenbank, kein Netz), wird die Pipeline rot, nie grün.
- Lädt ein Werkzeug zur Laufzeit Binaries nach, pinnt der Action-SHA nur den Wrapper, nicht das Werkzeug. Deshalb wird das Flutter SDK per `git clone` auf eine **Commit-SHA** ausgecheckt (Pin per Inhalt), nicht über eine Setup-Action.

## Flutter SDK und pub

- Der SDK-Pin steht in `ci.yml` (Commit-SHA des Flutter-Releases) und lesbar im neuesten Sitzungsbericht. Ein SDK-Wechsel ist **ein** PR für beide Stellen. Vorher die Version lokal installieren und die Qualitätskette laufen lassen.
- `pubspec.lock` wird committet (App, kein Paket). Die CI läuft mit `--enforce-lockfile`: Lockfile-Bruch ist ein Lieferketten-Signal und schlägt fehl.
- Neue Abhängigkeit: Slopsquatting-Verifikation gegen pub.dev (Existenz, exakte Schreibweise, verified publisher, Alter, Pflege, Downloads) und Aufnahme-Prüfung (Pflegezustand, transitive Last, Bordmittel-Alternative?) – dann ADR.
- Sicherheitsankündigungen zu genutzten Paketen werden beim wöchentlichen Lauf und bei jeder Paketentscheidung geprüft (OSV/GitHub Advisories).

## Dependabot

- Änderungen an `dependabot.yml` **additiv** (bestehende Blöcke unangetastet), Commit-Präfix `chore` mit `include: scope`. Gruppen nur für nachweislich gekoppelte Abhängigkeiten, nie `patterns: ["*"]`.
- Bot-PRs durchlaufen dieselbe Pipeline, werden nie auto-gemergt und nie ungelesen übernommen. Der Bot meldet, die Pipeline urteilt, der Mensch führt gekoppelte Updates von Hand zusammen.
