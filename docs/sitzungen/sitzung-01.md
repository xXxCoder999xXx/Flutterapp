# Sitzungsbericht Sitzung 1

**Datum:** 08.10.2026
**Phase:** 0 abgeschlossen (Governance steht); Phase 1 begonnen (Scaffold steht, Schichten und Tests offen)
**Vorgänger:** keiner (erste Sitzung)

---

## 1. Erledigt

### 1.1 Musteranalyse identity-service (nur lesend)

Struktur, GitHub-Strategie, Deployment-Strategie und Agent-Harness des
Musterprojekts analysiert (`C:\Projects\xXxCoder999xXx\identity-service`).
Quellen: `CLAUDE.md`, alle vier Workflows, `dependabot.yml`, `CODEOWNERS`,
ADRs 001/004, `main-ruleset.json`, Sitzungsbericht 9. Kernergebnis: Prinzipien
werden übernommen (Walking Skeleton, DevSecOps ab Tag 1, geschützter Merge,
Pin per Inhalt), Mechanik bekommt Flutter-Äquivalente (`pubspec.lock` +
`--enforce-lockfile` statt NuGet-Lockfiles, strenger Analyzer statt CodeQL,
Quelltext-Architekturtest statt Reflection).

### 1.2 Grundsatzentscheidungen und Plan

Mit der Projekt-Ownerin entschieden: **Client für identity-service**,
**Android + iOS** (kein Web/Desktop), **neues öffentliches GitHub-Repo**,
**Harness vollständig adaptiert**. Plan geschrieben und freigegeben.

### 1.3 Phase 0: Governance (Commit `7f78d7b`)

15 Dateien: `.gitignore`/`.gitattributes`/`.editorconfig`, `README.md`,
`AGENTS.md` (Projektverfassung, Mentor-Modus), `docs/rules/` (Architektur,
Lieferkette, Mobile), `ADR-000` + `ADR-001` (GitHub, öffentlich),
`docs/governance/main-ruleset.json` (Ziel-Definition für Phase 3),
`docs/sitzungen/README.md`, `scripts/Protect-Secrets.ps1`,
`scripts/Test-CommitConvention.ps1`. Commit signiert (SSH, ED25519).

### 1.4 Skripte in beide Richtungen bewiesen

- `Protect-Secrets.ps1`: grün auf echtem Stand; rot bei erzwungener `.env`;
  rot bei Datei mit privatem Schlüssel (nach Korrektur der Probe, s. u.)
- `Test-CommitConvention.ps1`: grün bei `feat: add login screen`; rot bei
  `Add something`; rot bei Punkt am Ende; rot auf `main` (Branch-Schutz)

### 1.5 Phase 1 begonnen: Scaffold (Commit `209c8f4`)

`flutter create . --org dev.xxxcoder999xxx --project-name identity_client
--platforms android,ios` — 71 Dateien, **unverändert** als eigener Commit.
Qualitätskette komplett grün: `format` 0 Änderungen, `analyze` 0 Funde,
1 Test grün. Keine Kollision mit den Governance-Dateien (per `git status`
bewiesen, nicht angenommen).

---

## 2. Gelernt

- Vor dem ersten Commit existiert `main` noch nicht (unborn HEAD): Ein
  Branch-Wechsel scheitert, der Rückweg ist `git branch -m main`
- bash `printf` mit führendem `--` im Formattext bricht als „invalid option"
  — Format in `'%s\n'` verpacken; die „grüne" Probe danach war wertlos und
  musste wiederholt werden (Muster-Regel: ein Werkzeug, das nicht suchen
  konnte, meldet falschen Erfolg)
- `flutter create` überschreibt bestehende Dateien im Zielordner nicht —
  trotzdem gilt: danach `git status` lesen statt annehmen
- Die Ignorierung von Plattform-Müll (`local.properties`, `.gradle`,
  `ephemeral`) lebt in `android/.gitignore` und `ios/.gitignore`, nicht in
  der Wurzel-Datei — Deckung per `git check-ignore` bewiesen

---

## 3. Entscheidungen (ADR-Kandidaten)

| Code | Entscheidung | Kernbegründung |
|---|---|---|
| **E-0-1** | Harness-Portierung: `AGENTS.md` + `docs/rules/` + eigenständige Skripte statt `.claude/`-Mechanik | Kimi Code liest `AGENTS.md`; Hooks/Berechtigungen leben in der Werkzeug-Konfiguration außerhalb des Repos (ADR-Kandidat) |
| **E-0-2** | Öffentliches Repo direkt in ADR-001 mitbegründet | macOS-Minuten bei privaten Repos verzehnfacht; mobile App ist ohnehin dekompilierbar |
| **E-0-3** | Schutzskripte harness-unabhängig (manuell/hookfähig) | Die Muster-Hooks lesen Claude-spezifisches Harness-JSON |
| **E-1-1** | `flutter create`-Rohstand als eigener Commit vor jeder Änderung | Generierte Baseline und eigene Änderungen bleiben getrennt reviewbar |
| **E-1-2** | Nur `android` + `ios` als Plattformen | Zielplattform-Entscheidung der Ownerin; Web/Desktop bewusst ausgeschlossen |

---

## 4. Offene Punkte

**Aus dieser Sitzung**

- `flutter doctor --android-licenses` ist noch nicht gelaufen (Ownerin,
  interaktiv) — blockiert Emulator-Start und jeden Android-Build
- `lib/main.dart` ist noch die Zähler-Vorlage; `test/widget_test.dart`
  prüft die Vorlage; Schichten `lib/{domain,application,infrastructure,presentation}`
  fehlen; Architekturtest und erster eigener Test fehlen
- `cupertino_icons` ist eine ungenutzte Template-Abhängigkeit: transitive
  Last ohne Nutzen — Entfernung in Sitzung 2 (Änderung an `pubspec.yaml`,
  Lieferketten-Regeln beachten)
- `pubspec.yaml` enthält Template-Kommentare und die Beschreibung
  „A new Flutter project."
- `pub get` meldet 9 Pakete mit neueren Versionen außerhalb der Constraints —
  nur Information; Dependabot übernimmt ab Phase 2
- Dieser Bericht war beim Schreiben noch nicht committet

**Bekannte Grenzen**

- `main` ist noch ungeschützt (Ruleset erst in Phase 3); Bootstrap-Commits
  gehen bis dahin direkt auf `main`
- Die Schutzskripte laufen vorerst nur manuell; eine Hook-Verdrahtung in der
  Kimi-Konfiguration liegt außerhalb des Repos und ist ein eigener Schritt

---

## 5. Phasen-Status und Gates

Phase 0: abgeschlossen. Phase 1: läuft — Scaffold steht und ist grün;
Schichten, eigene Tests und der Emulator-Nachweis fehlen.

| Thema (aus AGENTS.md Abschnitt 8) | Status |
|---|---|
| State-Management-Bibliothek | Nicht ausgelöst |
| Sicherer Token-Speicher | Nicht ausgelöst (kommt frühestens Phase 5) |
| Certificate Pinning, Resilienz, iOS-/Store-Verteilung | Nicht ausgelöst |

---

## 6. Technische Referenz (für Folgesitzungen)

```
Flutter 3.38.3 (stable) / Dart 3.10.1 · Android SDK 36 (Lizenzen offen)
Docker 29.8.2 · gh angemeldet als xXxCoder999xXx
Signatur: SSH ED25519, commit.gpgsign=true (global)
```

Qualitätskette (Reihenfolge ist Urteils-Hierarchie):

```
flutter pub get --enforce-lockfile
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-warnings
flutter test
```

Skripte (nach `git add` bzw. vor dem Commit):

```
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/Protect-Secrets.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/Test-CommitConvention.ps1 -Message "<betreff>"
```

Musterprojekt `C:\Projects\xXxCoder999xXx\identity-service` bleibt für uns
read-only.

---

## 7. Roadmap Sitzung 2

1. **Zuerst (Ownerin):** `flutter doctor --android-licenses` durchlaufen
   lassen; danach App im Emulator starten — grün ist nicht funktionierend,
   der echte Start ist der Beweis
2. Schichtenstruktur anlegen (`domain`, `application`, `infrastructure`,
   `presentation`), minimale App (ein Screen), `main.dart` als reine
   Composition Root
3. Erster eigener Unit-Test und der Architekturtest (Quelltext-Scan der
   Dependency Rule) — mit **Rot-Beweis** durch absichtlichen Schichtverstoß
4. `pubspec.yaml` aufräumen: Beschreibung, Template-Kommentare,
   `cupertino_icons` entfernen (Begründung: ungenutzte Abhängigkeit)
5. Qualitätskette komplett, Phase-1-Abschluss-Commit
6. Danach **Konzept vor erster Datei** für Phase 2: Schrittfolge `ci.yml`,
   Auflösung des Flutter-Commit-SHA per `git ls-remote`, Dependabot-
   Ökosysteme `pub` + `github-actions`
