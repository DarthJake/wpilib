$ErrorActionPreference = 'Stop'; # stop on all errors

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$url32         = 'https://github.com/wpilibsuite/allwpilib/releases/download/v2021.1.1-beta-4/WPILib_Windows32-2021.1.1-beta-4.iso'
$url64         = 'https://github.com/wpilibsuite/allwpilib/releases/download/v2021.1.1-beta-4/WPILib_Windows64-2021.1.1-beta-4.iso'
$fileName32    = 'WPILibInstaller.exe'
$fileName64    = 'WPILibInstaller.exe'
$isoChecksum32 = '1064f3705f7217b66a06747117d2cb4303be6438530e049c956fae5a2f827ba3'
$isoChecksum64 = '48b454b9a2e806ba9304cf8d6df1cb359a8737732834c860d3b334b4a8398744'

$pp = Get-PackageParameters
$ahkParameters = ""
$ahkParameters += if ($pp.ProgrammingLanguage) { "`"$($pp.ProgrammingLanguage)`"" }
$ahkParameters += if ($pp.CachedZip) { " $($pp.CachedZip)" }
$ahkParameters += if ($pp.AllowUserInteraction) { " $($pp.AllowUserInteraction)" }

$url = ""
if (Get-ProcessorBits -compare '64') {
  $url = $url64
  $checksum = $isoChecksum64
} elseif (Get-ProcessorBits -compare '32') {
  $url = $url32
  $checksum = $isoChecksum32
}

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  softwareName   = 'WPILib*'
  fileType       = 'EXE'
  Url            = $url
  file           = $fileName32
  file64         = $fileName64
  checksum       = $checksum
  checksumType   = 'sha256'
  checksumType64 = 'sha256'
  silentArgs     = '' #none
}

$ahkExe = "AutoHotKey" # This is a reference to the global AHK exe
$ahkFile = Join-Path $toolsDir "WPILibInstall.ahk"
Write-Debug "Running: $ahkExe `"$ahkFile`"$ahkParameters"
$ahkProc = Start-Process -FilePath $ahkExe -ArgumentList "`"$ahkFile`" $ahkParameters" -Verb RunAs -PassThru

$ahkId = $ahkProc.Id
Write-Debug "$ahkExe start time:`t$($ahkProc.StartTime.ToShortTimeString())"
Write-Debug "Process ID:`t$ahkId"

Install-ChocolateyIsoPackage @packageArgs #https://docs.chocolatey.org/en-us/guides/create/mount-an-iso-in-chocolatey-package