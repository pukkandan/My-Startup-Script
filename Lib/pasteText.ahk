pasteText(text:="", win:="", cntrl:="", waitWin:="") {
    if text {
        clipOld:=ClipboardAll
        Clipboard:=text
        ClipWait
    }

    if waitWin
        WinWaitActive, % waitWin
    
    if (win) {
        ControlSend, % cntrl, ^v, % win
    } else {
        Send, +{Insert} ;^v
    }
    
    if text
        Clipboard:=clipOld

    return

}