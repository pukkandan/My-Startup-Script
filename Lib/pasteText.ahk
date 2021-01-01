pasteText(text:="", win:="", cntrl:="", waitWin:="", opts:="") {
    static def:={allowClip:False, keep:False}
    if !IsObject(opts) {
        opts:=def.clone()
    } else {
        for i,j in def
            if !opts.haskey(i)
                opts[i]:=j
    }

    if (text!="") {
        clipOld:=ClipboardAll
        Clipboard:=text
        ClipWait, 0.5, 1
    } else if !opts.allowClip {
        return
    }


    if waitWin
        WinWaitActive, % waitWin
    sleep 100

    if (win) {
        ControlSend, % cntrl, +{Insert}, % win
    } else {
        Send, +{Insert} ;^v
    }
    
    sleep 100
    if (text!="") {
        Clipboard:=clipOld
        if opts.keep
            Clipboard:=text
    }

    return

}