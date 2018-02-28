class winProbe {
    activate(){
        Menu, Tray, Check, &Window Probe
        if !this.Obj
            this.Obj:=ObjBindMethod(this,"show")
        if !this.copyObj
            this.copyObj:=ObjBindMethod(this,"copy")
        if !this.otherObj
            this.otherObj:=ObjBindMethod(this,"toggleOther")
        act:=this.Obj
        setTimer, % act, 100
        setTimer, % act, On
        act:=this.copyObj
        Hotkey, ^#w , % act, On
        act:=this.otherObj
        Hotkey, ^#o , % act, On
        this.showOther:=False
        return this.active:=True
    }
    deActivate(){
        Menu, Tray, UnCheck, &Window Probe
        act:=this.Obj
        setTimer, % act, Off
        Hotkey, ^#w,, Off
        Hotkey, ^#o,, Off
        Tooltip("",{no:2})
        return this.active:=False
    }
    toggle(){
        return this.active?this.deActivate():this.activate()
    }

    copy(){
        ClipBoard:= strReplace(this.tip (this.showOther?"`n`n" this.extended_tip:""),"`n","`r`n")
        return
    }
    toggleOther(){
        return this.showOther:=!this.showOther
    }

    show(){
        DetectHiddenWindows, On
        MouseGetPos,x,y, w, c
        Winget, pn, ProcessName, ahk_id %w%
        WingetClass, cl, ahk_id %w%
        WinGetTitle, t, ahk_id %w%
        Winget, s, style, ahk_id %w%
        Winget, es, eXstyle, ahk_id %w%
        ControlGetFocus, ac,  ahk_id %w%
        this.tip:="Title: """ substr(strReplace(t,"`n"," "),1,100) """`nID: " w "`nProcess: " pn "`nClass: " cl "`nStyle: " s "`nExStyle: " es "`nControl: " c "`nActive Control: " ac "`n"

        if (this.showOther) {
            winget, l, List, ahk_exe %pn% ahk_class %cl%
            this.extended_tip:="Windows with same Class and Process`n"
            loop, % l {
                i:=l%A_Index%
                WinGetTitle, t, ahk_id %i%
                Winget, s, Style, ahk_id %i%
                Winget, es, ExStyle, ahk_id %i%
                this.extended_tip.=i " | S:" s " | E:" es  " | """ substr(strReplace(t,"`n"," "),1,100) """`n"
            }
        } else this.extended_tip:=""
        toolTip(this.tip "`nCTRL+WIN+W to Copy to Clipboard`nCTRL+WIN+O to " (this.showOther?"HIDE":"SHOW") " details of other windows with same class and process`n`n" this.extended_tip,{no:2})
        return
    }
}