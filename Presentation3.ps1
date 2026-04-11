param(
    [Parameter(Mandatory = $false)]
    [string]$FilePath = "slides_PS.md",

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

# 罫線文字を判定する関数
function Test-BoxChar {
    param([string]$line)
    # 罫線・ボックス描画文字を含むかチェック
    foreach ($c in $line.ToCharArray()) {
        $code = [int]$c
        # Box Drawing (U+2500-U+257F), Block Elements (U+2580-U+259F)
        if (($code -ge 0x2500 -and $code -le 0x257F) -or
            ($code -ge 0x2580 -and $code -le 0x259F) -or
            ($code -ge 0x2550 -and $code -le 0x256C)) {
            return $true
        }
    }
    return $false
}

function Show-Slide {
    param(
        [string]$text,
        [int]$speed
    )

    Clear-Host

    # ヘッダー
    $slideNum = $script:currentSlide + 1
    $filled = "=" * $slideNum
    $empty = "-" * ($script:totalSlides - $slideNum)
    $progressBar = "[${filled}${empty}]"

    Write-Host ""
    Write-Host "  +---------------------------------------------+" -ForegroundColor DarkCyan
    Write-Host "  |  Slide $slideNum / $script:totalSlides   $progressBar  |" -ForegroundColor DarkCyan
    Write-Host "  +---------------------------------------------+" -ForegroundColor DarkCyan
    $navText = "    <- Prev  |  Next ->  |  Q: Quit"
    Write-Host $navText -ForegroundColor DarkGray
    Write-Host ""

    $lines = $text -split "`r?`n"

    foreach ($line in $lines) {
        if ($line -match "^#\s+(.*)") {
            # 見出し1（タイトル）
            $title = $matches[1]
            Write-Host "  $title" -ForegroundColor Cyan
        }
        elseif ($line -match "^##\s+(.*)") {
            # 見出し2（サブタイトル）
            Write-Host ""
            $subtitle = $matches[1]
            Write-Host "  $subtitle" -ForegroundColor Yellow
            Write-Host ""
        }
        elseif ($line -match "^    -\s+(.*)") {
            # インデントされた箇条書き（サブ項目）
            $subitem = $matches[1]
            Write-Host "       -> $subitem" -ForegroundColor DarkGray
        }
        elseif ($line -match "^-\s+(.*)") {
            # 箇条書き
            $item = $matches[1]
            Write-Host "    * $item" -ForegroundColor Gray
        }
        elseif ($line -match "^\s*(.+)") {
            $content = $matches[1]
            if ($content.StartsWith([string][char]0x2605)) {
                # デモ行（★マーク U+2605）
                Write-Host ""
                Write-Host "    $content" -ForegroundColor Green
            }
            elseif (Test-BoxChar $line) {
                # 罫線・ボックス文字を含む行
                Write-Host "  $line" -ForegroundColor DarkCyan
            }
            else {
                # その他の行
                Write-Host "  $line"
            }
        }
        else {
            Write-Host $line
        }
    }

    # フッター
    Write-Host ""
    Write-Host "  ---------------------------------------------" -ForegroundColor DarkGray
}

# メインループ
while ($true) {
    Show-Slide -text $slides[$currentSlide] -speed $TypingSpeed

    # キー入力待機
    $keyInfo = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

    switch ($keyInfo.VirtualKeyCode) {
        39 {
            # RightArrow
            if ($currentSlide -lt ($totalSlides - 1)) { $currentSlide++ }
        }
        32 {
            # Spacebar
            if ($currentSlide -lt ($totalSlides - 1)) { $currentSlide++ }
        }
        13 {
            # Enter
            if ($currentSlide -lt ($totalSlides - 1)) { $currentSlide++ }
        }
        37 {
            # LeftArrow
            if ($currentSlide -gt 0) { $currentSlide-- }
        }
        8 {
            # Backspace
            if ($currentSlide -gt 0) { $currentSlide-- }
        }
        27 {
            # Escape
            Clear-Host
            Write-Host "Presentation ended." -ForegroundColor DarkGray
            exit
        }
        default {
            if ($keyInfo.Character -eq 'q' -or $keyInfo.Character -eq 'Q') {
                Clear-Host
                Write-Host "Presentation ended." -ForegroundColor DarkGray
                exit
            }
        }
    }
}
