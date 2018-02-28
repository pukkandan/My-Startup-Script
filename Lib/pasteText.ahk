;Buggy!!
pasteText(text:="",window:="",controll:="") {
    Msgbox, Warning - Buggy!!
    if text {
        clipOld:=ClipboardAll
        Clipboard:=text
        loop {
        sleep, 100
        if (Clipboard=text)
            break
        }
    }

    if window
        ControlSend, % controll, ^v, % window
    else
        Send, ^v

    if text
        Clipboard:=clipOld

    return

}