<#
.SYNOPSIS
    Prueft Branch und Commit-Betreff gegen die Git-Regeln (AGENTS.md Abschnitt 4).

.DESCRIPTION
    Zwei Pruefungen:
      1. Kein Commit auf main - Integration nur ueber Feature-Branches
         (gilt ab Phase 3, sobald Branch Protection steht).
      2. Der Betreff folgt Conventional Commits: <type>(<scope>): <subject>
         mit type aus feat|fix|docs|chore|refactor|test|build|ci|perf|style|revert,
         Gross-/Kleinschreibung beachtet, kein Punkt am Ende.

    Das Betreff-Muster steht wortgleich auch in .github/workflows/pr-title.yml
    (kommt in Phase 2). Wer es aendert, aendert alle Stellen.

    Aufruf:
      ./scripts/Test-CommitConvention.ps1 -Message "feat: add login screen"
      ./scripts/Test-CommitConvention.ps1            # prueft HEAD-Betreff

    Ausgabe:  Exit 0 = regelkonform, Exit 2 = blockiert (Grund auf stderr).
    Fail closed: Kann die Pruefung nicht laufen, wird blockiert.
#>
[CmdletBinding()]
param(
    [string] $Message
)

$ErrorActionPreference = 'Stop'

$betreffMuster = '^(feat|fix|docs|chore|refactor|test|build|ci|perf|style|revert)(\([^)]+\))?!?: .'

try {
    # Pruefung 1: Kein Commit auf main.
    # "branch --show-current" funktioniert auch ohne ersten Commit und liefert
    # bei losgeloestem HEAD einen leeren Namen (dann greift nur Pruefung 2).
    $branch = & git branch --show-current 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw 'Aktueller Branch konnte nicht ermittelt werden.'
    }
    if ($branch -eq 'main') {
        [Console]::Error.WriteLine('Test-CommitConvention: blockiert - Commit auf main. Erst einen Feature-Branch <type>/<kebab-case> anlegen.')
        exit 2
    }

    # Betreff bestimmen: Parameter oder Betreff des letzten Commits.
    $betreff = $Message
    if ([string]::IsNullOrWhiteSpace($betreff)) {
        $betreff = & git log -1 --pretty=%s 2>$null
        if ($LASTEXITCODE -ne 0) {
            throw 'Betreff des letzten Commits konnte nicht gelesen werden.'
        }
    }

    if ([string]::IsNullOrWhiteSpace($betreff)) {
        [Console]::Error.WriteLine('Test-CommitConvention: blockiert - kein Betreff. Erwartet: <type>(<scope>): <subject>.')
        exit 2
    }

    if ($betreff -cnotmatch $betreffMuster) {
        [Console]::Error.WriteLine("Test-CommitConvention: blockiert - Betreff ist kein Conventional Commit: '$betreff'. Erwartet: <type>(<scope>): <subject> mit type aus feat|fix|docs|chore|refactor|test|build|ci|perf|style|revert.")
        exit 2
    }

    if ($betreff.EndsWith('.')) {
        [Console]::Error.WriteLine('Test-CommitConvention: blockiert - der Betreff endet mit einem Punkt.')
        exit 2
    }

    Write-Output "Test-CommitConvention: ok - '$betreff'"
    exit 0
}
catch {
    [Console]::Error.WriteLine("Test-CommitConvention: Pruefung nicht moeglich, daher blockiert (fail closed). $($_.Exception.Message)")
    exit 2
}
