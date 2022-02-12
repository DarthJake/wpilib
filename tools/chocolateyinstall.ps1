$ErrorActionPreference = 'Stop'; # stop on all errors

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$url32         = 'https://github.com/wpilibsuite/allwpilib/releases/download/v2022.2.1/WPILib_Windows32-2022.2.1.iso'
$url64         = 'https://github.com/wpilibsuite/allwpilib/releases/download/v2022.2.1/WPILib_Windows64-2022.2.1.iso'
$fileName32    = 'WPILibInstaller.exe'
$fileName64    = 'WPILibInstaller.exe'
$isoChecksum32 = '96ad0e15345a975e9d20e1abc85b9589da673202e469f21e841a0ff40f9ae5ec'
$isoChecksum64 = '40a852b6db487790719b2d007f1bf5a052698238817d6ca8dcd0fe8f9faefc02'

$pp = Get-PackageParameters
$ahkParameters = ""
$ahkParameters += if ($pp.InstallScope) { "`"$($pp.InstallScope)`"" }
$ahkParameters += if ($pp.VSCodeZipPath) { " $($pp.VSCodeZipPath)" }
$ahkParameters += if ($pp.AllowUserInteraction) { " $($pp.AllowUserInteraction)" }

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  softwareName   = 'WPILib*'
  fileType       = 'EXE'
  checksumType   = 'sha256'
  checksumType64 = 'sha256'
  silentArgs     = '' #none
}
if (Get-ProcessorBits -compare '32') {
  $packageArgs += @{
    Url      = $url32
    file     = $fileName32
    checksum = $isoChecksum32
  }
} elseif (Get-ProcessorBits -compare '64') {
  $packageArgs += @{
    Url      = $url64
    file     = $fileName64
    checksum = $isoChecksum64
  }
}

if (!(Get-OSArchitectureWidth -Compare 64) -or !($env:OS_NAME -eq "Windows 10" -or $env:OS_NAME -eq "Windows 11")) {
  throw "WPILib requires Windows 10 64-bit version or newer. Aborting installation."
}

$ahkExe = "AutoHotKey" # This is a reference to the global AHK exe
$ahkFile = Join-Path $toolsDir "WPILibInstall.ahk"
Write-Debug "Running: $ahkExe `"$ahkFile`"$ahkParameters"
$ahkProc = Start-Process -FilePath $ahkExe -ArgumentList "`"$ahkFile`" $ahkParameters" -Verb RunAs -PassThru

$ahkId = $ahkProc.Id
Write-Debug "$ahkExe start time:`t$($ahkProc.StartTime.ToShortTimeString())"
Write-Debug "Process ID:`t$ahkId"

Install-ChocolateyIsoPackage @packageArgs #https://docs.chocolatey.org/en-us/guides/create/mount-an-iso-in-chocolatey-package