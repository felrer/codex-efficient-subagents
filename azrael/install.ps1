#requires -Version 7.0
[CmdletBinding()]
param(
    [string]$ArchivePath,
    [string]$InstallRoot = (Join-Path $env:LOCALAPPDATA 'Azrael'),
    [string]$StateRoot = (Join-Path ([Environment]::GetFolderPath('UserProfile')) '.azrael-ex'),
    [string]$ExtensionsDir,
    [string]$UserDataDir,
    [string]$CodePath = 'code',
    [switch]$PrepareOnly
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

if (-not $IsWindows -or [Runtime.InteropServices.RuntimeInformation]::ProcessArchitecture -ne 'X64') {
    throw 'This Azrael package requires local Windows x64.'
}
$manifest = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'release.json') -Raw | ConvertFrom-Json
if ($manifest.schema -ne 1 -or $manifest.tag -notmatch '^[a-zA-Z0-9._-]+$' -or
    $manifest.asset -ne 'azrael-windows-x64.zip') {
    throw 'Invalid Azrael release manifest.'
}
$install = [IO.Path]::GetFullPath($InstallRoot)
$state = [IO.Path]::GetFullPath($StateRoot).TrimEnd('\', '/')
$ordinary = [IO.Path]::GetFullPath((Join-Path ([Environment]::GetFolderPath('UserProfile')) '.codex')).TrimEnd('\', '/')
if ($state -ieq $ordinary -or $state.StartsWith($ordinary + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'StateRoot must be separate from ordinary Codex state.'
}

function Assert-Hash([string]$Path, [string]$Expected) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { throw "Missing release file: $Path" }
    $actual = (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash
    if ($actual -ine $Expected) { throw "SHA-256 mismatch: $Path" }
}

if ($ArchivePath) {
    $archive = (Resolve-Path -LiteralPath $ArchivePath).Path
} else {
    $downloads = Join-Path $install 'downloads'
    New-Item -ItemType Directory -Path $downloads -Force | Out-Null
    $archive = Join-Path $downloads ("$($manifest.tag)-$($manifest.asset)")
    $validDownload = (Test-Path -LiteralPath $archive -PathType Leaf) -and
        ((Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash -ieq $manifest.sha256)
    if (-not $validDownload) {
        $uri = "https://github.com/felrer/codex-efficient-subagents/releases/download/$($manifest.tag)/$($manifest.asset)"
        $partial = "$archive.download"
        Invoke-WebRequest -Uri $uri -OutFile $partial -MaximumRedirection 10
        Assert-Hash $partial $manifest.sha256
        [IO.File]::Move($partial, $archive, $true)
    }
}
Assert-Hash $archive $manifest.sha256

$nodeCommand = Get-Command node.exe -CommandType Application -ErrorAction Stop | Select-Object -First 1
$nodePath = $nodeCommand.Source
$nodeVersion = (& $nodePath --version).Trim()
if ($LASTEXITCODE -ne 0 -or [version]$nodeVersion.TrimStart('v') -lt [version]'22.18.0') {
    throw 'Node.js 22.18 or newer is required for the Devin native provider.'
}

$releases = Join-Path $install 'releases'
$target = Join-Path $releases $manifest.tag
$readyPath = Join-Path $target '.azrael-installed.json'
if (Test-Path -LiteralPath $target) {
    if (-not (Test-Path -LiteralPath $readyPath -PathType Leaf)) {
        throw "Incomplete existing release directory: $target. Choose another InstallRoot."
    }
    $ready = Get-Content -LiteralPath $readyPath -Raw | ConvertFrom-Json
    if ($ready.archiveSha256 -ine $manifest.sha256 -or $ready.nodePath -ine $nodePath -or
        $ready.stateRoot -ine $state) {
        throw "Existing release was prepared with different inputs: $target. Choose another InstallRoot."
    }
} else {
    New-Item -ItemType Directory -Path $releases -Force | Out-Null
    $staging = Join-Path $releases ('.staging-' + [guid]::NewGuid().ToString('N'))
    Expand-Archive -LiteralPath $archive -DestinationPath $staging
    foreach ($relative in @('azrael-host.vsix', 'engine/codex.exe', 'engine/azrael-bridge.exe', 'engine/codex-code-mode-host.exe')) {
        Assert-Hash (Join-Path $staging $relative) $manifest.files.$relative
    }

    $devinManifestPath = Join-Path $staging 'devin-native-build.json'
    $devinManifest = Get-Content -LiteralPath $devinManifestPath -Raw | ConvertFrom-Json
    $devinManifest.node.path = $nodePath
    $devinManifest.node.version = $nodeVersion
    $devinManifest.node.sha256 = (Get-FileHash -LiteralPath $nodePath -Algorithm SHA256).Hash
    $devinManifest | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $devinManifestPath -Encoding utf8NoBOM

    $candidateDevin = Join-Path $env:LOCALAPPDATA 'azrael-ex/tools/devin/3000.10.21/bin/devin.exe'
    $devinExecutable = if (Test-Path -LiteralPath $candidateDevin -PathType Leaf) { $candidateDevin } else { $null }
    $extensionRoot = if ($ExtensionsDir) { [IO.Path]::GetFullPath($ExtensionsDir) } else {
        Join-Path ([Environment]::GetFolderPath('UserProfile')) '.vscode/extensions'
    }
    $official = @(Get-ChildItem -LiteralPath $extensionRoot -Directory -Filter 'openai.chatgpt-26.917.62051-*' -ErrorAction SilentlyContinue |
        Select-Object -First 1)
    $config = [ordered]@{
        schema = 1
        engine = Join-Path $target 'engine/codex.exe'
        bridge = Join-Path $target 'engine/azrael-bridge.exe'
        engineVersion = [string]$manifest.engineVersion
        codexHome = $state
        devinExecutable = $devinExecutable
        devinNative = @{ releaseDirectory = $target }
        providerAccounts = @{ releaseDirectory = $target }
        originalExtension = if ($official.Count) { $official[0].FullName } else { $null }
    }
    $patchedVsix = Join-Path $staging 'azrael-host-local.vsix'
    Copy-Item -LiteralPath (Join-Path $staging 'azrael-host.vsix') -Destination $patchedVsix
    $zip = [IO.Compression.ZipFile]::Open($patchedVsix, [IO.Compression.ZipArchiveMode]::Update)
    try {
        $entry = $zip.GetEntry('extension/out/azrael-runtime.json')
        if (-not $entry) { throw 'Host VSIX is missing its runtime configuration.' }
        $entry.Delete()
        $replacement = $zip.CreateEntry('extension/out/azrael-runtime.json', [IO.Compression.CompressionLevel]::Optimal)
        $writer = [IO.StreamWriter]::new($replacement.Open(), [Text.UTF8Encoding]::new($false))
        try { $writer.Write((ConvertTo-Json -InputObject $config -Depth 10)) } finally { $writer.Dispose() }
    } finally { $zip.Dispose() }
    @{ archiveSha256 = $manifest.sha256; nodePath = $nodePath; stateRoot = $state } |
        ConvertTo-Json | Set-Content -LiteralPath (Join-Path $staging '.azrael-installed.json') -Encoding utf8NoBOM
    Move-Item -LiteralPath $staging -Destination $target
}

$localVsix = Join-Path $target 'azrael-host-local.vsix'
if (-not (Test-Path -LiteralPath $localVsix -PathType Leaf)) { throw "Prepared VSIX is missing: $localVsix" }
if ($PrepareOnly) {
    [pscustomobject]@{ Status = 'prepared'; Release = $target; Vsix = $localVsix; StateRoot = $state }
    exit 0
}

$code = (Get-Command $CodePath -CommandType Application -ErrorAction Stop | Select-Object -First 1).Source
$codeVersionText = @(& $code --version)
$codeVersion = if ($codeVersionText.Count) { ($codeVersionText[0] -split '[+-]')[0] } else { '' }
if ($LASTEXITCODE -ne 0 -or $codeVersionText.Count -eq 0 -or
    [version]$codeVersion -lt [version]'1.96.2') {
    throw 'VS Code 1.96.2 or newer is required.'
}
$arguments = @()
if ($UserDataDir) { $arguments += @('--user-data-dir', [IO.Path]::GetFullPath($UserDataDir)) }
if ($ExtensionsDir) { $arguments += @('--extensions-dir', [IO.Path]::GetFullPath($ExtensionsDir)) }
& $code @arguments --install-extension $localVsix --force
if ($LASTEXITCODE -ne 0) { throw "VS Code extension install failed with exit code $LASTEXITCODE." }
$inventory = @(& $code @arguments --list-extensions --show-versions)
if ($LASTEXITCODE -ne 0 -or $inventory -notcontains "azrael-ex-local.azrael@$($manifest.hostVersion)") {
    throw "VS Code did not report azrael-ex-local.azrael@$($manifest.hostVersion) after installation."
}
[pscustomobject]@{ Status = 'installed-reload-required'; Release = $target; Vsix = $localVsix; StateRoot = $state }
