<#
.SYNOPSIS
    Prueft die Buehne (git index) auf Dateien, die nie ins Repository gehoeren.

.DESCRIPTION
    Zwei Pruefungen (AGENTS.md Abschnitt 5):
      1. Verbotene Pfade und Namen: certs/, .env-Dateien, Signierschluessel
         (*.jks, *.keystore, *.p12, *.mobileprovision) und key.properties.
      2. Private-Schluessel-Muster im Inhalt der gestaffelten Dateien.

    Aufruf:
      ./scripts/Protect-Secrets.ps1

    Ausgabe:  Exit 0 = sauber, Exit 2 = blockiert (Grund auf stderr).

    Sicherheitsgrundsaetze:
      - Fail closed: Kann die Pruefung nicht laufen, wird blockiert.
      - Melden statt reparieren: Das Skript aendert nichts.
      - Es werden nie Dateiinhalte ausgegeben - nur Dateiname und Regel.
#>

$ErrorActionPreference = 'Stop'

try {
    $dateien = & git diff --cached --name-only --diff-filter=ACM 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw 'Buehne konnte nicht gelesen werden.'
    }

    $verbotenePfade = [ordered]@{
        'certs/ (lokale Zertifikate und private Schluessel)' = '(^|/)certs/'
        '.env-Dateien'                                       = '(^|/)\.env(\.|$)'
        'Signierschluessel'                                  = '(?i)\.(jks|keystore|p12|mobileprovision)$'
        'Android-Key-Passwoerter'                            = '(^|/)key\.properties$'
    }

    $blockiert = $false
    foreach ($datei in $dateien) {
        foreach ($eintrag in $verbotenePfade.GetEnumerator()) {
            if ($datei -match $eintrag.Value) {
                [Console]::Error.WriteLine("Protect-Secrets: blockiert - '$datei' gehoert zu $($eintrag.Key). AGENTS.md Abschnitt 5 verbietet das.")
                $blockiert = $true
            }
        }
    }

    # Private-Schluessel-Muster im Inhalt. Nur der Fundort wird gemeldet,
    # niemals die Zeile selbst.
    $schluesselMuster = '-----BEGIN [A-Z0-9 ]*PRIVATE KEY-----'
    foreach ($datei in $dateien) {
        if (-not (Test-Path $datei -PathType Leaf)) { continue }
        if (Select-String -Path $datei -Pattern $schluesselMuster -Quiet -ErrorAction SilentlyContinue) {
            [Console]::Error.WriteLine("Protect-Secrets: blockiert - '$datei' enthaelt einen privaten Schluessel.")
            $blockiert = $true
        }
    }

    if ($blockiert) {
        exit 2
    }

    Write-Output 'Protect-Secrets: ok - Buehne enthaelt keine verbotenen Dateien.'
    exit 0
}
catch {
    [Console]::Error.WriteLine("Protect-Secrets: Pruefung nicht moeglich, daher blockiert (fail closed). $($_.Exception.Message)")
    exit 2
}
