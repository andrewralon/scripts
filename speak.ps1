param
(
    [string] $phrase
)

Add-Type -AssemblyName System.Speech

do {
    while (!$phrase) {
        $phrase = Read-Host #-Prompt 'Phrase to speak:'
    }

    #Write-Host $phrase
    (New-Object System.Speech.Synthesis.SpeechSynthesizer).Speak($phrase)

    $phrase = $null
}
while ($true) 
