# ADR-002: Flutter-MVVM mit Clean-Grenzen

- **Status:** Akzeptiert
- **Datum:** 2026-10-26

## Kontext

Der Walking Skeleton braucht eine prüfbare Architektur, bevor fachliche Breite
entsteht. Die ursprünglich festgelegten vier Pflichtschichten `domain`,
`application`, `infrastructure` und `presentation` würden bereits für statische
oder rein UI-bezogene Funktionen Ports, Adapter und Use Cases erzwingen. Dadurch
entstünden Weiterleitungsklassen ohne eigenen fachlichen Nutzen.

Die aktuellen offiziellen Flutter-Architekturleitfäden empfehlen MVVM mit Views
und ViewModels, Repositories und Services, unidirektionalem Datenfluss sowie
Dependency Injection. Eine Domain-Schicht mit Use Cases ist dort bedingt statt
grundsätzlich empfohlen: bei komplexer oder in mehreren ViewModels wiederholter
Fachlogik. Auch der Android-Architekturleitfaden warnt vor Use Cases, die simple
Datenzugriffe nur weiterreichen.

Quellen:

- https://docs.flutter.dev/app-architecture/guide
- https://docs.flutter.dev/app-architecture/recommendations
- https://docs.flutter.dev/app-architecture/case-study
- https://developer.android.com/topic/architecture
- https://developer.android.com/topic/architecture/domain-layer

## Entscheidung

Wir verwenden **Flutter-MVVM mit Clean-Grenzen und bedarfsgesteuerten Use
Cases**.

- `ui` enthält feature-orientierte Views und ViewModels. Views enthalten keine
  Fach- oder Datenzugriffslogik. ViewModels besitzen den UI-State und werden
  zunächst mit `ChangeNotifier` und `ListenableBuilder` umgesetzt.
- `domain` enthält bei Bedarf immutable, reine Dart-Modelle und abstrakte
  Repositories. Es kennt weder Flutter noch andere Schichten oder Drittpakete.
- `data` enthält bei Bedarf Repository-Implementierungen und Services für HTTP,
  Plattformzugriffe und Speicher. `ui` importiert niemals `data`.
- `application` wird erst eingeführt, wenn ein Use Case komplexe oder
  wiederholte Anwendungslogik kapselt. Es kennt dann ausschließlich `domain`.
- Abhängigkeiten werden per Konstruktor übergeben. `lib/main.dart` bleibt die
  einzige Composition Root. Ein DI-Paket wird erst bei nachweisbarem Bedarf
  geprüft.
- Der Quelltext-Architekturtest erzwingt diese Grenzen ohne zusätzliche
  Bibliothek. Daten und Ereignisse folgen dem unidirektionalen Datenfluss.

Verzeichnisse und Abstraktionen werden nicht vorbeugend ohne konkrete Aufgabe
angelegt.

## Betrachtete Alternativen

1. **Strikte Clean/Hexagonal-Architektur mit vier Pflichtschichten** – bietet
   sehr strenge Trennung, erzeugt aber in diesem eher dünnen Client früh
   Weiterleitungs-Use-Cases und Adapter ohne konkreten Bedarf.
2. **MVVM ohne verbindliche Dependency Rule** – entspricht oberflächlich dem
   Flutter-Leitfaden und spart Prüfcode, erlaubt aber direkte Zugriffe der UI
   auf technische Implementierungen und schwächt Testbarkeit und Austauschbarkeit.
3. **Riverpod oder Bloc als Ausgangspunkt** – kann State Management und
   Objektbeschaffung vereinfachen, ersetzt aber nicht die Schichtgrenzen und
   würde bereits jetzt zusätzliche Abhängigkeiten und Konzepte einführen.

## Begründung

Die Entscheidung übernimmt die von Flutter priorisierten Bausteine, ohne die
für dieses Projekt wichtigen Sicherheits- und Abhängigkeitsgrenzen aufzugeben.
Reine Modelle, abstrakte Repositories und Konstruktor-Injection bleiben
unabhängig von konkreten Technologien testbar. Gleichzeitig entsteht kein
Boilerplate für Funktionen ohne Datenzugriff oder Anwendungslogik.

Das unterstützt Open/Closed: Neue Datenquellen werden hinter Repository-
Schnittstellen ergänzt, ohne Views oder ViewModels an technische Details zu
koppeln. Das Verzichten auf nicht benötigte Pakete begrenzt die Lieferkette.
Die Entscheidung verändert keine Security-Gates und erlaubt keine Secrets oder
sensiblen Daten in UI, Logs oder Repository.

## Konsequenzen

- Views, ViewModels, Repositories und Services werden getrennt getestet;
  Architekturtests prüfen zusätzlich die Importrichtung.
- Ein ViewModel darf abstrakte Repositories, aber keine konkreten Services oder
  Repository-Implementierungen kennen.
- `AGENTS.md`, `README.md` und `docs/rules/architektur-und-tests.md` beschreiben
  dieselben Grenzen. Die ältere Vier-Schichten-Beschreibung wird ersetzt.
- Ein Use Case wird eingeführt, wenn nachweisbar komplexe Anwendungslogik,
  Wiederholung über mehrere ViewModels oder die Koordination mehrerer
  Repositories dies rechtfertigt. Eine reine Weiterleitung reicht nicht.
- Komplexeres State Management, ein DI-Container und separate API-Modelle
  bleiben eigene, bei Bedarf auszulösende Entscheidungen mit Prüfung und ADR.
