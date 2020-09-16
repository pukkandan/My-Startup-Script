unwantedPopupBlocker(){
    DetectHiddenWindows On

    winHide  ahk_group WG_unwantedHide
    winClose ahk_group WG_unwantedClose

	IfWinExist, (UNREGISTERED) ahk_group WG_SublimeText
    {
		WinGetTitle, t
		WinSetTitle,% StrReplace(t, " (UNREGISTERED)")
	}

    IfWinExist, Disable developer mode extensions ahk_exe chrome.exe
    {
        winactivate
        send, {esc}
        ; ControlSend, Intermediate D3D Window1, {esc},
    }
    return
}


