[CmdletBinding()]
param([string]$Root = '')

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
$sourceRoot = if ([string]::IsNullOrWhiteSpace($Root)) { Split-Path -Parent $PSScriptRoot } else { [System.IO.Path]::GetFullPath($Root) }
Import-Module (Join-Path $sourceRoot 'scripts/lib/ModelProject.Platform.psm1') -Force
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
$pwshPath = (Get-Process -Id $PID).Path
$tempBase = Get-ModelProjectSystemTempRoot
$tempComparison = Get-ModelProjectPathComparison -Path $tempBase
$fixtureRoot = [System.IO.Path]::GetFullPath((Join-Path $tempBase ('model-project-v2-consumer-' + [guid]::NewGuid().ToString('N'))))

function Copy-PortableFile {
    param([Parameter(Mandatory = $true)][string]$RelativePath)
    $source = Join-Path $sourceRoot $RelativePath
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { throw "Portable source отсутствует: $RelativePath" }
    $target = Join-Path $fixtureRoot $RelativePath
    $parent = Split-Path -Parent $target
    if (-not (Test-Path -LiteralPath $parent -PathType Container)) { [System.IO.Directory]::CreateDirectory($parent) | Out-Null }
    [System.IO.File]::Copy($source, $target, $false)
}

function Invoke-ChildScript {
    param([Parameter(Mandatory = $true)][string]$Script, [Parameter(Mandatory = $true)][string[]]$Arguments)
    $output = @(& $pwshPath -NoProfile -File $Script @Arguments 2>&1)
    $code = $LASTEXITCODE
    if ($code -ne 0) { throw "Child script failed: $Script. Output: $($output -join ' | ')" }
    return @($output | ForEach-Object { [string]$_ })
}

try {
    if (-not $fixtureRoot.StartsWith($tempBase + [System.IO.Path]::DirectorySeparatorChar, $tempComparison)) {
        throw 'Unsafe consumer fixture root.'
    }
    [System.IO.Directory]::CreateDirectory($fixtureRoot) | Out-Null
    $manifestPath = Join-Path $sourceRoot '.template-manifest.json'
    $manifest = [System.IO.File]::ReadAllText($manifestPath) | ConvertFrom-Json -ErrorAction Stop
    $portable = @($manifest.portable_files | ForEach-Object { [string]$_ })
    foreach ($relative in $portable) { Copy-PortableFile -RelativePath $relative }
    foreach ($relative in @($manifest.portable_empty_directories)) {
        [System.IO.Directory]::CreateDirectory((Join-Path $fixtureRoot ([string]$relative))) | Out-Null
    }

    $actual = @(Get-ChildItem -LiteralPath $fixtureRoot -Recurse -File -Force | ForEach-Object {
        [System.IO.Path]::GetRelativePath($fixtureRoot, $_.FullName).Replace('\', '/')
    })
    $missing = @($portable | Where-Object { $actual -cnotcontains $_ })
    $extra = @($actual | Where-Object { $portable -cnotcontains $_ })
    if ($missing.Count -gt 0 -or $extra.Count -gt 0) { throw 'Consumer inventory не совпадает с portable allowlist.' }

    $requiredV2 = @(
        '.agents/skills/project-delivery/SKILL.md',
        '.agents/skills/knowledge-curator/SKILL.md',
        '.agents/skills/startup-researcher/SKILL.md',
        'product/INDEX.md', 'business/architecture.md',
        'docs/architecture/overview.md', 'docs/codebase/overview.md',
        'plans/INDEX.md', 'plans/TEMPLATE.md',
        'scripts/new-plan.ps1', 'scripts/assert-plan-resume.ps1',
        'scripts/verify-canon.ps1', 'scripts/verify-plans.ps1'
    )
    foreach ($relative in $requiredV2) {
        if ($actual -cnotcontains $relative) { throw "Consumer не содержит обязательный v2 path: $relative" }
    }
    $forbiddenPrefixes = @(
        '.agents/skills/it-analysis/', 'analysis/', 'business/analysis/', 'business/raw/',
        'docs/analysis/', 'mastery/analyst/'
    )
    $forbiddenExact = @(
        'prompts/analysis-run.md', 'prompts/business-baseline.md',
        'prompts/decision-and-delivery.md', 'prompts/knowledge-and-mastery.md',
        'scripts/new-analysis-run.ps1', 'scripts/verify-analysis.ps1'
    )
    foreach ($relative in $actual) {
        if ($forbiddenExact -ccontains $relative -or @($forbiddenPrefixes | Where-Object { $relative.StartsWith($_, [System.StringComparison]::Ordinal) }).Count -gt 0) {
            throw "Consumer содержит retired formal-analysis path: $relative"
        }
    }
    foreach ($sourceOnly in @($manifest.source_only_paths)) {
        if ($actual -ccontains [string]$sourceOnly) { throw "Consumer содержит source-only path: $sourceOnly" }
    }

    $projectPath = Join-Path $fixtureRoot 'PROJECT.md'
    $project = [System.IO.File]::ReadAllText($projectPath)
    if (-not $project.Contains('repository_kind: template-source')) { throw 'PROJECT.md не содержит source marker.' }
    [System.IO.File]::WriteAllText($projectPath, $project.Replace('repository_kind: template-source', 'repository_kind: distribution-template'), $utf8NoBom)

    $planIndexer = Join-Path $fixtureRoot 'scripts/update-plan-index.ps1'
    [void](Invoke-ChildScript -Script $planIndexer -Arguments @('-Root', $fixtureRoot, '-Mode', 'Write'))
    $planIndex = [System.IO.File]::ReadAllText((Join-Path $fixtureRoot 'plans/INDEX.md'))
    if ($planIndex -match 'PLAN-[0-9]|legacy:') { throw 'Consumer plan index содержит source-only plans.' }

    $payloadHashes = [System.Collections.Generic.List[object]]::new()
    foreach ($relative in @($portable | Where-Object { $_ -cne 'TEMPLATE-DISTRIBUTION.json' } | Sort-Object)) {
        $hash = (Get-FileHash -LiteralPath (Join-Path $fixtureRoot $relative) -Algorithm SHA256).Hash.ToLowerInvariant()
        $payloadHashes.Add([ordered]@{ path = $relative; sha256 = $hash }) | Out-Null
    }
    $descriptor = [ordered]@{
        schema_version = 1
        distribution_kind = 'github-template'
        template_version = [string]$manifest.template_version
        source_tag = 'v' + [string]$manifest.template_version
        source_commit = '0000000000000000000000000000000000000000'
        template_repository_url = 'https://github.com/example/model-project-template'
        built_at = '2026-08-20T00:00:00Z'
        payload_sha256 = $payloadHashes.ToArray()
    }
    [System.IO.File]::WriteAllText(
        (Join-Path $fixtureRoot 'TEMPLATE-DISTRIBUTION.json'),
        (($descriptor | ConvertTo-Json -Depth 6) + "`n"),
        $utf8NoBom
    )

    $verifier = Join-Path $fixtureRoot 'scripts/verify-structure.ps1'
    $verifyOutput = Invoke-ChildScript -Script $verifier -Arguments @('-Root', $fixtureRoot, '-Mode', 'DistributionTemplate')
    if (($verifyOutput -join "`n") -notmatch 'PASS \[DistributionTemplate\]') { throw 'DistributionTemplate gate не вернул PASS.' }
    Write-Host "PASS: v2 consumer boundary; portable=$($portable.Count); formal-analysis absent; DistributionTemplate green."
}
finally {
    if (Test-Path -LiteralPath $fixtureRoot -PathType Container) {
        $full = [System.IO.Path]::GetFullPath($fixtureRoot)
        if (-not $full.StartsWith($tempBase + [System.IO.Path]::DirectorySeparatorChar, $tempComparison) -or
            [System.IO.Path]::GetFileName($full) -cnotmatch '^model-project-v2-consumer-[a-f0-9]{32}$') {
            throw 'Unsafe consumer fixture cleanup target.'
        }
        Remove-Item -LiteralPath $full -Recurse -Force
    }
}
