#SingleInstance, Force
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
CoordMode, Mouse, Relative
CoordMode, Pixel, Relative

;;;;; Options ;;;;;
installScope := "allUsers" ; Default value for whether to install for "allUsers" or "currentUser"
VSCodeZipPath := "download" ; Default Zip Name of "download" will cause a download instead of using a cached zip
allowUserInteraction := "false" ; Default is to not allow user interaction

;;;;; Contstants ;;;;;
INSTALLER_TITLE := "WPILib Installer"
ZIP_SELECTOR_TITLE := "Select VS Code Installer ZIP"
BUTTON_COLOR := "0xF5F5F5"

;;;;; Parameters ;;;;;
; MsgBox % "Starting with " . A_Args[0] . " parameters: " . A_Args[1] . " " A_Args[2] . " " A_Args[3] . "."

; Parameter for Install Scope
if(A_Args[1] != "" and (A_Args[1] = "allUsers" or A_Args[1] = "currentUser")) {
    installScope := A_Args[1]
}

; Parameter for whether to download zip or use given or default local zip
if(A_Args[2] != "") {
    VSCodeZipPath := A_Args[2]
}

; Parameter for user interaction
if(A_Args[3] = "true") {
    allowUserInteraction := "true"
}

;;;;; Operations ;;;;;
WinWait, %INSTALLER_TITLE%
WinActivate, %INSTALLER_TITLE%
WinSet, AlwaysOnTop , On, %INSTALLER_TITLE%
Sleep, 2000

; Find and click the start button on the right side of the screen
WinGetPos, X, Y, Width, Height, %INSTALLER_TITLE%
FindAndClick(Width/2, Height/2, Width, Height, BUTTON_COLOR)
Sleep, 1500

; Find and click install for all users or install for this user.
if (installScope = "allUsers") {
    ; All Users
    WinGetPos, X, Y, Width, Height, %INSTALLER_TITLE%
    FindAndClick(Width/2, Height/2, Width, Height*.75, BUTTON_COLOR)
} else if (installScope = "currentUser") {
    ; Current User
    WinGetPos, X, Y, Width, Height, %INSTALLER_TITLE%
    FindAndClick(0, Height/2, Width/2, Height*.75, BUTTON_COLOR)
}
Sleep, 1500

; Selecting the options to either download or choose existing
if (VSCodeZipPath = "download") {
    ; Download
    WinGetPos, X, Y, Width, Height, %INSTALLER_TITLE%
    FindAndClick(0, 0, Width/2, Height/2, BUTTON_COLOR)
} else {
    ; Use Existing Zip
    WinGetPos, X, Y, Width, Height, %INSTALLER_TITLE%
    FindAndClick(Width/2, Height*.7, Width, Height/2, BUTTON_COLOR)
    Sleep, 300
    WinWait, %ZIP_SELECTOR_TITLE%
    Sleep, 300
    SendInput {Raw}%VSCodeZipPath%
    Send {Enter}
}
Sleep, 1500

if !(ErrorLevel) {
    ; MsgBox % "No AHK errors! - GO!"
    if (allowUserInteraction == "false") {
        ; Click next which will start instalation
        WinGetPos, X, Y, Width, Height, %INSTALLER_TITLE%
        FindAndClick(Width, Height, Width/2, Height/2, BUTTON_COLOR)
        Sleep, 1500

        ; Click Finish
        WinGetPos, X, Y, Width, Height, %INSTALLER_TITLE%
        FindAndClick(Width, Height, Width/2, Height*.85, BUTTON_COLOR)
    } else {
        MsgBox % "Ending to allow user interaction."
    }
} else {
    MsgBox % "AHK ERROR!!" 
}

; Finds the specified color in the bounding box created by (X1, Y1), (X2, Y2).
; It will search in the direction of X1->X2 and Y1->Y2 (from the first point, to the second)
; It will continute to search until it finds it.
FindAndClick(X1, Y1, X2, Y2, color) {
    WinActivate, %INSTALLER_TITLE%
    PixelSearch, Xout, Yout, X1, Y1, X2, Y2, color, 0, Fast
    While(ErrorLevel = 1) { ; Wait till its found
        ; WinGetPos, X, Y, Width, Height, %INSTALLER_TITLE%
        WinActivate, %INSTALLER_TITLE%
        PixelSearch, Xout, Yout, X1, Y1, X2, Y2, color, 0, Fast
        Sleep, 500
    }
    MouseClick, Left, Xout, Yout, 1, 0
}

; Function for debugging PixelSearch parameters
TestPixelSearch(){
    Loop {
        Sleep, 500
        WinGetPos, X, Y, Width, Height, %INSTALLER_TITLE%
        PixelSearch, X, Y, Width, Height, Width/2, Height/2, %BUTTON_COLOR%, 0, Fast
        ToolTip, The color is at %X%`,%Y%, X, Y
    }
}