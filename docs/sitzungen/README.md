# Sitzungsberichte

Jede Arbeitssitzung endet mit einem Bericht `sitzung-NN.md` (fortlaufend,
zweistellig). Der **neueste** Bericht ist die verbindliche Statusquelle für
die nächste Sitzung: Was gilt als erledigt, was ist offen, wo geht es weiter.

Aufbau (wie im Musterprojekt):

1. **Erledigt** – was in dieser Sitzung abgeschlossen wurde, mit PR-/Commit-Bezug
2. **Gelernt** – Fallstricke und Erkenntnisse, die Zeit gekostet haben
3. **Entscheidungen (ADR-Kandidaten)** – mit Codes `E-<Schritt>-<n>`
4. **Offene Punkte** – aus dieser Sitzung, bekannte Grenzen, unverändert Altes
5. **Phasen-Status und Gates**
6. **Technische Referenz** – Pins, Befehle, Arbeitsteilung für Folgesitzungen
7. **Roadmap der Folgesitzung** – in verbindlicher Reihenfolge

Regeln:

- Berichte sind dauerhaft und werden nicht nachträglich umgeschrieben;
  Korrekturen stehen im Folgebericht.
- Dauerhaftes gehört nicht in Berichte: Entscheidungen in `docs/adr/`,
  Regeln in `AGENTS.md` und `docs/rules/`.
