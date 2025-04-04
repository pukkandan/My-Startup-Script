; d:={ title:{color:"0x0000FF"} , margin:[100,100]}
; t:=new toast(d)
; p:={ title:{text:"hi",color:"0x0000FF"} , margin:[100,50] ,message:{ text:["hello","2","3"], def_size:18, size:[9,10], color:["0xFF00FF","0x00FF00"], offset:["",1] },life:0 }
; t.show(p)
; sleep, 1000
; t.show({ title:{text:"whatever"},message:{text:["hello"]} }) ;Replaces previous instance of same obj
; sleep, 200
; Toast.show("hi") ;Show with all default settings
; Toast.show(p) ;Show without creating a dedicated object. Will replace other instances without object, but not other object

class Toast{
    __new(p:=""){
        static toastCount:=0
        toastCount++
        this.id:=toastCount, this.closeObj:=ObjBindMethod(this,"close")
        ,this.def:={ life:500, pos:{x:"center",y:"center"}, bgColor:"0x222222", trans:250, margin:{x:5,y:5}
                    , closekeys:[["~LButton","Esc"]], sound:false, activate:False
                    , title:{ text:"", color: "0xFFFFFF", size:14, opt:"bold", font:"Segoe UI" }
                    , message:{ text:[], color: [], size:[], opt:[], name:[], offset:[20]
                              , def_color: "0xFFFFFF", def_size:12, def_opt:"", def_name:"Segoe UI", def_offset:5 } }
        if (p.life==0)
            this.def.closekeys:=[["~Space","Return","~LButton","Esc"]]
        if p
            for i,x in p {
                if IsObject(x)
                    for j,y in x
                        this.def[i][j]:= p[i][j]
                else this.def[i]:=p[i]
            }

    }
    setParam(p,def:=false){
        if !IsObject(p) ;If not object, assume only title is given
            p:={title:{text:p}}
        for i,x in this.def {
            if IsObject(x) {
                this[i]:={}
                for j,y in x
                    this[i][j]:= (p[i][j]="")? this.def[i][j] : p[i][j]
            } else this[i]:= (p[i]="")? this.def[i] : p[i]
        }
        this.x:=this.pos.x, this.y:=this.pos.y, this.pos:="", this.closekeys:=this.closekeys[1]
        return
    }
    show(param){
        if A_IsPaused
            return
        if !this.def
            this.__new()
        this.setParam(param)

        GUI_handle:="Toast_GUI" this.id
        Gui, %GUI_handle%: New, -Caption +ToolWindow +AlwaysOnTop +hwndHWND
        this.hwnd:=hwnd
        Gui, %GUI_handle%: Color, % this.bgColor
        Gui, %GUI_handle%:+LastFoundExist
        WinSet, Trans, % this.trans
        Gui, %GUI_handle%:Margin, % this.margin.X, % this.margin.Y

        t:=this.title.text, s:=this.title.size, c:=this.title.color, o:=this.title.opt, f:=this.title.Font
        Gui, %GUI_handle%: Font, norm s%s% c%c% %o%, %f%
        Gui, %GUI_handle%: Add, Text, Center hwndTitleHwnd, %t%

        for i,t in this.message.text {
             s:= this.message.size  [i] = "" ? this.message.def_size    : this.message.size  [i]
            ,c:= this.message.Color [i] = "" ? this.message.def_color   : this.message.color [i]
            ,o:= this.message.opt   [i] = "" ? this.message.def_opt     : this.message.opt   [i]
            ,f:= this.message.Font  [i] = "" ? this.message.def_font    : this.message.Font  [i]
            ,m:= this.message.offset[i] = "" ? this.message.def_offset  : this.message.offset[i]
            Gui, %GUI_handle%: Font, norm s%s% c%c% %o%, %f%
            Gui, %GUI_handle%: Add, Text, xp y+%m%, %t%
        }

        OnMessage(0x202, closeObj:=this.closeObj)
        this.exist:=True
        Gui, %GUI_handle%: Show, % (this.activate?"":"NoActivate ") "autosize x" this.x " y" this.y, % "Toast" this.id

        ; Center title
        WinGetPos,,, w,, ahk_id %hwnd%
        GuiControl, %GUI_handle%: MoveDraw, % titleHWnd, % "w" w - 2*this.margin.X

        if this.sound
            SoundPlay, *-1
        if this.life
            setTimer, % closeObj , % "-" this.life
        for _,k in this.closekeys
            Hotkey, % k , % closeObj, On B0 T1
        return
    }
    close(wparam:="",lParam:="",msg:="",hwnd:=""){
        if (hwnd and hwnd!=this.hwnd)
            return

        this.exist:=False, GUI_handle:="Toast_GUI" this.id
        for _,k in this.closekeys
            try Hotkey % k, Off
        Gui, %GUI_handle%: Destroy
        return
    }
}
