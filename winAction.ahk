class winAction{

    __new(txt:="winAction.ini"){
        this.itemList:=[]

        act:=ObjBindMethod(this,"onTopToggle")
        Menu, winAction, Add, Always on &Top , % act
        act:=ObjBindMethod(this,"trayit")
        Menu, winAction, Add, &Minimize to Tray , % act
        act:=ObjBindMethod(this,"TaskView_PinWindowToggle")
        Menu, winAction, Add, &Pin Window , % act
        act:=ObjBindMethod(this,"PIP_main")
        Menu, winAction, Add, Add to Main PIP [&V], % act
        act:=ObjBindMethod(this,"microWindows")
        Menu, winAction, Add, Make &Micro-Window , % act
        Menu, winAction, Add

        act:=ObjBindMethod(this,"Opacity")
        Menu, winAction, Add, &Opacity , % act
        act:=ObjBindMethod(this,"TaskView_PinWindowToggle")
        Menu, winAction TaskView, Add, Pin Window , % act
        act:=ObjBindMethod(this,"TaskView_PinAppToggle")
        Menu, winAction TaskView, Add, Pin App , % act
        act:=ObjBindMethod(this,"TaskView_Moveto")
        Menu, winAction TaskView, Add, Send to , % act
        act:=ObjBindMethod(this,"TaskView_Goto")
        Menu, winAction TaskView, Add, Go to , % act
        Menu, winAction, Add, TaskView, :winAction TaskView

        this.PIP_setnames:=["Main","Terminal","Calculator"]
        act:=ObjBindMethod(this,"PIP_add_remove",1)
        Menu, winAction PIP list, Add, % "[1] " this.PIP_setnames[1] , % act
        Menu, winAction PIP, Add, Add to , :winAction PIP list
        act:=ObjBindMethod(this,"PIP_new")
        Menu, winAction PIP, Add, New , % act
        act:=ObjBindMethod(this,"PIP_rename")
        Menu, winAction PIP, Add, Rename , % act
        Menu, winAction, Add, PIP, :winAction PIP

        Menu, winAction, Add

        IniRead, submenus, % txt
        loop, Parse, submenus, `n
        {
            submenu:=A_LoopField
            if (substr(submenu,1,1)="-")
                Menu, winAction, Add
            else {
                IniRead, lines, % txt, % submenu
                loop, parse, lines, `n
                {
                    it:=new this.item(this,A_LoopField,submenu="winAction"?"winAction":"winAction " submenu)
                    if (it.exist)
                        this.itemList.Push(it)
                }
                if (submenu!="winAction")
                    Menu, winAction, Add, % submenu, :winAction %submenu%
            }
        }
    }

    PIP_main(){
        if !this.PIP_remove()
            return PIP.add(this.win_hwnd)
        return
    }
    PIP_new(){
        InputBox, n, PIP - Set Name,,,200,100,,,,, % "Set " PIP.sets+1
        if ErrorLevel
            return

        this.PIP_setnames[PIP.sets+1]:=n
        return this.PIP_TypeMenu()
    }
    PIP_remove(){
        if PIP.list.haskey(this.win_) {  ; Cannot remove windows that arent set by winAction
            s:=PIP.list[this.win].set
            if (PIP.topListOld.s.id=this.win_hwnd)
                PIP.unPIP(s)
            PIP.list.Delete(this.win)
            return s
        }
        return 0
    }
    PIP_TypeMenu(set:=0){
        act:=ObjBindMethod(PIP,"add",[{title:this.win, set:set, type:"VJT"}])
        Menu, winAction PIP type, Add, &Potplayer-like, % act
        act:=ObjBindMethod(PIP,"add",[{title:this.win, set:set, type:"CJT"}])
        Menu, winAction PIP type, Add, &Chrome-like, % act
        act:=ObjBindMethod(PIP,"add",[{title:this.win, set:set, type:"J"}])
        Menu, winAction PIP type, Add, Keep &Titlebar, % act
        act:=ObjBindMethod(PIP,"add",[{title:this.win, set:set, type:"JT"}])
        Menu, winAction PIP type, Add, &Normal, % act
        act:=ObjBindMethod(PIP,"add",[{title:this.win, set:set, type:"N"}])
        Menu, winAction PIP type, Add, &Just on Top, % act
        Menu, winAction PIP type, Default, Keep &Titlebar
        Menu, winAction PIP type, show
        return
    }
    PIP_add_remove(set){
        s:=this.PIP_remove()
        if (s!=0 and s=set)
            return
        return this.PIP_TypeMenu(set)
    }
    PIP_check(){
        Menu, winAction PIP list, DeleteAll
        loop, % PIP.sets {
            act:=ObjBindMethod(this,"PIP_add_remove",A_Index)
            name:= "[" A_Index "] " (this.PIP_setnames[A_Index]?this.PIP_setnames[A_Index]:"Set " A_Index)
            Menu, winAction PIP list, Add, % name, % act
            set:=PIP.list[this.win].set
            Menu, winAction PIP list, % (set=A_Index)?"Check":"UnCheck", % name
            if (A_Index=1)
                Menu, winAction, % (set=A_Index)?"Check":"UnCheck", Add to Main PIP [&V]
        }
        return
    }
    PIP_rename() {
        InputBox, n, PIP - Rename,Enter Set number,,200,125,,,,,
        if ErrorLevel
            return
        if n is not number
            return
        InputBox, name, PIP - Rename,Enter new name,,200,125,,,,, % "Set " n
        if ErrorLevel
            return
        this.PIP_setnames[n]:=name
        return

    }

    microWindows(){
        return new microWindow(this.win_hwnd)
    }

    TaskView_Goto(){
        InputBox, n, Go to,,,150,100,,,,, % taskView.GetCurrentDesktopNumber()
        return taskView.GoToDesktopNumber(n)
    }
    TaskView_Moveto(){
        InputBox, n, Move to,,,150,100,,,,, % taskView.GetCurrentDesktopNumber()
        return taskView.MoveWindowToDesktopNumber(n,this.win_hwnd)
    }
    TaskView_PinWindowToggle(){
        return taskView.PinWindowToggle(this.win_hwnd)
    }
    TaskView_PinAppToggle(){
        return taskView.PinAppToggle(this.win_hwnd)
    }
    TaskView_pinCheck(){
        isPinnedWin:= taskView.isPinnedWindow(this.win_hwnd) ? "Check" : "Uncheck"
        Menu, winAction, % isPinnedWin, &Pin Window
        Menu, winAction TaskView, % isPinnedWin, Pin Window
        Menu, winAction TaskView, % taskView.isPinnedApp(this.win_hwnd)?"Check":"Uncheck", Pin App
        return
    }

    onTopToggle(){
        winset, AlwaysOnTop,, % this.win
        return
    }
    onTopCheck(){
        WinGet, s, ExStyle, % this.win
            Menu, winAction, % (s&0x8)?"Check":"Uncheck", Always on &Top
        return
    }

    Opacity(){
        winget, T_def, Transparent, % this.win
        if T_def is not number
            T_def:=255
        InputBox, trans, Opacity, 000 = Fully Transparent`n255 = Fully Opaque,,300,150,,,,, % T_def
        if trans is not number
            trans=Off
        winset, Transparent, % trans, % this.win
        winset, redraw
        return
    }

    trayit(){
        static title_len:=90
        WinGetTitle, title , % this.win
        WinGet, exe, ProcessName, % this.win
        WinGet, path, ProcessPath, % this.win
        if (exe="hh.exe") ; hh.exe is the name of chm reader
            exe:="CHM"
        else if (exe="Applicationframehost.exe") ; Metro App
        {
            path:="C:\Windows\System32\consent.exe" ; For Icon
            exe:="X"
        }
        exe:=Format("{:T}", str_replace(exe, [[".exe"], ["_"," "]] )) ;"sublime_text.exe" to "Sublime Text" etc
        title:="[" exe "]> " StrReplace(title, " - " exe) ; Remove " - Sublime Text" etc
        title:=(strLen(title)>title_len? substr(title, 1, title_len-3) "..." :title) " " this.win_hwnd ; Limit Size. win_hwnd is added for uniqueness

        ; winget, s, style, % this.win
        ; winget, es, exstyle, % this.win
        act:=ObjBindMethod(this,"unTrayIt",this.win,title)
        Menu, trayIt, Add, % title, % act
        try Menu, trayIt, Icon, % title, % path, 0
        OnExit(act)

        ; WinSet, style, -0, % this.win
        ; WinSet, exstyle, -0x80, % this.win
        WinHide, % this.win
        return
    }
    unTrayIt(uid,name,s:=0,es:=0){
        winshow, % uid
        winactivate, % uid
        ; winset, Style, % s, % uid
        ; winset, ExStyle, % es, % uid
        ; WinSet, Redraw

        try{
            menu, trayIt, delete, % name
            OnExit(ObjBindMethod(this,"unTrayIt",this.win,title),0) ;Unregister
        }
        return
    }

    class item{
        __new(parent,line,menu){
            this.menu:=menu, rep:=1, this.exist:=True, this.parent:=parent
            if (substr(line,1,1)="-"){
                this.exist:=False
                Menu, % this.menu, Add
                return
            }

            line:=StrReplace(line, " ", "`t")
            loop
                line:=StrReplace(line, "`t`t", "`t", rep)
            until rep=0
            line:=StrReplace(line, "_", " ")

            lineArr:=StrSplit(line, A_Tab)
            if (substr(lineArr[1],1,1)="E")
                this.exstyle:=True
            else this.exstyle:=False
            this.style:=substr(lineArr[1],this.exstyle?2:1)
            this.name:=lineArr[2]

            if (this.name="" OR this.style=""){
                this.exist:=False
                msgbox, Insufficient data!!`n"%line%"
            } else{
                act:=ObjBindMethod(this,"action")
                Menu, % this.menu, Add, % this.name , % act
            }
            ; Msgbox, % this.name " " this.style
        }
        action(){
            if (this.exstyle)
                winset, exstyle, % "^" this.style, % this.parent.win
            else
                winset, style, % "^" this.style, % this.parent.win
            e:=ErrorLevel
            WinSet, Redraw
            if e
                MsgBox, 0x30, Error! %errorlevel%, Could not apply style
            this.checkMenu()
            return
        }
        checkMenu(){
            if (this.exstyle)
                winget, s, exstyle, % this.parent.win
            else
                winget, s, style, % this.parent.win
            ; msgbox, % this.name "`n" s " " this.style " " s&this.style
            Menu, % this.menu, % (s&this.style)?"Check":"Uncheck", % this.name
            return
        }
    }

    show(){
        Toast.show("winAction")
        if !this.bind_Window()
            return
        ; sleep, % 500+t0-A_TickCount ;Give time for toast to disappear
        Menu, winAction, show
        Tooltip
        return
    }

    bind_Window(win:="A"){
        this.win_hwnd:=WinExist(win)
        ; t0:=A_TickCount
        this.win:="ahk_id " this.win_hwnd
        WinGetClass, winclass, % this.win
        if (winclass="WorkerW" OR winclass="Shell_TrayWnd" OR !winexist(this.win)){
            Toast.show("No Window")
            return False
        }

        this.PIP_Check()
        this.TaskView_pinCheck()
        this.onTopCheck()
        loop, % this.itemlist.length()
            this.itemList[A_index].checkMenu()
        return True
    }

}
