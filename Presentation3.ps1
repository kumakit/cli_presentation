param(
    [Parameter(Mandatory = $false)]
    [string]$FilePath = "slides.md",

    [Parameter(Mandatory = $false)]
    [int]$TypingSpeed = 20
)

$ErrorActionPreference = 'Stop'

# スライドの読み込み
if (-not (Test-Path $FilePath)) {
    Write-Error "File not found: $FilePath"
    exit
}

$content = Get-Content $FilePath -Raw -Encoding utf8
$slides = $content -split "(?m)^---`r?`n" | Where-Object { $_.Trim() -ne "" }

$currentSlide = 0
$totalSlides = $slides.Count

function Show-Slide {
    param(
        [string]$text,
        [int]$speed
    )

    Clear-Host
    
    # コントロール表示を上部に配置
    Write-Host "--- [ Slide $($script:currentSlide + 1) / $script:totalSlides ] ---" -ForegroundColor DarkGray
    Write-Host "(Right: Next, Left: Prev, Q: Quit)`n" -ForegroundColor DarkGray
    
    $lines = $text -split "`r?`n"
    
    foreach ($line in $lines) {
        if ($line -match "^#\s+(.*)") {
            # 見出し1
            Write-Host ">>> $($matches[1])" -ForegroundColor Cyan
        }
        elseif ($line -match "^##\s+(.*)") {
            # 見出し2
            Write-Host ">>  $($matches[1])" -ForegroundColor Yellow
        }
        elseif ($line -match "^\-\s+(.*)") {
            # 箇条書き
            Write-Host "  * $($matches[1])" -ForegroundColor Gray
        }
        else {
            # それ以外の行はそのまま表示
            Write-Host $line
        }
    }
}

# メインループ
while ($true) {
    Show-Slide -text $slides[$currentSlide] -speed $TypingSpeed
    
    # キー入力待機
    $keyInfo = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

    switch ($keyInfo.VirtualKeyCode) {
        39 {  # RightArrow
            if ($currentSlide -lt ($totalSlides - 1)) { $currentSlide++ }
        }
        32 {  # Spacebar
            if ($currentSlide -lt ($totalSlides - 1)) { $currentSlide++ }
        }
        13 {  # Enter
            if ($currentSlide -lt ($totalSlides - 1)) { $currentSlide++ }
        }
        37 {  # LeftArrow
            if ($currentSlide -gt 0) { $currentSlide-- }
        }
        8  {  # Backspace
            if ($currentSlide -gt 0) { $currentSlide-- }
        }
        27 {  # Escape
            Clear-Host
            Write-Host "Presentation ended."
            exit
        }
        default {
            if ($keyInfo.Character -eq 'q' -or $keyInfo.Character -eq 'Q') {
                Clear-Host
                Write-Host "Presentation ended."
                exit
            }
        }
    }
}
