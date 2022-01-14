#Debug lines can be printed by passing the flag -Debug
$ErrorActionPreference = 'Stop'; # stop on all errors
Write-Host "Beginning uninstall process of WPILib..."

# Variables that will need changed
$year = '2022'

# Generated/Constant Variables
$systemDriveLetter = (Get-WmiObject Win32_OperatingSystem).getPropertyValue("SystemDrive")
$publicUserHome = $systemDriveLetter + "\Users\Public"
$wpiFolder = "$publicUserHome\wpilib"
$userStartMenuFolder = "$HOME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs"
$systemStartMenuFolder = "$systemDriveLetter\ProgramData\Microsoft\Windows\Start Menu\Programs"
$startMenuLinks = @(
  "$year WPILib Tools",
  "$year WPILib Documentation.lnk",
  "$year WPILib VS Code.lnk"
)
$possibleLinkDirectories = @(
  "$HOME\Desktop",
  "$publicUserHome\Desktop",
  "$HOME\OneDrive\Desktop"
)
$linkNames = @(
  "$year WPILib VS Code.lnk",
  "$year WPILib Documentation.lnk",
  "$year WPILib Tools"
)

##### Delete WPILib folder #####
# Check if the inside wpilib folder exists, attempt to delete it, check if was successful
Write-Host "`nRemoving the WPILib folder..."
if (Test-Path -Path "$wpiFolder\$year") {
  Remove-Item "$wpiFolder\$year" -ErrorAction SilentlyContinue -Force -Recurse
  
  if (!(Test-Path -Path "$wpiFolder\$year")) {
    Write-Host "`tRemoved wpilib folder at `"$wpiFolder\$year`"" -ForegroundColor Green
  } else {
    Write-Host "`tAn error occured while trying to delete the wpilib folder at `"$wpiFolder\$year`"" -ForegroundColor Red
  }
} else {
  Write-Host "`tIt appears that the wpilib folder expected at `"$wpiFolder\$year`" does not exists. This could be a good indicator that wpilib (for this year) is not/no longer installed, however the uninstall process will continue to ensure that all elements of wpilib are gone`n" -ForegroundColor Yellow
}

# Delete the outside wpilib folder if it exists and is now empty
if(Test-Path $wpiFolder){
  if ((Get-ChildItem $wpiFolder -force | Select-Object -First 1 | Measure-Object).Count -eq 0) {
    Remove-Item $wpiFolder -ErrorAction SilentlyContinue -Force -Recurse

    if (!(Test-Path -Path $wpiFolder)) {
      Write-Host "`tRemoved the main wpilib folder at `"$wpiFolder`" because it was empty" -ForegroundColor Green
    } else {
      Write-Host "`tAn error occured while trying to delete the main wpilib folder at `"$wpiFolder`"" -ForegroundColor Red
    }
  }
} else {
  Write-Host "`tIt appears that the main wpilib folder at `"$wpiFolder`" does not exists. This could be a good indicator that wpilib is not/no longer installed, however the uninstall process will continue to ensure that all elements of wpilib are gone" -ForegroundColor Yellow
}

##### Delete Desktop Shortcuts ##### 
# Both public and current user desktop. It differes upon whether you select current user or all users when installing. 
# It might be infered that if one link is found the others will be next to it, but that's a dangerous game. Plus what if the links are in multiple places?
Write-Host "`nDeleteing Desktop Shortcuts..."
$LinksFound = ""
foreach ($directory in $possibleLinkDirectories) {
  Write-Host "`tSearching `"$directory`" for links to delete:"
  foreach ($link in $linkNames) {
    # Check for link file, if its there attempt to delete it, recheck if its there.
    if (Test-Path ("{0}\{1}" -f $directory, $link)) {
      $LinksFound = $TRUE
      Remove-Item ("{0}\{1}" -f $directory, $link) -ErrorAction SilentlyContinue -Force -Recurse

      if (!(Test-Path ("{0}\{1}" -f $directory, $link))) {
        Write-Host "`t`tFound and deleted `"$link`" in `"$directory`"" -ForegroundColor Green
      } else {
        Write-Host "`t`tAttempted Deleting `"$link`" in `"$directory`" but could not delete" -ForegroundColor Red
      }
    } else {
      Write-Host "`t`tLooked for `"$link`" in `"$directory`" but found nothing" -ForegroundColor Yellow
    }
  }
}
if (!$LinksFound) {
  Write-Host "`tUnable to find links to be deleted automatically. You will have to manually delete them if you have them in a place other than your desktop." -ForegroundColor Yellow
}

##### Remove Start Menu Shortcuts #####
Write-Host "`nRemoving Start Menu Shortcuts..."
$foundStartMenu = ""
# Check for and delete start menu shortcuts in the user's start menu folder
Write-Host "`tSearching `"$userStartMenuFolder`" for links to delete:"
foreach ($item in $startMenuLinks) {
  if (Test-Path -Path "$userStartMenuFolder\$item") {
    Remove-Item "$userStartMenuFolder\$item" -ErrorAction SilentlyContinue -Force -Recurse
    $foundStartMenu = $TRUE
    
    if (!(Test-Path -Path "$userStartMenuFolder\$item")) {
      Write-Host "`t`tRemoved start menu item at `"$userStartMenuFolder\$item`"" -ForegroundColor Green
    } else {
      Write-Host "`t`tAn error occured while trying to delete the start menu item at `"$userStartMenuFolder\$item`"" -ForegroundColor Red
    }
  } else {
    Write-Host "`t`tLooked for `"$item`" in `"$userStartMenuFolder`" but found nothing" -ForegroundColor Yellow
  }
}
# Check for and delete start menu shortcuts in the system's start menu folder
Write-Host "`tSearching `"$systemStartMenuFolder`" for links to delete:"
foreach ($item in $startMenuLinks) {
  if (Test-Path -Path "$systemStartMenuFolder\$item") {
    Remove-Item "$systemStartMenuFolder\$item" -ErrorAction SilentlyContinue -Force -Recurse
    $foundStartMenu = $TRUE
    
    if (!(Test-Path -Path "$systemStartMenuFolder\$item")) {
      Write-Host "`t`tRemoved start menu item at `"$systemStartMenuFolder\$item`"" -ForegroundColor Green
    } else {
      Write-Host "`t`tAn error occured while trying to delete the start menu item at `"$systemStartMenuFolder\$item`"" -ForegroundColor Red
    } 
  } else {
    Write-Host "`t`tLooked for `"$item`" in `"$userStartMenuFolder`" but found nothing" -ForegroundColor Yellow
  }
}
if (!$foundStartMenu) {
  Write-Host "`tThere is no Start Menu folder to delete. It was either already removed or the wpilib installer was run without admin privlages" -ForegroundColor Yellow
}

Write-Host "`nFinished uninstalling WPILib!" -ForegroundColor Green