$ErrorActionPreference = 'Stop'; # stop on all errors

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$url32         = 'https://github.com/wpilibsuite/allwpilib/releases/download/v2021.2.1/WPILib_Windows32-2021.2.1.iso'
$url64         = 'https://github.com/wpilibsuite/allwpilib/releases/download/v2021.2.1/WPILib_Windows64-2021.2.1.iso'
$fileName32    = 'WPILibInstaller.exe'
$fileName64    = 'WPILibInstaller.exe'
$isoChecksum32 = '8a0fcfae9f3eed70b33ab9a56f60a1c7c03e5cf78763256a4c7675a5d20fbc89'
$isoChecksum64 = '388d25a0b0cc312546df1c00f51b87c1552ed87eb7367cd2ed058faf6170c0af'

$pp = Get-PackageParameters
$ahkParameters = ""
$ahkParameters += if ($pp.ProgrammingLanguage) { "`"$($pp.ProgrammingLanguage)`"" }
$ahkParameters += if ($pp.CachedZip) { " $($pp.CachedZip)" }
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

$ahkExe = "AutoHotKey" # This is a reference to the global AHK exe
$ahkFile = Join-Path $toolsDir "WPILibInstall.ahk"
Write-Debug "Running: $ahkExe `"$ahkFile`"$ahkParameters"
$ahkProc = Start-Process -FilePath $ahkExe -ArgumentList "`"$ahkFile`" $ahkParameters" -Verb RunAs -PassThru

$ahkId = $ahkProc.Id
Write-Debug "$ahkExe start time:`t$($ahkProc.StartTime.ToShortTimeString())"
Write-Debug "Process ID:`t$ahkId"

Install-ChocolateyIsoPackage @packageArgs #https://docs.chocolatey.org/en-us/guides/create/mount-an-iso-in-chocolatey-package