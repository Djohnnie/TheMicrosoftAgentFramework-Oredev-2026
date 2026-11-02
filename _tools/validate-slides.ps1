$ErrorActionPreference = "Stop"

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$slideDirectory = Join-Path $repositoryRoot "_slides"
$resourceDirectory = Join-Path $repositoryRoot "_resources"
$slideNames = 1..17 | ForEach-Object { "slide-{0:D2}.svg" -f $_ }
$documentsToValidate = $slideNames + @("slide-template.svg")
$repositoryUrl = "https://github.com/Djohnnie/TheMicrosoftAgentFramework--redev-2026"

foreach ($slideName in $documentsToValidate) {
    $slidePath = Join-Path $slideDirectory $slideName
    if (-not (Test-Path -LiteralPath $slidePath -PathType Leaf)) {
        throw "Missing slide: $slidePath"
    }

    $document = [System.Xml.XmlDocument]::new()
    $document.XmlResolver = $null
    $document.Load($slidePath)

    $root = $document.DocumentElement
    if ($root.GetAttribute("viewBox") -ne "0 0 1920 1080") {
        throw "Unexpected canvas on $slideName; expected a 1920x1080 viewBox."
    }
    if (-not $document.SelectSingleNode("//*[local-name()='title']")) {
        throw "Missing accessible title in $slideName."
    }
    if (-not $document.SelectSingleNode("//*[local-name()='desc']")) {
        throw "Missing accessible description in $slideName."
    }
    $backgroundDots = $document.SelectSingleNode("//*[local-name()='pattern' and @id='background-dots' and @width='32' and @height='32']/*[local-name()='circle' and @r='1.5' and @fill-opacity='.14']")
    $dotOverlay = $document.SelectSingleNode("//*[local-name()='rect' and @width='1920' and @height='1080' and @fill='url(#background-dots)']")
    if (-not $backgroundDots -or -not $dotOverlay) {
        throw "Missing subtle full-canvas dot pattern in $slideName."
    }
    if ($slideName -ne "slide-01.svg") {
        $expectedHeader = switch ($slideName) {
            "slide-02.svg" { "&gt;&gt; THE SPEAKER"; break }
            "slide-03.svg" { "&gt;&gt; TAKE IT WITH YOU"; break }
            { $_ -in @("slide-04.svg", "slide-05.svg", "slide-06.svg", "slide-07.svg", "slide-08.svg") } { "&gt;&gt; THE EVOLUTION OF AI"; break }
            "slide-09.svg" { "&gt;&gt; LLM FUNDAMENTALS"; break }
            "slide-10.svg" { "&gt;&gt; EXAMPLE 01 / HANDS-ON"; break }
            { $_ -in @("slide-11.svg", "slide-12.svg", "slide-13.svg", "slide-14.svg", "slide-15.svg", "slide-16.svg") } { "&gt;&gt; THE AGENT FRAMEWORK"; break }
            "slide-17.svg" { "&gt;&gt; THANK YOU FOR JOINING"; break }
            "slide-template.svg" { "&gt;&gt; SECTION TITLE"; break }
            default { throw "Unexpected slide name: $slideName" }
        }
        $header = $document.SelectSingleNode("//*[local-name()='text' and @x='88' and @y='86' and @font-size='30' and @fill='#dbf536']")
        if (-not $header -or $header.InnerText -ne $expectedHeader.Replace("&gt;", ">")) {
            throw "Missing doubled, green section header in $slideName."
        }
        $headerPrefix = $header.SelectSingleNode("./*[local-name()='tspan' and @fill='#40f59f']")
        if (-not $headerPrefix -or $headerPrefix.InnerText -ne ">>") {
            throw "Missing Azure-green header prefix in $slideName."
        }
        $zureLogo = $document.SelectSingleNode("//*[local-name()='svg' and @x='1676' and @y='53' and @width='156' and @viewBox='0 0 98 25']")
        if (-not $zureLogo -or $zureLogo.SelectNodes(".//*[local-name()='path']").Count -lt 1) {
            throw "Missing copied Zure logo SVG in $slideName."
        }
    }
    $footerLogo = $document.SelectSingleNode("//*[local-name()='svg' and @x='850' and @y='1009.53' and @width='760' and @height='70.47']")
    if (-not $footerLogo -or $footerLogo.SelectNodes(".//*[local-name()='path']").Count -lt 1) {
        throw "Missing inline footer logo in $slideName."
    }
    if ($slideName -eq "slide-01.svg") {
        $oredevHeader = $document.SelectSingleNode("//*[local-name()='text' and normalize-space(.)='ØREDEV' and @font-size='51']")
        $locationHeader = $document.SelectSingleNode("//*[local-name()='text' and normalize-space(.)='MALMÖ · SWEDEN' and @font-size='18']")
        $conferenceHeader = $document.SelectSingleNode("//*[local-name()='text' and normalize-space(.)='DEVELOPER CONFERENCE' and @font-size='24']")
        $datesHeader = $document.SelectSingleNode("//*[local-name()='text' and normalize-space(.)='4–6 NOVEMBER 2026' and @font-size='19.5']")
        $zureLogo = $document.SelectSingleNode("//*[local-name()='svg' and @x='1676' and @y='84' and @width='156' and @viewBox='0 0 98 25' and @aria-label='Zure logo']")
        if ($zureLogo -and $zureLogo.SelectNodes(".//*[local-name()='path']").Count -lt 2) {
            $zureLogo = $null
        }
        $speakerName = $document.SelectSingleNode("//*[local-name()='text' and normalize-space(.)='Johnny Hooyberghs']")
        if (-not $oredevHeader -or -not $locationHeader -or -not $conferenceHeader -or -not $datesHeader -or -not $zureLogo -or -not $speakerName) {
            throw "Missing title-slide event branding, speaker name, or Zure logo."
        }
        if ($document.SelectSingleNode("//*[local-name()='line' and @x1='88' and @x2='1832' and @y1='980' and @y2='980']") -or
            $document.SelectSingleNode("//*[local-name()='a' and @href='$repositoryUrl']") -or
            $document.SelectSingleNode("//*[local-name()='text' and @x='1832' and @y='1054']")) {
            throw "Title slide should not include the standard footer divider, repository link, or slide number."
        }
        $applicationStack = $document.SelectSingleNode("//*[local-name()='g' and @aria-label='The application stack']")
        foreach ($provider in @("Microsoft Foundry", "OpenAI", "Ollama")) {
            if (-not $applicationStack.SelectSingleNode(".//*[local-name()='text' and normalize-space(.)='$provider']")) {
                throw "Missing $provider box in the title-slide application stack."
            }
        }
        foreach ($boxPosition in @("1311,222", "1627,354", "1627,622", "1311,755", "1182,622", "1132,354")) {
            $coordinates = $boxPosition.Split(",")
            if (-not $applicationStack.SelectSingleNode(".//*[local-name()='rect' and @x='$($coordinates[0])' and @y='$($coordinates[1])']")) {
                throw "Missing an evenly spaced application-stack box at $boxPosition."
            }
        }
        if (-not $applicationStack.SelectSingleNode(".//*[local-name()='rect' and @stroke='#dc8ea2']")) {
            throw "Missing the Oredev pink accent in the title-slide application stack."
        }
        if ($applicationStack.SelectSingleNode("./*[local-name()='circle' and @r='8']") -or
            $applicationStack.SelectSingleNode("./*[local-name()='path']") -or
            $applicationStack.SelectSingleNode("./*[local-name()='circle' and @stroke-dasharray]")) {
            throw "The title-slide application stack should not include decorative dots or curves."
        }
    } else {
        if (-not $document.SelectSingleNode("//*[local-name()='line' and @x1='88' and @x2='1832' and @y1='980' and @y2='980']")) {
            throw "Missing standard footer divider in $slideName."
        }
        $footerLink = $document.SelectNodes("//*[local-name()='a' and @href='$repositoryUrl']") |
            Where-Object { $_.InnerText -eq $repositoryUrl } |
            Select-Object -First 1
        if (-not $footerLink) {
            throw "Missing standard repository footer link in $slideName."
        }
        $pageNumber = $document.SelectSingleNode("//*[local-name()='text' and @x='1832' and @y='1054' and @fill='#dbf536']")
        $expectedPageNumber = if ($slideName -eq "slide-template.svg") { '^XX / 17$' } else { '^\d{2} / 17$' }
        if (-not $pageNumber -or $pageNumber.InnerText -notmatch $expectedPageNumber) {
            throw "Missing green slide number in the expected format in $slideName."
        }
    }
    if ($slideName -eq "slide-03.svg") {
        if (-not $document.SelectSingleNode("//*[local-name()='a' and @href='$repositoryUrl']")) {
            throw "Slide 3 is missing its repository link."
        }
        if ($document.SelectSingleNode("//*[local-name()='rect' and @x='1192' and @y='0' and @width='728' and @height='1080' and @fill='#dbf536']")) {
            throw "Slide 3 should not include the green panel behind the QR code."
        }
        $qrGroup = $document.SelectSingleNode("//*[local-name()='g' and @transform='translate(1167 195) scale(0.52734375)']")
        if (-not $qrGroup -or $qrGroup.SelectNodes("./*[local-name()='path']").Count -lt 400) {
            throw "Slide 3 is missing its inline repository QR artwork."
        }
        if ($qrGroup.SelectSingleNode(".//*[local-name()='image']")) {
            throw "Slide 3 should copy the QR SVG content instead of embedding it as an image."
        }
    }
    if ($slideName -eq "slide-17.svg") {
        foreach ($closingText in @("Questions?", "Thanks for being part of the conversation.", "What questions can I answer?")) {
            if (-not $document.SelectSingleNode("//*[local-name()='text' and normalize-space(.)='$closingText']")) {
                throw "Slide 17 is missing closing-slide text: $closingText"
            }
        }
        if ($document.SelectSingleNode("//*[local-name()='text' and normalize-space(.)='Thank you']") -or
            $document.SelectSingleNode("//*[local-name()='text' and normalize-space(.)='for joining']")) {
            throw "Slide 17 should keep the thank-you message in the header, not the title."
        }
        $questionTitle = $document.SelectSingleNode("//*[local-name()='text' and @x='88' and @y='432' and @class='display' and normalize-space(.)='Questions?']")
        if (-not $questionTitle) {
            throw "Slide 17 title should be Questions?."
        }
        $qrGroup = $document.SelectSingleNode("//*[local-name()='g' and @transform='translate(1167 195) scale(0.52734375)']")
        if (-not $qrGroup -or $qrGroup.SelectNodes("./*[local-name()='path']").Count -lt 400 -or $qrGroup.SelectSingleNode(".//*[local-name()='image']")) {
            throw "Slide 17 is missing its inline repository QR artwork."
        }
    }
    if ($slideName -in @("slide-04.svg", "slide-05.svg", "slide-06.svg", "slide-07.svg", "slide-08.svg")) {
        $stage = [int]$slideName.Substring(6, 2) - 4
        $evolutionCards = @("Rules-based", "Machine learning", "Deep learning", "Generative AI")
        for ($cardIndex = 0; $cardIndex -lt $evolutionCards.Count; $cardIndex++) {
            $card = $document.SelectSingleNode("//*[local-name()='g' and @aria-label='$($evolutionCards[$cardIndex])']")
            $shouldBeHidden = $stage -lt ($cardIndex + 1)
            if (-not $card -or (($card.GetAttribute("style") -eq "display:none") -ne $shouldBeHidden)) {
                throw "Slide $slideName has an unexpected reveal state for $($evolutionCards[$cardIndex])."
            }
        }
        $sourceLink = $document.SelectSingleNode("//*[local-name()='a' and @href='https://techcommunity.microsoft.com/blog/azure-ai-foundry-blog/testing-modern-ai-systems-from-rule-based-systems-to-deep-learning-and-large-lan/4429518']")
        if (-not $sourceLink -or $sourceLink.InnerText -ne "https://techcommunity.microsoft.com/blog/azure-ai-foundry-blog/testing-modern-ai-systems-from-rule-based-systems-to-deep-learning-and-large-lan/4429518") {
            throw "Slide $slideName is missing its Microsoft TechCommunity source link."
        }
        $approachNote = $document.SelectSingleNode("//*[local-name()='text' and normalize-space(.)='A shift in approach, not a strict hierarchy: deep learning is a type of machine learning, and generative AI often uses it.']")
        if (($slideName -eq "slide-08.svg") -ne [bool]$approachNote) {
            throw "The approach note should appear only on slide 8."
        }
    }
    if ($slideName -eq "slide-09.svg") {
        $sourceUrl = "https://learn.microsoft.com/en-us/agent-framework/journey/llm-fundamentals"
        $sourceLink = $document.SelectSingleNode("//*[local-name()='a' and @href='$sourceUrl']")
        if (-not $sourceLink -or $sourceLink.InnerText -ne $sourceUrl) {
            throw "Slide 9 is missing its Microsoft Learn LLM fundamentals source link."
        }
        foreach ($processStep in @("Input", "Tokenization", "Embeddings", "Next-token prediction", "Selection and append")) {
            if (-not $document.SelectSingleNode("//*[local-name()='g' and @aria-label='$processStep']")) {
                throw "Slide 9 is missing the $processStep stage."
            }
        }
        if (-not $document.SelectSingleNode("//*[local-name()='text' and normalize-space(.)='Repeat prediction and appending until a stop token or output limit.']")) {
            throw "Slide 9 is missing the autoregressive generation loop takeaway."
        }
    }
    if ($slideName -eq "slide-10.svg") {
        $sourceUrl = "https://github.com/Djohnnie/MicrosoftAgentFrameworkWorkshop-DotNetDeveloperDays-Warsaw-2026/tree/main/exercises/exercise-001"
        $sourceLink = $document.SelectSingleNode("//*[local-name()='a' and @href='$sourceUrl']")
        if (-not $sourceLink -or $sourceLink.InnerText -ne $sourceUrl) {
            throw "Slide 10 is missing its Token Visualizer source link."
        }
        foreach ($step in @("Configure", "Run", "Explore")) {
            if (-not $document.SelectSingleNode("//*[local-name()='g' and @aria-label='$step']")) {
                throw "Slide 10 is missing the $step step."
            }
        }
        if (-not $document.SelectSingleNode("//*[local-name()='text' and normalize-space(.)='examples\example-01']")) {
            throw "Slide 10 is missing the example-01 path."
        }
    }
    if ($slideName -in @("slide-11.svg", "slide-12.svg", "slide-13.svg", "slide-14.svg", "slide-15.svg", "slide-16.svg")) {
        $stage = [int]$slideName.Substring(6, 2) - 10
        $frameworkHeader = $document.SelectSingleNode("//*[local-name()='text' and @x='88' and @y='86']")
        if (-not $frameworkHeader -or $frameworkHeader.InnerText -ne ">> THE AGENT FRAMEWORK") {
            throw "Slide $slideName is missing the THE AGENT FRAMEWORK header."
        }
        $sourceLabel = $document.SelectSingleNode("//*[local-name()='text' and normalize-space(.)='SOURCE' and @fill='#dbf536']")
        $sourceLink = $document.SelectSingleNode("//*[local-name()='a' and @href='https://learn.microsoft.com/en-us/agent-framework/overview/']")
        if (-not $sourceLabel -or -not $sourceLink -or -not $sourceLink.SelectSingleNode("./*[local-name()='text' and @fill='#b8b8b8']")) {
            throw "Slide $slideName is missing its green SOURCE label and gray Microsoft Learn link."
        }
        $cards = @("Agents", "Harness agent", "Workflows", "Integrations")
        for ($cardIndex = 0; $cardIndex -lt $cards.Count; $cardIndex++) {
            $card = $document.SelectSingleNode("//*[local-name()='g' and @aria-label='$($cards[$cardIndex])']")
            $shouldBeHidden = $stage -lt ($cardIndex + 2)
            if (-not $card -or (($card.GetAttribute("style") -eq "display:none") -ne $shouldBeHidden)) {
                throw "Slide $slideName has an unexpected reveal state for $($cards[$cardIndex])."
            }
        }
        $languageBlock = $document.SelectSingleNode("//*[local-name()='g' and @aria-label='Supported languages']")
        $languageShouldBeHidden = $stage -lt 6
        if (-not $languageBlock -or (($languageBlock.GetAttribute("style") -eq "display:none") -ne $languageShouldBeHidden)) {
            throw "Slide $slideName has an unexpected language-support reveal state."
        }
        if (-not $document.SelectSingleNode("//*[local-name()='text' and normalize-space(.)='Build in .NET, Python and Go (preview).']")) {
            throw "Slide $slideName is missing the language-support callout."
        }
    }
    if ($slideName -eq "slide-02.svg") {
        $speakerImage = $document.SelectSingleNode("//*[local-name()='image' and starts-with(@href, 'data:image/jpeg;base64,') and @clip-path='url(#speaker-photo-clip)']")
        if (-not $speakerImage) {
            throw "Slide 2 is missing its embedded, clipped speaker photo."
        }
        try {
            $imageBytes = [Convert]::FromBase64String($speakerImage.GetAttribute("href").Substring("data:image/jpeg;base64,".Length))
        } catch {
            throw "Slide 2 contains an invalid embedded speaker photo."
        }
        if ($imageBytes.Length -lt 4 -or $imageBytes[0] -ne 0xFF -or $imageBytes[1] -ne 0xD8 -or $imageBytes[2] -ne 0xFF) {
            throw "Slide 2's embedded speaker photo is not a valid JPEG."
        }
        $belgiumImage = $document.SelectSingleNode("//*[local-name()='image' and starts-with(@href, 'data:image/png;base64,') and @filter='url(#belgium-oredev)']")
        if (-not $belgiumImage) {
            throw "Slide 2 is missing its inline, theme-colored Belgium map."
        }
        try {
            $mapBytes = [Convert]::FromBase64String($belgiumImage.GetAttribute("href").Substring("data:image/png;base64,".Length))
        } catch {
            throw "Slide 2 contains invalid embedded Belgium map data."
        }
        if ($mapBytes.Length -lt 8 -or $mapBytes[0] -ne 0x89 -or $mapBytes[1] -ne 0x50 -or $mapBytes[2] -ne 0x4E -or $mapBytes[3] -ne 0x47) {
            throw "Slide 2's embedded Belgium map is not a valid PNG."
        }
    }

    Write-Output "Valid SVG: $slideName"
}

$qrPath = Join-Path $resourceDirectory "qrcode.svg"
if (-not (Test-Path -LiteralPath $qrPath -PathType Leaf)) {
    throw "Missing repository QR asset: $qrPath"
}

$qrDocument = [System.Xml.XmlDocument]::new()
$qrDocument.XmlResolver = $null
$qrDocument.Load($qrPath)
if ($qrDocument.DocumentElement.LocalName -ne "svg") {
    throw "Repository QR asset is not an SVG document."
}
Write-Output "Valid SVG: _resources\qrcode.svg"

Write-Output "Valid embedded JPEG: slide-02.svg"
Write-Output "Valid embedded Belgium PNG: slide-02.svg"
