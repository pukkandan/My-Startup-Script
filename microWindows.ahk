; new microWindow(WinExist("My Script 2 ahk_exe explorer.exe"))

class microWindow{
    __new(wid, pos:="", w:=240, pos1:="", pos2:=""){
        static
        static n:=0
        local ww, wh
        wingetpos,,, ww, wh, % "ahk_id " wid
        this.id:=n, this.wid:=wid, this.pos1:=pos1, this.pos2:=pos2, this.mx:=16, this.my:=39
        , this.M_over:=false, this.width:=w, this.win_width:=ww, this.win_height:=wh

        if (!this.pos1)
            this.pos1:=[0,0]
        if (!this.pos2)
            this.pos2:=[ww,wh]

        local h:=w*(this.pos2[2]-this.pos1[2])/(this.pos2[1]-this.pos1[1])
        h:=(h>0?h:64)
        this.height:=h
        if (pos="")
            pos:=[ A_ScreenWidth*0.05 , A_ScreenHeight*0.87-h ]

        local GUIhwnd, act
        GUI, microWindow%n%:New, +HwndGUIhwnd +AlwaysOnTop +ToolWindow -Caption
        this.hwnd:=GUIhwnd, this.mouse_allowed:=False
        Gui, microWindow%n%:Add, Pic, x0 y0 w%w% h%h% vpic%n%
        this.dll:=this.dllLoad()
        this.prepare()

        this.hotKeys()

        GUI, microWindow%n%:Show, % "Noactivate x" pos[1] " y" pos[2] " w" w+this.mx " h" h+this.my, microWindow %n% [%wid%]
        this.update()
        n++

        act:=ObjBindMethod(this,"update")
        setTimer, % act, 100

        OnMessage(0x201, ObjBindMethod(this,"onClick")) ;Left click (down)
        OnMessage(0x204, ObjBindMethod(this,"onClick")) ;Right click (down)
    }

    dllLoad(){
        static dwmapi:= DllCall("LoadLibrary", "Str", "dwmapi.dll", Ptr)
        , dll:={ DRT  :DllCall("GetProcAddress", Ptr, dwmapi, AStr, "DwmRegisterThumbnail"        , Ptr)
               , DQTSS:DllCall("GetProcAddress", Ptr, dwmapi, AStr, "DwmQueryThumbnailSourceSize" , Ptr)
               , DUTP :DllCall("GetProcAddress", Ptr, dwmapi, AStr, "DwmUpdateThumbnailProperties", Ptr)
               , DUT  :DllCall("GetProcAddress", Ptr, dwmapi, AStr, "DwmUnregisterThumbnail"      , Ptr)   }
        return dll
    }
    prepare(){
        VarSetCapacity(thumbnail, 4, 0)
        DllCall(this.dll.DRT , UInt, this.hwnd, UInt, this.wid, UInt, &thumbnail)
        this.hThumb:=NumGet(thumbnail)
        return this.putThumb()
    }
    putThumb(){
        VarSetCapacity(dskThumbProps, 45, 0)
        NumPut(3, dskThumbProps, 0, "UInt")
        NumPut(0, dskThumbProps, 4, "Int")
        NumPut(0, dskThumbProps, 8, "Int")
        NumPut(this.width  , dskThumbProps, 12, "Int")
        NumPut(this.height , dskThumbProps, 16, "Int")
        NumPut(this.pos1[1], dskThumbProps, 20, "Int")
        NumPut(this.pos1[2], dskThumbProps, 24, "Int")
        NumPut(this.pos2[1], dskThumbProps, 28, "Int")
        NumPut(this.pos2[2], dskThumbProps, 32, "Int")
        DllCall(this.dll.DUTP, UInt, this.hThumb, UInt, &dskThumbProps)

        VarSetCapacity(dskThumbProps, 45, 0)
        NumPut(8, dskThumbProps,  0, "UInt")
        NumPut(1, dskThumbProps, 37,  "Int")
        return DllCall(this.dll.DUTP, UInt, this.hThumb, UInt, &dskThumbProps)
    }

    delete(){
        this.hotKeys(False)
        GUI_handle:="microWindow" this.id
        GUI, %GUI_handle%: Destroy
        DllCall(this.dll.DUT, UInt, this.hThumb)
        this.SetCapacity(0)
        return this.base:=""
    }

    getWinSize(){
        VarSetCapacity(Size, 8, 0)
        DllCall(this.dll.DQTSS, Uint, this.hThumb, Uint, &Size)
        ww:= NumGet(&Size, 0, "int"), wh:= NumGet(&Size, 4, "int")
        , rw:=ww/this.win_width, rh:=wh/this.win_height
        , this.pos1[1]*=rw, this.pos2[1]*=rw, this.pos1[2]*=rh, this.pos2[2]*=rh
        , this.win_width := ww, this.win_height:= wh
        return
    }

    update(){
        if WinActive("ahk_id " this.wid){           ; Hide if parent is in focus
            if !this.hidden
                winhide % "ahk_id " this.hwnd
            this.hidden:=true
            return
        } else if this.hidden {
            winshow % "ahk_id " this.hwnd
            this.hidden:=false
        }

        M_wasOver:=this.M_over, this.M_over:=this.mouseOver(), n:=this.id
        wingetpos,x,y,w,, % "ahk_id " this.hwnd
        if !w   ;Closed
            return this.delete()
        this.getWinSize()
        this.pos:=[x,y], this.width:=w-(M_wasOver?this.mx:0)
        , h:=this.width*(this.pos2[2]-this.pos1[2])/(this.pos2[1]-this.pos1[1]), this.height:=h>0?h:16
        this.putThumb()

        GuiControl, Move, Pic%n%, % "X0 Y0 W" this.width " H" this.height
        mDir:=(!this.M_over AND M_wasOver)? 1 :(this.M_over AND !M_wasOver? -1 :0)
        WinMove, % "ahk_id " this.hwnd,, % x+mDir*this.mx/2, % y+mDir*(this.my-this.mx/2)
            , % this.width+(this.M_over?this.mx:0), % this.height+(this.M_over?this.my:0)
        return
    }
    onClick(wParam, lParam, msg, hwnd){
        if (hwnd!=this.hwnd)
            return

        ; CoordMode, Mouse, Client
        ; ; MouseGetPos, mx, my
        ; mx := lParam & 0xFFFF
        ; my := lParam >> 16
        ; key:=(msg==0x204)? "R" :(msg==0x201)? "L" :""
        ;  x:= (mx*(this.pos2[1]-this.pos1[1]))//this.width  + this.pos1[1]
        ; ,y:= (my*(this.pos2[2]-this.pos1[2]))//this.height + this.pos1[2]
        ; if key
        ;     ControlClick, x%x% y%y%, % "ahk_id" this.wid,,% key,, NA Pos
        ; ; msgbox, % key "|" mx "|" my "`n" x "=" mx "*(" this.pos2[1] "-" this.pos1[1] ")/" this.width "+" this.pos1[1] "`n" y "=" my "*(" this.pos2[2] "-" this.pos1[2] ")/" this.height "+" this.pos1[2]

        winactivate, % "ahk_id " this.wid
        return
    }
    mouseOver(){
        GUI_handle:="microWindow" this.id
        if !isOver_mouse(this.hwnd){
            GUI %GUI_handle%: -Caption -Resize
            this.mouse_allowed:=False
            return False
        }
        WinGetPos, X,,W,, % "ahk_id " this.hwnd
        X/=A_ScreenWidth, W/=A_ScreenWidth

        if (W>0.5 || GetKeyState("Control","P") || GetKeyState("LButton","P") || GetKeyState("RButton","P") || GetKeyState("MButton","P") || WinActive("ahk_id" this.hwnd))
            this.mouse_allowed:=True

        if this.mouse_allowed {
            GUI %GUI_handle%: +Caption +Resize -MaximizeBox
            return True
        } else
            WinMove, % "ahk_id " this.hwnd,, % A_ScreenWidth*(2*X>1-W ? 0.05 : 1-W-0.02)
        return False
    }

    crop(dir, expand:=False, amt:=32){
        ;msgbox crop %dir% %expand% %amt%
        amt:= expand? -amt :amt
        if (dir="l"){ 
            this.pos1[1]+= amt
        } else if (dir="u"){ 
            this.pos1[2]+= amt
        } else if (dir="r"){ 
            this.pos2[1]-= amt
        } else if (dir="d"){ 
            this.pos2[2]-= amt
        }
        return this.update()
    }
    resetCrop(){
        this.pos1:=[0,0]
        this.pos2:=[this.win_width, this.win_height]
        return
    }

    hotkeys(register:=True){
        map:={"l":["Left","Right"], "r":["Right", "Left"] ,"u":["Up", "Down"] ,"d":["Down","Up"] }

        hotkey, ifWinActive, % "ahk_id " this.hwnd
        for l,k in map
        {
            obj:= register? ObjBindMethod(this, "crop", l, True) :"Off"
            hotkey, % "^" k[1] , % obj
            obj:= register? ObjBindMethod(this, "crop", l) :"Off"
            hotkey, % k[2] , % obj
            
            obj:= register? ObjBindMethod(this, "crop", l, True, 4) :"Off"
            hotkey, % "+^" k[1] , % obj
            obj:= register? ObjBindMethod(this, "crop", l,, 4) :"Off"
            hotkey, % "+" k[2] , % obj

            if (register) {
                hotkey, % "^" k[1] , On
                hotkey, % k[2] , On
                hotkey, % "^+" k[1] , On
                hotkey, % "+" k[2] , On
            }
        }
        obj:= register? ObjBindMethod(this, "resetCrop") :"Off"
        hotkey, Return, % obj
        hotkey, if
    }
}