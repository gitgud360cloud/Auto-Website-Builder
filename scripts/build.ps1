$ErrorActionPreference = "Stop"

Write-Host "Starting Auto Website Builder..."

$projectRoot = Split-Path -Parent $PSScriptRoot
$configPath = Join-Path $projectRoot "site.json"
$outputPath = Join-Path $projectRoot "build"

if (-not (Test-Path $configPath)) {
    throw "site.json was not found."
}

$config = Get-Content -Path $configPath -Raw | ConvertFrom-Json

if (-not $config.title -or -not $config.services) {
    throw "Configuration must include a title and services."
}

# Create or clean the output directory
if (Test-Path $outputPath) {
    Remove-Item -Path $outputPath -Recurse -Force
}

New-Item -ItemType Directory -Path $outputPath -Force | Out-Null

# HTML-encode content to avoid inserting raw HTML from the JSON file
function Encode-Html {
    param([AllowNull()][string]$Value)

    return [System.Net.WebUtility]::HtmlEncode($Value)
}

$title = Encode-Html ([string]$config.title)
$tagline = Encode-Html ([string]$config.tagline)
$description = Encode-Html ([string]$config.description)
$buttonText = Encode-Html ([string]$config.buttonText)
$email = Encode-Html ([string]$config.email)
$footer = Encode-Html ([string]$config.footer)

$serviceCards = foreach ($service in $config.services) {
    $serviceName = Encode-Html ([string]$service.name)
    $serviceDescription = Encode-Html ([string]$service.description)

    @"
        <article class="service-card">
            <h3>$serviceName</h3>
            <p>$serviceDescription</p>
        </article>
"@
}

$servicesHtml = $serviceCards -join "`n"

$html = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="$description">
    <title>$title</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <header class="hero">
        <nav class="navbar">
            <a class="brand" href="#">$title</a>
            <a class="nav-link" href="#services">Our Services</a>
        </nav>

        <div class="hero-content">
            <p class="eyebrow">WELCOME</p>
            <h1>$tagline</h1>
            <p class="intro">$description</p>
            <a class="button" href="mailto:$email">$buttonText</a>
        </div>
    </header>

    <main>
        <section id="services" class="services">
            <div class="section-heading">
                <p class="eyebrow">WHAT WE DO</p>
                <h2>Our Services</h2>
            </div>

            <div class="service-grid">
                $servicesHtml
            </div>
        </section>

        <section class="contact">
            <h2>Let's work together</h2>
            <p>Have a project in mind? Get in touch with us.</p>
            <a href="mailto:$email">$email</a>
        </section>
    </main>

    <footer>
        <p>$footer</p>
    </footer>
</body>
</html>
"@

$css = @"
* {
    box-sizing: border-box;
    margin: 0;
    padding: 0;
}

body {
    font-family: Arial, Helvetica, sans-serif;
    color: #1f2937;
    line-height: 1.6;
    background: #f8fafc;
}

.hero {
    min-height: 480px;
    color: white;
    background: linear-gradient(135deg, #102a43, #2563a6);
}

.navbar {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 24px 8%;
}

.brand, .nav-link {
    color: white;
    text-decoration: none;
    font-weight: bold;
}

.hero-content {
    max-width: 850px;
    padding: 90px 8%;
}

.eyebrow {
    color: #60a5fa;
    font-weight: bold;
    letter-spacing: 3px;
    font-size: 13px;
}

h1 {
    font-size: clamp(36px, 6vw, 58px);
    line-height: 1.1;
    margin: 18px 0;
}

.intro {
    max-width: 600px;
    font-size: 18px;
    margin-bottom: 30px;
    color: #e2e8f0;
}

.button {
    display: inline-block;
    background: #60a5fa;
    color: #102a43;
    padding: 12px 25px;
    border-radius: 6px;
    text-decoration: none;
    font-weight: bold;
}

.services {
    padding: 75px 8%;
}

.section-heading {
    text-align: center;
    margin-bottom: 35px;
}

.section-heading h2, .contact h2 {
    font-size: 32px;
    margin-top: 8px;
}

.service-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
    gap: 22px;
}

.service-card {
    background: white;
    padding: 28px;
    border-radius: 10px;
    box-shadow: 0 5px 20px rgba(0, 0, 0, 0.06);
}

.service-card h3 {
    margin-bottom: 12px;
    color: #1d4ed8;
}

.contact {
    text-align: center;
    padding: 65px 20px;
    background: #eaf2fb;
}

.contact p {
    margin: 12px 0;
}

.contact a {
    color: #1d4ed8;
    font-weight: bold;
}

footer {
    text-align: center;
    padding: 22px;
    background: #102a43;
    color: white;
}

@media (max-width: 600px) {
    .hero-content {
        padding-top: 65px;
        padding-bottom: 65px;
    }

    .navbar {
        padding: 20px 6%;
    }
}
"@

# Write generated files as UTF-8
$utf8 = [System.Text.UTF8Encoding]::new($false)

[System.IO.File]::WriteAllText(
    (Join-Path $outputPath "index.html"),
    $html,
    $utf8
)

[System.IO.File]::WriteAllText(
    (Join-Path $outputPath "style.css"),
    $css,
    $utf8
)

Write-Host "Website generated successfully!"
Write-Host "Output: $outputPath"