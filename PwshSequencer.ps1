#Requires -Version 7
param(
    [int] $Bars = 4,
    [int] $Beats = 4,
    [int] $Tempo = 180
)

Import-Module PSAudio

# Haha wtf is this mess
$steps = $Bars * ($Beats)
$topBorder = "$([char]0x2582)$([char]0x2582)$([char]0x2582)$([char]0x2582)$([char]0x2582)$([char]0x2582)"
$bottomBorder = "$([char]0x2594)$([char]0x2594)$([char]0x2594)$([char]0x2594)$([char]0x2594)$([char]0x2594)"
$sounds = (Join-Path (Get-Module PSAudio).Path "../audio" | Get-ChildItem -Filter "*.wav" | Select-Object -ExpandProperty Name) -replace "\.wav$", ""
$maxSoundNameLength = ($sounds | Measure-Object -Property Length -Maximum).Maximum
$soundMatrix = @()
$sounds | ForEach-Object { $soundMatrix += ,(@($false) * $steps) }
$rows = $sounds | ForEach-Object {
    $row = $_.PadLeft($maxSoundNameLength + 1) + " |" + ("      " * $steps)
    $row = $row -replace ".$", "|"
    return $row
}
$topBorderString = " " * ($maxSoundNameLength + 2) + ($topBorder * $steps + [char]0x2582)
$bottomBorderString = " " * ($maxSoundNameLength + 2) + ($bottomBorder * $steps + [char]0x2594)
$inputsEvaluatedPerBeat = 3
$inputPauseToMeetBpm = (4 / $Beats * 60 / $Tempo * 1000) / $inputsEvaluatedPerBeat
$background =       "`nPowered by PSAudio - $Bars bars of $Beats beats @ $Tempo BPM`n`n$topBorderString`n$($rows -join "`n")`n$bottomBorderString"
$backgroundBarLines = ("|     " * $steps)
$soundMatrixLocation = @{ Step = 0; Sound = 0 }
$title = @"
  _____           _   _____                                 
 |  _  |_ _ _ ___| |_|   __|___ ___ _ _ ___ ___ ___ ___ ___ 
 |   __| | | |_ -|   |__   | -_| . | | | -_|   |  _| -_|  _|
 |__|  |_____|___|_|_|_____|___|_  |___|___|_|_|___|___|_|  
                                 |_|
"@
$titleHeight = 5

function Clear-PreviousInputPosition($matrix, $titleHeight) {
    [Console]::SetCursorPosition($maxSoundNameLength + 3 + (6 * $matrix.Step), $matrix.Sound + 4 + $titleHeight)
    Write-Host "     "
}

function Get-LastKeyPressed {
    if([Console]::KeyAvailable) {
        $key = $null
        while([Console]::KeyAvailable) {
            $key = [Console]::ReadKey($true)
        }
        return $key
    } else {
        return $null
    }
}

try {
    Clear-Host
    [Console]::CursorVisible = $false

    Write-Host -ForegroundColor DarkCyan $title
    while($true) {
        [Console]::SetCursorPosition(0, $titleHeight)
        Write-Host $background
        for($sound = 0; $sound -lt $sounds.Count; $sound++) {
            [Console]::SetCursorPosition($maxSoundNameLength + 2, $titleHeight + 4 + $sound)
            Write-Host -ForegroundColor DarkGray $backgroundBarLines
            for($bar = 0; $bar -lt $Bars; $bar++) {
                [Console]::SetCursorPosition($maxSoundNameLength + 2 + ($bar * 6 * $Beats), $titleHeight + 4 + $sound)
                Write-Host "|"
            }
        }
        
        for($step = 0; $step -lt $steps; $step++) {
            # make sound happen
            for($sound = 0; $sound -lt $sounds.Count; $sound++) {
                if($soundMatrix[$sound][$step]) {
                    Start-Sound $sounds[$sound]
                }
            }

            # check for input and move the cursor
            $cursorColor = "DarkGray"
            for($inputLoop = 0; $inputLoop -lt $inputsEvaluatedPerBeat; $inputLoop++) {
                $lastKeyPressed = Get-LastKeyPressed
                if($lastKeyPressed) {
                    switch($lastKeyPressed.Key) {
                        "UpArrow" {
                            Clear-PreviousInputPosition $soundMatrixLocation $titleHeight
                            $soundMatrixLocation.Sound = if($soundMatrixLocation.Sound - 1 -lt 0) { $sounds.Count - 1 } else { $soundMatrixLocation.Sound - 1 }
                        }
                        "DownArrow" {
                            Clear-PreviousInputPosition $soundMatrixLocation $titleHeight
                            $soundMatrixLocation.Sound = ($soundMatrixLocation.Sound + 1) % $sounds.Count
                        }
                        "LeftArrow" {
                            Clear-PreviousInputPosition $soundMatrixLocation $titleHeight
                            $soundMatrixLocation.Step = if($soundMatrixLocation.Step - 1 -lt 0) { $steps - 1 } else { $soundMatrixLocation.Step - 1 }
                        }
                        "RightArrow" {
                            Clear-PreviousInputPosition $soundMatrixLocation $titleHeight
                            $soundMatrixLocation.Step = ($soundMatrixLocation.Step + 1) % $steps
                        }
                        "Spacebar" {
                            $soundMatrix[$soundMatrixLocation.Sound][$soundMatrixLocation.Step] = !$soundMatrix[$soundMatrixLocation.Sound][$soundMatrixLocation.Step]
                        }
                    }
                }

                # mark the currently selected sounds
                for($sound = 0; $sound -lt $sounds.Count; $sound++) {
                    for($innerStep = 0; $innerStep -lt $steps; $innerStep++) {
                        if($soundMatrix[$sound][$innerStep]) {
                            [Console]::SetCursorPosition($maxSoundNameLength + 3 + (6 * [Math]::Max(($innerStep), 0)), $sound + 4 + $titleHeight)
                            Write-Host -ForegroundColor Black -BackgroundColor "DarkCyan" "     "
                        }
                    }
                }

                # mark the current cursor position
                [Console]::SetCursorPosition($maxSoundNameLength + 3 + (6 * $soundMatrixLocation.Step), $soundMatrixLocation.Sound + 4 + $titleHeight)
                $cursorColor = if($soundMatrix[$soundMatrixLocation.Sound][$soundMatrixLocation.Step]) { "Cyan" } else { "DarkGray" }
                Write-Host -BackgroundColor $cursorColor "     "

                # mark the current scrubber position
                [Console]::SetCursorPosition($maxSoundNameLength + 2 + (6 * [Math]::Max(($step - 1), 0)), 3 + $titleHeight)
                Write-Host -ForegroundColor DarkGreen $topBorder
                [Console]::SetCursorPosition($maxSoundNameLength + 2 + (6 * $step), 3 + $titleHeight)
                Write-Host -ForegroundColor Black -BackgroundColor Green "   $([char]0x25B6)   "
                
                Start-Sleep -Milliseconds $inputPauseToMeetBpm
            }

            Write-Host ""
        }
    }
} finally {
    [Console]::CursorVisible = $true
}