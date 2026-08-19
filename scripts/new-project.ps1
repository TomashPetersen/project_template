[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Destination,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ProjectName,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[a-z0-9][a-z0-9-]*$')]
    [string]$ProjectSlug,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Description,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Owner
)

$ErrorActionPreference = 'Stop'
$manifestMaxBytes = 1MB
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
$strictUtf8 = [System.Text.UTF8Encoding]::new($false, $true)
[Console]::OutputEncoding = $utf8NoBom
$OutputEncoding = $utf8NoBom

function Assert-ManifestRelativePath {
    param(
        [Parameter(Mandatory = $true)][string]$RelativePath,
        [Parameter(Mandatory = $true)][string]$FieldName
    )

    if ([string]::IsNullOrWhiteSpace($RelativePath) -or
        $RelativePath.Contains('\') -or
        $RelativePath.StartsWith('/') -or
        $RelativePath.EndsWith('/') -or
        $RelativePath -match '^[A-Za-z]:' -or
        $RelativePath.IndexOfAny([char[]]'*?[]:<>|"') -ge 0) {
        throw ".template-manifest.json $FieldName содержит небезопасный путь: $RelativePath"
    }
    foreach ($segment in ($RelativePath -split '/')) {
        if ([string]::IsNullOrWhiteSpace($segment) -or $segment -eq '.' -or $segment -eq '..' -or
            $segment.EndsWith('.') -or $segment.EndsWith(' ') -or
            $segment -match '^(?i:CON|PRN|AUX|NUL|CLOCK\$|CONIN\$|CONOUT\$|COM[1-9]|LPT[1-9])(?:\..*)?$') {
            throw ".template-manifest.json $FieldName содержит небезопасный Windows path segment: $RelativePath"
        }
    }
}

function Assert-UniquePaths {
    param(
        [Parameter(Mandatory = $true)][string[]]$Paths,
        [Parameter(Mandatory = $true)][string]$FieldName
    )

    $seen = @{}
    foreach ($relativePath in $Paths) {
        Assert-ManifestRelativePath -RelativePath $relativePath -FieldName $FieldName
        $key = $relativePath.ToLowerInvariant()
        if ($seen.ContainsKey($key)) {
            throw ".template-manifest.json $FieldName содержит дубликат: $relativePath"
        }
        $seen[$key] = $true
    }
}

function Assert-NoReparseChain {
    param([Parameter(Mandatory = $true)][string]$AbsolutePath)

    $full = [System.IO.Path]::GetFullPath($AbsolutePath)
    $pathRoot = [System.IO.Path]::GetPathRoot($full)
    $current = $pathRoot
    $relative = $full.Substring($pathRoot.Length)

    foreach ($segment in (($relative -split '[\\/]') | Where-Object { $_ -ne '' })) {
        $current = Join-Path $current $segment
        if (-not (Test-Path -LiteralPath $current)) {
            break
        }
        $item = Get-Item -LiteralPath $current -Force
        if (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
            throw "Путь содержит reparse point: $current"
        }
    }
}

function Test-PathWithinControlledRoot {
    param(
        [Parameter(Mandatory = $true)][string]$CandidatePath,
        [Parameter(Mandatory = $true)][string]$ControlledRoot
    )

    $candidate = [System.IO.Path]::GetFullPath($CandidatePath).TrimEnd([char[]]'\/')
    $root = [System.IO.Path]::GetFullPath($ControlledRoot).TrimEnd([char[]]'\/')
    return (
        $candidate.Equals($root, [System.StringComparison]::OrdinalIgnoreCase) -or
        $candidate.StartsWith($root + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)
    )
}

function Get-TrustedGitExecutable {
    param([Parameter(Mandatory = $true)][string[]]$ControlledRoots)

    $command = Get-Command -Name 'git.exe' -CommandType Application -ErrorAction SilentlyContinue |
        Select-Object -First 1
    if ($null -eq $command) {
        $command = Get-Command -Name 'git' -CommandType Application -ErrorAction SilentlyContinue |
            Select-Object -First 1
    }
    if ($null -eq $command -or [string]::IsNullOrWhiteSpace([string]$command.Source)) {
        throw 'Доверенный Git executable не найден.'
    }

    try { $path = [System.IO.Path]::GetFullPath([string]$command.Source) }
    catch { throw 'Доверенный Git executable имеет некорректный путь.' }
    if ([System.IO.Path]::GetFileName($path) -cnotin @('git.exe', 'git') -or
        -not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw 'Доверенный Git executable не прошел проверку имени и типа.'
    }
    Assert-NoReparseChain $path
    foreach ($controlledRoot in $ControlledRoots) {
        if (Test-PathWithinControlledRoot -CandidatePath $path -ControlledRoot $controlledRoot) {
            throw 'Git executable не может находиться внутри управляемого корня проекта.'
        }
    }
    return $path
}

function Get-TrustedCurrentPowerShellHost {
    param([Parameter(Mandatory = $true)][string[]]$ControlledRoots)

    try { $path = [System.IO.Path]::GetFullPath((Get-Process -Id $PID -ErrorAction Stop).MainModule.FileName) }
    catch { throw 'Не удалось точно определить текущий PowerShell host.' }
    if ([System.IO.Path]::GetFileName($path) -cnotin @('powershell.exe', 'pwsh.exe') -or
        -not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw 'Текущий PowerShell host не прошел проверку имени и типа.'
    }
    Assert-NoReparseChain $path
    foreach ($controlledRoot in $ControlledRoots) {
        if (Test-PathWithinControlledRoot -CandidatePath $path -ControlledRoot $controlledRoot) {
            throw 'PowerShell host не может находиться внутри управляемого корня проекта.'
        }
    }
    return $path
}

function ConvertTo-SanitizedProcessArgument {
    param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$Value)

    if ($Value.IndexOf([char]0) -ge 0 -or $Value -match '[\r\n]') {
        throw 'Аргумент дочернего процесса содержит запрещенный символ.'
    }
    if ($Value.Length -eq 0) { return '""' }
    if ($Value -notmatch '[\s"]') { return $Value }

    $builder = [System.Text.StringBuilder]::new()
    [void]$builder.Append('"')
    $backslashes = 0
    foreach ($character in $Value.ToCharArray()) {
        if ($character -eq '\') {
            $backslashes++
            continue
        }
        if ($character -eq '"') {
            [void]$builder.Append(('\' * (($backslashes * 2) + 1)))
            [void]$builder.Append('"')
            $backslashes = 0
            continue
        }
        if ($backslashes -gt 0) {
            [void]$builder.Append(('\' * $backslashes))
            $backslashes = 0
        }
        [void]$builder.Append($character)
    }
    if ($backslashes -gt 0) {
        [void]$builder.Append(('\' * ($backslashes * 2)))
    }
    [void]$builder.Append('"')
    return $builder.ToString()
}

function Invoke-SanitizedProcess {
    param(
        [Parameter(Mandatory = $true)][string]$Executable,
        [Parameter(Mandatory = $true)][string[]]$Arguments
    )

    $startInfo = [System.Diagnostics.ProcessStartInfo]::new()
    $startInfo.FileName = $Executable
    $startInfo.Arguments = (($Arguments | ForEach-Object {
        ConvertTo-SanitizedProcessArgument -Value ([string]$_)
    }) -join ' ')
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $null = $startInfo.EnvironmentVariables
    $environment = $startInfo.Environment
    if ($null -eq $environment) {
        throw 'Окружение дочернего процесса недоступно.'
    }
    foreach ($name in @($environment.Keys)) {
        if (([string]$name).StartsWith('GIT_', [System.StringComparison]::OrdinalIgnoreCase)) {
            [void]$environment.Remove([string]$name)
        }
    }
    $isPowerShellHost = [System.IO.Path]::GetFileName($Executable) -cin @('powershell.exe', 'pwsh.exe')
    if ($isPowerShellHost) {
        $startInfo.StandardOutputEncoding = $utf8NoBom
        $startInfo.StandardErrorEncoding = $utf8NoBom
    }
    else {
        $environment['GIT_CONFIG_NOSYSTEM'] = '1'
        $environment['GIT_CONFIG_GLOBAL'] = 'NUL'
        $environment['GIT_CONFIG_SYSTEM'] = 'NUL'
    }

    $process = [System.Diagnostics.Process]::new()
    $process.StartInfo = $startInfo
    try {
        if (-not $process.Start()) {
            throw 'Не удалось запустить дочерний процесс.'
        }
        $stdoutTask = $process.StandardOutput.ReadToEndAsync()
        $stderrTask = $process.StandardError.ReadToEndAsync()
        $process.WaitForExit()
        $output = [System.Collections.Generic.List[string]]::new()
        foreach ($streamText in @($stdoutTask.Result, $stderrTask.Result)) {
            foreach ($line in @($streamText -split '\r?\n')) {
                if ($line.Length -gt 0) { $output.Add($line) | Out-Null }
            }
        }
        return [pscustomobject]@{ ExitCode = $process.ExitCode; Output = @($output) }
    }
    finally {
        $process.Dispose()
    }
}

function Read-BoundedUtf8File {
    param(
        [Parameter(Mandatory = $true)][string]$LiteralPath,
        [Parameter(Mandatory = $true)][long]$MaxBytes,
        [Parameter(Mandatory = $true)][string]$Label
    )

    if ($MaxBytes -le 0) {
        throw "Некорректный лимит чтения для ${Label}: $MaxBytes"
    }

    $absolutePath = [System.IO.Path]::GetFullPath($LiteralPath)
    if (-not (Test-Path -LiteralPath $absolutePath -PathType Leaf)) {
        throw "Файл для чтения не найден: ${Label}: $absolutePath"
    }

    Assert-NoReparseChain $absolutePath
    $item = Get-Item -LiteralPath $absolutePath -Force
    if (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
        throw "Файл является reparse point: ${Label}: $absolutePath"
    }
    if ([long]$item.Length -gt $MaxBytes) {
        throw "Файл превышает лимит $MaxBytes байт: ${Label}: $($item.Length)"
    }

    Assert-NoReparseChain $absolutePath
    $stream = $null
    $memory = $null
    try {
        $stream = [System.IO.FileStream]::new(
            $absolutePath,
            [System.IO.FileMode]::Open,
            [System.IO.FileAccess]::Read,
            [System.IO.FileShare]::Read
        )
        if ($stream.Length -gt $MaxBytes) {
            throw "Файл превышает лимит $MaxBytes байт после открытия: ${Label}: $($stream.Length)"
        }

        $memory = [System.IO.MemoryStream]::new()
        $buffer = New-Object byte[] 65536
        [long]$totalRead = 0
        while (($read = $stream.Read($buffer, 0, $buffer.Length)) -gt 0) {
            $totalRead += $read
            if ($totalRead -gt $MaxBytes) {
                throw "Файл превысил лимит $MaxBytes байт во время чтения: $Label"
            }
            $memory.Write($buffer, 0, $read)
        }
        $bytes = $memory.ToArray()
    }
    finally {
        if ($null -ne $memory) { $memory.Dispose() }
        if ($null -ne $stream) { $stream.Dispose() }
    }

    try {
        $text = $strictUtf8.GetString($bytes)
    }
    catch {
        throw "Файл содержит невалидный UTF-8: ${Label}: $($_.Exception.Message)"
    }
    if ($text.Length -gt 0 -and $text[0] -eq [char]0xFEFF) {
        $text = $text.Substring(1)
    }
    return $text
}

function Assert-LocalDestination {
    param([Parameter(Mandatory = $true)][string]$RawDestination)

    if ($RawDestination.StartsWith('\\') -or $RawDestination.StartsWith('//')) {
        throw 'UNC, device и protocol-relative destination запрещены.'
    }
    $full = [System.IO.Path]::GetFullPath($RawDestination)
    $pathRoot = [System.IO.Path]::GetPathRoot($full)
    if ([string]::IsNullOrWhiteSpace($pathRoot) -or $pathRoot.StartsWith('\\') -or $pathRoot.StartsWith('//')) {
        throw 'Destination должен находиться на локальном файловом диске.'
    }

    try {
        $driveInfo = [System.IO.DriveInfo]::new($pathRoot)
        if ($driveInfo.DriveType -eq [System.IO.DriveType]::Network) {
            throw 'Destination на сетевом диске запрещен.'
        }
    }
    catch [System.ArgumentException] {
        throw "Не удалось определить локальный диск destination: $pathRoot"
    }

    $driveName = $pathRoot.TrimEnd([char[]]'\/').TrimEnd(':')
    $psDrive = Get-PSDrive -Name $driveName -PSProvider FileSystem -ErrorAction SilentlyContinue
    if ($null -ne $psDrive -and -not [string]::IsNullOrWhiteSpace([string]$psDrive.DisplayRoot) -and
        ([string]$psDrive.DisplayRoot).StartsWith('\\')) {
        throw 'Destination на mapped network drive запрещен.'
    }
}

function Copy-PortableFile {
    param(
        [Parameter(Mandatory = $true)][string]$RelativeFile,
        [Parameter(Mandatory = $true)][string]$TargetRoot
    )

    $normalized = $RelativeFile.Replace('/', '\')
    $source = Join-Path $sourceRoot $normalized
    $target = Join-Path $TargetRoot $normalized
    $targetParent = Split-Path -Parent $target
    if (-not (Test-Path -LiteralPath $targetParent -PathType Container)) {
        New-Item -ItemType Directory -Path $targetParent -Force | Out-Null
    }
    Assert-NoReparseChain $source
    Assert-NoReparseChain $targetParent
    Copy-Item -LiteralPath $source -Destination $target
    Assert-NoReparseChain $target
}

function Assert-PortableDestination {
    param(
        [Parameter(Mandatory = $true)][string]$BaseRoot,
        [Parameter(Mandatory = $true)][string[]]$PortableFiles,
        [Parameter(Mandatory = $true)][string[]]$PortableEmptyDirectories
    )

    $actualFiles = @(Get-ChildItem -LiteralPath $BaseRoot -Recurse -File -Force | ForEach-Object {
        $_.FullName.Substring($BaseRoot.Length + 1).Replace('\', '/')
    })
    $missingFiles = @($PortableFiles | Where-Object { $actualFiles -cnotcontains $_ })
    $extraFiles = @($actualFiles | Where-Object { $PortableFiles -cnotcontains $_ })
    if ($missingFiles.Count -gt 0 -or $extraFiles.Count -gt 0) {
        throw "Копия не совпадает с portable_files. Missing: $($missingFiles -join ', '); extra: $($extraFiles -join ', ')"
    }
    foreach ($relativeDirectory in $PortableEmptyDirectories) {
        $absoluteDirectory = Join-Path $BaseRoot $relativeDirectory.Replace('/', '\')
        if (-not (Test-Path -LiteralPath $absoluteDirectory -PathType Container)) {
            throw "Копия не содержит portable empty directory: $relativeDirectory"
        }
        if (@(Get-ChildItem -LiteralPath $absoluteDirectory -Force).Count -ne 0) {
            throw "Portable empty directory неожиданно заполнен до инициализации: $relativeDirectory"
        }
    }
}

function Remove-DirectoryTreeWithoutFollowingReparse {
    param([Parameter(Mandatory = $true)][string]$DirectoryPath)

    foreach ($entry in [System.IO.Directory]::EnumerateFileSystemEntries($DirectoryPath)) {
        $attributes = [System.IO.File]::GetAttributes($entry)
        $isDirectory = ($attributes -band [System.IO.FileAttributes]::Directory) -ne 0
        $isReparse = ($attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0
        if ($isReparse) {
            if ($isDirectory) {
                [System.IO.Directory]::Delete($entry, $false)
            }
            else {
                [System.IO.File]::Delete($entry)
            }
        }
        elseif ($isDirectory) {
            Remove-DirectoryTreeWithoutFollowingReparse $entry
        }
        else {
            [System.IO.File]::SetAttributes($entry, [System.IO.FileAttributes]::Normal)
            [System.IO.File]::Delete($entry)
        }
    }
    [System.IO.Directory]::Delete($DirectoryPath, $false)
}

function Remove-ExactStagingDirectory {
    param(
        [Parameter(Mandatory = $true)][string]$StagingDirectory,
        [Parameter(Mandatory = $true)][string]$ExpectedParent
    )

    $fullStaging = [System.IO.Path]::GetFullPath($StagingDirectory).TrimEnd([char[]]'\/')
    $fullParent = [System.IO.Path]::GetFullPath($ExpectedParent).TrimEnd([char[]]'\/')
    $actualParent = [System.IO.Path]::GetDirectoryName($fullStaging)
    $leaf = [System.IO.Path]::GetFileName($fullStaging)
    if (-not $actualParent.Equals($fullParent, [System.StringComparison]::OrdinalIgnoreCase) -or
        $leaf -notmatch '^\.codex-new-project-[0-9a-f]{32}$') {
        throw "Отказ от cleanup неожиданного staging path: $fullStaging"
    }
    Assert-NoReparseChain $fullParent
    if (-not (Test-Path -LiteralPath $fullStaging)) { return }

    $attributes = [System.IO.File]::GetAttributes($fullStaging)
    if (($attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
        [System.IO.Directory]::Delete($fullStaging, $false)
        return
    }
    Assert-NoReparseChain $fullStaging
    Remove-DirectoryTreeWithoutFollowingReparse $fullStaging
}

$sourceRootCandidate = [System.IO.Path]::GetFullPath((Split-Path -Parent $PSScriptRoot)).TrimEnd([char[]]'\/')
Assert-NoReparseChain $sourceRootCandidate
$sourceRoot = (Resolve-Path -LiteralPath $sourceRootCandidate).Path.TrimEnd([char[]]'\/')
$manifestPath = Join-Path $sourceRoot '.template-manifest.json'

Assert-LocalDestination $Destination
$destinationPath = [System.IO.Path]::GetFullPath($Destination).TrimEnd([char[]]'\/')
if ($destinationPath.Equals($sourceRoot, [System.StringComparison]::OrdinalIgnoreCase) -or
    $destinationPath.StartsWith($sourceRoot + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw 'Новый проект нельзя создавать внутри исходного шаблона.'
}
if (Test-Path -LiteralPath $destinationPath) {
    throw "Целевая папка уже существует: $destinationPath"
}

$parent = Split-Path -Parent $destinationPath
if (-not (Test-Path -LiteralPath $parent -PathType Container)) {
    throw "Родительская папка не существует: $parent"
}
Assert-NoReparseChain $parent
if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
    throw '.template-manifest.json не найден.'
}
Assert-NoReparseChain $manifestPath

$manifestText = Read-BoundedUtf8File -LiteralPath $manifestPath -MaxBytes $manifestMaxBytes -Label '.template-manifest.json'
try {
    $manifest = $manifestText | ConvertFrom-Json
}
catch {
    throw '.template-manifest.json содержит невалидный JSON; parser details скрыты.'
}

$requiredProperties = @(
    'schema_version',
    'template_version',
    'portable_files',
    'portable_empty_directories',
    'initialization_renames',
    'source_only_paths',
    'generated_forbidden_paths',
    'generated_extension_zones',
    'mastery_baseline'
)
foreach ($propertyName in $requiredProperties) {
    if ($manifest.PSObject.Properties.Name -cnotcontains $propertyName) {
        throw ".template-manifest.json: отсутствует поле $propertyName"
    }
}
if ([int]$manifest.schema_version -ne 1) {
    throw "Неподдерживаемая schema_version: $($manifest.schema_version)"
}
$semVerPattern = '^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(?:-(?:(?:0|[1-9][0-9]*)|[0-9]*[A-Za-z-][0-9A-Za-z-]*)(?:\.(?:(?:0|[1-9][0-9]*)|[0-9]*[A-Za-z-][0-9A-Za-z-]*))*)?(?:\+[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*)?$'
if ($manifest.template_version -isnot [string] -or
    $manifest.template_version.Length -gt 128 -or
    $manifest.template_version -cnotmatch $semVerPattern) {
    throw '.template-manifest.json template_version должен быть SemVer scalar длиной не более 128 символов.'
}

$portableFiles = @($manifest.portable_files | ForEach-Object { [string]$_ })
$portableEmptyDirectories = @($manifest.portable_empty_directories | ForEach-Object { [string]$_ })
$initializationRenames = @($manifest.initialization_renames)
$sourceOnlyPaths = @($manifest.source_only_paths | ForEach-Object { [string]$_ })
$generatedForbiddenPaths = @($manifest.generated_forbidden_paths | ForEach-Object { [string]$_ })
$generatedExtensionZones = @($manifest.generated_extension_zones | ForEach-Object { [string]$_ })

Assert-UniquePaths -Paths $portableFiles -FieldName 'portable_files'
Assert-UniquePaths -Paths $portableEmptyDirectories -FieldName 'portable_empty_directories'
Assert-UniquePaths -Paths $sourceOnlyPaths -FieldName 'source_only_paths'
Assert-UniquePaths -Paths $generatedForbiddenPaths -FieldName 'generated_forbidden_paths'
Assert-UniquePaths -Paths $generatedExtensionZones -FieldName 'generated_extension_zones'

if ($portableFiles -cnotcontains '.template-manifest.json') {
    throw 'portable_files должен включать .template-manifest.json.'
}
$renameFromPaths = [System.Collections.Generic.List[string]]::new()
$renameToPaths = [System.Collections.Generic.List[string]]::new()
foreach ($rename in $initializationRenames) {
    if ($null -eq $rename -or
        $rename.PSObject.Properties.Name -cnotcontains 'from' -or
        $rename.PSObject.Properties.Name -cnotcontains 'to') {
        throw 'initialization_renames: каждая запись должна содержать from и to.'
    }
    $from = [string]$rename.from
    $to = [string]$rename.to
    Assert-ManifestRelativePath -RelativePath $from -FieldName 'initialization_renames.from'
    Assert-ManifestRelativePath -RelativePath $to -FieldName 'initialization_renames.to'
    if ($portableFiles -cnotcontains $from) {
        throw "initialization_renames.from отсутствует в portable_files: $from"
    }
    if ($portableFiles -ccontains $to -or $sourceOnlyPaths -ccontains $to) {
        throw "initialization_renames.to конфликтует с manifest inventory: $to"
    }
    if ($generatedForbiddenPaths -cnotcontains $from -or $generatedForbiddenPaths -ccontains $to) {
        throw "initialization_renames не согласован с generated_forbidden_paths: $from -> $to"
    }
    $renameFromPaths.Add($from)
    $renameToPaths.Add($to)
}
Assert-UniquePaths -Paths $renameFromPaths.ToArray() -FieldName 'initialization_renames.from'
Assert-UniquePaths -Paths $renameToPaths.ToArray() -FieldName 'initialization_renames.to'
foreach ($sourceOnlyPath in $sourceOnlyPaths) {
    if ($portableFiles -ccontains $sourceOnlyPath) {
        throw "Путь одновременно portable и source-only: $sourceOnlyPath"
    }
}

foreach ($relativeFile in $portableFiles) {
    $source = Join-Path $sourceRoot $relativeFile.Replace('/', '\')
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
        throw "Отсутствует portable file: $relativeFile"
    }
    Assert-NoReparseChain $source
}
foreach ($relativeDirectory in $portableEmptyDirectories) {
    $sourceDirectory = Join-Path $sourceRoot $relativeDirectory.Replace('/', '\')
    if (-not (Test-Path -LiteralPath $sourceDirectory -PathType Container)) {
        throw "Отсутствует portable empty directory: $relativeDirectory"
    }
    Assert-NoReparseChain $sourceDirectory
    if (@(Get-ChildItem -LiteralPath $sourceDirectory -Force).Count -ne 0) {
        throw "Portable empty directory должен быть пустым в шаблоне: $relativeDirectory"
    }
}

$verifier = Join-Path $PSScriptRoot 'verify-structure.ps1'
if (-not (Test-Path -LiteralPath $verifier -PathType Leaf)) {
    throw 'Доверенный verify-structure.ps1 не найден.'
}
Assert-NoReparseChain $verifier
$powershellExe = Get-TrustedCurrentPowerShellHost -ControlledRoots @($sourceRoot, $destinationPath)
# Fail-fast: initialize-project.ps1 понадобится Git после копирования. Разрешаем
# executable до создания staging, затем initializer повторно валидирует его сам.
$null = Get-TrustedGitExecutable -ControlledRoots @($sourceRoot, $destinationPath)
$sourceVerifyResult = Invoke-SanitizedProcess -Executable $powershellExe -Arguments @(
    '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $verifier,
    '-Root', $sourceRoot, '-Mode', 'TemplateSource'
)
foreach ($line in $sourceVerifyResult.Output) { Write-Host ([string]$line) }
if ($sourceVerifyResult.ExitCode -ne 0) {
    throw 'Исходный шаблон не прошел проверку TemplateSource. Копирование остановлено до создания staging.'
}

do {
    $stagingLeaf = ".codex-new-project-$([guid]::NewGuid().ToString('N'))"
    $stagingPath = Join-Path $parent $stagingLeaf
} while (Test-Path -LiteralPath $stagingPath)

$stagingMoved = $false
try {
    New-Item -ItemType Directory -Path $stagingPath | Out-Null
    Assert-NoReparseChain $stagingPath

    foreach ($relativeFile in $portableFiles) {
        Copy-PortableFile -RelativeFile $relativeFile -TargetRoot $stagingPath
    }
    foreach ($relativeDirectory in $portableEmptyDirectories) {
        $stagingDirectory = Join-Path $stagingPath $relativeDirectory.Replace('/', '\')
        if (-not (Test-Path -LiteralPath $stagingDirectory -PathType Container)) {
            New-Item -ItemType Directory -Path $stagingDirectory -Force | Out-Null
        }
        Assert-NoReparseChain $stagingDirectory
    }
    Assert-PortableDestination -BaseRoot $stagingPath -PortableFiles $portableFiles -PortableEmptyDirectories $portableEmptyDirectories

    if (Test-Path -LiteralPath (Join-Path $stagingPath '.git')) {
        throw 'Staging неожиданно получил .git исходного шаблона.'
    }
    foreach ($forbiddenPath in $generatedForbiddenPaths) {
        if ($renameFromPaths -ccontains $forbiddenPath) { continue }
        if (Test-Path -LiteralPath (Join-Path $stagingPath $forbiddenPath.Replace('/', '\'))) {
            throw "Staging неожиданно получил generated forbidden path: $forbiddenPath"
        }
    }

    $initializer = Join-Path $stagingPath 'scripts\initialize-project.ps1'
    if (-not (Test-Path -LiteralPath $initializer -PathType Leaf)) {
        throw "Staging создан, но инициализатор не найден: $initializer"
    }
    Assert-NoReparseChain $initializer
    $initializeResult = Invoke-SanitizedProcess -Executable $powershellExe -Arguments @(
        '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $initializer,
        '-ProjectName', $ProjectName,
        '-ProjectSlug', $ProjectSlug,
        '-Description', $Description,
        '-Owner', $Owner,
        '-InitializeGit'
    )
    foreach ($line in $initializeResult.Output) { Write-Host ([string]$line) }
    if ($initializeResult.ExitCode -ne 0) {
        throw 'Staging initializer завершился с ошибкой.'
    }

    $generatedVerifyResult = Invoke-SanitizedProcess -Executable $powershellExe -Arguments @(
        '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $verifier,
        '-Root', $stagingPath, '-Mode', 'GeneratedProject'
    )
    foreach ($line in $generatedVerifyResult.Output) { Write-Host ([string]$line) }
    if ($generatedVerifyResult.ExitCode -ne 0) {
        throw 'Staging не прошел доверенную проверку GeneratedProject.'
    }

    Assert-NoReparseChain $parent
    Assert-NoReparseChain $stagingPath
    if (Test-Path -LiteralPath $destinationPath) {
        throw "Final destination появился во время сборки: $destinationPath"
    }
    [System.IO.Directory]::Move($stagingPath, $destinationPath)
    $stagingMoved = $true
}
catch {
    $originalFailure = $_
    if (-not $stagingMoved) {
        try {
            Remove-ExactStagingDirectory -StagingDirectory $stagingPath -ExpectedParent $parent
        }
        catch {
            throw "Создание проекта завершилось ошибкой: $($originalFailure.Exception.Message). Дополнительно не удалось безопасно очистить staging: $($_.Exception.Message)"
        }
    }
    throw $originalFailure
}

Write-Host "Новый проект создан атомарным rename: $destinationPath"
