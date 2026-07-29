param(
    [string]$Source = "",
    [string]$Output = "",
    [string]$PreviewPdf = ""
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = Split-Path -Parent $scriptDir
if (-not $Source) {
    $Source = Join-Path $root "paper\manuscript.md"
}
if (-not $Output) {
    $Output = Join-Path $root "paper\submission\F1000Research_Software_Tool_Article_v1.1.0.docx"
}
if (-not $PreviewPdf) {
    $PreviewPdf = Join-Path $root "generated\F1000Research_Software_Tool_Article_v1.1.0-preview.pdf"
}

$Source = [System.IO.Path]::GetFullPath($Source)
$Output = [System.IO.Path]::GetFullPath($Output)
$PreviewPdf = [System.IO.Path]::GetFullPath($PreviewPdf)

if (-not (Test-Path -LiteralPath $Source -PathType Leaf)) {
    throw "Manuscript source not found: $Source"
}

New-Item -ItemType Directory -Path (Split-Path -Parent $Output) -Force | Out-Null
New-Item -ItemType Directory -Path (Split-Path -Parent $PreviewPdf) -Force | Out-Null

function Convert-InlineMarkdown {
    param([string]$Text)
    $clean = $Text -replace '\*\*', ''
    $clean = $clean -replace '(?<!\*)\*(?!\*)', ''
    $clean = $clean -replace '`', ''
    return $clean.Trim()
}

function Split-PipeRow {
    param([string]$Line)
    $trimmed = $Line.Trim()
    if ($trimmed.StartsWith("|")) {
        $trimmed = $trimmed.Substring(1)
    }
    if ($trimmed.EndsWith("|")) {
        $trimmed = $trimmed.Substring(0, $trimmed.Length - 1)
    }
    return @($trimmed.Split("|") | ForEach-Object { Convert-InlineMarkdown $_ })
}

function Add-Paragraph {
    param(
        $Document,
        [string]$Text,
        $Style,
        [int]$Alignment = 0,
        [double]$LeftIndent = 0,
        [double]$FirstLineIndent = 0,
        [switch]$KeepWithNext
    )
    $range = $Document.Content
    $range.Collapse(0)
    $range.Text = $Text
    $range.Style = $Style
    $range.ParagraphFormat.Alignment = $Alignment
    $range.ParagraphFormat.LeftIndent = $LeftIndent
    $range.ParagraphFormat.FirstLineIndent = $FirstLineIndent
    if ($KeepWithNext) {
        $range.ParagraphFormat.KeepWithNext = -1
    }
    $range.InsertParagraphAfter()
    return $range
}

function Add-WordTable {
    param(
        $Document,
        [object[]]$Rows
    )
    if ($Rows.Count -lt 2) {
        return
    }
    $header = [string[]](Split-PipeRow $Rows[0])
    $allRows = New-Object System.Collections.Generic.List[object]
    $allRows.Add([object]$header)
    for ($i = 2; $i -lt $Rows.Count; $i++) {
        $row = [string[]](Split-PipeRow $Rows[$i])
        $allRows.Add([object]$row)
    }
    $columnCount = $header.Count
    $range = $Document.Content
    $range.Collapse(0)
    $table = $Document.Tables.Add($range, $allRows.Count, $columnCount)
    $table.Style = "Table Grid"
    $table.AllowAutoFit = $true
    $table.Rows.Item(1).HeadingFormat = -1
    $table.Rows.Item(1).Range.Font.Bold = -1
    $table.Rows.Item(1).Range.Font.Color = 16777215
    $table.Rows.Item(1).Shading.BackgroundPatternColor = 7419530
    $table.Range.Font.Name = "Arial"
    $table.Range.Font.Size = 9
    $table.Range.ParagraphFormat.SpaceAfter = 0
    $table.Range.ParagraphFormat.LineSpacingRule = 0
    $table.Range.Cells.VerticalAlignment = 1

    for ($r = 0; $r -lt $allRows.Count; $r++) {
        $cells = @($allRows[$r])
        for ($c = 0; $c -lt $columnCount; $c++) {
            $value = if ($c -lt $cells.Count) { [string]$cells[$c] } else { "" }
            $table.Cell($r + 1, $c + 1).Range.Text = $value
        }
        $table.Rows.Item($r + 1).AllowBreakAcrossPages = 0
        if ($r -gt 0 -and ($r % 2 -eq 0)) {
            $table.Rows.Item($r + 1).Shading.BackgroundPatternColor = 15921906
        }
    }
    $table.Range.InsertParagraphAfter()
}

$word = $null
$document = $null
try {
    $word = New-Object -ComObject Word.Application
    $word.Visible = $false
    $word.DisplayAlerts = 0
    $document = $word.Documents.Add()

    # Formal narrative-proposal preset adapted to an F1000Research manuscript:
    # restrained typography, clear hierarchy, no decorative cover, editable tables.
    $section = $document.Sections.Item(1)
    $section.PageSetup.PaperSize = 7
    $section.PageSetup.TopMargin = 72
    $section.PageSetup.BottomMargin = 72
    $section.PageSetup.LeftMargin = 72
    $section.PageSetup.RightMargin = 72

    $normal = $document.Styles.Item(-1)
    $normal.Font.Name = "Arial"
    $normal.Font.Size = 11
    $normal.Font.Color = 0
    $normal.ParagraphFormat.SpaceAfter = 6
    $normal.ParagraphFormat.LineSpacingRule = 5
    $normal.ParagraphFormat.LineSpacing = 13.8
    $normal.ParagraphFormat.WidowControl = -1

    $titleStyle = $document.Styles.Item(-63)
    $titleStyle.Font.Name = "Arial"
    $titleStyle.Font.Size = 17
    $titleStyle.Font.Bold = -1
    $titleStyle.Font.Color = 4797253
    $titleStyle.ParagraphFormat.SpaceAfter = 12
    $titleStyle.ParagraphFormat.KeepWithNext = -1

    $heading1 = $document.Styles.Item(-2)
    $heading1.Font.Name = "Arial"
    $heading1.Font.Size = 14
    $heading1.Font.Bold = -1
    $heading1.Font.Color = 4797253
    $heading1.ParagraphFormat.SpaceBefore = 12
    $heading1.ParagraphFormat.SpaceAfter = 5
    $heading1.ParagraphFormat.KeepWithNext = -1

    $heading2 = $document.Styles.Item(-3)
    $heading2.Font.Name = "Arial"
    $heading2.Font.Size = 12
    $heading2.Font.Bold = -1
    $heading2.Font.Color = 4797253
    $heading2.ParagraphFormat.SpaceBefore = 9
    $heading2.ParagraphFormat.SpaceAfter = 4
    $heading2.ParagraphFormat.KeepWithNext = -1

    $heading3 = $document.Styles.Item(-4)
    $heading3.Font.Name = "Arial"
    $heading3.Font.Size = 11
    $heading3.Font.Bold = -1
    $heading3.Font.Italic = -1
    $heading3.Font.Color = 4797253
    $heading3.ParagraphFormat.SpaceBefore = 7
    $heading3.ParagraphFormat.SpaceAfter = 3
    $heading3.ParagraphFormat.KeepWithNext = -1

    try {
        $codeStyle = $document.Styles.Item("Manuscript Code")
    } catch {
        $codeStyle = $document.Styles.Add("Manuscript Code", 1)
    }
    $codeStyle.Font.Name = "Consolas"
    $codeStyle.Font.Size = 9
    $codeStyle.ParagraphFormat.LeftIndent = 18
    $codeStyle.ParagraphFormat.RightIndent = 18
    $codeStyle.ParagraphFormat.SpaceBefore = 3
    $codeStyle.ParagraphFormat.SpaceAfter = 3
    $codeStyle.ParagraphFormat.KeepTogether = -1
    $codeStyle.Shading.BackgroundPatternColor = 15921906

    $header = $section.Headers.Item(1).Range
    $header.Text = "F1000Research Software Tool Article"
    $header.Font.Name = "Arial"
    $header.Font.Size = 8
    $header.Font.Color = 10066329
    $header.ParagraphFormat.Alignment = 2

    $footer = $section.Footers.Item(1).Range
    $footer.ParagraphFormat.Alignment = 1
    $footer.Font.Name = "Arial"
    $footer.Font.Size = 9
    $footer.Fields.Add($footer, 33) | Out-Null

    $metadata = @{
        Title = "An R pipeline for district-level environmental layers and provenance labelling: a Rwanda proof of concept"
        Author = "Tuyishime Audre Prince"
        Subject = "F1000Research Software Tool Article"
        Keywords = "environmental data preparation; provenance; geospatial software; reproducibility; Rwanda"
    }
    foreach ($propertyName in $metadata.Keys) {
        try {
            $property = $document.BuiltInDocumentProperties.Item($propertyName)
            $property.Value = $metadata[$propertyName]
        } catch {
            # Some Word builds expose document properties through a late-bound
            # COM interface that PowerShell cannot assign directly.
        }
    }
    $document.RemovePersonalInformation = $true

    $lines = @(Get-Content -LiteralPath $Source -Encoding UTF8)
    $inCode = $false
    $codeLines = New-Object System.Collections.Generic.List[string]
    $tableLines = New-Object System.Collections.Generic.List[string]
    $frontMatter = $true

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = [string]$lines[$i]
        $trim = $line.Trim()

        if ($trim.StartsWith('```')) {
            if ($inCode) {
                Add-Paragraph $document ($codeLines -join [Environment]::NewLine) $codeStyle | Out-Null
                $codeLines.Clear()
                $inCode = $false
            } else {
                $inCode = $true
            }
            continue
        }
        if ($inCode) {
            $codeLines.Add($line)
            continue
        }

        if ($trim.StartsWith("|")) {
            $tableLines.Add($line)
            $nextIsTable = ($i + 1 -lt $lines.Count) -and $lines[$i + 1].Trim().StartsWith("|")
            if (-not $nextIsTable) {
                Add-WordTable $document @($tableLines)
                $tableLines.Clear()
            }
            continue
        }

        if (-not $trim) {
            continue
        }

        if ($trim.StartsWith("# ")) {
            Add-Paragraph $document (Convert-InlineMarkdown $trim.Substring(2)) $titleStyle 1 -KeepWithNext | Out-Null
            continue
        }
        if ($trim.StartsWith("## ")) {
            $headingText = Convert-InlineMarkdown $trim.Substring(3)
            if ($headingText -eq "Tables") {
                # F1000Research requires editable tables at the end, but a
                # separate "Tables" heading is unnecessary and can create an
                # otherwise blank page when the preceding references fill a page.
                continue
            }
            Add-Paragraph $document $headingText $heading1 0 -KeepWithNext | Out-Null
            $frontMatter = $false
            continue
        }
        if ($trim.StartsWith("### ")) {
            Add-Paragraph $document (Convert-InlineMarkdown $trim.Substring(4)) $heading2 0 -KeepWithNext | Out-Null
            continue
        }
        if ($trim.StartsWith("#### ")) {
            Add-Paragraph $document (Convert-InlineMarkdown $trim.Substring(5)) $heading3 0 -KeepWithNext | Out-Null
            continue
        }
        if ($trim -match '^[-*]\s+(.+)$') {
            Add-Paragraph $document ("• " + (Convert-InlineMarkdown $Matches[1])) $normal 0 18 -18 | Out-Null
            continue
        }
        if ($trim -match '^(\d+)\.\s+(.+)$') {
            Add-Paragraph $document ("$($Matches[1]). " + (Convert-InlineMarkdown $Matches[2])) $normal 0 18 -18 | Out-Null
            continue
        }

        $text = Convert-InlineMarkdown $trim
        if ($frontMatter) {
            $p = Add-Paragraph $document $text $normal 1
            if ($text -eq "Tuyishime Audre Prince") {
                $p.Font.Bold = -1
            }
            if ($text.StartsWith("Article type:")) {
                $p.Font.Italic = -1
                $p.ParagraphFormat.SpaceAfter = 12
            }
            continue
        }

        $paragraph = Add-Paragraph $document $text $normal
        if ($trim -match '^\*\*([^*]+):\*\*') {
            $label = "$($Matches[1]):"
            $find = $paragraph.Duplicate
            $find.End = $find.Start + $label.Length
            $find.Font.Bold = -1
        }
    }

    $document.Content.LanguageID = 2057
    $document.Content.NoProofing = 0
    $document.Repaginate()

    if (Test-Path -LiteralPath $Output) {
        Remove-Item -LiteralPath $Output -Force
    }
    if (Test-Path -LiteralPath $PreviewPdf) {
        Remove-Item -LiteralPath $PreviewPdf -Force
    }
    $document.SaveAs2($Output, 16)
    $document.ExportAsFixedFormat($PreviewPdf, 17)
    $pageCount = $document.ComputeStatistics(2)
    Write-Output "DOCX=$Output"
    Write-Output "PDF=$PreviewPdf"
    Write-Output "PAGES=$pageCount"
} finally {
    if ($null -ne $document) {
        $document.Close(0)
    }
    if ($null -ne $word) {
        $word.Quit()
    }
    if ($null -ne $document) {
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($document) | Out-Null
    }
    if ($null -ne $word) {
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($word) | Out-Null
    }
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
}
