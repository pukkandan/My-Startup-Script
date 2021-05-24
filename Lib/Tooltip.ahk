Tooltip(tip:="", p:=""){
    ; static def:={ color:{bg:"0x222222",text:"0xFFFFFF"}, font:{size:8, opt:"",name:"Segoe UI"} }
    static def:={ font:{size:8, opt:"",name:"Segoe UI"} }
    if !tip
        return _TT_RemoveNow(p.no)
    if A_IsPaused
        return

    ; Tooltip_color(p.color.bg? p.color.bg :def.color.bg , p.color.text? p.color.text :def.color.text)
    ; ToolTip_Font( "norm s" (p.font.size? p.font.size :def.font.size) (p.font.opt? p.font.opt :def.font.opt)
    ;             , p.font.name ? p.font.name  :def.font.name )

    if (p.mode) {
        mode:=A_CoordModeToolTip
        CoordMode, Tooltip, % p.mode
    }
    tooltip, % tip, % p.x, % p.y, % p.no
    if mode
        CoordMode, Tooltip, % mode

    if p.life
        _TT_Remove(p.life,p.no)
    ; if (p.reset!=false){
    ;     ToolTip_Font ("Default")
    ;     Tooltip_color("Default","Default")
    ; }
    return
}

;------------------------------------------------------------------------------
_TT_Remove(time:=1,WhichToolTip:=1){
    if WhichToolTip not between 1 and 20
        WhichToolTip:=1
    static act:=[]
    if !act.haskey(Whichtooltip)
        act[WhichToolTip]:=Func("_TT_RemoveNow").bind(WhichToolTip)
    obj:=act[WhichToolTip]
    setTimer, % obj, -%time%
    return
}
_TT_RemoveNow(no:=1){
    Tooltip,,,,% no
    return
}

;------------------------------------------------------------------------------
;Causes problems with thread delays!
;lexikos: https://autohotkey.com/boards/viewtopic.php?t=4777
ToolTip_Font(Options := "", Name := "", hwnd := "") {
    static hfont := 0
    if (hwnd = ""){
        hfont := Options="Default" ? 0 : _TTG("Font", Options, Name)
        _TTHook()
    } else
        DllCall("SendMessage", "ptr", hwnd, "uint", 0x30, "ptr", hfont, "ptr", 0)
}
ToolTip_Color(Background := "", Text := "", hwnd := "") {
    static bc := "", tc := ""
    if (hwnd = "") {
        if (Background != "")
            bc := Background="Default" ? "" : _TTG("Color", Background)
        if (Text != "")
            tc := Text="Default" ? "" : _TTG("Color", Text)
        _TTHook()
    } else {
        VarSetCapacity(empty, 2, 0)
        DllCall("UxTheme.dll\SetWindowTheme", "ptr", hwnd, "ptr", 0
            , "ptr", (bc != "" && tc != "") ? &empty : 0)
        if (bc != "")
            DllCall("SendMessage", "ptr", hwnd, "uint", 1043, "ptr", bc, "ptr", 0)
        if (tc != "")
            DllCall("SendMessage", "ptr", hwnd, "uint", 1044, "ptr", tc, "ptr", 0)
    }
}
_TTHook() {
    static hook := 0
    if !hook
        hook := DllCall("SetWindowsHookExW", "int", 4
            , "ptr", RegisterCallback("_TTWndProc"), "ptr", 0
            , "uint", DllCall("GetCurrentThreadId"), "ptr")
}
_TTWndProc(nCode, _wp, _lp) {
    ; Critical 999
   ;lParam  := NumGet(_lp+0*A_PtrSize)
   ;wParam  := NumGet(_lp+1*A_PtrSize)
    uMsg    := NumGet(_lp+2*A_PtrSize, "uint")
    hwnd    := NumGet(_lp+3*A_PtrSize)
    if (nCode >= 0 && (uMsg = 1081 || uMsg = 1036)) {
        _hack_ = ahk_id %hwnd%
        WinGetClass wclass, %_hack_%
        if (wclass = "tooltips_class32") {
            ToolTip_Color(,, hwnd)
            ToolTip_Font(,, hwnd)
        }
    }
    return DllCall("CallNextHookEx", "ptr", 0, "int", nCode, "ptr", _wp, "ptr", _lp, "ptr")
}
_TTG(Cmd, Arg1, Arg2:="") {
    static htext := 0, hgui := 0
    if !htext {
        Gui _TTG: Add, Text, +hwndhtext
        Gui _TTG: +hwndhgui +0x40000000
    }
    Gui _TTG: %Cmd%, %Arg1%, %Arg2%
    if (Cmd = "Font") {
        GuiControl _TTG: Font, %htext%
        SendMessage 0x31, 0, 0,, ahk_id %htext%
        return ErrorLevel
    }
    if (Cmd = "Color") {
        hdc := DllCall("GetDC", "ptr", htext, "ptr")
        SendMessage 0x138, hdc, htext,, ahk_id %hgui%
        clr := DllCall("GetBkColor", "ptr", hdc, "uint")
        DllCall("ReleaseDC", "ptr", htext, "ptr", hdc)
        return clr
    }
}
