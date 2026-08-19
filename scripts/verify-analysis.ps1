[CmdletBinding()]
param(
    [string]$Root = '',
    [switch]$Report,
    [switch]$SelfTest
)

$ErrorActionPreference = 'Stop'
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
$strictUtf8 = [System.Text.UTF8Encoding]::new($false, $true)
[Console]::OutputEncoding = $utf8NoBom
$OutputEncoding = $utf8NoBom

$runIdPattern = '^RUN-(?<date>[0-9]{8})-(?<time>[0-9]{6})-(?<slug>[a-z0-9](?:[a-z0-9-]{0,46}[a-z0-9])?)-(?<hex>[0-9a-f]{6})$'
$safeTaskRefPattern = '^[A-Za-z0-9][A-Za-z0-9._:-]{0,127}$'
$safeEvidenceRefPattern = '^evidence:[A-Za-z0-9][A-Za-z0-9._:-]{0,127}$'
$safeUserRefPattern = '^user-request:[A-Za-z0-9][A-Za-z0-9._:-]{0,127}$'
$datePattern = '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
$timestampPattern = '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$'
$canonicalFileMaxBytes = 2MB
$canonicalCorpusMaxBytes = 64MB
$runFileMaxBytes = 2MB
$runCorpusMaxBytes = 16MB
$auxiliaryCorpusMaxBytes = 32MB
$reachabilityCorpusMaxBytes = 64MB
$maximumRuns = 1000
$maximumCanonicalFiles = 10000
$maximumMarkdownFilesForReachability = 20000
$maximumAuxiliaryMarkdownFiles = 20000
$analysisIntentIds = @(
    'stakeholder-analysis', 'requirements-elicitation', 'business-process-analysis', 'as-is-to-be',
    'gap-analysis', 'business-rule-analysis', 'use-case-modeling', 'functional-requirements',
    'nonfunctional-requirements', 'data-analysis', 'integration-analysis', 'api-contract-analysis',
    'traceability', 'change-impact-analysis', 'acceptance-criteria', 'specification-authoring',
    'specification-review', 'requirements-validation'
)

$runFiles = @(
    'brief.md', 'sources.md', 'analysis.md', 'requirements.md',
    'models.md', 'traceability.md', 'review.md', 'decision.md'
)

$artifactContracts = @(
    [pscustomobject]@{ Prefix = 'STK';  Kind = 'stakeholder';               Owner = 'business/analysis/stakeholders' },
    [pscustomobject]@{ Prefix = 'CAP';  Kind = 'capability';                Owner = 'business/analysis/capabilities' },
    [pscustomobject]@{ Prefix = 'BP';   Kind = 'business-process';          Owner = 'business/analysis/processes' },
    [pscustomobject]@{ Prefix = 'RULE'; Kind = 'business-rule';             Owner = 'business/analysis/rules' },
    [pscustomobject]@{ Prefix = 'BR';   Kind = 'business-requirement';      Owner = 'business/analysis/requirements' },
    [pscustomobject]@{ Prefix = 'UC';   Kind = 'use-case';                  Owner = 'docs/analysis/requirements' },
    [pscustomobject]@{ Prefix = 'FR';   Kind = 'functional-requirement';    Owner = 'docs/analysis/requirements' },
    [pscustomobject]@{ Prefix = 'NFR';  Kind = 'nonfunctional-requirement'; Owner = 'docs/analysis/requirements' },
    [pscustomobject]@{ Prefix = 'DATA'; Kind = 'data-model';                Owner = 'docs/analysis/models' },
    [pscustomobject]@{ Prefix = 'INT';  Kind = 'integration-contract';      Owner = 'docs/analysis/models' },
    [pscustomobject]@{ Prefix = 'SYS';  Kind = 'system-model';              Owner = 'docs/analysis/models' },
    [pscustomobject]@{ Prefix = 'AC';   Kind = 'acceptance-criterion';      Owner = 'docs/analysis/requirements' },
    [pscustomobject]@{ Prefix = 'SPEC'; Kind = 'specification';             Owner = 'docs/analysis/specifications' },
    [pscustomobject]@{ Prefix = 'CR';   Kind = 'change-request';            Owner = 'docs/analysis/changes' },
    [pscustomobject]@{ Prefix = 'REV';  Kind = 'review-decision';           Owner = 'docs/analysis/reviews' }
)

$canonicalFields = @(
    'artifact_kind', 'id', 'status', 'owner_scope', 'capture_basis', 'provenance_refs',
    'source_refs', 'parent_refs', 'related_refs', 'decision_refs', 'acceptance_refs',
    'verification_refs', 'supersedes_ref', 'approval_ref', 'approved_at', 'approved_by',
    'created_at', 'verified_at', 'review_due'
)

$runSchemas = @{
    'brief.md' = @('run_id', 'run_asset', 'run_status', 'title', 'task_ref', 'created_at', 'intent_id', 'authority_ref', 'selected_method_refs', 'local_method_refs')
    'sources.md' = @('run_id', 'run_asset', 'run_status', 'title', 'task_ref', 'created_at')
    'analysis.md' = @('run_id', 'run_asset', 'run_status', 'title', 'task_ref', 'created_at')
    'requirements.md' = @('run_id', 'run_asset', 'run_status', 'title', 'task_ref', 'created_at', 'proposed_ids', 'canonical_target_refs')
    'models.md' = @('run_id', 'run_asset', 'run_status', 'title', 'task_ref', 'created_at', 'proposed_ids', 'canonical_target_refs')
    'traceability.md' = @('run_id', 'run_asset', 'run_status', 'title', 'task_ref', 'created_at', 'traceability_outcome')
    'review.md' = @('run_id', 'run_asset', 'run_status', 'title', 'task_ref', 'created_at', 'review_outcome', 'unresolved_blockers')
    'decision.md' = @('run_id', 'run_asset', 'run_status', 'title', 'task_ref', 'created_at', 'decision_outcome', 'capture_basis', 'provenance_refs', 'canonical_target_refs', 'authority_ref', 'knowledge_outcome', 'candidate_ids', 'affected_canon', 'blocked_reason')
}

function Get-BootstrapReparsePointInFullChain {
    param([Parameter(Mandatory = $true)][string]$AbsolutePath)

    $full = [System.IO.Path]::GetFullPath($AbsolutePath)
    $pathRoot = [System.IO.Path]::GetPathRoot($full)
    $current = $pathRoot
    foreach ($segment in (($full.Substring($pathRoot.Length) -split '[\\/]') | Where-Object { $_ -ne '' })) {
        $current = Join-Path $current $segment
        if (-not (Test-Path -LiteralPath $current)) { break }
        $item = Get-Item -LiteralPath $current -Force -ErrorAction Stop
        if (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) { return $current }
    }
    return $null
}

function Test-BootstrapExactPathCase {
    param([Parameter(Mandatory = $true)][string]$AbsolutePath)

    $full = [System.IO.Path]::GetFullPath($AbsolutePath)
    if (-not (Test-Path -LiteralPath $full)) { return $false }
    $parent = [System.IO.Path]::GetDirectoryName($full)
    $leaf = [System.IO.Path]::GetFileName($full)
    $matches = @(
        [System.IO.Directory]::EnumerateFileSystemEntries($parent) |
            Where-Object { [System.IO.Path]::GetFileName($_).Equals($leaf, [System.StringComparison]::OrdinalIgnoreCase) }
    )
    return ($matches.Count -eq 1 -and [System.IO.Path]::GetFileName($matches[0]) -ceq $leaf)
}

$trustedScriptPath = [System.IO.Path]::GetFullPath($PSCommandPath)
$trustedScriptsRoot = [System.IO.Path]::GetFullPath($PSScriptRoot).TrimEnd([char[]]'\/')
$trustedRepositoryRoot = [System.IO.Path]::GetFullPath((Split-Path -Parent $trustedScriptsRoot)).TrimEnd([char[]]'\/')
$trustedModulePath = [System.IO.Path]::GetFullPath((Join-Path $trustedScriptsRoot 'lib\ModelProject.Knowledge.psm1'))
$trustedLibRoot = [System.IO.Path]::GetDirectoryName($trustedModulePath)
if ([System.IO.Path]::GetFileName($trustedScriptPath) -cne 'verify-analysis.ps1' -or
    -not [System.IO.Path]::GetDirectoryName($trustedScriptPath).Equals($trustedScriptsRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw 'Analysis verifier path integrity check failed.'
}
if (-not (Test-Path -LiteralPath $trustedModulePath -PathType Leaf)) { throw 'Trusted analysis verifier module is missing.' }
if ($null -ne (Get-BootstrapReparsePointInFullChain -AbsolutePath $trustedScriptPath) -or
    $null -ne (Get-BootstrapReparsePointInFullChain -AbsolutePath $trustedModulePath) -or
    -not (Test-BootstrapExactPathCase -AbsolutePath $trustedScriptPath) -or
    -not (Test-BootstrapExactPathCase -AbsolutePath $trustedLibRoot) -or
    -not (Test-BootstrapExactPathCase -AbsolutePath $trustedModulePath)) {
    throw 'Trusted analysis verifier path or helper module failed bootstrap integrity check.'
}
$trustedModule = Import-Module -Name $trustedModulePath -Scope Local -Force -PassThru -ErrorAction Stop
if ($null -eq $trustedModule -or
    [string]::IsNullOrWhiteSpace([string]$trustedModule.Path) -or
    -not [System.IO.Path]::GetFullPath([string]$trustedModule.Path).Equals($trustedModulePath, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw 'Trusted analysis helper module failed load-origin check.'
}
$trustedAnalysisExportNames = @(
    'Test-ModelProjectFrontMatterScalarValue', 'Test-ModelProjectJsonScalar',
    'ConvertTo-ModelProjectPercentDecodedText', 'Get-ModelProjectHttpsUrlSafetyFinding',
    'Get-ModelProjectHttpsUrlsFromText', 'Get-ModelProjectSensitiveTextFindings',
    'Remove-ModelProjectCommonMarkContainerPrefixes', 'Test-ModelProjectMarkdownEscaped',
    'Get-ModelProjectMarkdownLinkOpenerIndex', 'Test-ModelProjectInlineMarkdownClosure',
    'Test-ModelProjectPathWithinRoot', 'Get-ModelProjectReparsePointInFullChain',
    'Get-ModelProjectRepositoryRelativePath', 'Test-ModelProjectExactPathCase',
    'Read-ModelProjectBoundedUtf8File', 'ConvertTo-ModelProjectMarkdownAnchor',
    'Test-ModelProjectMarkdownAnchorExists', 'Resolve-ModelProjectSafeReference'
)
if ($trustedModule.ExportedCommands.Count -ne $trustedAnalysisExportNames.Count) { throw 'Trusted analysis helper module export set mismatch.' }
foreach ($requiredCommand in $trustedAnalysisExportNames) {
    $command = $trustedModule.ExportedCommands[$requiredCommand]
    if ($null -eq $command -or $command.CommandType -ne [System.Management.Automation.CommandTypes]::Function -or
        $null -eq $command.Module -or
        -not [System.IO.Path]::GetFullPath([string]$command.Module.Path).Equals($trustedModulePath, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw 'Trusted analysis helper module failed export-origin check.'
    }
}

function New-IssueList {
    $list = [System.Collections.Generic.List[string]]::new()
    $list.Add('__sentinel__') | Out-Null
    return ,$list
}

function Add-AnalysisIssue {
    param(
        [Parameter(Mandatory = $true)][System.Collections.Generic.List[string]]$Issues,
        [Parameter(Mandatory = $true)][string]$Code,
        [string]$Path = ''
    )
    $safeCode = if ($Code -match '^[a-z0-9][a-z0-9.-]{0,127}$') { $Code } else { 'internal-validation-error' }
    if ([string]::IsNullOrWhiteSpace($Path)) { $Issues.Add($safeCode) | Out-Null; return }
    $safePath = $Path.Replace('\', '/')
    if ($safePath -notmatch '^[A-Za-z0-9._/-]{1,512}$') { $safePath = '<redacted-path>' }
    $Issues.Add("$safeCode [$safePath]") | Out-Null
}

function Convert-FrontMatterScalar {
    param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$RawValue)
    $value = $RawValue.Trim()
    if ($value -ceq 'null') { return $null }
    if ($value -ceq 'true') { return $true }
    if ($value -ceq 'false') { return $false }
    if ($value.Length -ge 2 -and $value[0] -eq '"' -and $value[$value.Length - 1] -eq '"') {
        $inner = $value.Substring(1, $value.Length - 2)
        if ($inner -match '(?<!\\)\\(?!["\\/bfnrtu])' -or $inner -match '\\u(?![0-9A-Fa-f]{4})') { throw 'invalid-quoted-frontmatter-scalar' }
        $inner = [regex]::Replace($inner, '\\u(?<hex>[0-9A-Fa-f]{4})', { param($match) [char][convert]::ToInt32($match.Groups['hex'].Value, 16) })
        $inner = $inner.Replace('\"', '"').Replace('\/', '/').Replace('\n', "`n").Replace('\r', "`r").Replace('\t', "`t").Replace('\b', "`b").Replace('\f', "`f").Replace('\\', '\')
        return $inner
    }
    if ($value.Length -ge 2 -and $value[0] -eq "'" -and $value[$value.Length - 1] -eq "'") {
        return $value.Substring(1, $value.Length - 2).Replace("''", "'")
    }
    return $value
}

function Read-ClosedFrontMatter {
    param([Parameter(Mandatory = $true)][string]$Text, [Parameter(Mandatory = $true)][string]$Label)
    $lines = @($Text -split '\r?\n')
    if ($lines.Count -lt 3 -or $lines[0] -cne '---') { throw 'missing-frontmatter' }
    $data = @{}
    $currentList = $null
    $closedAt = -1
    for ($index = 1; $index -lt $lines.Count; $index++) {
        $line = [string]$lines[$index]
        if ($line -ceq '---') { $closedAt = $index; break }
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        if ($line -match '^  -[ \t]+(?<value>.+)$') {
            if ($null -eq $currentList) { throw 'unexpected-frontmatter-list-item' }
            $itemValue = Convert-FrontMatterScalar -RawValue ([string]$Matches['value'])
            if ($null -eq $itemValue -or $itemValue -isnot [string] -or [string]::IsNullOrWhiteSpace([string]$itemValue)) { throw 'invalid-frontmatter-list-item' }
            $currentList.Add([string]$itemValue) | Out-Null
            continue
        }
        if ($line -cnotmatch '^(?<key>[a-z][a-z0-9_]*):[ \t]*(?<value>.*)$') { throw 'unsupported-frontmatter-line' }
        $key = [string]$Matches['key']
        if ($data.ContainsKey($key)) { throw 'duplicate-frontmatter-field' }
        $raw = [string]$Matches['value']
        if ($raw -ceq '[]') {
            $data[$key] = [System.Collections.Generic.List[string]]::new()
            $currentList = $null
        }
        elseif ([string]::IsNullOrWhiteSpace($raw)) {
            $list = [System.Collections.Generic.List[string]]::new()
            $data[$key] = $list
            $currentList = $list
        }
        else {
            $data[$key] = Convert-FrontMatterScalar -RawValue $raw
            $currentList = $null
        }
    }
    if ($closedAt -lt 0) { throw 'unclosed-frontmatter' }
    $body = if ($closedAt + 1 -lt $lines.Count) { ($lines[($closedAt + 1)..($lines.Count - 1)] -join "`n") } else { '' }
    return [pscustomobject]@{ Data = $data; Body = $body; Label = $Label }
}

function Test-ExactFieldSet {
    param([Parameter(Mandatory = $true)][hashtable]$Data, [Parameter(Mandatory = $true)][string[]]$Expected)
    $actual = @($Data.Keys | ForEach-Object { [string]$_ } | Sort-Object)
    $wanted = @($Expected | Sort-Object)
    if ($actual.Count -ne $wanted.Count) { return $false }
    for ($index = 0; $index -lt $actual.Count; $index++) { if ($actual[$index] -cne $wanted[$index]) { return $false } }
    return $true
}

function Test-StringList {
    param($Value)
    if ($null -eq $Value -or $Value -is [string]) { return $false }
    foreach ($entry in @($Value)) { if ($entry -isnot [string] -or [string]::IsNullOrWhiteSpace([string]$entry)) { return $false } }
    return $true
}

function Test-StrictDate {
    param($Value)
    if ($null -eq $Value) { return $false }
    $text = [string]$Value
    if ($text -cnotmatch $datePattern) { return $false }
    $parsed = [datetime]::MinValue
    return [datetime]::TryParseExact($text, 'yyyy-MM-dd', [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::None, [ref]$parsed)
}

function Test-StrictUtcTimestamp {
    param($Value)
    if ($null -eq $Value) { return $false }
    $text = [string]$Value
    if ($text -cnotmatch $timestampPattern) { return $false }
    $parsed = [datetimeoffset]::MinValue
    return [datetimeoffset]::TryParseExact($text, 'yyyy-MM-ddTHH:mm:ssZ', [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::AssumeUniversal, [ref]$parsed)
}

function Test-KnowledgeOutcomeValue {
    param($Value)
    if ($Value -isnot [string]) { return $false }
    return ([string]$Value -cmatch '^(?:none|existing|blocked|ready:KC-[0-9]{8}-[0-9]{6}-[0-9a-f]{8}|applied:KC-[0-9]{8}-[0-9]{6}-[0-9a-f]{8})$')
}

function Get-SafeRepositoryRelativePath {
    param([Parameter(Mandatory = $true)][string]$RepositoryRoot, [Parameter(Mandatory = $true)][string]$Path)
    try { return Get-ModelProjectRepositoryRelativePath -Root $RepositoryRoot -Path $Path } catch { return '<invalid-path>' }
}

function Read-SafeText {
    param([Parameter(Mandatory = $true)][string]$RepositoryRoot, [Parameter(Mandatory = $true)][string]$Path, [Parameter(Mandatory = $true)][long]$MaxBytes)
    if (-not (Test-ModelProjectExactPathCase -Root $RepositoryRoot -Path $Path)) { throw 'wrong-case-path' }
    return Read-ModelProjectBoundedUtf8File -Root $RepositoryRoot -Path $Path -MaxBytes $MaxBytes
}

function Get-SafeRecursiveMarkdownFiles {
    param(
        [Parameter(Mandatory = $true)][System.Collections.Generic.List[string]]$Issues,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string]$Directory,
        [Parameter(Mandatory = $true)][string]$RelativeDirectory
    )

    $files = [System.Collections.Generic.List[System.IO.FileInfo]]::new(); $corpusBytes = [long]0
    if ($null -ne (Get-ModelProjectReparsePointInFullChain -Root $RepositoryRoot -Path $Directory) -or
        -not (Test-ModelProjectExactPathCase -Root $RepositoryRoot -Path $Directory)) {
        Add-AnalysisIssue -Issues $Issues -Code 'unsafe-auxiliary-zone' -Path $RelativeDirectory
        return @()
    }
    $pending = [System.Collections.Generic.Stack[string]]::new()
    $pending.Push($Directory)
    while ($pending.Count -gt 0) {
        $current = $pending.Pop()
        foreach ($entryPath in [System.IO.Directory]::EnumerateFileSystemEntries($current)) {
            $entry = Get-Item -LiteralPath $entryPath -Force -ErrorAction Stop
            $relative = Get-SafeRepositoryRelativePath -RepositoryRoot $RepositoryRoot -Path $entry.FullName
            if (($entry.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
                Add-AnalysisIssue -Issues $Issues -Code 'reparse-auxiliary-entry' -Path $relative
                continue
            }
            if ($entry.PSIsContainer) {
                $pending.Push($entry.FullName)
                continue
            }
            if ($entry.Extension -ceq '.md') {
                $files.Add([System.IO.FileInfo]$entry) | Out-Null
                $corpusBytes += [long]$entry.Length
                if ($files.Count -gt $maximumAuxiliaryMarkdownFiles) {
                    Add-AnalysisIssue -Issues $Issues -Code 'auxiliary-markdown-count-exhaustion' -Path $RelativeDirectory
                    return @()
                }
                if ($corpusBytes -gt $auxiliaryCorpusMaxBytes) {
                    Add-AnalysisIssue -Issues $Issues -Code 'auxiliary-markdown-corpus-exhaustion' -Path $RelativeDirectory
                    return @()
                }
            }
        }
    }
    return @($files)
}

function Get-MarkdownLinkTargets {
    param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$Text)
    $targets = [System.Collections.Generic.List[string]]::new()
    $pattern = '(?m)(?<!!)\[[^\]\r\n]+\]\((?<target><[^>\r\n]+>|[^)\s\r\n]+)(?:[ \t]+["''][^)\r\n]*["''])?\)'
    foreach ($match in [regex]::Matches($Text, $pattern)) {
        $target = [string]$match.Groups['target'].Value
        if ($target.StartsWith('<') -and $target.EndsWith('>')) { $target = $target.Substring(1, $target.Length - 2) }
        if (-not [string]::IsNullOrWhiteSpace($target)) { $targets.Add($target) | Out-Null }
    }
    return @($targets)
}

function Test-ReferenceResultValid {
    param($Result)
    return ($null -ne $Result -and [string]::IsNullOrWhiteSpace([string]$Result.Error) -and $Result.Exists -and $Result.ExactCase -and $Result.AnchorExists)
}

function Test-AndRecordMachineReference {
    param(
        [Parameter(Mandatory = $true)][System.Collections.Generic.List[string]]$Issues,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string]$SourcePath,
        [Parameter(Mandatory = $true)][string]$Reference,
        [Parameter(Mandatory = $true)][string]$Label,
        [switch]$AllowHttps,
        [switch]$AllowLogical
    )
    $relative = Get-SafeRepositoryRelativePath -RepositoryRoot $RepositoryRoot -Path $SourcePath
    try {
        $resolved = Resolve-ModelProjectSafeReference -Root $RepositoryRoot -SourcePath $SourcePath -Reference $Reference -ReferenceBase Repository -AllowHttps:$AllowHttps -AllowLogical:$AllowLogical
        if (-not (Test-ReferenceResultValid -Result $resolved)) { Add-AnalysisIssue -Issues $Issues -Code "invalid-$Label" -Path $relative; return $null }
        return $resolved
    }
    catch { Add-AnalysisIssue -Issues $Issues -Code "invalid-$Label" -Path $relative; return $null }
}

function Test-AndRecordMarkdownLinks {
    param(
        [Parameter(Mandatory = $true)][System.Collections.Generic.List[string]]$Issues,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string]$SourcePath,
        [Parameter(Mandatory = $true)][string]$Text
    )
    $relative = Get-SafeRepositoryRelativePath -RepositoryRoot $RepositoryRoot -Path $SourcePath
    foreach ($target in (Get-MarkdownLinkTargets -Text $Text)) {
        if ($target.StartsWith('#')) {
            if ($target.Length -le 1 -or -not (Test-ModelProjectMarkdownAnchorExists -Root $RepositoryRoot -Path $SourcePath -Anchor $target.Substring(1))) { Add-AnalysisIssue -Issues $Issues -Code 'broken-markdown-anchor' -Path $relative }
            continue
        }
        try {
            $resolved = Resolve-ModelProjectSafeReference -Root $RepositoryRoot -SourcePath $SourcePath -Reference $target -ReferenceBase File -AllowHttps
            if (-not (Test-ReferenceResultValid -Result $resolved)) { Add-AnalysisIssue -Issues $Issues -Code 'broken-markdown-link' -Path $relative }
        }
        catch { Add-AnalysisIssue -Issues $Issues -Code 'broken-markdown-link' -Path $relative }
    }
}

function Test-AndRecordSensitiveText {
    param([Parameter(Mandatory = $true)][System.Collections.Generic.List[string]]$Issues, [Parameter(Mandatory = $true)][string]$RelativePath, [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Text)
    foreach ($finding in @(Get-ModelProjectSensitiveTextFindings -Text $Text)) { Add-AnalysisIssue -Issues $Issues -Code "sensitive-$finding" -Path $RelativePath }
}

function Resolve-VerificationRoot {
    param([string]$RequestedRoot)
    $candidate = if ([string]::IsNullOrWhiteSpace($RequestedRoot)) { $trustedRepositoryRoot } else { $RequestedRoot }
    if ([string]::IsNullOrWhiteSpace($candidate) -or $candidate.IndexOf([char]0) -ge 0 -or $candidate -match '[\r\n]' -or
        $candidate -match '^(?i:file:|\\\\[.?]\\|GLOBALROOT)' -or $candidate.StartsWith('\\') -or $candidate.StartsWith('//') -or $candidate -match '^[A-Za-z]:[^\\/]') { throw 'invalid-verification-root' }
    $full = [System.IO.Path]::GetFullPath($candidate).TrimEnd([char[]]'\/')
    if (-not (Test-Path -LiteralPath $full -PathType Container) -or $null -ne (Get-ModelProjectReparsePointInFullChain -Root $full -Path $full) -or
        -not (Test-ModelProjectExactPathCase -Root $full -Path $full)) { throw 'invalid-verification-root' }
    return $full
}

function Get-ProjectMode {
    param([Parameter(Mandatory = $true)][System.Collections.Generic.List[string]]$Issues, [Parameter(Mandatory = $true)][string]$RepositoryRoot)
    $path = Join-Path $RepositoryRoot 'PROJECT.md'
    try {
        $frontMatter = Read-ClosedFrontMatter -Text (Read-SafeText -RepositoryRoot $RepositoryRoot -Path $path -MaxBytes 1MB) -Label 'PROJECT.md'
        foreach ($field in @('repository_kind', 'project_status', 'knowledge_capture_mode')) {
            if (-not $frontMatter.Data.ContainsKey($field) -or $frontMatter.Data[$field] -isnot [string]) { Add-AnalysisIssue -Issues $Issues -Code 'invalid-project-mode' -Path 'PROJECT.md'; return $null }
        }
        $kind = [string]$frontMatter.Data.repository_kind; $status = [string]$frontMatter.Data.project_status; $capture = [string]$frontMatter.Data.knowledge_capture_mode
        $valid = (($kind -ceq 'template-source' -and $status -ceq 'template' -and $capture -ceq 'disabled') -or
            ($kind -ceq 'generated-project' -and $status -ceq 'initialized' -and $capture -ceq 'report-only') -or
            ($kind -ceq 'generated-project' -and $status -ceq 'active' -and $capture -cin @('report-only', 'safe-local')) -or
            ($kind -ceq 'generated-project' -and $status -ceq 'archived' -and $capture -ceq 'disabled'))
        if (-not $valid) { Add-AnalysisIssue -Issues $Issues -Code 'invalid-project-mode' -Path 'PROJECT.md' }
        return [pscustomobject]@{ Kind = $kind; Status = $status; Capture = $capture }
    }
    catch { Add-AnalysisIssue -Issues $Issues -Code 'invalid-project-mode' -Path 'PROJECT.md'; return $null }
}

function Get-ContractById {
    param([Parameter(Mandatory = $true)][string]$Id)
    foreach ($contract in $artifactContracts) { if ($Id -cmatch ('^' + [regex]::Escape($contract.Prefix) + '-[0-9]{4}$')) { return $contract } }
    return $null
}

function Get-CanonicalFiles {
    param([Parameter(Mandatory = $true)][System.Collections.Generic.List[string]]$Issues, [Parameter(Mandatory = $true)][string]$RepositoryRoot)
    $files = [System.Collections.Generic.List[System.IO.FileInfo]]::new()
    foreach ($owner in @($artifactContracts.Owner | Sort-Object -Unique)) {
        $directory = Join-Path $RepositoryRoot $owner.Replace('/', '\')
        if (-not (Test-Path -LiteralPath $directory -PathType Container)) { Add-AnalysisIssue -Issues $Issues -Code 'missing-canonical-owner' -Path $owner; continue }
        if ($null -ne (Get-ModelProjectReparsePointInFullChain -Root $RepositoryRoot -Path $directory) -or
            -not (Test-ModelProjectExactPathCase -Root $RepositoryRoot -Path $directory)) { Add-AnalysisIssue -Issues $Issues -Code 'unsafe-canonical-owner' -Path $owner; continue }
        foreach ($entry in @(Get-ChildItem -LiteralPath $directory -Force)) {
            $relative = Get-SafeRepositoryRelativePath -RepositoryRoot $RepositoryRoot -Path $entry.FullName
            if (($entry.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) { Add-AnalysisIssue -Issues $Issues -Code 'reparse-canonical-entry' -Path $relative }
            elseif ($entry.PSIsContainer) { Add-AnalysisIssue -Issues $Issues -Code 'nested-canonical-entry' -Path $relative }
            elseif ($entry.Extension -cne '.md') { Add-AnalysisIssue -Issues $Issues -Code 'non-markdown-canonical-entry' -Path $relative }
            elseif ($entry.Name -cnotin @('README.md', 'TEMPLATE.md', 'INDEX.md')) { $files.Add($entry) | Out-Null }
        }
    }
    foreach ($derived in @('docs/analysis/context', 'docs/analysis/traceability')) {
        $directory = Join-Path $RepositoryRoot $derived.Replace('/', '\')
        if (-not (Test-Path -LiteralPath $directory -PathType Container)) { Add-AnalysisIssue -Issues $Issues -Code 'missing-derived-view-zone' -Path $derived; continue }
        if ($null -ne (Get-ModelProjectReparsePointInFullChain -Root $RepositoryRoot -Path $directory) -or
            -not (Test-ModelProjectExactPathCase -Root $RepositoryRoot -Path $directory)) { Add-AnalysisIssue -Issues $Issues -Code 'unsafe-derived-view-zone' -Path $derived; continue }
        foreach ($entry in @(Get-ChildItem -LiteralPath $directory -Force)) {
            $relative = Get-SafeRepositoryRelativePath -RepositoryRoot $RepositoryRoot -Path $entry.FullName
            if ($entry.PSIsContainer -or $entry.Name -cnotin @('README.md', 'TEMPLATE.md')) { Add-AnalysisIssue -Issues $Issues -Code 'invalid-derived-view-entry' -Path $relative }
        }
    }
    if ($files.Count -gt $maximumCanonicalFiles) { Add-AnalysisIssue -Issues $Issues -Code 'canonical-file-count-exhaustion'; return @() }
    $canonicalBytes = [long]0; foreach ($file in $files) { $canonicalBytes += [long]$file.Length }
    if ($canonicalBytes -gt $canonicalCorpusMaxBytes) { Add-AnalysisIssue -Issues $Issues -Code 'canonical-corpus-exhaustion'; return @() }
    return @($files)
}

function Read-CanonicalArtifacts {
    param(
        [Parameter(Mandatory = $true)][System.Collections.Generic.List[string]]$Issues,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][System.IO.FileInfo[]]$Files
    )
    $artifacts = [System.Collections.Generic.List[object]]::new(); $ids = @{}
    foreach ($file in $Files) {
        $relative = Get-SafeRepositoryRelativePath -RepositoryRoot $RepositoryRoot -Path $file.FullName
        try {
            $text = Read-SafeText -RepositoryRoot $RepositoryRoot -Path $file.FullName -MaxBytes $canonicalFileMaxBytes
            Test-AndRecordSensitiveText -Issues $Issues -RelativePath $relative -Text $text
            Test-AndRecordMarkdownLinks -Issues $Issues -RepositoryRoot $RepositoryRoot -SourcePath $file.FullName -Text $text
            $parsed = Read-ClosedFrontMatter -Text $text -Label $relative; $data = $parsed.Data
            if (-not (Test-ExactFieldSet -Data $data -Expected $canonicalFields)) { Add-AnalysisIssue -Issues $Issues -Code 'invalid-canonical-schema' -Path $relative; continue }
            foreach ($field in @('provenance_refs', 'source_refs', 'parent_refs', 'related_refs', 'decision_refs', 'acceptance_refs', 'verification_refs')) {
                if (-not (Test-StringList -Value $data[$field])) { Add-AnalysisIssue -Issues $Issues -Code 'invalid-canonical-list' -Path $relative }
            }
            $id = [string]$data.id
            if ($id -cmatch '^[A-Za-z]+-[0-9]{4}$') {
                $idKey = $id.ToUpperInvariant()
                if ($ids.ContainsKey($idKey)) { Add-AnalysisIssue -Issues $Issues -Code 'duplicate-canonical-id' -Path $relative } else { $ids[$idKey] = $relative }
            }
            $contract = Get-ContractById -Id $id
            if ($null -eq $contract) { Add-AnalysisIssue -Issues $Issues -Code 'invalid-canonical-id' -Path $relative; continue }
            if ([string]$data.artifact_kind -cne [string]$contract.Kind -or -not $relative.StartsWith($contract.Owner + '/', [System.StringComparison]::Ordinal)) {
                Add-AnalysisIssue -Issues $Issues -Code 'canonical-kind-owner-mismatch' -Path $relative
            }
            $expectedStem = $id.ToLowerInvariant()
            if ($file.Name -cnotmatch ('^' + [regex]::Escape($expectedStem) + '-[a-z0-9](?:[a-z0-9-]{0,62}[a-z0-9])?\.md$')) { Add-AnalysisIssue -Issues $Issues -Code 'canonical-filename-mismatch' -Path $relative }
            if ([string]$data.owner_scope -cne 'project' -or [string]$data.status -cnotin @('draft', 'in-review', 'approved', 'rejected', 'superseded') -or
                [string]$data.capture_basis -cnotin @('repo-derived', 'explicit-user-capture', 'research-derived')) { Add-AnalysisIssue -Issues $Issues -Code 'invalid-canonical-enum' -Path $relative }
            foreach ($dateField in @('created_at', 'verified_at', 'review_due')) { if (-not (Test-StrictDate -Value $data[$dateField])) { Add-AnalysisIssue -Issues $Issues -Code 'invalid-canonical-date' -Path $relative } }
            if ((Test-StrictDate -Value $data.verified_at) -and (Test-StrictDate -Value $data.review_due) -and
                [datetime]::ParseExact([string]$data.review_due, 'yyyy-MM-dd', [System.Globalization.CultureInfo]::InvariantCulture) -lt
                [datetime]::ParseExact([string]$data.verified_at, 'yyyy-MM-dd', [System.Globalization.CultureInfo]::InvariantCulture)) { Add-AnalysisIssue -Issues $Issues -Code 'invalid-canonical-review-window' -Path $relative }
            foreach ($field in @('source_refs', 'parent_refs', 'related_refs', 'decision_refs', 'acceptance_refs', 'verification_refs')) {
                foreach ($reference in @($data[$field])) {
                    $allowSource = $field -ceq 'source_refs'
                    [void](Test-AndRecordMachineReference -Issues $Issues -RepositoryRoot $RepositoryRoot -SourcePath $file.FullName -Reference ([string]$reference) -Label 'canonical-reference' -AllowHttps:$allowSource -AllowLogical:$allowSource)
                }
            }
            foreach ($provenanceRef in @($data.provenance_refs)) {
                if ([string]$provenanceRef -cnotmatch $safeUserRefPattern -and [string]$provenanceRef -cnotmatch $safeEvidenceRefPattern) { Add-AnalysisIssue -Issues $Issues -Code 'invalid-provenance-ref' -Path $relative }
            }
            $artifacts.Add([pscustomobject]@{ Id=$id; Kind=[string]$data.artifact_kind; Status=[string]$data.status; Contract=$contract; Data=$data; Body=$parsed.Body; Path=$relative; FullPath=$file.FullName }) | Out-Null
        }
        catch { Add-AnalysisIssue -Issues $Issues -Code 'unreadable-canonical-artifact' -Path $relative }
    }
    return @($artifacts)
}

function Get-ArtifactTargetKinds {
    param([Parameter(Mandatory = $true)][string]$RepositoryRoot, [Parameter(Mandatory = $true)]$Artifact, [Parameter(Mandatory = $true)][string[]]$Fields, [Parameter(Mandatory = $true)][hashtable]$ByPath)
    $kinds = [System.Collections.Generic.List[string]]::new()
    foreach ($field in $Fields) {
        foreach ($reference in @($Artifact.Data[$field])) {
            try {
                $resolved = Resolve-ModelProjectSafeReference -Root $RepositoryRoot -SourcePath $Artifact.FullPath -Reference ([string]$reference) -ReferenceBase Repository -AllowHttps:($field -ceq 'source_refs') -AllowLogical:($field -ceq 'source_refs')
                if ($resolved.Kind -ceq 'internal') { $key = ([string]$resolved.RepositoryPath).ToLowerInvariant(); if ($ByPath.ContainsKey($key)) { $kinds.Add([string]$ByPath[$key].Kind) | Out-Null } }
            }
            catch { }
        }
    }
    return @($kinds)
}

function Test-CanonicalSemantics {
    param([Parameter(Mandatory = $true)][System.Collections.Generic.List[string]]$Issues, [Parameter(Mandatory = $true)][string]$RepositoryRoot, [Parameter(Mandatory = $true)][AllowEmptyCollection()][object[]]$Artifacts)
    $byId = @{}; $byPath = @{}
    foreach ($artifact in $Artifacts) { $byId[$artifact.Id.ToUpperInvariant()] = $artifact; $byPath[$artifact.Path.ToLowerInvariant()] = $artifact }
    foreach ($artifact in $Artifacts) {
        $data = $artifact.Data; $status = $artifact.Status; $path = $artifact.Path
        $approvalIsNull = $null -eq $data.approval_ref; $approvedAtIsNull = $null -eq $data.approved_at; $approvedByIsNull = $null -eq $data.approved_by
        if ($status -cin @('draft', 'in-review', 'rejected') -and (-not $approvalIsNull -or -not $approvedAtIsNull -or -not $approvedByIsNull)) { Add-AnalysisIssue -Issues $Issues -Code 'unexpected-approval-fields' -Path $path }
        if ($status -ceq 'draft' -and $null -ne $data.supersedes_ref) { Add-AnalysisIssue -Issues $Issues -Code 'draft-supersedes-not-null' -Path $path }
        if ($status -ceq 'approved') {
            if ($data.approval_ref -isnot [string] -or [string]$data.approval_ref -cnotmatch $safeUserRefPattern -or -not (Test-StrictDate -Value $data.approved_at) -or
                $data.approved_by -isnot [string] -or [string]::IsNullOrWhiteSpace([string]$data.approved_by)) { Add-AnalysisIssue -Issues $Issues -Code 'approved-without-direct-authority' -Path $path }
            $hasSource = @($data.source_refs).Count -gt 0 -or ([string]$data.capture_basis -ceq 'explicit-user-capture' -and @($data.provenance_refs | Where-Object { [string]$_ -cmatch $safeUserRefPattern }).Count -gt 0)
            if (-not $hasSource) { Add-AnalysisIssue -Issues $Issues -Code 'approved-without-source' -Path $path }
            if (@($data.acceptance_refs).Count -eq 0 -and @($data.verification_refs).Count -eq 0) { Add-AnalysisIssue -Issues $Issues -Code 'approved-without-acceptance-or-verification' -Path $path }
        }
        if ($status -ceq 'in-review' -or $status -ceq 'rejected') {
            $decisionKinds = Get-ArtifactTargetKinds -RepositoryRoot $RepositoryRoot -Artifact $artifact -Fields @('decision_refs') -ByPath $byPath
            if ($decisionKinds -cnotcontains 'review-decision') { Add-AnalysisIssue -Issues $Issues -Code 'status-without-review-decision' -Path $path }
        }
        $basis = [string]$data.capture_basis; $provenance = @($data.provenance_refs)
        $analysisRunIds = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
        $analysisDecisionRefs = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
        foreach ($sourceRef in @($data.source_refs)) {
            if ([string]$sourceRef -cmatch '^analysis/runs/(?<run>[^/]+)/(?<asset>[^/#]+\.md)(?:#[^#]+)?$') {
                $analysisRunIds.Add([string]$Matches['run']) | Out-Null
                if ([string]$Matches['asset'] -ceq 'decision.md') { $analysisDecisionRefs.Add("analysis/runs/$([string]$Matches['run'])/decision.md") | Out-Null }
            }
        }
        foreach ($analysisRunId in $analysisRunIds) {
            $decisionRef = "analysis/runs/$analysisRunId/decision.md"
            if (-not $analysisDecisionRefs.Contains($decisionRef)) { Add-AnalysisIssue -Issues $Issues -Code 'analysis-source-without-decision' -Path $path; continue }
            try {
                $decisionPath = Join-Path $RepositoryRoot $decisionRef.Replace('/', '\')
                $decisionDocument = Read-ClosedFrontMatter -Text (Read-SafeText -RepositoryRoot $RepositoryRoot -Path $decisionPath -MaxBytes $runFileMaxBytes) -Label $decisionRef
                $decisionData = $decisionDocument.Data
                if ([string]$decisionData.run_status -cne 'completed' -or [string]$decisionData.decision_outcome -cne 'handoff') { Add-AnalysisIssue -Issues $Issues -Code 'canonical-source-requires-completed-handoff' -Path $path; continue }
                $sourceBasis = [string]$decisionData.capture_basis
                if ($sourceBasis -ceq 'research-derived') {
                    if ($basis -cne 'research-derived') { Add-AnalysisIssue -Issues $Issues -Code 'analysis-provenance-basis-mismatch' -Path $path }
                    foreach ($requiredRef in @($decisionData.provenance_refs | Where-Object { [string]$_ -cmatch $safeEvidenceRefPattern })) {
                        if ($provenance -cnotcontains [string]$requiredRef) { Add-AnalysisIssue -Issues $Issues -Code 'analysis-provenance-ref-not-inherited' -Path $path }
                    }
                }
                elseif ($sourceBasis -ceq 'explicit-user-capture') {
                    if ($basis -cnotin @('explicit-user-capture', 'research-derived')) { Add-AnalysisIssue -Issues $Issues -Code 'analysis-provenance-basis-mismatch' -Path $path }
                    foreach ($requiredRef in @($decisionData.provenance_refs | Where-Object { [string]$_ -cmatch $safeUserRefPattern })) {
                        if ($provenance -cnotcontains [string]$requiredRef) { Add-AnalysisIssue -Issues $Issues -Code 'analysis-provenance-ref-not-inherited' -Path $path }
                    }
                }
                elseif ($sourceBasis -cne 'repo-derived') { Add-AnalysisIssue -Issues $Issues -Code 'invalid-analysis-source-provenance' -Path $path }
            }
            catch { Add-AnalysisIssue -Issues $Issues -Code 'invalid-analysis-source-decision' -Path $path }
        }
        $hasDirectResearchSource = @($data.source_refs | Where-Object { [string]$_ -cmatch '^research/runs/[^/]+/decision\.md(?:#[^#]+)?$' }).Count -gt 0
        if ($hasDirectResearchSource -and $basis -cne 'research-derived') { Add-AnalysisIssue -Issues $Issues -Code 'research-source-basis-mismatch' -Path $path }
        if ($basis -ceq 'repo-derived') {
            $repoSources = @($data.source_refs | Where-Object {
                [string]$_ -notmatch '^(?i:https://|logical:)' -and
                -not ([string]$_).StartsWith('analysis/runs/', [System.StringComparison]::Ordinal) -and
                -not ([string]$_).StartsWith('research/runs/', [System.StringComparison]::Ordinal)
            })
            if ($repoSources.Count -eq 0 -or $provenance.Count -ne 0) { Add-AnalysisIssue -Issues $Issues -Code 'invalid-repo-derived-provenance' -Path $path }
        }
        elseif ($basis -ceq 'explicit-user-capture') {
            if (@($provenance | Where-Object { [string]$_ -cmatch $safeUserRefPattern }).Count -eq 0 -or @($data.source_refs).Count -eq 0) { Add-AnalysisIssue -Issues $Issues -Code 'explicit-capture-without-user-provenance' -Path $path }
        }
        elseif ($basis -ceq 'research-derived') {
            $hasDecision = @($data.source_refs | Where-Object { [string]$_ -cmatch '^research/runs/[^/]+/decision\.md(?:#[^#]+)?$' }).Count -gt 0
            $hasEvidence = @($provenance | Where-Object { [string]$_ -cmatch $safeEvidenceRefPattern }).Count -gt 0
            if (-not $hasDecision -or -not $hasEvidence) { Add-AnalysisIssue -Issues $Issues -Code 'invalid-research-derived-provenance' -Path $path }
        }
        if ($artifact.Kind -cin @('functional-requirement', 'nonfunctional-requirement') -and $status -ceq 'approved') {
            $parentKinds = Get-ArtifactTargetKinds -RepositoryRoot $RepositoryRoot -Artifact $artifact -Fields @('parent_refs') -ByPath $byPath
            if (@($parentKinds | Where-Object { $_ -cin @('business-requirement', 'stakeholder', 'capability') }).Count -eq 0) { Add-AnalysisIssue -Issues $Issues -Code 'approved-requirement-without-parent' -Path $path }
        }
        if ($artifact.Kind -ceq 'nonfunctional-requirement' -and $status -ceq 'approved') {
            $hasNumber = $artifact.Body -match '(?<![A-Za-z0-9])[0-9]+(?:[.,][0-9]+)?'; $hasUnit = $artifact.Body -match '(?i)\b(?:ms|s|sec|seconds?|minutes?|hours?|bytes?|kb|mb|gb|%|percent|rps|tps|requests?/s|users?|items?)\b'; $hasCondition = $artifact.Body -match '(?i)\b(?:when|given|under|measured|test|condition|\u043f\u0440\u0438|\u0435\u0441\u043b\u0438|\u0438\u0437\u043c\u0435\u0440|\u043f\u0440\u043e\u0432\u0435\u0440)\b'
            if (-not $hasNumber -or -not $hasUnit -or -not $hasCondition) { Add-AnalysisIssue -Issues $Issues -Code 'nfr-without-measurable-fit-criterion' -Path $path }
        }
        if ($artifact.Kind -ceq 'integration-contract' -and $status -ceq 'approved') {
            $relationKinds = Get-ArtifactTargetKinds -RepositoryRoot $RepositoryRoot -Artifact $artifact -Fields @('parent_refs', 'related_refs') -ByPath $byPath
            if ($relationKinds -cnotcontains 'data-model' -or $relationKinds -cnotcontains 'system-model') { Add-AnalysisIssue -Issues $Issues -Code 'integration-without-data-or-system' -Path $path }
        }
        if ($artifact.Kind -ceq 'specification' -and $status -ceq 'approved') {
            $relationKinds = Get-ArtifactTargetKinds -RepositoryRoot $RepositoryRoot -Artifact $artifact -Fields @('parent_refs', 'related_refs', 'acceptance_refs') -ByPath $byPath
            $hasRequirement = @($relationKinds | Where-Object { $_ -cin @('business-requirement', 'use-case', 'functional-requirement', 'nonfunctional-requirement') }).Count -gt 0
            $hasModel = @($relationKinds | Where-Object { $_ -cin @('data-model', 'integration-contract', 'system-model') }).Count -gt 0
            $hasAcceptance = $relationKinds -ccontains 'acceptance-criterion' -or @($data.verification_refs).Count -gt 0
            $requiredHeadingPatterns = @('^## Purpose, scope .+ non-goals[ \t]*$', '^## Context refs[ \t]*$', '^## Requirement refs[ \t]*$', '^## Model refs[ \t]*$', '^## Acceptance .+ verification[ \t]*$', '^## Risks, security .+ privacy[ \t]*$', '^## Unresolved questions[ \t]*$')
            if (-not $hasRequirement -or -not $hasModel -or -not $hasAcceptance -or @($requiredHeadingPatterns | Where-Object { $artifact.Body -cnotmatch ('(?m)' + $_) }).Count -gt 0) { Add-AnalysisIssue -Issues $Issues -Code 'incomplete-approved-specification' -Path $path }
        }
        if ($null -ne $data.supersedes_ref) {
            $targetId = [string]$data.supersedes_ref
            if ($targetId -cnotmatch '^[A-Z]+-[0-9]{4}$' -or $targetId -ceq $artifact.Id -or -not $byId.ContainsKey($targetId.ToUpperInvariant())) { Add-AnalysisIssue -Issues $Issues -Code 'invalid-supersedes-ref' -Path $path }
            elseif ($byId[$targetId.ToUpperInvariant()].Status -cne 'superseded') { Add-AnalysisIssue -Issues $Issues -Code 'supersedes-target-not-superseded' -Path $path }
        }
    }
    foreach ($artifact in $Artifacts) {
        $seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase); $cursor = $artifact
        while ($null -ne $cursor -and $null -ne $cursor.Data.supersedes_ref) {
            if (-not $seen.Add($cursor.Id)) { Add-AnalysisIssue -Issues $Issues -Code 'supersedes-cycle' -Path $artifact.Path; break }
            $nextId = [string]$cursor.Data.supersedes_ref; if (-not $byId.ContainsKey($nextId.ToUpperInvariant())) { break }; $cursor = $byId[$nextId.ToUpperInvariant()]
        }
    }
}

function Test-SourceRegistrySafety {
    param(
        [Parameter(Mandatory = $true)][System.Collections.Generic.List[string]]$Issues,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string]$SourcePath,
        [Parameter(Mandatory = $true)][string]$RelativePath,
        [Parameter(Mandatory = $true)][string]$Body
    )
    $records = @([regex]::Split($Body, '(?m)^- source_id:[ \t]*') | Select-Object -Skip 1)
    foreach ($record in $records) {
        $requiredFields = @('source_type', 'source_ref', 'primary_origin', 'authority_ref', 'captured_at', 'verified_at', 'rights', 'limitations', 'conflict', 'prompt_injection_detected', 'quarantine_status', 'quarantine_reason', 'redacted_observation')
        foreach ($field in $requiredFields) {
            if (-not [regex]::IsMatch($record, '(?m)^- ' + [regex]::Escape($field) + ':[ \t]*[^\r\n]*$')) { Add-AnalysisIssue -Issues $Issues -Code 'invalid-source-registry-schema' -Path $RelativePath }
        }
        $sourceRefMatch = [regex]::Match($record, '(?m)^- source_ref:[ \t]*(?<value>[^\r\n]+)$')
        if ($sourceRefMatch.Success) {
            $sourceRef = $sourceRefMatch.Groups['value'].Value.Trim()
            if ($sourceRef -cne 'null') { [void](Test-AndRecordMachineReference -Issues $Issues -RepositoryRoot $RepositoryRoot -SourcePath $SourcePath -Reference $sourceRef -Label 'run-source-reference' -AllowHttps -AllowLogical) }
        }
        $authorityMatch = [regex]::Match($record, '(?m)^- authority_ref:[ \t]*(?<value>[^\r\n]+)$')
        if ($authorityMatch.Success) {
            $authorityRef = $authorityMatch.Groups['value'].Value.Trim()
            if ($authorityRef -cne 'null' -and $authorityRef -cnotmatch $safeUserRefPattern) { Add-AnalysisIssue -Issues $Issues -Code 'invalid-run-source-authority' -Path $RelativePath }
        }
        $flagMatch = [regex]::Match($record, '(?m)^- prompt_injection_detected:[ \t]*(?<value>[^\r\n]+)$')
        $statusMatch = [regex]::Match($record, '(?m)^- quarantine_status:[ \t]*(?<value>[^\r\n]+)$')
        $reasonMatch = [regex]::Match($record, '(?m)^- quarantine_reason:[ \t]*(?<value>[^\r\n]+)$')
        if (-not $flagMatch.Success -or -not $statusMatch.Success -or -not $reasonMatch.Success) { Add-AnalysisIssue -Issues $Issues -Code 'invalid-source-quarantine-schema' -Path $RelativePath; continue }
        $flag = $flagMatch.Groups['value'].Value.Trim(); $status = $statusMatch.Groups['value'].Value.Trim(); $reason = $reasonMatch.Groups['value'].Value.Trim()
        if ($flag -cnotin @('true', 'false')) { Add-AnalysisIssue -Issues $Issues -Code 'invalid-prompt-injection-flag' -Path $RelativePath }
        elseif ($flag -ceq 'true' -and ($status -cne 'quarantined' -or $reason -ceq 'null' -or [string]::IsNullOrWhiteSpace($reason))) { Add-AnalysisIssue -Issues $Issues -Code 'invalid-source-quarantine-schema' -Path $RelativePath }
        elseif ($flag -ceq 'false' -and ($status -cne 'clear' -or $reason -cne 'null')) { Add-AnalysisIssue -Issues $Issues -Code 'invalid-source-quarantine-schema' -Path $RelativePath }
    }
}

function Test-RunDirectory {
    param([Parameter(Mandatory = $true)][System.Collections.Generic.List[string]]$Issues, [Parameter(Mandatory = $true)][string]$RepositoryRoot, [Parameter(Mandatory = $true)][System.IO.DirectoryInfo]$Directory)
    $relativeDirectory = Get-SafeRepositoryRelativePath -RepositoryRoot $RepositoryRoot -Path $Directory.FullName
    $runMatch = [regex]::Match($Directory.Name, $runIdPattern)
    if (-not $runMatch.Success) { Add-AnalysisIssue -Issues $Issues -Code 'invalid-run-id' -Path $relativeDirectory; return }
    if (($Directory.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0 -or $null -ne (Get-ModelProjectReparsePointInFullChain -Root $RepositoryRoot -Path $Directory.FullName)) { Add-AnalysisIssue -Issues $Issues -Code 'reparse-run' -Path $relativeDirectory; return }
    $entries = @(Get-ChildItem -LiteralPath $Directory.FullName -Force)
    if ($entries.Count -ne $runFiles.Count) { Add-AnalysisIssue -Issues $Issues -Code 'invalid-run-inventory' -Path $relativeDirectory }
    foreach ($entry in $entries) {
        $entryRelative = Get-SafeRepositoryRelativePath -RepositoryRoot $RepositoryRoot -Path $entry.FullName
        if ($entry.PSIsContainer -or ($entry.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0 -or $entry.Name -cnotin $runFiles) { Add-AnalysisIssue -Issues $Issues -Code 'invalid-run-entry' -Path $entryRelative }
    }
    foreach ($expected in $runFiles) { if (@($entries | Where-Object { $_.Name -ceq $expected }).Count -ne 1) { Add-AnalysisIssue -Issues $Issues -Code 'missing-or-wrong-case-run-file' -Path $relativeDirectory } }

    $parsedFiles = @{}; $totalBytes = [long]0
    foreach ($fileName in $runFiles) {
        $path = Join-Path $Directory.FullName $fileName
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { continue }
        try {
            $item = Get-Item -LiteralPath $path -Force; $totalBytes += [long]$item.Length
            if ($item.Length -gt $runFileMaxBytes) { Add-AnalysisIssue -Issues $Issues -Code 'oversized-run-file' -Path "$relativeDirectory/$fileName"; continue }
            $text = Read-SafeText -RepositoryRoot $RepositoryRoot -Path $path -MaxBytes $runFileMaxBytes
            Test-AndRecordSensitiveText -Issues $Issues -RelativePath "$relativeDirectory/$fileName" -Text $text
            Test-AndRecordMarkdownLinks -Issues $Issues -RepositoryRoot $RepositoryRoot -SourcePath $path -Text $text
            $parsed = Read-ClosedFrontMatter -Text $text -Label "$relativeDirectory/$fileName"
            if (-not (Test-ExactFieldSet -Data $parsed.Data -Expected $runSchemas[$fileName])) { Add-AnalysisIssue -Issues $Issues -Code 'invalid-run-schema' -Path "$relativeDirectory/$fileName"; continue }
            $requiredRunHeadings = switch ($fileName) {
                'analysis.md' { @('Agent assignments', 'Agent findings', 'Conflict resolution', 'Lead synthesis') }
                'review.md' { @('Independent review', 'Red-team verdict') }
                default { @() }
            }
            foreach ($heading in $requiredRunHeadings) {
                if ($parsed.Body -cnotmatch ('(?m)^##[ \t]+' + [regex]::Escape($heading) + '[ \t]*$')) {
                    Add-AnalysisIssue -Issues $Issues -Code 'missing-run-orchestration-heading' -Path "$relativeDirectory/$fileName"
                }
            }
            $parsedFiles[$fileName] = [pscustomobject]@{ Parsed = $parsed; FullPath = $path }
        }
        catch { Add-AnalysisIssue -Issues $Issues -Code 'unreadable-run-file' -Path "$relativeDirectory/$fileName" }
    }
    if ($totalBytes -gt $runCorpusMaxBytes) { Add-AnalysisIssue -Issues $Issues -Code 'oversized-run-corpus' -Path $relativeDirectory }
    if ($parsedFiles.Count -ne $runFiles.Count) { return }

    $first = $parsedFiles['brief.md'].Parsed.Data
    foreach ($fileName in $runFiles) {
        $data = $parsedFiles[$fileName].Parsed.Data; $expectedAsset = [System.IO.Path]::GetFileNameWithoutExtension($fileName)
        if ([string]$data.run_id -cne $Directory.Name -or [string]$data.run_asset -cne $expectedAsset) { Add-AnalysisIssue -Issues $Issues -Code 'run-folder-frontmatter-mismatch' -Path "$relativeDirectory/$fileName" }
        foreach ($field in @('run_id', 'run_status', 'title', 'task_ref', 'created_at')) { if ([string]$data[$field] -cne [string]$first[$field]) { Add-AnalysisIssue -Issues $Issues -Code 'inconsistent-run-frontmatter' -Path "$relativeDirectory/$fileName" } }
        if ([string]$data.run_status -cnotin @('open', 'in-review', 'completed', 'blocked', 'rejected')) { Add-AnalysisIssue -Issues $Issues -Code 'invalid-run-status' -Path "$relativeDirectory/$fileName" }
    }
    $taskRefText = [string]$first.task_ref
    if ($taskRefText -cnotmatch $safeTaskRefPattern -or -not (Test-StrictUtcTimestamp -Value $first.created_at)) {
        Add-AnalysisIssue -Issues $Issues -Code 'invalid-run-identity-metadata' -Path $relativeDirectory
    }
    else {
        $timestampFromId = $runMatch.Groups['date'].Value + $runMatch.Groups['time'].Value
        $timestampFromMetadata = ([string]$first.created_at).Replace('-', '').Replace(':', '').Replace('T', '').Replace('Z', '')
        if ($timestampFromId -cne $timestampFromMetadata) { Add-AnalysisIssue -Issues $Issues -Code 'run-timestamp-mismatch' -Path $relativeDirectory }
    }

    $brief = $parsedFiles['brief.md'].Parsed.Data
    if ($null -ne $brief.intent_id -and ([string]$brief.intent_id -cnotin $analysisIntentIds)) { Add-AnalysisIssue -Issues $Issues -Code 'invalid-analysis-intent' -Path "$relativeDirectory/brief.md" }
    foreach ($field in @('selected_method_refs', 'local_method_refs')) { if (-not (Test-StringList -Value $brief[$field])) { Add-AnalysisIssue -Issues $Issues -Code 'invalid-run-method-list' -Path "$relativeDirectory/brief.md" } }
    if (@($brief.selected_method_refs).Count -gt 2 -or @($brief.local_method_refs).Count -gt 1) { Add-AnalysisIssue -Issues $Issues -Code 'invalid-run-method-selection' -Path "$relativeDirectory/brief.md" }
    foreach ($reference in @($brief.selected_method_refs)) {
        if ([string]$reference -cnotmatch '^mastery/analyst/(?!INDEX\.md$)[a-z0-9-]+\.md#[^#\s]+$') { Add-AnalysisIssue -Issues $Issues -Code 'invalid-analyst-method-ref' -Path "$relativeDirectory/brief.md" }
        else { [void](Test-AndRecordMachineReference -Issues $Issues -RepositoryRoot $RepositoryRoot -SourcePath $parsedFiles['brief.md'].FullPath -Reference ([string]$reference) -Label 'analyst-method-reference') }
    }
    foreach ($reference in @($brief.local_method_refs)) {
        if ([string]$reference -cnotmatch '^mastery/local/(?!INDEX\.md$)[A-Za-z0-9._/-]+\.md#[^#]+$') { Add-AnalysisIssue -Issues $Issues -Code 'invalid-local-method-ref' -Path "$relativeDirectory/brief.md" }
        else { [void](Test-AndRecordMachineReference -Issues $Issues -RepositoryRoot $RepositoryRoot -SourcePath $parsedFiles['brief.md'].FullPath -Reference ([string]$reference) -Label 'local-method-reference') }
    }
    foreach ($fileName in @('requirements.md', 'models.md')) {
        $data = $parsedFiles[$fileName].Parsed.Data
        foreach ($field in @('proposed_ids', 'canonical_target_refs')) { if (-not (Test-StringList -Value $data[$field])) { Add-AnalysisIssue -Issues $Issues -Code 'invalid-run-list' -Path "$relativeDirectory/$fileName" } }
        foreach ($id in @($data.proposed_ids)) { if ($null -eq (Get-ContractById -Id ([string]$id))) { Add-AnalysisIssue -Issues $Issues -Code 'invalid-proposed-id' -Path "$relativeDirectory/$fileName" } }
        foreach ($reference in @($data.canonical_target_refs)) {
            if ([string]$reference -match '^analysis/runs/') { Add-AnalysisIssue -Issues $Issues -Code 'run-used-as-canonical-target' -Path "$relativeDirectory/$fileName" }
            [void](Test-AndRecordMachineReference -Issues $Issues -RepositoryRoot $RepositoryRoot -SourcePath $parsedFiles[$fileName].FullPath -Reference ([string]$reference) -Label 'canonical-target-reference')
        }
    }
    Test-SourceRegistrySafety -Issues $Issues -RepositoryRoot $RepositoryRoot -SourcePath $parsedFiles['sources.md'].FullPath -RelativePath "$relativeDirectory/sources.md" -Body $parsedFiles['sources.md'].Parsed.Body

    $reviewData = $parsedFiles['review.md'].Parsed.Data; $traceabilityData = $parsedFiles['traceability.md'].Parsed.Data; $decisionData = $parsedFiles['decision.md'].Parsed.Data
    if (-not (Test-StringList -Value $reviewData.unresolved_blockers) -or -not (Test-StringList -Value $decisionData.provenance_refs) -or -not (Test-StringList -Value $decisionData.canonical_target_refs) -or
        -not (Test-StringList -Value $decisionData.candidate_ids) -or -not (Test-StringList -Value $decisionData.affected_canon)) { Add-AnalysisIssue -Issues $Issues -Code 'invalid-run-outcome-list' -Path $relativeDirectory }
    if ([string]$traceabilityData.traceability_outcome -cnotin @('pending', 'pass', 'fail')) { Add-AnalysisIssue -Issues $Issues -Code 'invalid-traceability-outcome' -Path "$relativeDirectory/traceability.md" }
    if ([string]$reviewData.review_outcome -cnotin @('pending', 'pass', 'pass-with-actions', 'reject')) { Add-AnalysisIssue -Issues $Issues -Code 'invalid-review-outcome' -Path "$relativeDirectory/review.md" }
    if ([string]$decisionData.decision_outcome -cnotin @('pending', 'handoff', 'no-change', 'blocked', 'rejected')) { Add-AnalysisIssue -Issues $Issues -Code 'invalid-decision-outcome' -Path "$relativeDirectory/decision.md" }
    foreach ($candidateId in @($decisionData.candidate_ids)) {
        if ([string]$candidateId -cnotmatch '^KC-[0-9]{8}-[0-9]{6}-[0-9a-f]{8}$') { Add-AnalysisIssue -Issues $Issues -Code 'invalid-run-candidate-id' -Path "$relativeDirectory/decision.md" }
    }
    if (@($decisionData.candidate_ids | Sort-Object -Unique).Count -ne @($decisionData.candidate_ids).Count) { Add-AnalysisIssue -Issues $Issues -Code 'duplicate-run-candidate-id' -Path "$relativeDirectory/decision.md" }
    if ($null -ne $decisionData.knowledge_outcome -and -not (Test-KnowledgeOutcomeValue -Value $decisionData.knowledge_outcome)) { Add-AnalysisIssue -Issues $Issues -Code 'invalid-run-knowledge-outcome' -Path "$relativeDirectory/decision.md" }
    if ($decisionData.knowledge_outcome -is [string] -and [string]$decisionData.knowledge_outcome -cmatch '^(?:ready|applied):(?<candidate>KC-[0-9]{8}-[0-9]{6}-[0-9a-f]{8})$' -and
        @($decisionData.candidate_ids) -cnotcontains [string]$Matches['candidate']) { Add-AnalysisIssue -Issues $Issues -Code 'run-knowledge-candidate-mismatch' -Path "$relativeDirectory/decision.md" }
    foreach ($reference in @($decisionData.canonical_target_refs) + @($decisionData.affected_canon)) {
        if ([string]$reference -match '^analysis/runs/') { Add-AnalysisIssue -Issues $Issues -Code 'run-used-as-canonical-target' -Path "$relativeDirectory/decision.md" }
        [void](Test-AndRecordMachineReference -Issues $Issues -RepositoryRoot $RepositoryRoot -SourcePath $parsedFiles['decision.md'].FullPath -Reference ([string]$reference) -Label 'decision-target-reference')
    }
    foreach ($authority in @($brief.authority_ref, $decisionData.authority_ref)) {
        if ($null -ne $authority -and ($authority -isnot [string] -or [string]$authority -cnotmatch $safeUserRefPattern)) { Add-AnalysisIssue -Issues $Issues -Code 'invalid-run-authority' -Path $relativeDirectory }
    }
    $runStatus = [string]$first.run_status; $outcome = [string]$decisionData.decision_outcome
    if ($runStatus -cin @('completed', 'blocked', 'rejected') -and -not (Test-KnowledgeOutcomeValue -Value $decisionData.knowledge_outcome)) { Add-AnalysisIssue -Issues $Issues -Code 'terminal-run-without-knowledge-outcome' -Path $relativeDirectory }
    if ([string]$decisionData.knowledge_outcome -ceq 'blocked' -and ($decisionData.blocked_reason -isnot [string] -or [string]::IsNullOrWhiteSpace([string]$decisionData.blocked_reason))) { Add-AnalysisIssue -Issues $Issues -Code 'blocked-knowledge-without-reason' -Path "$relativeDirectory/decision.md" }
    if ($runStatus -ceq 'completed') {
        if ([string]$reviewData.review_outcome -cnotin @('pass', 'pass-with-actions', 'reject') -or [string]$traceabilityData.traceability_outcome -cne 'pass' -or
            $outcome -cnotin @('handoff', 'no-change', 'blocked', 'rejected')) { Add-AnalysisIssue -Issues $Issues -Code 'incomplete-completed-run' -Path $relativeDirectory }
        if ($outcome -cin @('handoff', 'no-change') -and (@($reviewData.unresolved_blockers).Count -ne 0 -or $null -ne $decisionData.blocked_reason)) { Add-AnalysisIssue -Issues $Issues -Code 'completed-run-has-blockers' -Path $relativeDirectory }
        if (($outcome -ceq 'handoff' -and @($decisionData.canonical_target_refs).Count -eq 0) -or ($outcome -cne 'handoff' -and @($decisionData.canonical_target_refs).Count -ne 0)) { Add-AnalysisIssue -Issues $Issues -Code 'invalid-completed-run-targets' -Path $relativeDirectory }
        if ($outcome -ceq 'handoff') {
            if ($decisionData.authority_ref -isnot [string] -or [string]$decisionData.authority_ref -cnotmatch $safeUserRefPattern) { Add-AnalysisIssue -Issues $Issues -Code 'handoff-without-direct-authority' -Path "$relativeDirectory/decision.md" }
            if ([string]$decisionData.capture_basis -cnotin @('repo-derived', 'explicit-user-capture', 'research-derived')) { Add-AnalysisIssue -Issues $Issues -Code 'handoff-without-capture-basis' -Path "$relativeDirectory/decision.md" }
            $registeredSourceRefs = @([regex]::Matches($parsedFiles['sources.md'].Parsed.Body, '(?m)^- source_ref:[ \t]*(?<value>[^\r\n]+)$') | ForEach-Object { $_.Groups['value'].Value.Trim() } | Where-Object { $_ -cne 'null' })
            foreach ($provenanceRef in @($decisionData.provenance_refs)) {
                if ([string]$provenanceRef -cnotmatch $safeUserRefPattern -and [string]$provenanceRef -cnotmatch $safeEvidenceRefPattern) { Add-AnalysisIssue -Issues $Issues -Code 'invalid-run-provenance-ref' -Path "$relativeDirectory/decision.md" }
            }
            if ([string]$decisionData.capture_basis -ceq 'repo-derived') {
                $repoSources = @($registeredSourceRefs | Where-Object { [string]$_ -notmatch '^(?i:https://|logical:|research/runs/|analysis/runs/)' })
                if ($repoSources.Count -eq 0 -or @($decisionData.provenance_refs).Count -ne 0) { Add-AnalysisIssue -Issues $Issues -Code 'handoff-without-repo-provenance' -Path "$relativeDirectory/decision.md" }
            }
            if ([string]$decisionData.capture_basis -ceq 'explicit-user-capture' -and (@($decisionData.provenance_refs | Where-Object { [string]$_ -cmatch $safeUserRefPattern }).Count -eq 0 -or $registeredSourceRefs.Count -eq 0)) { Add-AnalysisIssue -Issues $Issues -Code 'handoff-without-user-provenance' -Path "$relativeDirectory/decision.md" }
            if ([string]$decisionData.capture_basis -ceq 'research-derived' -and (@($decisionData.provenance_refs | Where-Object { [string]$_ -cmatch $safeEvidenceRefPattern }).Count -eq 0 -or @($registeredSourceRefs | Where-Object { [string]$_ -cmatch '^research/runs/[^/]+/decision\.md(?:#[^#]+)?$' }).Count -eq 0)) { Add-AnalysisIssue -Issues $Issues -Code 'handoff-without-research-provenance' -Path "$relativeDirectory/decision.md" }
        }
        elseif ($outcome -ceq 'blocked' -and ($decisionData.blocked_reason -isnot [string] -or [string]::IsNullOrWhiteSpace([string]$decisionData.blocked_reason))) { Add-AnalysisIssue -Issues $Issues -Code 'completed-blocked-without-reason' -Path $relativeDirectory }
        elseif ($outcome -ceq 'rejected' -and [string]$reviewData.review_outcome -cne 'reject') { Add-AnalysisIssue -Issues $Issues -Code 'completed-rejected-without-review-reject' -Path $relativeDirectory }
    }
    elseif ($runStatus -ceq 'blocked' -and ($outcome -cne 'blocked' -or $decisionData.blocked_reason -isnot [string] -or [string]::IsNullOrWhiteSpace([string]$decisionData.blocked_reason))) { Add-AnalysisIssue -Issues $Issues -Code 'blocked-run-without-reason' -Path $relativeDirectory }
    elseif ($runStatus -ceq 'rejected' -and ($outcome -cne 'rejected' -or [string]$reviewData.review_outcome -cne 'reject')) { Add-AnalysisIssue -Issues $Issues -Code 'rejected-run-without-review-reject' -Path $relativeDirectory }
}

function Test-AnalysisRuns {
    param([Parameter(Mandatory = $true)][System.Collections.Generic.List[string]]$Issues, [Parameter(Mandatory = $true)][string]$RepositoryRoot, $ProjectMode)
    $runsRoot = Join-Path $RepositoryRoot 'analysis\runs'
    if (-not (Test-Path -LiteralPath $runsRoot -PathType Container)) { Add-AnalysisIssue -Issues $Issues -Code 'missing-analysis-runs' -Path 'analysis/runs'; return }
    if ($null -ne (Get-ModelProjectReparsePointInFullChain -Root $RepositoryRoot -Path $runsRoot)) { Add-AnalysisIssue -Issues $Issues -Code 'reparse-analysis-runs' -Path 'analysis/runs'; return }
    $entries = @(Get-ChildItem -LiteralPath $runsRoot -Force | Where-Object { $_.Name -cne '.gitkeep' })
    if ($null -ne $ProjectMode -and $ProjectMode.Kind -ceq 'template-source' -and $entries.Count -gt 0) { Add-AnalysisIssue -Issues $Issues -Code 'template-source-run-not-empty' -Path 'analysis/runs'; return }
    if ($entries.Count -gt $maximumRuns) { Add-AnalysisIssue -Issues $Issues -Code 'run-count-exhaustion' -Path 'analysis/runs'; return }
    foreach ($entry in $entries) {
        $relative = Get-SafeRepositoryRelativePath -RepositoryRoot $RepositoryRoot -Path $entry.FullName
        if (-not $entry.PSIsContainer) { Add-AnalysisIssue -Issues $Issues -Code 'non-directory-run-entry' -Path $relative; continue }
        Test-RunDirectory -Issues $Issues -RepositoryRoot $RepositoryRoot -Directory $entry
    }
}

function Get-ReachableMarkdownPaths {
    param([Parameter(Mandatory = $true)][string]$RepositoryRoot, [Parameter(Mandatory = $true)][System.Collections.Generic.List[string]]$Issues)
    $reachable = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase); $queue = [System.Collections.Generic.Queue[string]]::new(); $rootIndex = Join-Path $RepositoryRoot 'INDEX.md'
    if (-not (Test-Path -LiteralPath $rootIndex -PathType Leaf)) { return $reachable }
    $queue.Enqueue($rootIndex); $visitedCount = 0; $corpusBytes = [long]0
    while ($queue.Count -gt 0) {
        $path = $queue.Dequeue(); $relative = Get-SafeRepositoryRelativePath -RepositoryRoot $RepositoryRoot -Path $path
        if (-not $reachable.Add($relative)) { continue }; $visitedCount++
        if ($visitedCount -gt $maximumMarkdownFilesForReachability) { Add-AnalysisIssue -Issues $Issues -Code 'markdown-reachability-exhaustion'; break }
        try {
            $item = Get-Item -LiteralPath $path -Force; $corpusBytes += [long]$item.Length
            if ($corpusBytes -gt $reachabilityCorpusMaxBytes) { Add-AnalysisIssue -Issues $Issues -Code 'markdown-reachability-corpus-exhaustion'; break }
            $text = Read-SafeText -RepositoryRoot $RepositoryRoot -Path $path -MaxBytes 2MB
        }
        catch { continue }
        foreach ($target in (Get-MarkdownLinkTargets -Text $text)) {
            if ($target.StartsWith('#')) { continue }
            try {
                $resolved = Resolve-ModelProjectSafeReference -Root $RepositoryRoot -SourcePath $path -Reference $target -ReferenceBase File -AllowHttps
                if ($resolved.Kind -ceq 'internal' -and $resolved.Exists -and $resolved.ExactCase -and [System.IO.Path]::GetExtension([string]$resolved.FullPath) -ceq '.md') { $queue.Enqueue([string]$resolved.FullPath) }
            }
            catch { }
        }
    }
    return $reachable
}

function Test-CanonicalReachability {
    param([Parameter(Mandatory = $true)][System.Collections.Generic.List[string]]$Issues, [Parameter(Mandatory = $true)][string]$RepositoryRoot, [Parameter(Mandatory = $true)][AllowEmptyCollection()][object[]]$Artifacts)
    $reachable = Get-ReachableMarkdownPaths -RepositoryRoot $RepositoryRoot -Issues $Issues
    foreach ($artifact in $Artifacts) { if (-not $reachable.Contains($artifact.Path)) { Add-AnalysisIssue -Issues $Issues -Code 'orphan-canonical-artifact' -Path $artifact.Path } }
}

function Test-ForbiddenAnalysisTargets {
    param([Parameter(Mandatory = $true)][System.Collections.Generic.List[string]]$Issues, [Parameter(Mandatory = $true)][string]$RepositoryRoot)
    foreach ($zone in @('knowledge/candidates', 'plans', 'retrospectives', 'research/runs', 'docs/decisions')) {
        $directory = Join-Path $RepositoryRoot $zone.Replace('/', '\'); if (-not (Test-Path -LiteralPath $directory -PathType Container)) { continue }
        foreach ($file in @(Get-SafeRecursiveMarkdownFiles -Issues $Issues -RepositoryRoot $RepositoryRoot -Directory $directory -RelativeDirectory $zone)) {
            $relative = Get-SafeRepositoryRelativePath -RepositoryRoot $RepositoryRoot -Path $file.FullName
            try {
                $text = Read-SafeText -RepositoryRoot $RepositoryRoot -Path $file.FullName -MaxBytes 2MB; if ($text -notmatch '(?m)^---[ \t]*$') { continue }
                $parsed = Read-ClosedFrontMatter -Text $text -Label $relative
                foreach ($field in @('target_ref', 'affected_canon', 'canonical_target_refs')) {
                    if (-not $parsed.Data.ContainsKey($field)) { continue }
                    foreach ($reference in @($parsed.Data[$field])) { if ([string]$reference -match '^analysis/runs/') { Add-AnalysisIssue -Issues $Issues -Code 'analysis-run-forbidden-as-target' -Path $relative } }
                }
            }
            catch { }
        }
    }
}

function Invoke-AnalysisVerification {
    param([Parameter(Mandatory = $true)][string]$RepositoryRoot)
    $issues = New-IssueList; $mode = Get-ProjectMode -Issues $issues -RepositoryRoot $RepositoryRoot
    foreach ($required in @('analysis/CONTRACT.md', 'analysis/INDEX.md', 'mastery/analyst/INDEX.md')) {
        $path = Join-Path $RepositoryRoot $required.Replace('/', '\'); if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { Add-AnalysisIssue -Issues $issues -Code 'missing-analysis-contract-file' -Path $required }
    }
    $canonicalFiles = @(Get-CanonicalFiles -Issues $issues -RepositoryRoot $RepositoryRoot)
    $artifacts = @(Read-CanonicalArtifacts -Issues $issues -RepositoryRoot $RepositoryRoot -Files $canonicalFiles)
    Test-CanonicalSemantics -Issues $issues -RepositoryRoot $RepositoryRoot -Artifacts $artifacts
    Test-CanonicalReachability -Issues $issues -RepositoryRoot $RepositoryRoot -Artifacts $artifacts
    Test-AnalysisRuns -Issues $issues -RepositoryRoot $RepositoryRoot -ProjectMode $mode
    Test-ForbiddenAnalysisTargets -Issues $issues -RepositoryRoot $RepositoryRoot
    $runCount = 0; $runRoot = Join-Path $RepositoryRoot 'analysis\runs'; if (Test-Path -LiteralPath $runRoot) { $runCount = @(Get-ChildItem -LiteralPath $runRoot -Directory -Force).Count }
    return [pscustomobject]@{ Issues=@($issues | Where-Object { $_ -cne '__sentinel__' } | Sort-Object -Unique); ProjectMode=$mode; CanonicalCount=@($artifacts).Count; RunCount=$runCount }
}

function Write-Utf8FixtureFile {
    param([Parameter(Mandatory = $true)][string]$Base, [Parameter(Mandatory = $true)][string]$Relative, [Parameter(Mandatory = $true)][string]$Content)
    $path = Join-Path $Base $Relative.Replace('/', '\'); $parent = Split-Path -Parent $path
    [System.IO.Directory]::CreateDirectory($parent) | Out-Null; [System.IO.File]::WriteAllText($path, $Content, $utf8NoBom)
}

function New-SelfTestFixture {
    param([Parameter(Mandatory = $true)][string]$Base)
    [System.IO.Directory]::CreateDirectory($Base) | Out-Null
    Write-Utf8FixtureFile -Base $Base -Relative 'PROJECT.md' -Content @'
---
repository_kind: generated-project
project_status: initialized
project_id: "fixture"
knowledge_contract_version: 1
knowledge_capture_mode: report-only
---

# Fixture
'@
    Write-Utf8FixtureFile -Base $Base -Relative 'INDEX.md' -Content "# Fixture`n`n- [Analysis](analysis/INDEX.md)`n- [Business analysis](business/analysis/INDEX.md)`n- [System analysis](docs/analysis/INDEX.md)`n"
    Write-Utf8FixtureFile -Base $Base -Relative 'analysis/INDEX.md' -Content "# Analysis`n"
    Write-Utf8FixtureFile -Base $Base -Relative 'analysis/CONTRACT.md' -Content "# Contract`n"
    Write-Utf8FixtureFile -Base $Base -Relative 'business/analysis/INDEX.md' -Content "# Business analysis`n"
    Write-Utf8FixtureFile -Base $Base -Relative 'docs/analysis/INDEX.md' -Content "# System analysis`n"
    Write-Utf8FixtureFile -Base $Base -Relative 'mastery/analyst/INDEX.md' -Content "# Analyst`n"
    foreach ($owner in @($artifactContracts.Owner | Sort-Object -Unique)) { [System.IO.Directory]::CreateDirectory((Join-Path $Base $owner.Replace('/', '\'))) | Out-Null }
    foreach ($derived in @('docs/analysis/context', 'docs/analysis/traceability')) {
        [System.IO.Directory]::CreateDirectory((Join-Path $Base $derived.Replace('/', '\'))) | Out-Null
        Write-Utf8FixtureFile -Base $Base -Relative "$derived/README.md" -Content "# View`n"
        Write-Utf8FixtureFile -Base $Base -Relative "$derived/TEMPLATE.md" -Content "# Template`n"
    }
    [System.IO.Directory]::CreateDirectory((Join-Path $Base 'analysis\runs')) | Out-Null
    foreach ($zone in @('knowledge/candidates', 'plans', 'retrospectives', 'research/runs', 'docs/decisions')) { [System.IO.Directory]::CreateDirectory((Join-Path $Base $zone.Replace('/', '\'))) | Out-Null }
}

function New-SelfTestRun {
    param(
        [Parameter(Mandatory = $true)][string]$Base,
        [Parameter(Mandatory = $true)][string]$RunId,
        [string]$Status = 'open',
        [string]$DecisionOutcome = 'pending',
        [string]$ReviewOutcome = 'pending',
        [string]$TraceabilityOutcome = 'pending',
        [string]$KnowledgeOutcome = 'null'
    )
    $runDirectory = Join-Path $Base "analysis\runs\$RunId"; [System.IO.Directory]::CreateDirectory($runDirectory) | Out-Null
    $date = $RunId.Substring(4, 8); $time = $RunId.Substring(13, 6)
    $created = '{0}-{1}-{2}T{3}:{4}:{5}Z' -f $date.Substring(0,4),$date.Substring(4,2),$date.Substring(6,2),$time.Substring(0,2),$time.Substring(2,2),$time.Substring(4,2)
    foreach ($fileName in $runFiles) {
        $asset = [System.IO.Path]::GetFileNameWithoutExtension($fileName)
        $extras = switch ($fileName) {
            'brief.md' { "intent_id: null`nauthority_ref: null`nselected_method_refs: []`nlocal_method_refs: []" }
            'requirements.md' { "proposed_ids: []`ncanonical_target_refs: []" }
            'models.md' { "proposed_ids: []`ncanonical_target_refs: []" }
            'traceability.md' { "traceability_outcome: $TraceabilityOutcome" }
            'review.md' { "review_outcome: $ReviewOutcome`nunresolved_blockers: []" }
            'decision.md' { "decision_outcome: $DecisionOutcome`ncapture_basis: null`nprovenance_refs: []`ncanonical_target_refs: []`nauthority_ref: null`nknowledge_outcome: $KnowledgeOutcome`ncandidate_ids: []`naffected_canon: []`nblocked_reason: null" }
            default { '' }
        }
        $body = switch ($fileName) {
            'analysis.md' { "# analysis`n`n## Agent assignments`n`n## Agent findings`n`n## Conflict resolution`n`n## Lead synthesis`n" }
            'review.md' { "# review`n`n## Independent review`n`n## Red-team verdict`n" }
            default { "# $asset`n" }
        }
        if ($fileName -ceq 'sources.md') {
            $body = @'
# Sources

- source_id: null
- source_type: null
- source_ref: null
- primary_origin: null
- authority_ref: null
- captured_at: null
- verified_at: null
- rights: null
- limitations: null
- conflict: null
- prompt_injection_detected: false
- quarantine_status: clear
- quarantine_reason: null
- redacted_observation: null
'@
        }
        $content = "---`nrun_id: `"$RunId`"`nrun_asset: $asset`nrun_status: $Status`ntitle: `"Fixture run`"`ntask_ref: fixture-task`ncreated_at: `"$created`""
        if (-not [string]::IsNullOrWhiteSpace($extras)) { $content += "`n$extras" }
        $content += "`n---`n`n$body"
        Write-Utf8FixtureFile -Base $Base -Relative "analysis/runs/$RunId/$fileName" -Content $content
    }
}

function ConvertTo-FixtureYamlList {
    param([string[]]$Values)
    if ($null -eq $Values -or @($Values).Count -eq 0) { return '[]' }
    $items = @(@($Values) | ForEach-Object { "  - $_" })
    return "`n" + [string]::Join("`n", $items)
}

function New-SelfTestCanonicalArtifact {
    param(
        [Parameter(Mandatory = $true)][string]$Base,
        [Parameter(Mandatory = $true)][string]$Id,
        [string]$Slug = 'fixture',
        [string]$Status = 'draft',
        [string]$CaptureBasis = 'repo-derived',
        [string[]]$ProvenanceRefs = @(),
        [string[]]$SourceRefs = @('PROJECT.md'),
        [string[]]$ParentRefs = @(),
        [string[]]$RelatedRefs = @(),
        [string[]]$DecisionRefs = @(),
        [string[]]$AcceptanceRefs = @(),
        [string[]]$VerificationRefs = @(),
        [AllowNull()][string]$SupersedesRef = $null,
        [AllowNull()][string]$ApprovalRef = $null,
        [string]$Body = '# Fixture artifact'
    )
    $contract = Get-ContractById -Id $Id
    if ($null -eq $contract) { throw 'invalid-selftest-artifact-id' }
    $fileName = $Id.ToLowerInvariant() + '-' + $Slug + '.md'; $relative = $contract.Owner + '/' + $fileName
    $approvedAt = 'null'; $approvedBy = 'null'
    if ($Status -ceq 'approved') {
        if ([string]::IsNullOrWhiteSpace($ApprovalRef)) { $ApprovalRef = 'user-request:fixture-approval' }
        $approvedAt = '2026-08-15'; $approvedBy = 'fixture-owner'
    }
    $approvalText = if ([string]::IsNullOrWhiteSpace($ApprovalRef)) { 'null' } else { $ApprovalRef }
    $supersedesText = if ([string]::IsNullOrWhiteSpace($SupersedesRef)) { 'null' } else { $SupersedesRef }
    $content = @"
---
artifact_kind: $($contract.Kind)
id: $Id
status: $Status
owner_scope: project
capture_basis: $CaptureBasis
provenance_refs: $(ConvertTo-FixtureYamlList $ProvenanceRefs)
source_refs: $(ConvertTo-FixtureYamlList $SourceRefs)
parent_refs: $(ConvertTo-FixtureYamlList $ParentRefs)
related_refs: $(ConvertTo-FixtureYamlList $RelatedRefs)
decision_refs: $(ConvertTo-FixtureYamlList $DecisionRefs)
acceptance_refs: $(ConvertTo-FixtureYamlList $AcceptanceRefs)
verification_refs: $(ConvertTo-FixtureYamlList $VerificationRefs)
supersedes_ref: $supersedesText
approval_ref: $approvalText
approved_at: $approvedAt
approved_by: $approvedBy
created_at: 2026-08-15
verified_at: 2026-08-15
review_due: 2027-02-15
---

$Body
"@
    Write-Utf8FixtureFile -Base $Base -Relative $relative -Content $content
    $indexPath = Join-Path $Base 'INDEX.md'; $indexText = [System.IO.File]::ReadAllText($indexPath, $strictUtf8)
    $linkLine = "- [$Id]($relative)"
    if ($indexText -notmatch ('(?m)^' + [regex]::Escape($linkLine) + '$')) { [System.IO.File]::WriteAllText($indexPath, $indexText.TrimEnd() + "`n$linkLine`n", $utf8NoBom) }
    return $relative
}

function Assert-SelfTestFinding {
    param([Parameter(Mandatory = $true)]$Result, [Parameter(Mandatory = $true)][string]$Pattern, [Parameter(Mandatory = $true)][string]$Name)
    if (@($Result.Issues | Where-Object { $_ -match $Pattern }).Count -eq 0) { throw $Name }
}

function Remove-OwnedSelfTestRoot {
    param([Parameter(Mandatory = $true)][string]$Path)
    $full = [System.IO.Path]::GetFullPath($Path).TrimEnd([char[]]'\/'); $leaf = [System.IO.Path]::GetFileName($full); $parent = [System.IO.Path]::GetDirectoryName($full)
    $temp = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath()).TrimEnd([char[]]'\/')
    if (-not $parent.Equals($temp, [System.StringComparison]::OrdinalIgnoreCase) -or $leaf -cnotmatch '^model-project-analysis-selftest-[0-9a-f]{32}$') { throw 'Refusing to remove unowned self-test path.' }
    if (Test-Path -LiteralPath $full) { [System.IO.Directory]::Delete($full, $true) }
}

function Invoke-AnalysisSelfTest {
    $base = Join-Path ([System.IO.Path]::GetTempPath()) ("model-project-analysis-selftest-" + [guid]::NewGuid().ToString('N')); $passed = [System.Collections.Generic.List[string]]::new()
    try {
        New-SelfTestFixture -Base $base
        $result = Invoke-AnalysisVerification -RepositoryRoot $base
        if ($result.Issues.Count -ne 0) { throw 'positive-empty-generated-project' }; $passed.Add('positive-empty-generated-project') | Out-Null

        $projectPath = Join-Path $base 'PROJECT.md'; $projectOriginal = [System.IO.File]::ReadAllText($projectPath, $strictUtf8)
        $templateProject = $projectOriginal.Replace('repository_kind: generated-project', 'repository_kind: template-source').Replace('project_status: initialized', 'project_status: template').Replace('knowledge_capture_mode: report-only', 'knowledge_capture_mode: disabled')
        [System.IO.File]::WriteAllText($projectPath, $templateProject, $utf8NoBom)
        $result = Invoke-AnalysisVerification -RepositoryRoot $base
        if ($result.Issues.Count -ne 0) { throw 'positive-empty-template-source' }; [System.IO.File]::WriteAllText($projectPath, $projectOriginal, $utf8NoBom); $passed.Add('positive-empty-template-source') | Out-Null

        $runId = 'RUN-20260815-120000-fixture-run-a1b2c3'; New-SelfTestRun -Base $base -RunId $runId
        $result = Invoke-AnalysisVerification -RepositoryRoot $base
        if ($result.Issues.Count -ne 0) { throw 'positive-open-run' }; $passed.Add('positive-open-run') | Out-Null

        $openBriefPath = Join-Path $base "analysis\runs\$runId\brief.md"; $openBriefOriginal = [System.IO.File]::ReadAllText($openBriefPath, $strictUtf8)
        [System.IO.File]::WriteAllText($openBriefPath, ($openBriefOriginal -replace 'intent_id: null', 'intent_id: requirements-validation-near-miss'), $utf8NoBom)
        $result = Invoke-AnalysisVerification -RepositoryRoot $base; Assert-SelfTestFinding -Result $result -Pattern '^invalid-analysis-intent' -Name 'negative-analysis-intent-near-miss'
        [System.IO.File]::WriteAllText($openBriefPath, $openBriefOriginal, $utf8NoBom); $passed.Add('negative-analysis-intent-near-miss') | Out-Null

        $runDirectory = Join-Path $base "analysis\runs\$runId"; $invalidRunDirectory = Join-Path $base 'analysis\runs\invalid-run-id'
        [System.IO.Directory]::Move($runDirectory, $invalidRunDirectory)
        $result = Invoke-AnalysisVerification -RepositoryRoot $base; Assert-SelfTestFinding -Result $result -Pattern '^invalid-run-id' -Name 'negative-invalid-run-id'
        [System.IO.Directory]::Move($invalidRunDirectory, $runDirectory); $passed.Add('negative-invalid-run-id') | Out-Null

        $partialPath = Join-Path $runDirectory 'analysis.md'; $partialOriginal = [System.IO.File]::ReadAllText($partialPath, $strictUtf8); [System.IO.File]::Delete($partialPath)
        $result = Invoke-AnalysisVerification -RepositoryRoot $base; Assert-SelfTestFinding -Result $result -Pattern '^(invalid-run-inventory|missing-or-wrong-case-run-file)' -Name 'negative-partial-run-inventory'
        [System.IO.File]::WriteAllText($partialPath, $partialOriginal, $utf8NoBom); $passed.Add('negative-partial-run-inventory') | Out-Null

        [System.IO.File]::WriteAllText($partialPath, ($partialOriginal -replace '(?m)^## Lead synthesis\r?\n', ''), $utf8NoBom)
        $result = Invoke-AnalysisVerification -RepositoryRoot $base; Assert-SelfTestFinding -Result $result -Pattern '^missing-run-orchestration-heading' -Name 'negative-missing-orchestration-heading'
        [System.IO.File]::WriteAllText($partialPath, $partialOriginal, $utf8NoBom); $passed.Add('negative-missing-orchestration-heading') | Out-Null

        $extraPath = Join-Path $base "analysis\runs\$runId\extra.md"; [System.IO.File]::WriteAllText($extraPath, '# extra', $utf8NoBom)
        $result = Invoke-AnalysisVerification -RepositoryRoot $base
        if (@($result.Issues | Where-Object { $_ -match '^invalid-run-' }).Count -eq 0) { throw 'negative-extra-run-entry' }; [System.IO.File]::Delete($extraPath); $passed.Add('negative-extra-run-entry') | Out-Null

        $briefPath = Join-Path $base "analysis\runs\$runId\brief.md"; $briefOriginal = [System.IO.File]::ReadAllText($briefPath, $strictUtf8)
        [System.IO.File]::WriteAllText($briefPath, ($briefOriginal -replace 'run_id: "[^"]+"', 'run_id: "RUN-20260815-120000-other-a1b2c3"'), $utf8NoBom)
        $result = Invoke-AnalysisVerification -RepositoryRoot $base
        if (@($result.Issues | Where-Object { $_ -match '^run-folder-frontmatter-mismatch' }).Count -eq 0) { throw 'negative-folder-mismatch' }; [System.IO.File]::WriteAllText($briefPath, $briefOriginal, $utf8NoBom); $passed.Add('negative-folder-mismatch') | Out-Null

        $sourcesPath = Join-Path $base "analysis\runs\$runId\sources.md"; $sourcesOriginal = [System.IO.File]::ReadAllText($sourcesPath, $strictUtf8)
        [System.IO.File]::WriteAllText($sourcesPath, ($sourcesOriginal -replace 'prompt_injection_detected: false', 'prompt_injection_detected: maybe'), $utf8NoBom)
        $result = Invoke-AnalysisVerification -RepositoryRoot $base
        if (@($result.Issues | Where-Object { $_ -match '^invalid-prompt-injection-flag' }).Count -eq 0) { throw 'negative-prompt-injection-schema' }; [System.IO.File]::WriteAllText($sourcesPath, $sourcesOriginal, $utf8NoBom); $passed.Add('negative-prompt-injection-schema') | Out-Null

        [System.IO.File]::WriteAllText($sourcesPath, ($sourcesOriginal -replace 'prompt_injection_detected: false', 'prompt_injection_detected: true'), $utf8NoBom)
        $result = Invoke-AnalysisVerification -RepositoryRoot $base; Assert-SelfTestFinding -Result $result -Pattern '^invalid-source-quarantine-schema' -Name 'negative-prompt-quarantine-state'
        [System.IO.File]::WriteAllText($sourcesPath, $sourcesOriginal, $utf8NoBom); $passed.Add('negative-prompt-quarantine-state') | Out-Null

        [System.IO.Directory]::Delete((Join-Path $base "analysis\runs\$runId"), $true); New-SelfTestRun -Base $base -RunId $runId -Status completed -DecisionOutcome no-change -ReviewOutcome pass -TraceabilityOutcome pass -KnowledgeOutcome none
        $result = Invoke-AnalysisVerification -RepositoryRoot $base
        if ($result.Issues.Count -ne 0) { throw 'positive-completed-run' }; $passed.Add('positive-completed-run') | Out-Null

        $reviewPath = Join-Path $base "analysis\runs\$runId\review.md"; $reviewOriginal = [System.IO.File]::ReadAllText($reviewPath, $strictUtf8)
        [System.IO.File]::WriteAllText($reviewPath, ($reviewOriginal -replace 'review_outcome: pass', 'review_outcome: passed'), $utf8NoBom)
        $result = Invoke-AnalysisVerification -RepositoryRoot $base; Assert-SelfTestFinding -Result $result -Pattern '^invalid-review-outcome' -Name 'negative-legacy-passed-outcome'
        [System.IO.File]::WriteAllText($reviewPath, $reviewOriginal, $utf8NoBom); $passed.Add('negative-legacy-passed-outcome') | Out-Null

        $decisionPath = Join-Path $base "analysis\runs\$runId\decision.md"; $decisionOriginal = [System.IO.File]::ReadAllText($decisionPath, $strictUtf8)
        [System.IO.File]::WriteAllText($decisionPath, ($decisionOriginal -replace 'decision_outcome: no-change', 'decision_outcome: pending'), $utf8NoBom)
        $result = Invoke-AnalysisVerification -RepositoryRoot $base
        if (@($result.Issues | Where-Object { $_ -match '^incomplete-completed-run' }).Count -eq 0) { throw 'negative-incomplete-completed-run' }; [System.IO.File]::WriteAllText($decisionPath, $decisionOriginal, $utf8NoBom); $passed.Add('negative-incomplete-completed-run') | Out-Null

        [System.IO.File]::WriteAllText($decisionPath, ($decisionOriginal -replace 'knowledge_outcome: none', 'knowledge_outcome: null'), $utf8NoBom)
        $result = Invoke-AnalysisVerification -RepositoryRoot $base; Assert-SelfTestFinding -Result $result -Pattern '^terminal-run-without-knowledge-outcome' -Name 'negative-terminal-knowledge-outcome'
        [System.IO.File]::WriteAllText($decisionPath, $decisionOriginal, $utf8NoBom); $passed.Add('negative-terminal-knowledge-outcome') | Out-Null

        $safeRepoRef = Resolve-ModelProjectSafeReference -Root $base -SourcePath (Join-Path $base 'analysis\INDEX.md') -Reference 'PROJECT.md' -ReferenceBase Repository
        $badRepoRef = Resolve-ModelProjectSafeReference -Root $base -SourcePath (Join-Path $base 'analysis\INDEX.md') -Reference '../PROJECT.md' -ReferenceBase Repository
        $safeMarkdownRef = Resolve-ModelProjectSafeReference -Root $base -SourcePath (Join-Path $base 'analysis\INDEX.md') -Reference '../PROJECT.md' -ReferenceBase File
        if (-not (Test-ReferenceResultValid -Result $safeRepoRef) -or [string]::IsNullOrWhiteSpace([string]$badRepoRef.Error) -or -not (Test-ReferenceResultValid -Result $safeMarkdownRef)) { throw 'reference-base-separation' }
        $passed.Add('reference-base-separation') | Out-Null

        if (@($artifactContracts.Prefix | Sort-Object -Unique).Count -ne $artifactContracts.Count -or @($artifactContracts.Kind | Sort-Object -Unique).Count -ne $artifactContracts.Count) { throw 'namespace-not-bijective' }
        $passed.Add('namespace-bijection') | Out-Null

        [void](New-SelfTestCanonicalArtifact -Base $base -Id 'STK-0001' -VerificationRefs @('PROJECT.md'))
        $result = Invoke-AnalysisVerification -RepositoryRoot $base
        if ($result.Issues.Count -ne 0) { throw 'positive-draft-canonical-set' }; $passed.Add('positive-draft-canonical-set') | Out-Null

        $br = New-SelfTestCanonicalArtifact -Base $base -Id 'BR-0001' -Status approved -VerificationRefs @('PROJECT.md')
        $ac = New-SelfTestCanonicalArtifact -Base $base -Id 'AC-0001' -Status approved -VerificationRefs @('PROJECT.md')
        $fr = New-SelfTestCanonicalArtifact -Base $base -Id 'FR-0001' -Status approved -ParentRefs @($br) -AcceptanceRefs @($ac)
        $nfr = New-SelfTestCanonicalArtifact -Base $base -Id 'NFR-0001' -Status approved -ParentRefs @($br) -AcceptanceRefs @($ac) -Body "# NFR`n`nUnder repeatable test condition latency is at most 500 ms."
        $dataRef = New-SelfTestCanonicalArtifact -Base $base -Id 'DATA-0001' -Status approved -VerificationRefs @('PROJECT.md')
        $sysRef = New-SelfTestCanonicalArtifact -Base $base -Id 'SYS-0001' -Status approved -VerificationRefs @('PROJECT.md')
        $intRef = New-SelfTestCanonicalArtifact -Base $base -Id 'INT-0001' -Status approved -RelatedRefs @($dataRef, $sysRef) -VerificationRefs @('PROJECT.md')
        $specBody = "# SPEC`n`n## Purpose, scope and non-goals`n`n## Context refs`n`n## Requirement refs`n`n## Model refs`n`n## Acceptance and verification`n`n## Risks, security and privacy`n`n## Unresolved questions`n"
        $specRef = New-SelfTestCanonicalArtifact -Base $base -Id 'SPEC-0001' -Status approved -RelatedRefs @($fr, $dataRef) -AcceptanceRefs @($ac) -VerificationRefs @('PROJECT.md') -Body $specBody
        $result = Invoke-AnalysisVerification -RepositoryRoot $base
        if ($result.Issues.Count -ne 0) { throw 'positive-approved-canonical-set' }; $passed.Add('positive-approved-canonical-set') | Out-Null

        $caseDuplicateRef = New-SelfTestCanonicalArtifact -Base $base -Id 'FR-0002' -Status approved -ParentRefs @($br) -AcceptanceRefs @($ac)
        $caseDuplicatePath = Join-Path $base $caseDuplicateRef.Replace('/', '\'); $caseDuplicateText = [System.IO.File]::ReadAllText($caseDuplicatePath, $strictUtf8)
        [System.IO.File]::WriteAllText($caseDuplicatePath, ($caseDuplicateText -replace 'id: FR-0002', 'id: fr-0001'), $utf8NoBom)
        $result = Invoke-AnalysisVerification -RepositoryRoot $base; Assert-SelfTestFinding -Result $result -Pattern '^duplicate-canonical-id' -Name 'negative-case-insensitive-duplicate-id'
        [System.IO.File]::Delete($caseDuplicatePath); $passed.Add('negative-case-insensitive-duplicate-id') | Out-Null

        $frPath = Join-Path $base $fr.Replace('/', '\'); $frOriginal = [System.IO.File]::ReadAllText($frPath, $strictUtf8)
        $duplicateRef = New-SelfTestCanonicalArtifact -Base $base -Id 'FR-0001' -Slug 'duplicate' -Status approved -ParentRefs @($br) -AcceptanceRefs @($ac)
        $result = Invoke-AnalysisVerification -RepositoryRoot $base; Assert-SelfTestFinding -Result $result -Pattern '^duplicate-canonical-id' -Name 'negative-duplicate-id'
        [System.IO.File]::Delete((Join-Path $base $duplicateRef.Replace('/', '\'))); $passed.Add('negative-duplicate-id') | Out-Null

        [System.IO.File]::WriteAllText($frPath, ($frOriginal -replace 'artifact_kind: functional-requirement', 'artifact_kind: system-model'), $utf8NoBom)
        $result = Invoke-AnalysisVerification -RepositoryRoot $base; Assert-SelfTestFinding -Result $result -Pattern '^canonical-kind-owner-mismatch' -Name 'negative-kind-owner-mismatch'
        [System.IO.File]::WriteAllText($frPath, $frOriginal, $utf8NoBom); $passed.Add('negative-kind-owner-mismatch') | Out-Null

        $wrongNamePath = Join-Path (Split-Path -Parent $frPath) 'fr-0001_wrong.md'; [System.IO.File]::Move($frPath, $wrongNamePath)
        $result = Invoke-AnalysisVerification -RepositoryRoot $base; Assert-SelfTestFinding -Result $result -Pattern '^canonical-filename-mismatch' -Name 'negative-canonical-filename-mismatch'
        [System.IO.File]::Move($wrongNamePath, $frPath); $passed.Add('negative-canonical-filename-mismatch') | Out-Null

        $wrongOwnerPath = Join-Path $base 'docs\analysis\models\fr-0001-fixture.md'; [System.IO.File]::Move($frPath, $wrongOwnerPath)
        $result = Invoke-AnalysisVerification -RepositoryRoot $base; Assert-SelfTestFinding -Result $result -Pattern '^canonical-kind-owner-mismatch' -Name 'negative-canonical-owner-mismatch'
        [System.IO.File]::Move($wrongOwnerPath, $frPath); $passed.Add('negative-canonical-owner-mismatch') | Out-Null

        [System.IO.File]::WriteAllText($frPath, ($frOriginal -replace '  - PROJECT.md', '  - missing-source.md'), $utf8NoBom)
        $result = Invoke-AnalysisVerification -RepositoryRoot $base; Assert-SelfTestFinding -Result $result -Pattern '^invalid-canonical-reference' -Name 'negative-broken-machine-ref'
        [System.IO.File]::WriteAllText($frPath, $frOriginal, $utf8NoBom); $passed.Add('negative-broken-machine-ref') | Out-Null

        [System.IO.File]::WriteAllText($frPath, $frOriginal + "`n[Broken](../../../PROJECT.md#missing-anchor)`n", $utf8NoBom)
        $result = Invoke-AnalysisVerification -RepositoryRoot $base; Assert-SelfTestFinding -Result $result -Pattern '^broken-markdown-link' -Name 'negative-broken-markdown-anchor'
        [System.IO.File]::WriteAllText($frPath, $frOriginal, $utf8NoBom); $passed.Add('negative-broken-markdown-anchor') | Out-Null

        [System.IO.File]::WriteAllText($frPath, $frOriginal + "`n[Missing](../../../missing.md)`n", $utf8NoBom)
        $result = Invoke-AnalysisVerification -RepositoryRoot $base; Assert-SelfTestFinding -Result $result -Pattern '^broken-markdown-link' -Name 'negative-broken-markdown-file'
        [System.IO.File]::WriteAllText($frPath, $frOriginal, $utf8NoBom); $passed.Add('negative-broken-markdown-file') | Out-Null

        [System.IO.File]::WriteAllText($frPath, $frOriginal + "`n[Unsafe](javascript:alert)`n", $utf8NoBom)
        $result = Invoke-AnalysisVerification -RepositoryRoot $base; Assert-SelfTestFinding -Result $result -Pattern '^broken-markdown-link' -Name 'negative-unsafe-markdown-uri'
        [System.IO.File]::WriteAllText($frPath, $frOriginal, $utf8NoBom); $passed.Add('negative-unsafe-markdown-uri') | Out-Null

        [System.IO.File]::WriteAllText($frPath, ($frOriginal -replace '  - PROJECT.md', '  - ../PROJECT.md'), $utf8NoBom)
        $result = Invoke-AnalysisVerification -RepositoryRoot $base; Assert-SelfTestFinding -Result $result -Pattern '^invalid-canonical-reference' -Name 'negative-machine-traversal'
        [System.IO.File]::WriteAllText($frPath, $frOriginal, $utf8NoBom); $passed.Add('negative-machine-traversal') | Out-Null

        [System.IO.File]::WriteAllText($frPath, ($frOriginal -replace '  - PROJECT.md', '  - C:\\unsafe\\absolute.md'), $utf8NoBom)
        $result = Invoke-AnalysisVerification -RepositoryRoot $base; Assert-SelfTestFinding -Result $result -Pattern '^invalid-canonical-reference' -Name 'negative-machine-absolute-path'
        [System.IO.File]::WriteAllText($frPath, $frOriginal, $utf8NoBom); $passed.Add('negative-machine-absolute-path') | Out-Null

        [void](New-SelfTestCanonicalArtifact -Base $base -Id 'FR-0001' -Status approved -SourceRefs @() -ParentRefs @($br) -AcceptanceRefs @($ac))
        $result = Invoke-AnalysisVerification -RepositoryRoot $base; Assert-SelfTestFinding -Result $result -Pattern '^approved-without-source' -Name 'negative-approved-without-source'
        [System.IO.File]::WriteAllText($frPath, $frOriginal, $utf8NoBom); $passed.Add('negative-approved-without-source') | Out-Null

        [void](New-SelfTestCanonicalArtifact -Base $base -Id 'FR-0001' -Status approved -ParentRefs @() -AcceptanceRefs @($ac))
        $result = Invoke-AnalysisVerification -RepositoryRoot $base; Assert-SelfTestFinding -Result $result -Pattern '^approved-requirement-without-parent' -Name 'negative-approved-without-parent'
        [System.IO.File]::WriteAllText($frPath, $frOriginal, $utf8NoBom); $passed.Add('negative-approved-without-parent') | Out-Null

        [void](New-SelfTestCanonicalArtifact -Base $base -Id 'FR-0001' -Status approved -ParentRefs @($br) -ApprovalRef 'docs/decisions/fake.md' -AcceptanceRefs @($ac))
        $result = Invoke-AnalysisVerification -RepositoryRoot $base; Assert-SelfTestFinding -Result $result -Pattern '^approved-without-direct-authority' -Name 'negative-approved-without-direct-authority'
        [System.IO.File]::WriteAllText($frPath, $frOriginal, $utf8NoBom); $passed.Add('negative-approved-without-direct-authority') | Out-Null

        [void](New-SelfTestCanonicalArtifact -Base $base -Id 'FR-0001' -Status approved -ParentRefs @($br) -ApprovalRef "analysis/runs/$runId/decision.md" -AcceptanceRefs @($ac))
        $result = Invoke-AnalysisVerification -RepositoryRoot $base; Assert-SelfTestFinding -Result $result -Pattern '^approved-without-direct-authority' -Name 'negative-same-run-self-approval'
        [System.IO.File]::WriteAllText($frPath, $frOriginal, $utf8NoBom); $passed.Add('negative-same-run-self-approval') | Out-Null

        [void](New-SelfTestCanonicalArtifact -Base $base -Id 'FR-0001' -Status approved -ParentRefs @($br) -AcceptanceRefs @() -VerificationRefs @())
        $result = Invoke-AnalysisVerification -RepositoryRoot $base; Assert-SelfTestFinding -Result $result -Pattern '^approved-without-acceptance-or-verification' -Name 'negative-approved-without-acceptance'
        [System.IO.File]::WriteAllText($frPath, $frOriginal, $utf8NoBom); $passed.Add('negative-approved-without-acceptance') | Out-Null

        $nfrPath = Join-Path $base $nfr.Replace('/', '\'); $nfrOriginal = [System.IO.File]::ReadAllText($nfrPath, $strictUtf8)
        [void](New-SelfTestCanonicalArtifact -Base $base -Id 'NFR-0001' -Status approved -ParentRefs @($br) -AcceptanceRefs @($ac) -Body '# Qualitative only')
        $result = Invoke-AnalysisVerification -RepositoryRoot $base; Assert-SelfTestFinding -Result $result -Pattern '^nfr-without-measurable-fit-criterion' -Name 'negative-nfr-fit-criterion'
        [System.IO.File]::WriteAllText($nfrPath, $nfrOriginal, $utf8NoBom); $passed.Add('negative-nfr-fit-criterion') | Out-Null

        $intPath = Join-Path $base $intRef.Replace('/', '\'); $intOriginal = [System.IO.File]::ReadAllText($intPath, $strictUtf8)
        [void](New-SelfTestCanonicalArtifact -Base $base -Id 'INT-0001' -Status approved -RelatedRefs @($dataRef) -VerificationRefs @('PROJECT.md'))
        $result = Invoke-AnalysisVerification -RepositoryRoot $base; Assert-SelfTestFinding -Result $result -Pattern '^integration-without-data-or-system' -Name 'negative-integration-relations'
        [System.IO.File]::WriteAllText($intPath, $intOriginal, $utf8NoBom); $passed.Add('negative-integration-relations') | Out-Null

        $indexPath = Join-Path $base 'INDEX.md'; $indexOriginal = [System.IO.File]::ReadAllText($indexPath, $strictUtf8); $frLink = "- [FR-0001]($fr)"
        [System.IO.File]::WriteAllText($indexPath, ($indexOriginal -replace ('(?m)^' + [regex]::Escape($frLink) + '\r?\n?'), ''), $utf8NoBom)
        $result = Invoke-AnalysisVerification -RepositoryRoot $base; Assert-SelfTestFinding -Result $result -Pattern '^orphan-canonical-artifact' -Name 'negative-orphan-canonical'
        [System.IO.File]::WriteAllText($indexPath, $indexOriginal, $utf8NoBom); $passed.Add('negative-orphan-canonical') | Out-Null

        Write-Utf8FixtureFile -Base $base -Relative 'plans/forbidden.md' -Content "---`nartifact_kind: plan`nstatus: in-progress`naffected_canon:`n  - analysis/runs/$runId/decision.md`n---`n# Plan`n"
        $result = Invoke-AnalysisVerification -RepositoryRoot $base; Assert-SelfTestFinding -Result $result -Pattern '^analysis-run-forbidden-as-target' -Name 'negative-analysis-run-target'
        [System.IO.File]::Delete((Join-Path $base 'plans\forbidden.md')); $passed.Add('negative-analysis-run-target') | Out-Null

        Write-Utf8FixtureFile -Base $base -Relative 'research/runs/fixture/decision.md' -Content "# Research decision`n"
        $crResearch = New-SelfTestCanonicalArtifact -Base $base -Id 'CR-0001' -SourceRefs @('research/runs/fixture/decision.md')
        $result = Invoke-AnalysisVerification -RepositoryRoot $base; Assert-SelfTestFinding -Result $result -Pattern '^invalid-repo-derived-provenance' -Name 'negative-research-source-repo-derived'
        [System.IO.File]::Delete((Join-Path $base $crResearch.Replace('/', '\'))); $passed.Add('negative-research-source-repo-derived') | Out-Null

        $crExplicit = New-SelfTestCanonicalArtifact -Base $base -Id 'CR-0002' -CaptureBasis 'explicit-user-capture' -ProvenanceRefs @() -SourceRefs @()
        $result = Invoke-AnalysisVerification -RepositoryRoot $base; Assert-SelfTestFinding -Result $result -Pattern '^explicit-capture-without-user-provenance' -Name 'negative-explicit-without-provenance'
        [System.IO.File]::Delete((Join-Path $base $crExplicit.Replace('/', '\'))); $passed.Add('negative-explicit-without-provenance') | Out-Null

        $crSecret = New-SelfTestCanonicalArtifact -Base $base -Id 'CR-0003' -Body 'api_key=abcdefgh12345678'
        $result = Invoke-AnalysisVerification -RepositoryRoot $base; Assert-SelfTestFinding -Result $result -Pattern '^sensitive-credential-value' -Name 'negative-sensitive-content'
        [System.IO.File]::Delete((Join-Path $base $crSecret.Replace('/', '\'))); $passed.Add('negative-sensitive-content') | Out-Null

        $crCredentialUrl = New-SelfTestCanonicalArtifact -Base $base -Id 'CR-0003' -Slug 'credential-url' -Body 'https://user:secret@example.com/path'
        $result = Invoke-AnalysisVerification -RepositoryRoot $base; Assert-SelfTestFinding -Result $result -Pattern '^sensitive-https-url-userinfo' -Name 'negative-credential-url'
        [System.IO.File]::Delete((Join-Path $base $crCredentialUrl.Replace('/', '\'))); $passed.Add('negative-credential-url') | Out-Null

        $crPii = New-SelfTestCanonicalArtifact -Base $base -Id 'CR-0003' -Slug 'pii' -Body 'Contact test@example.com'
        $result = Invoke-AnalysisVerification -RepositoryRoot $base; Assert-SelfTestFinding -Result $result -Pattern '^sensitive-email-or-pii' -Name 'negative-known-pii'
        [System.IO.File]::Delete((Join-Path $base $crPii.Replace('/', '\'))); $passed.Add('negative-known-pii') | Out-Null

        $crSelf = New-SelfTestCanonicalArtifact -Base $base -Id 'CR-0006' -Status approved -SupersedesRef 'CR-0006' -VerificationRefs @('PROJECT.md')
        $result = Invoke-AnalysisVerification -RepositoryRoot $base; Assert-SelfTestFinding -Result $result -Pattern '^invalid-supersedes-ref' -Name 'negative-supersedes-self'
        [System.IO.File]::Delete((Join-Path $base $crSelf.Replace('/', '\'))); $passed.Add('negative-supersedes-self') | Out-Null

        $crMissing = New-SelfTestCanonicalArtifact -Base $base -Id 'CR-0006' -Status approved -SupersedesRef 'CR-9999' -VerificationRefs @('PROJECT.md')
        $result = Invoke-AnalysisVerification -RepositoryRoot $base; Assert-SelfTestFinding -Result $result -Pattern '^invalid-supersedes-ref' -Name 'negative-supersedes-missing'
        [System.IO.File]::Delete((Join-Path $base $crMissing.Replace('/', '\'))); $passed.Add('negative-supersedes-missing') | Out-Null

        $crCycleA = New-SelfTestCanonicalArtifact -Base $base -Id 'CR-0004' -Status superseded -SupersedesRef 'CR-0005' -VerificationRefs @('PROJECT.md')
        $crCycleB = New-SelfTestCanonicalArtifact -Base $base -Id 'CR-0005' -Status superseded -SupersedesRef 'CR-0004' -VerificationRefs @('PROJECT.md')
        $result = Invoke-AnalysisVerification -RepositoryRoot $base; Assert-SelfTestFinding -Result $result -Pattern '^supersedes-cycle' -Name 'negative-supersedes-cycle'
        [System.IO.File]::Delete((Join-Path $base $crCycleA.Replace('/', '\'))); [System.IO.File]::Delete((Join-Path $base $crCycleB.Replace('/', '\'))); $passed.Add('negative-supersedes-cycle') | Out-Null

        $runDirectory = Join-Path $base "analysis\runs\$runId"; [System.IO.Directory]::CreateDirectory((Join-Path $runDirectory 'nested')) | Out-Null
        $result = Invoke-AnalysisVerification -RepositoryRoot $base; Assert-SelfTestFinding -Result $result -Pattern '^invalid-run-entry' -Name 'negative-nested-run-entry'
        [System.IO.Directory]::Delete((Join-Path $runDirectory 'nested')); $passed.Add('negative-nested-run-entry') | Out-Null

        $briefPath = Join-Path $runDirectory 'brief.md'; $caseTemp = Join-Path $runDirectory '_brief.tmp'; $wrongCase = Join-Path $runDirectory 'Brief.md'
        [System.IO.File]::Move($briefPath, $caseTemp); [System.IO.File]::Move($caseTemp, $wrongCase)
        $result = Invoke-AnalysisVerification -RepositoryRoot $base; Assert-SelfTestFinding -Result $result -Pattern '^(missing-or-wrong-case-run-file|unreadable-run-file)' -Name 'negative-wrong-case-run-file'
        [System.IO.File]::Move($wrongCase, $caseTemp); [System.IO.File]::Move($caseTemp, $briefPath); $passed.Add('negative-wrong-case-run-file') | Out-Null

        $reparseRunId = 'RUN-20260815-120001-reparse-run-d4e5f6'; $junctionPath = Join-Path $base "analysis\runs\$reparseRunId"; $junctionTarget = Join-Path ([System.IO.Path]::GetTempPath()) ('model-project-analysis-junction-' + [guid]::NewGuid().ToString('N'))
        [System.IO.Directory]::CreateDirectory($junctionTarget) | Out-Null
        try {
            New-Item -ItemType Junction -Path $junctionPath -Target $junctionTarget -Force | Out-Null
            $result = Invoke-AnalysisVerification -RepositoryRoot $base; Assert-SelfTestFinding -Result $result -Pattern '^reparse-run' -Name 'negative-reparse-run'
            $passed.Add('negative-reparse-run') | Out-Null
        }
        finally {
            if (Test-Path -LiteralPath $junctionPath) { Remove-Item -LiteralPath $junctionPath -Force }
            if (Test-Path -LiteralPath $junctionTarget) { [System.IO.Directory]::Delete($junctionTarget, $true) }
        }

        $savedRunFileLimit = $script:runFileMaxBytes; $script:runFileMaxBytes = 1
        $result = Invoke-AnalysisVerification -RepositoryRoot $base; Assert-SelfTestFinding -Result $result -Pattern '^oversized-run-file' -Name 'negative-run-file-budget'
        $script:runFileMaxBytes = $savedRunFileLimit; $passed.Add('negative-run-file-budget') | Out-Null

        $savedCorpusLimit = $script:runCorpusMaxBytes; $script:runCorpusMaxBytes = 1
        $result = Invoke-AnalysisVerification -RepositoryRoot $base; Assert-SelfTestFinding -Result $result -Pattern '^oversized-run-corpus' -Name 'negative-run-corpus-budget'
        $script:runCorpusMaxBytes = $savedCorpusLimit; $passed.Add('negative-run-corpus-budget') | Out-Null

        $savedRunCountLimit = $script:maximumRuns; $script:maximumRuns = 0
        $result = Invoke-AnalysisVerification -RepositoryRoot $base; Assert-SelfTestFinding -Result $result -Pattern '^run-count-exhaustion' -Name 'negative-run-count-budget'
        $script:maximumRuns = $savedRunCountLimit; $passed.Add('negative-run-count-budget') | Out-Null

        $savedCanonicalLimit = $script:maximumCanonicalFiles; $script:maximumCanonicalFiles = 1
        $result = Invoke-AnalysisVerification -RepositoryRoot $base; Assert-SelfTestFinding -Result $result -Pattern '^canonical-file-count-exhaustion' -Name 'negative-canonical-count-budget'
        $script:maximumCanonicalFiles = $savedCanonicalLimit; $passed.Add('negative-canonical-count-budget') | Out-Null

        Write-Host "PASS: analysis self-test ($($passed.Count) scenarios)."
    }
    finally { Remove-OwnedSelfTestRoot -Path $base }
}

if ($SelfTest) {
    try { Invoke-AnalysisSelfTest; exit 0 }
    catch {
        $selfTestCode = [string]$_.Exception.Message
        if ($selfTestCode -notmatch '^[a-z0-9][a-z0-9.-]{0,127}$') { $selfTestCode = 'internal-selftest-error' }
        Write-Host "FAIL: analysis self-test ($selfTestCode)." -ForegroundColor Red
        exit 1
    }
}

try { $rootPath = Resolve-VerificationRoot -RequestedRoot $Root; $result = Invoke-AnalysisVerification -RepositoryRoot $rootPath }
catch { Write-Host 'FAIL: analysis gate blocked (invalid-verification-root); repository data hidden.' -ForegroundColor Red; exit 1 }
if ($Report) {
    Write-Host "Analysis report: canon=$($result.CanonicalCount), runs=$($result.RunCount), issues=$($result.Issues.Count)."
    foreach ($issue in $result.Issues) { Write-Host "- $issue" }
}
if ($result.Issues.Count -gt 0) { if (-not $Report) { Write-Host "FAIL: analysis gate, issues=$($result.Issues.Count)." -ForegroundColor Red }; exit 1 }
Write-Host 'PASS: analysis gate.'
exit 0
