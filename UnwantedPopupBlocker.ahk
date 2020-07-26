unwantedPopupBlocker(){
    winClose ahk_group WG_unwantedClose
    winHide  ahk_group WG_unwantedHide

	IfWinExist, (UNREGISTERED) ahk_exe sublime_text.exe
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


