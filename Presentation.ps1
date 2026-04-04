param (
    [Parameter(Mandatory=$false)]
    [string]$FilePath = "slides.md",

    [Parameter(Mandatory=$false)]
    [int]$TypingSpeed = 20
)

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
    param (
        [string]$text,
        [int]$speed
    )
    Clear-Host
    
    $skipTyping = $false
    $lines = $text -split "`r?`n"
    
    foreach ($line in $lines) {
        if ($line -match "^#\s+(.*)") {
            Write-Host ">>> " -ForegroundColor Cyan -NoNewline
            Write-Host $matches[1] -ForegroundColor Cyan -Bold
        }
        elseif ($line -match "^##\s+(.*)") {
            Write-Host ">> " -ForegroundColor Yellow -NoNewline
            Write-Host $matches[1] -ForegroundColor Yellow
        }
        elseif ($line -match "^-\s+(.*)") {
            Write-Host "  * " -ForegroundColor Gray -NoNewline
            Write-Host $matches[1]
        }
        else {
            foreach ($char in $line.ToCharArray()) {
                Write-Host $char -NoNewline
                if (-not $skipTyping -and $speed -gt 0) {
                    Start-Sleep -Milliseconds $speed
                    if ([Console]::KeyAvailable) {
                        $skipTyping = $true
                        # 入力バッファをクリアせず、フラグだけ立てる
                    }
                }
            }
            Write-Host ""
        }
    }
    
    # 表示が終わった後にキーバッファをクリア（演出スキップ用の入力を捨てる）
    while ([Console]::KeyAvailable) { [Console]::ReadKey($true) | Out-Null }

    Write-Host "`n--- [ Slide $($script:currentSlide + 1) / $totalSlides ] ---" -ForegroundColor DarkGray
    Write-Host "(Right: Next, Left: Prev, Q: Quit)" -ForegroundColor DarkGray
}

# メインループ
while ($true) {
    Show-Slide -text $slides[$currentSlide] -speed $TypingSpeed
    
    # キー入力待機
    $key = [Console]::ReadKey($true)
    
    switch ($key.Key) {
        "RightArrow" {
            if ($currentSlide -lt ($totalSlides - 1)) {
                $currentSlide++
            }
        }
        "Spacebar" {
            if ($currentSlide -lt ($totalSlides - 1)) {
                $currentSlide++
            }
        }
        "Enter" {
            if ($currentSlide -lt ($totalSlides - 1)) {
                $currentSlide++
            }
        }
        "LeftArrow" {
            if ($currentSlide -gt 0) {
                $currentSlide--
            }
        }
        "Backspace" {
            if ($currentSlide -gt 0) {
                $currentSlide--
            }
        }
        "Q" {
            Clear-Host
            Write-Host "Presentation ended."
            exit
        }
        "Escape" {
            Clear-Host
            Write-Host "Presentation ended."
            exit
        }
    }
    
    # ページ遷移時はタイピングスピードを0にして即時表示するか、再度アニメーションするか
    # ここでは再度アニメーションするようにしていますが、一度表示したページは即時出すように
    # 改善することも可能です。
}
