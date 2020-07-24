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

    IfWinExist, ahk_class AvIPMDialog ahk_exe ipmGui.exe
        winclose
    IfWinExist, Internet Download Manager Registration ahk_exe IDMan.exe
        winclose
    IfWinExist, Internet Download Manager ahk_exe IDMan.exe, Internet Download Manager has been registered with a fake Serial Number
        winclose
    IfWinExist, Fences ahk_class WindowsForms10.Window.8.app.0.34f5582_r9_ad1 ahk_exe SdDisplay.exe
        winclose
    return
}


