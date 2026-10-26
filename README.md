# identity-client

Mobiler Client (Android, iOS) für den identity-service.
Das Projekt entsteht als vertikaler Durchstich: Automatisierungsfundament
(CI, geschützter Merge, Release-Pipeline) vor der ersten Fachlogik.

## Grundprinzipien

- Flutter-MVVM mit Clean-Grenzen nach ADR-002: Views und ViewModels in `ui`,
  reine Modelle und abstrakte Repositories in `domain`, technische Adapter in
  `data`; Use Cases in `application` nur bei nachweisbarem Bedarf.
- Open/Closed-Prinzip: neue Anforderungen durch Erweiterung, nicht Modifikation.
- Jede Warnung ist ein Fehlschlag (strenge `analysis_options.yaml`).
- Sicherheit durchgängig: keine Secrets im Repository, Least Privilege überall.
- Jede wesentliche Entscheidung ist als ADR dokumentiert: [`docs/adr/`](docs/adr/).

## Konventionen

- Commit-Nachrichten folgen [Conventional Commits](https://www.conventionalcommits.org/)
  (`feat:`, `fix:`, `chore:`, ...).
- Integration ausschließlich über kurzlebige Feature-Branches und Pull Requests
  (Branch Protection wird mit der CI-Pipeline aktiviert).

## Lokale Qualitätskette

Lokal == CI. Die Reihenfolge ist die Urteils-Hierarchie und bleibt:

```
flutter pub get --enforce-lockfile
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-warnings
flutter test
```
