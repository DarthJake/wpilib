$ErrorActionPreference = 'Stop'; # stop on all errors

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$url32         = 'https://github.com/wpilibsuite/allwpilib/releases/download/v2020.3.2/WPILibInstaller_Windows32-2020.3.2.zip'
$url64         = 'https://github.com/wpilibsuite/allwpilib/releases/download/v2020.3.2/WPILibInstaller_Windows64-2020.3.2.zip'
$fileName32    = 'WPILibInstaller_Windows32-2020.3.2.exe'
$fileName64    = 'WPILibInstaller_Windows64-2020.3.2.exe'
$zipChecksum32 = 'eb6099eb64f1af081ed144da44aa0d2a7036a9ab58888f76426a1edbd22e132c'
$zipChecksum64 = '65698bc0933b35763b6d62c0fb729634495102a1d7aedadd994dad66b772f4a5'
$exeChecksum32 = 'A6F610218A49E0CAC8C310D3B50228F91A3E6849AD7035B3936A325B28946A1D'
$exeChecksum64 = '894353FB0FBA25E88BF29AADCE9D15A5A8982C75D3E8C169242BF3D3B516A227'

$pp = Get-PackageParameters
$ahkParameters = ""
$ahkParameters += if ($pp.ProgrammingLanguage) { "`"$($pp.ProgrammingLanguage)`"" }
$ahkParameters += if ($pp.CachedZip) { " $($pp.CachedZip)" }
$ahkParameters += if ($pp.AllowUserInteraction) { " $($pp.AllowUserInteraction)" }

$unzipPackageArgs = @{
  packageName    = $env:ChocolateyPackageName
  Url            = $url32
  Url64bit       = $url64
  checksum       = $zipChecksum32
  checksum64     = $zipChecksum64
  checksumType   = 'sha256'
  checksumType64 = 'sha256'
  UnzipLocation  = $toolsDir
}
$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  softwareName   = 'WPILib*' 
  fileType       = 'EXE'
  file           = "$toolsDir\$fileName32"
  file64         = "$toolsDir\$fileName64"
  checksum       = $exeChecksum32
  checksum64     = $exeChecksum64
  checksumType   = 'sha256'
  checksumType64 = 'sha256'
  silentArgs     = '' #none
}

Install-ChocolateyZipPackage  @unzipPackageArgs # https://docs.chocolatey.org/en-us/create/functions/install-chocolateyzippackage.

$ahkExe = "AutoHotKey" # This is a reference to the global AHK exe
$ahkFile = Join-Path $toolsDir "WPILibInstall.ahk"
Write-Debug "Running: $ahkExe `"$ahkFile`"$ahkParameters"
$ahkProc = Start-Process -FilePath $ahkExe -ArgumentList "`"$ahkFile`" $ahkParameters" -Verb RunAs -PassThru

$ahkId = $ahkProc.Id
Write-Debug "$ahkExe start time:`t$($ahkProc.StartTime.ToShortTimeString())"
Write-Debug "Process ID:`t$ahkId"

Install-ChocolateyInstallPackage @packageArgs # https://chocolatey.org/docs/helpers-install-chocolatey-install-package