#SingleInstance, Force
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
CoordMode, Mouse, Client
CoordMode, Pixel, Client

;;;;; Options ;;;;;
VSCodeZipName := "WPILib-VSCode-1.51.1.zip" ; Default Zip Name
usePreDownloadedZip := "download" ; Default value that controls whether the main zip file will be downloaded(0) or looked for(1).
installModeOption := "both" ; Default value that sets whether or not to install Java(0) mode or C++(1) mode or both(2)
allowUserInteraction := "false" ; Default is to not allow user interaction

;;;;; Contstants ;;;;;
InstallerTitle := "WPILib Installer"
ZipSelecterTitle := "Select VS Code Installer ZIP"
ButtonPixelColor := "0xFFFFFF"
ActualButtonColor := "0xF5F5F5"

;;;;; Parameters ;;;;;
; MsgBox % "Starting with " . A_Args[0] . " parameters: " . A_Args[1] . " " A_Args[2] . " " A_Args[3] . "."

; Parameter for Install Mode Option
if(A_Args[1] != "" and A_Args[1] = "cpp" or A_Args[1] = "java" or A_Args[1] = "both") {
    installModeOption := A_Args[1]
    StringLower, installModeOption, installModeOption
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

;;;;; Operations ;;;;;
WinWait, %InstallerTitle%
WinActivate, %InstallerTitle%
Sleep, 3000

MouseClick, Left, 594, 360, 1, 0 ; Click Start
Sleep, 3000

; Selecting the options to either download or choose existing
if (usePreDownloadedZip = "cached") {
    MouseClick, Left, 129, 295, 1, 0 ; Click Use Downloaded Offline Installer

    ; Type in the file name and hit enter
    WinWait, %ZipSelecterTitle%
    Sleep, 300
    SendInput {Raw}%VSCodeZipName%
    Send {Enter}
    Sleep, 300

    MouseClick, Left, 594, 360, 1, 0 ; Click Next
} else {
    MouseClick, Left, 127, 254, 1, 0 ; Click Download
    Sleep, 2000
    While(ButtonPixelColor != ActualButtonColor) { ; Wait for Download to finish and for 'next' button to push 'back' button to the left
        PixelGetColor, ButtonPixelColor, 538, 350
        Sleep, 500
    }
    MouseClick, Left, 594, 360, 1, 0 ; Click Next
}
Sleep, 2000

; Select desired C++ or Java options
; MsgBox % "Selecting Language Options: " . installModeOption
if (installModeOption == "java") {
    MouseClick, Left, 136, 113, 1, 0
} else if (installModeOption == "cpp") {
    MouseClick, Left, 136, 154, 1, 0
} else if (installModeOption == "both") {
    ; Do nothing
}

if !(ErrorLevel) {
    ; MsgBox % "No AHK errors! - GO!"
    if (allowUserInteraction == "false") {
        MouseClick, Left, 438, 265, 1, 0 ; Click Install for all Users
        Sleep, 5000

        ButtonPixelColor := "0xFFFFFF"
        While(ButtonPixelColor != ActualButtonColor) { ; Wait for installation to finish and for 'finish' button to appear
            PixelGetColor, ButtonPixelColor, 599, 381
            Sleep, 1000
        }
        MouseClick, Left, 591, 362, 1, 0 ; Click Finish
    } else {
        MsgBox % "Ending to allow user interaction."
    }
} else {
   MsgBox % "AHK ERROR!!" 
}