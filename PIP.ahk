; EXAMPLE
;-------------------------
; #persistent
; #include TaskView.ahk
; TaskView.__new()
; #include PIP.ahk
; PIP.__new([   {title:"ahk_exe PotPlayerMini64.exe ahk_class PotPlayer64" ,type:"VJT"},
;               {title:"ahk_exe PotPlayer.exe ahk_class PotPlayer64"       ,type:"VJT"},
;               {title:"ahk_exe chrome.exe ahk_class Chrome_WidgetWin_1"   ,type:"CJT"}     ])
; obj:=ObjbindMethod(PIP,"run")
; setTimer, % obj, 100
; PIP.add("ahk_exe sublime_text.exe ahk_class PX_WINDOW_CLASS")
; PIP.add([{title:"ahk_exe explorer.exe ahk_class CabinetWClass",type:"J",set:2}])
; onExit(ObjbindMethod(PIP,"run",1))

class PIP {
    __module_init(args*){
        this.__new(args*)
        this.__module := { timerFn: ObjbindMethod(this, "run") }
    }
    __new(p:=""){
        this.list:={}, this.sets:=0, this.topListOld:=[], this.topList:=[], mouseAllowed:=[]
        , this.def:={ set:1, type:"J", maxwidth:0.45, maxheight:0.45 }
        onExit(ObjbindMethod(this, "run", true))
        if p
            this.add(p)
    }
    add(param){
        if !IsObject(param)
            param:=[{title:param}]

        for _,p in param {
            t:=p.title
            if t is number
                t:="ahk_id " t

            /*      Type
                    H = Get hidden windows as well
                    D = Return to parent desktop on unPiP
                    T = Show/Hide Titlebar
                    J = Jump on MouseOver
                    V = Dont Show Titlebar on Mouseover (for Video players that have internal titlebar)
                    C = Eliminate undesired Chrome windows (Page Unresponsive popup)
                    N = None of the above

            */
            if (!p.type)
                p.type:=this.def.type

            if (!p.set) {
                p.set:=this.def.set
            } if (p.set=0) {
                p.set:=this.sets+1   ;new set
            } else {
                set:=p.set
                if set is not number
                    p.set:=this.sets+1   ;new set
            }

            for _,dim in ["width", "height"] { ; If Width/height < 1 , it is relative
                key:="max" dim
                val:=p[key]? p[key] :this.def[key]
                if val<1
                    p[key]:= A_Screen%dim% *val
                ;msgbox % val "`n" p[key]
            }

            this.unPIP(this.list[t].set)
            for prop,def in this.def
                this.list[t,prop]:= p[prop]?p[prop]:def
            ;msgbox, % "Add:" t "`n" this.list[t].type " " this.list[t].set
        }

        return this.sets:=(this.sets>this.list[t].set?this.sets:this.list[t].set)
    }
    remove(title){
        if !IsObject(title)
            title:=[title]
        for _,t in title {
            if t is number
                t:=ahk_id %t%
            this.list.delete(t)
        }
    }

    getPIPWindow(t,item){
        DetectHiddenWindows % !!inStr(item.type,"H")
        IDList0:=WinActive(t)
        WinGet, IDList , List, % t
        ; msgbox, %t%`n%IDList% Windows
        Loop, % IDList+1
        {
            i:=A_Index-1
            n:=IDList%i%
            IfWinNotExist, ahk_id %n%
                continue
            ; msgbox, %t%`n%n%

            ;Elimination of undesired windows
            WinGet, currentPID, PID, ahk_id %n%
            if inStr(item.type,"V") { ;Potplayer-like
                ifWinExist, ahk_class #32768 ahk_pid %currentPID%    ;If a menu exists, the window is not forced on top
                    continue
                ifWinExist, ahk_class #32770 ahk_pid %currentPID%    ;Special windows like Settings
                    continue
            }
            WinGet, MinMax, MinMax, ahk_id %n%
            if MinMax=-1  ;Minimized
                continue
            WinGetPos,,, w, h, ahk_id %n%
            ; msgbox, %w% %h%
            if (h>item.maxHeight || w>item.maxWidth || h<32)    ;Too small
                continue
            if inStr(item.type,"C"){   ;Chrome-like
                WinGetTitle, title, ahk_id %n%
                if (title="Page Unresponsive" OR title="Pages Unresponsive")
                    continue
                WinGet, s, Style, ahk_id %n%
                if (s&0x80000000){  ;Chrome Notification
                    ;~ WinSet, AlwaysOnTop, On, ahk_id %n%   ;Make Chrome notification come on top
                    continue
                }
            }

            ; msgbox, return %n%`n%t%
            return n ;This window isnt eliminated
        }
        ; msgbox, %t%`nno window
        return 0
    }
    getPIPWindows(){
        winPref:=[], this_winPref:=0, topList:=[]
        for t,i in this.list {
            n:=this.getPIPWindow(t,i)
            IfWinNotExist, ahk_id %n%
                continue

            ifWinActive, ahk_id %n%
                this_winPref:=3
            else if (this.topListOld[i.set].id=n)
                this_winPref:=2
            else this_winPref:=1

            if ( this_winPref > (winPref.haskey(i.set)?winPref[i.set]:0) )
                winPref[i.set]:=this_winPref
            else
                continue
            topList[i.set]:={id: Format("{1:#x}",n), type: i.type}
            ; msgbox, % "this.topList[" i.set "]:={id:" n ",type:" i.type "}`nid=" this.topList[i.set].id ",type=" this.topList[i.set].type
        }
        return topList
    }
    unPIP(set){
        old:=this.topListOld[set]
        this.mouseAllowed[set]:=True
        WinSet, AlwaysOnTop, Off, % "ahk_id " old.id
        taskView.UnPinWindow(old.id)
        if inStr(old.type,"D") && old.desk {
            if WinActive("ahk_id " old.id)
                TaskView.MoveWindowAndGoToDesktopNumber(old.desk, old.id,,2)
            else
                TaskView.MoveWindowToDesktopNumber(old.desk, old.id)
        }
        if !isFullScreen(old.id,1) AND inStr(old.type,"T")
            WinSet, Style, +0xC00000, % "ahk_id " old.id
    }
    unPIPOld(force:=False){
        for set,old in this.topListOld {
            if (this.mouseAllowed[set]=="")
                this.mouseAllowed[set]:=True
            if (force || this.topList[set].id!=old.id)
                this.unPIP(set)
            else if (old.desk)
                this.topList[set].desk:=old.desk
        }
        return
    }

    PIP(set){
        n:=this.topList[set].id
        if inStr(this.topList[set].type,"D") && !this.topList[set].desk {
            this.topList[set].desk:=TaskView.getWindowDesktopNumber(n)
            if !this.topList[set].desk ; Couldn't get
                this.topList[set].desk:=TaskView.getCurrentDesktopNumber()
        }
        if !TaskView.isPinnedWindow(n)
            TaskView.pinWindow(n)
        WinSet, AlwaysOnTop, On, ahk_id %n%    ;Set onTop
        ; msgbox, PIP:%set% id:%n%

        ;Avoid mouseover
        if isOver_mouse(n){
            if (GetKeyState("Control","P") || GetKeyState("LButton","P") || GetKeyState("RButton","P") || GetKeyState("MButton","P") || WinActive("ahk_id" n))
                this.mouseAllowed[set]:=True

            if (!this.mouseAllowed[set]){
                if inStr(this.topList[set].type,"J") {
                    WinGetPos, onTopX,,onTopW,, ahk_id %n%
                    onTopX/=A_ScreenWidth, onTopW/=A_ScreenWidth
                    WinMove, ahk_id %n%,, % A_ScreenWidth*(2*onTopX>1-onTopW ? 0.05 : 1-onTopW-0.02)
                }
            } else if inStr(this.topList[set].type,"T") AND !inStr(this.topList[set].type,"V")
                WinSet, Style, +0xC00000, ahk_id %n%
        } else this.mouseAllowed[set]:=False

        if (!this.mouseAllowed[set]) AND inStr(this.topList[set].type,"T") {
            if inStr(this.topList[set].type,"V")
                WinSet, Style, -0x400000, ahk_id %n%
            else if (!this.mouseAllowed[set])
                WinSet, Style, -0xC00000, ahk_id %n%
        }
        return
    }
    setPIP(){
        if (this.mouseAllowed[set]="")
            this.mouseAllowed[set]:=False
        for set in this.topList
            this.PIP(set)
        return
    }

    run(exiting:=false){
        this.topListOld:=this.topList
        if !exiting
            this.topList:=this.getPIPWindows()
        this.unPIPOld(exiting)
        if !exiting
            this.setPIP()
        return
    }
}
