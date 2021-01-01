; Uses https://github.com/Ciantic/VirtualDesktopAccessor

; This script may work in slightly unexpected ways when used with sets.

; Functions starting with _ are not expected to be called from outside the class.

class TaskView {
    __new(msg:=False){
        this.base:={__call:ObjBindMethod(this,"_call")}

        this.dll := DllCall("LoadLibrary", "Str", A_ScriptDir . "\Lib\VirtualDesktopAccessor.dll", "Ptr")

        ; Desktop changes listener
       if msg {
            this.Toast:=new Toast({life:1000})
            ;this.Toast.show("Loaded")
            DllCall(this.fList["RegisterPostMessageHook"], Int, A_ScriptHwnd+(0x1000 << 32), Int, 0x1400 + 30)
            OnMessage(0x1400 + 30, ObjBindMethod(this,"_VWMessage"))
       }

        ; Restart the virtual desktop accessor when explorer.exe restarts
        OnMessage( DllCall("user32\RegisterWindowMessage", "Str", "TaskbarCreated")
                 , ObjBindMethod(this,"_OnExplorerRestart")                          )

    }

    fList[fn]{
        get {

            ; GetProcAddress is case-sensitive. So known functions are predefined to avoid errors when function call is made with wrong case
            if !isObject(this._fList) {
                l:=[ "GetCurrentDesktopNumber","GetDesktopCount","GoToDesktopNumber"
                    ,"IsWindowOnDesktopNumber","IsWindowOnCurrentVirtualDesktop"
                    ,"GetWindowDesktopNumber","MoveWindowToDesktopNumber"
                    ,"IsPinnedWindow","PinWindow","UnPinWindow","IsPinnedApp","PinApp","UnPinApp"
                    ,"RegisterPostMessageHook","UnregisterPostMessageHook" ]
                this._fList:={}
                for _,f in l {
                    StringLower, g, f
                    this._fList[g]:= DllCall("GetProcAddress", "Ptr", this.dll, "AStr", f, "Ptr")
                    ;msgbox % "x " f "`n" this._fList[g]
                }
            }

            StringLower, g, fn ; The keys are stored in lowercase to avoid case issues
            if !this._fList[g] { ; Try to create function if it doesnt exist
                this._fList[g]:= DllCall("GetProcAddress", "Ptr", this.dll, "AStr", fn, "Ptr")
                msgbox % "New function '" fn "'was created in TaskView.fList`nfList[" g "] = " this._fList[g]
            }
            return this._fList[g]

            /* ------------- Functions exported by DLL ; * = Usable Directly ** = Redefined here
            > Desktop
            **  int GetCurrentDesktopNumber()
            *   int GetDesktopCount()
            **  void GoToDesktopNumber(int number)

            > Window
            **  int IsWindowOnDesktopNumber(HWND window, int number)
            *   int IsWindowOnCurrentVirtualDesktop(HWND window)
            **  int GetWindowDesktopNumber(HWND window)
            **  BOOL MoveWindowToDesktopNumber(HWND window, int number)

            > Pinning
            *   int IsPinnedWindow(HWND hwnd) // Returns 1 if pinned, 0 if not pinned, -1 if not valid
            *   void PinWindow(HWND hwnd)
            *   void UnPinWindow(HWND hwnd)
            *   int IsPinnedApp(HWND hwnd) // Returns 1 if pinned, 0 if not pinned, -1 if not valid
            *   void PinApp(HWND hwnd)
            *   void UnPinApp(HWND hwnd)

            > Register/Unregister
            *   void RegisterPostMessageHook(HWND listener, int messageOffset)
            *   void UnregisterPostMessageHook(HWND hwnd)
            *   void RestartVirtualDesktopAccessor() // Shouldn't use pointer. So pointer is not defined in "fList"

            > GUID
                int GetDesktopNumber(IVirtualDesktop *pDesktop)
                GUID GetDesktopIdByNumber(int number) // Returns zeroed GUID with invalid number found
                int GetDesktopNumberById(GUID desktopId)
                GUID GetWindowDesktopId(HWND window)

            > Window Properties
                int ViewIsShownInSwitchers(HWND hwnd) // Is the window shown in Alt+Tab list?
                int ViewIsVisible(HWND hwnd) // Is the window visible?
                uint ViewGetLastActivationTimestamp(HWND) // Get last activation timestamp

            > AltTab
                void ViewSetFocus(HWND hwnd) // Set focus like Alt+Tab switcher
                void ViewSwitchTo(HWND hwnd) // Switch to window like Alt+Tab switcher

            > Thumbnail
                HWND ViewGetThumbnailHwnd(HWND hwnd) // Get thumbnail handle for a window, possibly peek preview of Alt+Tab
                HWND ViewGetFocused() // Get focused window thumbnail handle

            > View Order
                uint ViewGetByZOrder(HWND *windows, UINT count, BOOL onlySwitcherWindows, BOOL onlyCurrentDesktop) // Get windows in Z-order (NOT alt-tab order)
                uint ViewGetByLastActivationOrder(HWND *windows, UINT count, BOOL onlySwitcherWindows, BOOL onlyCurrentDesktop) // Get windows in alt tab order

             */
        }

        set { ;Never used
            throw Exception("Items of TaskView.fList should not be set", "TaskView.fList[" fn "]:=" value)
            StringLower, g, fn ; The keys are stored in lowercase to avoid case issues
            return this._fList[g]:=value
        }
    }

    ; Functions of the form "fn()" or "fn(hwnd)" doesnt have to be seperately defined
    _call(obj,fn,hwnd:=""){ ; obj will always be "this"
        ;msgbox % fn "(" hwnd ")=" ( hwnd=""? DllCall(this.fList[fn]) . " noHwnd": DllCall(this.fList[fn], "UInt", hwnd) )
        return hwnd=""? DllCall(this.fList[fn]): DllCall(this.fList[fn], "UInt", hwnd)
    }

    _OnExplorerRestart(wParam, lParam, msg, hwnd_scr) {
        this.restart()
    }
    restart(){
        DllCall("RestartVirtualDesktopAccessorProc", "UInt", result)
        if this.Toast
            this.Toast.show("TaskView Restarted")
        return result
    }

    _VWMessage(wParam, lParam, msg, hwnd_scr) {
        this._OnDesktopSwitch(lParam + 1)
    }
    _OnDesktopSwitch(x){
        this.Toast.show("Desktop " x)
        return x
    }

    ;------------------------------------------------------------------------
    _dummyGUI(n:=0){
        if (!this.dummyGUIhwnd) {
            GUI, TaskViewDummy:New, +hwndHWND -Caption +Owner
            this.dummyGUIhwnd:=HWND
            ;WinSet, Trans, 0, ahk_id %HWND%
            GUI, TaskViewDummy:Show, Hide
        }
        if (n!=0) {
            GUI, TaskViewDummy:Show, NoActivate
            winWait, % "ahk_id " this.dummyGUIhwnd
            sleep 100
            this.MoveWindowToDesktopNumber(n, this.dummyGUIhwnd)
        } else {
            winHide, % "ahk_id " this.dummyGUIhwnd
        }
        return this.dummyGUIhwnd
    }

    ;------------------------------------------------------------------------
    _desktopNumber(n, wrap:=False, ret:=-1, params*){ ; TODO: ReWork
        ; ret can be: 0=Dont return to current Desktop, 1=Return to current Desktop, -1=Dont create new Desktops
        ; ret only has any effect if wrap:=False

        maxNo:=this.GetDesktopCount()
        if (maxNo<=0)
            return n
        if (wrap){
            while n<=0
                n+=maxNo
            return mod(n-1, maxNo) +1
        } else if (n<=maxNo || ret==-1) {
            return min(max(n,1),maxNo)
        }

        ; Desktops need to be created
        if (ret>=0) {
            current:=this.GetCurrentDesktopNumber()
            params[1]:=0 ; No animation when creating desktops

            ;msgbox % "Implicitly creating " n-MaxNo " (" n "-" MaxNo ") new desktops!"
            ;this.createNewDesktops(n-MaxNo, params*)

            if (ret)
                this.GoToDesktopNumber(current,,"")
        }
        return min(max(n,1),maxNo)
    }

    ;------------------------------------------------------------------------
    GetCurrentDesktopNumber(){
        return DllCall(this.fList["GetCurrentDesktopNumber"]) + 1
    }
    GetWindowDesktopNumber(hwnd){
        return DllCall(this.fList["GetWindowDesktopNumber"], "UInt", hwnd) + 1
    }
    IsWindowOnDesktopNumber(hwnd, n, params*){
        params[2]:=-1  ; ret:=-1 => Dont create desktops
        return DllCall(this.fList["IsWindowOnDesktopNumber"], "UInt", hwnd, "UInt", this._desktopNumber(n,params*)-1)
    }

    ; Defined by __call
    /*
    GetDesktopCount(){
        return DllCall(this.fList["GetDesktopCount"])
    }
    IsWindowOnCurrentVirtualDesktop(hwnd){
        return DllCall(this.fList["IsWindowOnCurrentVirtualDesktop"], "UInt", hwnd)
    }
    IsPinnedWindow(hwnd){
        return DllCall(this.fList["IsPinnedWindow"], "UInt", hwnd)
    }
    IsPinnedApp(hwnd){
        return DllCall(this.fList["IsPinnedApp"], "UInt", hwnd)
    }
    PinWindow(hwnd){
        return DllCall(this.fList["PinWindow"], "UInt", hwnd)
    }
    UnPinWindow(hwnd){
        return DllCall(this.fList["UnPinWindow"], "UInt", hwnd)
    }
    PinApp(hwnd){
        return DllCall(this.fList["PinApp"], "UInt", hwnd)
    }
    UnPinApp(hwnd){
        return DllCall(this.fList["UnPinApp"], "UInt", hwnd)
    }
    */

    GoToDesktopNumber(n, wrap:=-1, anim:=-12, animDelay:=200) {
        ; wrap can be 0=Create desktop if necessary, -1=Dont create/wrap, 1= wrap

        ; anim can be a combination of:
        ; * -1 = Single page by #^{Arrow}
        ; +100 = Use 'Top Window Activate' Method // This is slow and therefore deprecated
        ; + 10 = Use 'GUI' Method
        ; and one of the following fallbacks:
        ;   0 = Animate Each Page (-0 = 0)
        ;   1 = Switch to nearest window and then animate (deprecated)
        ;   2 = No Animation
        ; If anim is empty, it is considered as "2"

        ; Eg:   2 => No animation
        ;      -2 => Animate if only one page, otherwise no animation
        ;     100 => Try to activate top window and animate each page if that fails
        ;    -112 => Try to activate top window, use GUI if there is no window, and skip animation if both fail

        ; Recomended methods are:
        ;  -12 = default
        ;   12 = Use GUI method only
        ;    2 = No animation
        ;   -2 = Animate only for single page
        ;    0 = Animate Each Page


        maxNo:=this.GetDesktopCount()
        n:=this._desktopNumber(n, wrap>0, wrap<0?-1:0, mod(abs(anim),10)? (anim==2? 0:1) :2, animDelay)
        m:=this.getCurrentDesktopNumber()
        ;msgbox %m%=>%n% (%maxNo%)
        if (m==n) {
           return this._OnDesktopSwitch(n)
        }
        
        static keyMap:={1:"Right", -1:"Left"}
        if (anim<0 && abs(m-n)==1) {
            send % "#^{" keyMap[n-m] "}"
            return n
        }

        if (anim=="")
            anim:=2
        anim:=abs(anim)
        anim:={ top: anim//100, gui: mod(anim,100)//10, fallback: mod(anim,10) }

        if (anim.top)
            newWin:=this.FirstWindowInDesktop(n)
        if (anim.gui && !newWin)
            newWin:=this._dummyGUI(n)
        if (newWin) {
            hw:=A_DetectHiddenWindows 
            DetectHiddenWindows, On
            WinActivate, ahk_id %newWin%
            sleep, % animDelay
            DetectHiddenWindows, % hw
        
            sleep % min(animDelay,500)
            this._dummyGUI() ; Hide the GUI. This is not actually needed
            m:=this.getCurrentDesktopNumber()
            if m==n
                return n
        }

        if (anim.fallback!=2) {
            pages:= anim.fallback? (n>m ? 1:-1) : n-m
            if (anim.fallback)
                DllCall(this.fList["GoToDesktopNumber"], "Int", n - (n>m? 2:0) )
            for sign,dir in keyMap {
                loop % sign*pages {
                    if(A_Index>1)
                        sleep % animDelay
                    send #^{%dir%}
                }
            }
            sleep % min(animDelay,500) ; confirm that we are in the right desktop after some time
        }

        DllCall(this.fList["GoToDesktopNumber"], "Int", n-1)
        return n
    }

    MoveWindowToDesktopNumber(n, win_hwnd, wrap:=False, params*){
        ; Any extra args are sent to params* and are ignored.
        ; This makes it possible to call both GoToDesktopNumber and this fn with the same optional arguments
        n:= this._desktopNumber(n, wrap, True)
        DllCall(this.fList["MoveWindowToDesktopNumber"], "UInt", win_hwnd, "UInt", n-1)
        return n
    }
    MoveWindowAndGoToDesktopNumber(n, win_hwnd, params*){
        active:=winActive(win_hwnd)
        params2:=params.clone()
        params2.insertAt(2,False)

        n:=this._desktopNumber(n, params2*)
        this.MoveWindowToDesktopNumber(n, win_hwnd, params*)
        if (active) ; Deactivate the window
            WinActivate ahk_group WG_TaskBar
        this.GoToDesktopNumber(n, params*)
        if(active)
            winactivate, ahk_id %win_hwnd%
        return n
    }



    createNewDesktops(n:=1, anim:=0, animDelay:=200) {
        ; anim can be: 0=No anim, 1=1 anim, 2=Full anim
        ;msgbox Creating %n% new desktops!
        loop, % n {
            if ( A_Index>1 && (anim>1 || (anim==1 && A_Index==n)) )  {
                sleep % animDelay
            }
            send, #^d       ; Create extra desktops
        }
        sleep 100
    }



    FirstWindowInDesktop(n, params*){
        n:=this._desktopNumber(n, params*)
        w:=0

        hw:=A_DetectHiddenWindows 
        DetectHiddenWindows, On
        winget win, list

        loop % win {
            if (this.GetWindowDesktopNumber(win%A_Index%)==n){
                WinGetTitle, t, % "ahk_id " win%A_Index%
                if t {
                    w:=win%A_Index%
                    break
                }
            }
        }
        DetectHiddenWindows, % hw
        return w
    }


    ;---------------------------------------------------------
    GoToDesktopPrev(params*) {
        return this.GoToDesktopNumber(this.GetCurrentDesktopNumber()-1, params*)
    }
    GoToDesktopNext(params*) {
        return this.GoToDesktopNumber(this.GetCurrentDesktopNumber()+1, params*)
    }
    MoveWindowToDesktopPrev(params*) {
        return this.MoveWindowToDesktopNumber(this.GetCurrentDesktopNumber()-1, params*)
    }
    MoveWindowToDesktopNext(params*) {
        return this.MoveWindowToDesktopNumber(this.GetCurrentDesktopNumber()+1, params*)
    }
    MoveWindowAndGoToDesktopPrev(params*) {
        return this.MoveWindowAndGoToDesktopNumber(this.GetCurrentDesktopNumber()-1, params*)
    }
    MoveWindowAndGoToDesktopNext(params*) {
        return this.MoveWindowAndGoToDesktopNumber(this.GetCurrentDesktopNumber()+1, params*)
    }


    PinWindowToggle(hwnd){
        if this.isPinnedWindow(hwnd){
            this.UnPinWindow(hwnd)
        } else {
            this.PinWindow(hwnd)
        }
        return this.isPinnedWindow(hwnd)
    }
    PinAppToggle(hwnd){
        if this.isPinnedApp(hwnd) {
            this.UnPinApp(hwnd)
        } else {
            this.PinApp(hwnd)
        }
        return this.isPinnedApp(hwnd)
    }


    MoveDesktops(dObj, params*) {
        deskList:={}, winLists:={}
        for from,to in dObj {
            n:=this._desktopNumber(from, params*)
            deskList[n]:=this._desktopNumber(to, params*)
            winLists[n]:=[]
        }

        hw:=A_DetectHiddenWindows 
        DetectHiddenWindows, On
        winget win, list

        loop % win { ; Get all windows to move
            d:=this.GetWindowDesktopNumber(win%A_Index%)
            if deskList.hasKey(d) {
                WinGetTitle, t, % "ahk_id " win%A_Index%
                if t
                    winLists[d].push(win%A_Index%)
            }
        }

        for d, winList in winLists ; Move to the other window
            for _,win in winList
                this.MoveWindowToDesktopNumber(deskList[d], win)

        DetectHiddenWindows, % hw
        return true
    }

    MoveDesktopTo(d1, d2, params*) {
        d1:=this._desktopNumber(d1, params*), d2:=this._desktopNumber(d2, params*)
        dObj:={(d1):d2}
        loop % d2-d1 ;Moving right
            dObj[d1+A_Index]:= d1+A_Index-1
        loop % d1-d2 ;Moving Left
            dObj[d2+A_Index-1]:= d2+A_Index
        return this.MoveDesktops(dObj, params*)
    }
    MoveDesktopRight(n, params*) {
        return this.MoveDesktopTo(n, n+1, params*)
    }
    MoveDesktopLeft(n, params*) {
        return this.MoveDesktopTo(n, n-1, params*)
    }
    MoveCurrentDesktopTo(n, params*) {
        current:=this.GetCurrentDesktopNumber()
        this.MoveDesktopTo(current, n, params*)
        return this.GoToDesktopNumber(n,,"")
    }
    MoveCurrentDesktopBy(n, params*) {
        current:=this.GetCurrentDesktopNumber()
        this.MoveDesktopTo(current, n+current, params*)
        return this.GoToDesktopNumber(n,,"")
    }
    MoveCurrentDesktopRight(params*) {
        return this.MoveCurrentDesktopBy(n, 1, params*)
    }
    MoveCurrentDesktopLeft(params*) {
        return this.MoveCurrentDesktopBy(n, -1, params*)
    }

    SwapDesktops(d1, d2, params*) {
        return this.MoveDesktops({(d1):d2, (d2):d1}, params*)
    }
    SwapCurrentDesktopWith(n, params*) {
        current:=this.GetCurrentDesktopNumber()
        this.SwapDesktops(current, n, params*)
        return this.GoToDesktopNumber(n,,"")
    }

    CreateNewDesktopsAfter(n, count:=1, params*) {
        ; Pass n="" to create new desktop at begining
        n:= (n=="")?0: this._desktopNumber(n, params*)
        last:=this.GetDesktopCount()
        dObj:={}
        loop % last-n
            dObj[n+A_Index]:= n+A_Index+count
        this.createNewDesktops(count)
        return this.MoveDesktops(dObj, params*)
    }
    CreateNewDesktopsBefore(n, params*) {
        ; Pass n="" to create new desktop at end
        return this.createNewDesktopsAfter(n==""?0: (n==1?"": n-1), params*)
    }
    CreateNewDesktopsAfterCurrent(params*) {
        n:=this.getCurrentDesktopNumber()
        this.CreateNewDesktopsAfter(n, params*)
        return this.GoToDesktopNumber(n+1,,"") ; Go to the first new desktop
    }
    CreateNewDesktopsBeforeCurrent(params*) {
        n:=this.getCurrentDesktopNumber()
        this.CreateNewDesktopsBefore(n, params*)
        return this.GoToDesktopNumber(n,,"") ; ; Go to the last new desktop
    }
}