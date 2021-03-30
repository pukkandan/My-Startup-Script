pasteText(text:="", opts:="") {
    static def:={allowClip:False, keep:False, win:"", waitWin:"", cntrl:""}
    if !IsObject(opts) {
        opts:=def.clone()
    } else {
        for i,j in def
            if !opts.haskey(i)
                opts[i]:=j
    }

    if !opts.cntrl {
        if (text!="") {
            clipOld:=ClipboardAll
            Clipboard:=text
            ClipWait, 1
            if (Clipboard!=text)
                return False
        } else if !opts.allowClip { ; No text was given. Consider as success
            return True
        }
    }

    if opts.waitWin
        WinWaitActive, % opts.waitWin
    sleep 100

    if opts.cntrl {
        ControlSetText, % opts.cntrl, % text, % opts.win
        return True
    } else {
        if opts.win {
            WinActivate % opts.win
            WinWaitActive % opts.win,, 1
        }
        Send, +{Insert} ;^v
    }
    
    sleep 100
    if (text!="") {
        Clipboard:=clipOld
        if opts.keep
            Clipboard:=text
    }

    return True

}