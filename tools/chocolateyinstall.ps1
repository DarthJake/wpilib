$ErrorActionPreference = 'Stop'; # stop on all errors

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$url32         = 'https://github.com/wpilibsuite/allwpilib/releases/download/v2022.1.1/WPILib_Windows32-2022.1.1.iso'
$url64         = 'https://github.com/wpilibsuite/allwpilib/releases/download/v2022.1.1/WPILib_Windows64-2022.1.1.iso'
$fileName32    = 'WPILibInstaller.exe'
$fileName64    = 'WPILibInstaller.exe'
$isoChecksum32 = '18ed99d77d649886edd62a0bfb8d117c37ea3252625d4b0886a616832865cc05'
$isoChecksum64 = 'cf31ebefab0f999aef27cf59ccaa67cb34ea6eb9b7b2f64dc92e739ee99c303e'

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