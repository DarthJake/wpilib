$ErrorActionPreference = 'Stop'; # stop on all errors

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$url32         = 'https://github.com/wpilibsuite/allwpilib/releases/download/v2021.1.2/WPILib_Windows32-2021.1.2.iso'
$url64         = 'https://github.com/wpilibsuite/allwpilib/releases/download/v2021.1.2/WPILib_Windows64-2021.1.2.iso'
$fileName32    = 'WPILibInstaller.exe'
$fileName64    = 'WPILibInstaller.exe'
$isoChecksum32 = 'd367e7e4ca0c5cbf3bb5764ccb70c8a62cb64e7692b9af98c752a7f62b609020'
$isoChecksum64 = '2a72f16dc2ee098b1871d2ec8ef2ef9baa70f08bf606cada1690c92dae8fe585'

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