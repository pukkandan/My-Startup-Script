getSelectedText(opts:="") {
 /* Returns selected text without disrupting the clipboard. However, if the clipboard contains a large amount of data, some of it may be lost
 */

    def:={path:False, clip:False, clean:False}

    if !IsObject(opts) {
        opts:=def.clone()
    } else {
        for i,j in def
            if !opts.haskey(i)
                opts[i]:=j
    }
    
    clipOld:=ClipboardAll
    Clipboard:=""
    Send, ^c
    ClipWait, 0.1, 1
    sleep 100
    clipNew:=Clipboard
    Clipboard:=clipOld
    clipOld:=""

    clipNew:=_getSelectedText_process(clipNew, opts)
    return (!opts.clip || clipNew)? clipNew: _getSelectedText_process(Clipboard, opts)
}

_getSelectedText_process(clip, opts){
    if !clip
        return ""
    if (!opts.path && Explorer_winActive() ) {
        clipNew:=""
        Loop, Parse, clip, `n, `r
            clipNew.=path(A_LoopField).name "`n"
    } else {
        clipNew:=clip
    }

    return !opts.clean? clipNew: str_Replace(clipNew, [ ["\s+", " ", True], ["^ | $", "", True] ])
}