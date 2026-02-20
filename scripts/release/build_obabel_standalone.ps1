param(
    [string]$BuildDir = "build-obabel-standalone",
    [string]$OutDir = "dist",
    [string]$Configuration = "Release",
    [string]$Generator = "Ninja"
)

$ErrorActionPreference = "Stop"

$rootDir = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$buildPath = Join-Path $rootDir $BuildDir
$outPath = Join-Path $rootDir $OutDir

$cmakeConfigureArgs = @(
    "-S", $rootDir,
    "-B", $buildPath,
    "-G", $Generator,
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5",
    "-DCMAKE_BUILD_TYPE=$Configuration",
    "-DBUILD_SHARED=OFF",
    "-DENABLE_TESTS=OFF",
    "-DBUILD_GUI=OFF",
    "-DRUN_SWIG=OFF",
    "-DPYTHON_BINDINGS=OFF",
    "-DWITH_COORDGEN=OFF",
    "-DWITH_MAEPARSER=OFF",
    "-DWITH_JSON=OFF",
    "-DWITH_STATIC_INCHI=ON",
    "-DOPENBABEL_USE_SYSTEM_INCHI=OFF",
    "-DOB_USE_PREBUILT_BINARIES=OFF"
)

& cmake @cmakeConfigureArgs
if ($LASTEXITCODE -ne 0) {
    throw "CMake configure failed with exit code $LASTEXITCODE"
}

$cmakeBuildArgs = @(
    "--build", $buildPath,
    "--config", $Configuration,
    "--target", "obabel"
)

& cmake @cmakeBuildArgs
if ($LASTEXITCODE -ne 0) {
    throw "CMake build failed with exit code $LASTEXITCODE"
}

$builtBinary = Join-Path $buildPath "bin\obabel.exe"
if (-not (Test-Path $builtBinary)) {
    throw "Build completed but obabel.exe was not found at $builtBinary"
}

New-Item -ItemType Directory -Force -Path $outPath | Out-Null
$arch = if ([Environment]::Is64BitOperatingSystem) { "x86_64" } else { "x86" }
$outputBinary = Join-Path $outPath "obabel-windows-$arch.exe"
Copy-Item -Force $builtBinary $outputBinary

& $outputBinary -V
Write-Host "Wrote $outputBinary"
