#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetTitleMatchMode, 1
SetControlDelay, -1

;;;;; Options ;;;;;
VSCodeZipName := "OfflineVsCodeFiles-1.41.1.zip" ; Default Zip Name
usePreDownloadedZip := "download" ; Default value that controls whether the main zip file will be downloaded(0) or looked for(1).
installModeOption := "both" ; Default value that sets whether or not to install Java(0) mode or C++(1) mode or both(2)
allowUserInteraction := "false" ; Default is to not allow user interaction

;;;;; Parameters ;;;;;
; MsgBox % "Starting with " . A_Args[0] . " parameters: " . A_Args[1] . " " A_Args[2] . " " A_Args[3] . "."

; Parameter for Install Mode Option
if(A_Args[1] != "" and A_Args[1] = "cpp" or A_Args[1] = "java" or A_Args[1] = "both") {
    installModeOption := A_Args[1]
}

; Parameter for whether to download zip or use given or default local zip
if(A_Args[2] = "true") {
    usePreDownloadedZip := "cached"
}
if(A_Args[2] != "" and A_Args[2] != "true" and A_Args[2] != "false") {
    usePreDownloadedZip := "cached"
    VSCodeZipName := A_Args[2]
}

; Parameter for user interaction
if(A_Args[3] = "true") {
    allowUserInteraction := "true"
}

;;;;; Window Search Settings ;;;;;
; Tite and Text for the first main install window
winMainInstallWindowTitle := "WPILib Installer"
winMainInstallWindowText := "Use Checkbox to force reinstall"

; Title and Textfor the window where you choose to download or select the VSCode download
winChooseDownloadOrSelectTitle := "Selector"
winChooseDownloadOrSelectText := "Would you like to download VS Code"

; Title and Text for the zip selection window
winSelectDownloadTitle := "Select VS Code Zip"
winSelectDownloadText := "Address: D:\Projects\Programming\Choco"

; Title and Text for the Finished Window
winFinishedTitle := ""
winFinishedText := "Finished! Use Desktop Icon to Open VS Code"

;;;;; Operations ;;;;;
; Selecting the Select/Download VS Code button
; MsgBox % "Select/Download"
WinWait, %winMainInstallWindowTitle%, %winMainInstallWindowText%
WinActivate, %winMainInstallWindowTitle%,,,
Sleep, 5000 ; So apparently the window and button exist before its actually clickable but it'll still try so we have to wait.
ControlClick, Select/Download VS Code, %winMainInstallWindowTitle%,,,, NA

; Selecting the options to either download or choose existing
if (usePreDownloadedZip = "cached") {
    WinWait, %winChooseDownloadOrSelectTitle%, %winChooseDownloadOrSelectText%
    Sleep, 300
    ControlClick, Select Existing, %winChooseDownloadOrSelectTitle%,,,, NA

    ; Type in the file name and hit enter
    WinWait, %winSelectDownloadTitle%
    Sleep, 300
    SendInput {Raw}%VSCodeZipName%
    Send {Enter}
} else {
    WinWait, %winChooseDownloadOrSelectTitle%, %winChooseDownloadOrSelectText%
    Sleep, 300
    ControlClick, Download, %winChooseDownloadOrSelectTitle%,,,, NA
    WinWaitClose, %winChooseDownloadOrSelectTitle%
}

; Select desired C++ or Java options
; MsgBox % "Selecting Language Options: " . installModeOption
if (installModeOption == "java") {
    Sleep, 400
    ControlClick, C++ Compiler, %winMainInstallWindowTitle%,,,, NA
} else if (installModeOption == "cpp") {
    Sleep, 400
    ControlClick, Java JDK/JRE, %winMainInstallWindowTitle%,,,, NA
} else if (installModeOption == "both") {
    ; Do nothing
}

Sleep, 100 ; Just to play it safe before install

; If no errors, start install and wait for finish and hit ok
if !(ErrorLevel) {
    ; MsgBox % "No AHK errors! - GO!"
    if (allowUserInteraction == "false") {
        ControlClick, Execute Install, %winMainInstallWindowTitle%,,,, NA
        WinWait, %winFinishedTitle%, %winFinishedText%
        ControlClick, OK, %winFinishedTitle%, %winFinishedText%,,, NA
    } else {
        MsgBox % "Ending to allow user interaction."
    }
} else {
   MsgBox % "AHK ERROR!!" 
}