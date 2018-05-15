unwantedPopupBlocker(){
	IfWinExist, (UNREGISTERED) ahk_exe sublime_text.exe
	{
		WinGetTitle, t
		WinSetTitle,% StrReplace(t, " (UNREGISTERED)")
	}
	IfWinExist, This is an unregistered copy ahk_exe sublime_text.exe ahk_class #32770     ;Sublimetext register
		ControlClick, Button2

    IfWinExist, Disable developer mode extensions ahk_exe chrome.exe        ;Chrome dev mode
    {
        winactivate
        send, {esc}
        ; ControlSend, Intermediate D3D Window1, {esc},
    }

    IfWinExist, Error ahk_class #32770 ahk_exe SdDisplay.exe
        winclose
    return
}