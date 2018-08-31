class TaskView { ; There should only be one object for this
    __new(){ ; new SHOULD be called by "TaskView.__new()", not by "new Taskview"
        hVirtualDesktopAccessor := DllCall("LoadLibrary", "Str", A_ScriptDir . "\Lib\VirtualDesktopAccessor.dll", "Ptr")
        fList:=[ "GetCurrentDesktopNumber","GetDesktopCount","GoToDesktopNumber"
                ,"IsWindowOnDesktopNumber","MoveWindowToDesktopNumber"
                ,"IsPinnedWindow","PinWindow","UnPinWindow","IsPinnedApp","PinApp","UnPinApp"
                ,"RegisterPostMessageHook","UnregisterPostMessageHook" ]
        this.Proc:=[]
        for _,func in fList
            this.Proc[func]:= DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, func, "Ptr")

        this.Toast:=new toast({life:1000})
        DllCall(this.Proc["RegisterPostMessageHook"], Int, SCR_hwnd, Int, 0x1400 + 30)
        message_func:=ObjBindMethod(this,"VWMessage")
        OnMessage(0x1400 + 30, message_func)
    }

    VWMessage(wParam, lParam, msg, SCR_hwnd) {
        return this.OnDesktopSwitch(lParam + 1)
    }
    OnDesktopSwitch(x){
        return this.toast.show("Desktop " x)
    }

    ; __call(func,hwnd:=""){
    ;     if hwnd
    ;         return DllCall(this.Proc[func], UInt, hwnd)
    ;     else return DllCall(this.Proc[func])
    ; }
    GetDesktopCount(){
        return DllCall(this.Proc["GetDesktopCount"])
    }
    GetCurrentDesktopNumber(){
        return DllCall(this.Proc["GetCurrentDesktopNumber"]) + 1
    }
    IsPinnedWindow(hwnd){
        return DllCall(this.Proc["IsPinnedWindow"], UInt, hwnd)
    }
    IsPinnedApp(hwnd){
        return DllCall(this.Proc["IsPinnedApp"], UInt, hwnd)
    }
    PinWindow(hwnd){
        return DllCall(this.Proc["PinWindow"], UInt, hwnd)
    }
    UnPinWindow(hwnd){
        return DllCall(this.Proc["UnPinWindow"], UInt, hwnd)
    }
    PinApp(hwnd){
        return DllCall(this.Proc["PinApp"], UInt, hwnd)
    }
    UnPinApp(hwnd){
        return DllCall(this.Proc["UnPinApp"], UInt, hwnd)
    }

    GetFixedWindowsNumber(n,wrap:=True){
        max:=this.GetDesktopCount()
        if (wrap){
            while n<=0
                n+=max
            n:= mod(n-1, max) +1
        } else {
            if (n<=0)
                n:=1
            else if (n>max) {
                loop, % n-max
                    send, #^d       ; Create extra desktops
                sleep, 100
            }
        }
        return n
    }
    GoToDesktopNumber(n,wrap:=True) {
        if n is not number
            return 0
        n:=this.GetFixedWindowsNumber(n,wrap)
        DllCall(this.Proc["GoToDesktopNumber"], Int, n-1)
        return n
    }
    MoveWindowToDesktopNumber(n,win_hwnd,wrap:=True){
        if n is not number
            return 0
        n:=this.GetFixedWindowsNumber(n,wrap)
        DllCall(this.Proc["MoveWindowToDesktopNumber"], UInt, win_hwnd, UInt, n-1)
        return n
    }

    GoToDesktopPrev(wrap:=True) {
        max:=this.GetDesktopCount()
        return this.GoToDesktopNumber(this.GetCurrentDesktopNumber()-1, win_hwnd, wrap)
    }
    GoToDesktopNext(wrap:=True) {
        return this.GoToDesktopNumber(this.GetCurrentDesktopNumber()+1, win_hwnd, wrap)
    }
    MoveToDesktopPrev(win_hwnd,wrap:=True) {
        n:=this.GetCurrentDesktopNumber()-1
        if this.MoveWindowToDesktopNumber(n, win_hwnd, wrap){
            this.GoToDesktopNumber(n,wrap)
            winactivate, ahk_id %win_hwnd%
            return n
        } else return 0
    }
    MoveToDesktopNext(win_hwnd,wrap:=True) {
        n:=this.GetCurrentDesktopNumber()+1
        if this.MoveWindowToDesktopNumber(n, win_hwnd, wrap){
            this.GoToDesktopNumber(n,wrap)
            winactivate, ahk_id %win_hwnd%
            return n
        } else return 0
    }

    PinWindowToggle(hwnd){
        if this.isPinnedWindow(hwnd)
            this.UnPinWindow(hwnd)
        else
            this.PinWindow(hwnd)
        return this.isPinnedWindow(hwnd)
    }
    PinAppToggle(hwnd){
        if this.isPinnedApp(hwnd)
            this.UnPinApp(hwnd)
        else
            this.PinApp(hwnd)
        return this.isPinnedApp(hwnd)
    }
}