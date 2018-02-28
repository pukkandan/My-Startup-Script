; new microWindow(WinExist("My Script 2 ahk_exe explorer.exe"))

class microWindow{
    __new(wid, pos:="", w:=200, pos1:="", pos2:=""){
        static
        static n:=0
        this.id:=n, this.wid:=wid, this.pos1:=pos1, this.pos2:=pos2, this.mx:=16, this.my:=39, this.M_over:=false
        local h:=w*this.win_height/this.win_width
        h:=(h>0?h:64)
        if (pos="")
            pos:=[ A_ScreenWidth-w-64 , A_ScreenHeight-h-64 ]

        local GUIhwnd, act
        GUI, microWindow%n%:New, +HwndGUIhwnd +AlwaysOnTop +ToolWindow -Caption
        this.hwnd:=GUIhwnd, this.mouse_allowed:=False
        Gui, microWindow%n%:Add, Pic, x0 y0 w%w% h%h% vpic%n%
        this.dll:=this.dllLoad()
        this.prepare()

        GUI, microWindow%n%:Show, % "Noactivate x" pos[1] " y" pos[2] " w" W+this.mx " h" H+this.my, microWindow %n% [%wid%]
        this.update()
        n++

        act:=ObjBindMethod(this,"update")
        setTimer, % act, 100

        OnMessage(0x201, ObjBindMethod(this,"onClick")) ;Mouse click
    }

    win_height[]{
        get{
            if this.pos1
                return this.pos2[2]-this.pos1[2]
            else {
                wingetpos,,,, H, % "ahk_id " this.wid
                return H
            }
        }
    }
    win_width[]{
        get{
            if this.pos1
                return this.pos2[1]-this.pos1[1]
            else {
                wingetpos,,, W,, % "ahk_id " this.wid
                return W
            }
        }
    }

    dllLoad(){
        static dll:={}
        if (this.id!=0)
            return dll
        hModule     := DllCall("LoadLibrary", "Str", "gdi32.dll" , Ptr)
        u32         := DllCall("LoadLibrary", "Str", "User32.dll", Ptr)

        dll.CCDC    := DllCall("GetProcAddress", Ptr, hModule, AStr, "CreateCompatibleDC"    , Ptr)
        dll.CCB     := DllCall("GetProcAddress", Ptr, hModule, AStr, "CreateCompatibleBitmap", Ptr)
        dll.SO      := DllCall("GetProcAddress", Ptr, hModule, AStr, "SelectObject"          , Ptr)
        dll.SSBM    := DllCall("GetProcAddress", Ptr, hModule, AStr, "SetStretchBltMode"     , Ptr)
        dll.SB      := DllCall("GetProcAddress", Ptr, hModule, AStr, "StretchBlt"            , Ptr)
        dll.DO      := DllCall("GetProcAddress", Ptr, hModule, AStr, "DeleteObject"          , Ptr)
        dll.DDC     := DllCall("GetProcAddress", Ptr, hModule, AStr, "DeleteDC"              , Ptr)
        dll.GDC     := DllCall("GetProcAddress", Ptr, u32    , AStr, "GetDC"                 , Ptr)
        dll.PW      := DllCall("GetProcAddress", Ptr, u32    , AStr, "PrintWindow"           , Ptr)
        return dll
    }
    prepare(){
        this.hdc_frame := DllCall(this.dll.GDC , UInt, this.hwnd)
        this.hdc_buffer:= DllCall(this.dll.CCDC, UInt, this.hdc_frame)
        this.hbm_buffer:= DllCall(this.dll.CCB , UInt, this.hdc_frame, Int, A_ScreenWidth, Int, A_ScreenHeight)
                          DllCall(this.dll.SO  , UInt, this.hdc_buffer, UInt, this.hbm_buffer)
                          DllCall(this.dll.SSBM, UInt, this.hdc_frame ,  Int, 4 )
        return
    }
    delete(){
        GUI_handle:="microWindow" this.id
        GUI, %GUI_handle%: Destroy

        DllCall(this.dll.DO , UInt,this.h_region )
        DllCall(this.dll.DO , UInt,this.hbm_buffer)
        DllCall(this.dll.DDC, UInt,this.hdc_frame )
        DllCall(this.dll.DDC, UInt,this.hdc_buffer)

        this.SetCapacity(0)
        this.base:=""
        return
    }

    update(){
        wingetpos,x,y,W,, % "ahk_id " this.hwnd
        if (W="")   ;Closed
            return this.delete()
        this.pos:=[x,y], this.width:=W-(this.M_over?this.mx:0), h:=(this.win_height*this.width)/this.win_width
        this.height:=h>0?h:16

        DllCall(this.dll.PW, UInt, this.wid, UInt, this.hdc_buffer, UInt, 0)
        DllCall(this.dll.SB, UInt, this.hdc_frame, Int, 0, Int, 0
                    , Int, this.width, Int, this.height, UInt, this.hdc_buffer
                    , Int, this.pos1[1], Int, this.pos1[2], Int, this.win_width, Int, this.win_height
                    , UInt, 0xCC0020)
        n:=this.id
        GuiControl, Move, Pic%n%, % "X0 Y0 W" this.width " H" this.height

        this.mouseOver()

        WinMove, % "ahk_id " this.hwnd,,,,% this.width+(this.M_over?this.mx:0), % this.height+(this.M_over?this.my:0)
        return
    }
    onClick(){
        if !isOver_mouse(this.hwnd)
            return
        winactivate, % "ahk_id " this.wid
        return
    }
    mouseOver(){
        GUI_handle:="microWindow" this.id
        if !isOver_mouse(this.hwnd){
            GUI %GUI_handle%: -Caption -Resize
            this.mouse_allowed:=False
            return
        }
        if (GetKeyState("Control","P") || GetKeyState("LButton","P") || GetKeyState("RButton","P") || GetKeyState("MButton","P") || WinActive("ahk_id" this.hwnd))
            this.mouse_allowed:=True

        if this.mouse_allowed {
            GUI %GUI_handle%: +Caption +Resize -MaximizeBox
        } else {
            WinGetPos, X,,W,, % "ahk_id " this.hwnd
            WinMove, % "ahk_id " this.hwnd,, % 2*X>A_ScreenWidth-W ? +64 : A_ScreenWidth-W-16
        }
        return
    }
}