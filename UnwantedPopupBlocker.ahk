unwantedPopupBlocker(){
	IfWinExist, (UNREGISTERED) ahk_group WG_Sublime
    {
		WinGetTitle, t
		WinSetTitle % StrReplace(t, " (UNREGISTERED)")
	}

    while winExist("ahk_group WG_unwantedEsc") {
        winactivate
        send, {esc}
    }

    winHide  ahk_group WG_unwantedHide
    winHide  ahk_group WG_unwantedClose
    winHide  ahk_group WG_unwantedCloseRegex

    /*
    win:=winExist("ahk_group WG_ImageViewer")
    if win && !winActive("ahk_id " win) {
        WinGetPos,, y,, h
        if (y==0 && h==A_ScreenHeight)
            winclose
    }
    */

    DetectHiddenWindows On
    winClose ahk_group WG_unwantedClose
    SetTitleMatchMode, Regex
    winClose ahk_group WG_unwantedCloseRegex
    ;SetTitleMatchMode 2 ; Important for firstRun
    return
}