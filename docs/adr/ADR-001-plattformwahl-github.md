# ADR-001: GitHub als Entwicklungs- und Automatisierungsplattform

- **Status:** Akzeptiert
- **Datum:** 2026-10-08

## Kontext

Das Projekt verlangt vor der ersten Fachlogik ein vollständiges
Automatisierungsfundament: CI-Pipeline mit hart fehlschlagenden Checks,
geschützter Merge-Prozess, automatisierte Dependency-Updates, signierte
Release-Artefakte mit Herkunftsnachweis sowie einen Secret-Store außerhalb
des Repositories. Die Wahl der Plattform bestimmt die konkrete Mechanik all
dieser Pfeiler und ist daher die erste Architekturentscheidung.

Zusätzliche Anforderung gegenüber dem Musterprojekt: iOS kann lokal nicht
gebaut werden (Windows-Entwicklungsrechner). Die CI muss macOS-Runner
anbieten – bei privaten Repositories mit zehnfachem Minuten-Multiplikator,
bei öffentlichen kostenlos.

## Entscheidung

Wir verwenden **GitHub** (Repository, GitHub Actions als CI/CD,
Branch-Protection-Rulesets, Dependabot, GitHub Releases mit Artefakt-
Attestierungen, Actions-Secrets/Environments). Das Repository wird
**öffentlich** geführt.

## Betrachtete Alternativen

1. **GitLab** – CI und Dependency-Scanning in einer Anwendung. Dagegen
   sprach: relevante Security-Features hinter der Ultimate-Lizenz, macOS-
   Runner nur eingeschränkt, kleineres Ökosystem geprüfter Pipeline-Bausteine.
2. **Azure DevOps** – im Musterprojekt bereits verworfen; Microsofts
   Investitionsschwerpunkt liegt erkennbar auf GitHub.
3. **Privates GitHub-Repository** – würde die macOS-Minuten verzehnfachen
   und Secret Scanning/Push Protection kostenpflichtig machen; die
   Kompensationswerkzeuge wären neue Abhängigkeiten.

## Begründung

GitHub erfüllt jeden Punkt des Anforderungskatalogs mit Bordmitteln und folgt
damit dem Projektprinzip minimaler Abhängigkeiten: kein Zusatzdienst, kein
Fremd-Bot nötig. Die öffentliche Führung ist vertretbar, weil das Projekt
keine Geheimnisse im Repository führt und die Sicherheit nicht auf Unkenntnis
des Aufbaus beruht – wie ADR-004 des Musterprojekts ausgeführt hat. Für eine
mobile App gilt zusätzlich: Der ausgelieferte Client ist ohnehin öffentlich
dekompilierbar; der Quelltext gibt nichts preis, was die App nicht ohnehin
verrät.

## Konsequenzen

- **Supply-Chain-Härtung ist Pflicht:** Actions werden auf vollständige
  Commit-SHAs gepinnt, jeder Workflow deklariert einen restriktiven
  `permissions:`-Block, Secrets liegen ausschließlich in
  Actions-Secrets/Environments (tj-actions-Lektion, siehe Muster ADR-001).
- **Alles im Repository ist öffentlich und bleibt es:** Code, Historie,
  PRs, ADRs und Sitzungsberichte. Bei einem versehentlich eingecheckten
  Geheimnis wird zuerst rotiert, dann aufgeräumt.
- **Fremde können Pull Requests aus Forks öffnen:** `pull_request` statt
  `pull_request_target`, keine Secrets für Fork-PRs, minimale Rechte je Job,
  vom Einreicher kontrollierter Text nie in ein `run:`.
- **Verfügbar ist nicht eingeschaltet:** Secret Scanning, Push Protection
  und Dependabot-Alerts werden nach dem Anlegen per API geprüft – der Stand
  steht in keiner Datei und ist nach Einstellungsänderungen erneut zu prüfen
  (Lektion aus dem Muster: zwei Funktionen liefen dort drei Monate nicht).
- Dependabot wird aktiviert, sobald die CI existiert.
- Lock-in-Risiko akzeptiert: Git bleibt portabel; Workflow-YAML wäre bei
  einem Plattformwechsel zu übersetzen.
