;      NO LONGER MAINTAINED
;=======================================


; Windows RS5 builds broke virtual-desktop-accessor.dll used in TaskView.ahk. This is a workaround to get the same functionality.

; This script may work in slightly unexpected ways when used with sets.

; The windows/apps are not actually pinned. The script moves them to the current desktop each time desktop is changed. As a result, the windows option "Show this windows/app on all desktop" work independently of the "pin app/window" feature of this script (except for modern apps).

; The windows API for moving windows b/w desktops can't be used. So, as a workaround, we winHide the window to be moved, move to the new desktop, and then winshow it causing it to appear in the new desktop. As a result, window cannot be moved without actually going to the new desktop.

; For modern apps, pinning/moving is done by opening TaskView using #Tab pressing the relevent keys. I havent tested pinning modern apps extensively. Expect it to fail sometimes.

; PinApp() of any modern app makes the script think all modern apps are pinned since they all use same process. Same for unpinning.

; Functions starting with _ are not expected to be called from outside the class. Also, make sure to use getDesktopCount() and getCurrentDesktopNumber() instead of desktopCount and currentDesktopNumber

class TaskView { ; There should only be one object for this
    static pinnedWindowList:={}, pinnedAppList:={}
    __new(){
        this.toast:=new Toast({life:1000})
        obj:=objbindMethod(this,"_desktopChange")
        setTimer, % obj , 100
    }

    _refreshDesktopList() { ;https://github.com/pmb6tz/windows-desktop-switcher
        static sessionID
        if (!sessionID)
            DllCall("ProcessIdToSessionId", "UInt", DllCall("GetCurrentProcessId","Uint"), "UInt*", sessionID)

        RegRead, currentDesktopID, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\SessionInfo\%SessionId%\VirtualDesktops, CurrentVirtualDesktop
        if currentDesktopID
            idLength := StrLen(currentDesktopID)
        else idLength:=32 ;It should always be 32, but we check just in case

        RegRead, desktopList, HKEY_CURRENT_USER, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops, VirtualDesktopIDs
        if desktopList
            this.desktopCount := StrLen(desktopList) / idLength
        else this.desktopCount := 1

        loop % this.desktopCount
            if (currentDesktopID=SubStr(desktopList, (A_Index*IDLength) + 1-IDLength, IDLength))
                return this.currentDesktopNumber:=A_Index
        return this.currentDesktopNumber:=1
    }

    _hideShow(hwnd){
        win:="ahk_id " hwnd
        DetectHiddenWindows On
        WinGet, minMax, MinMax, % win
        winHide % win
        sleep 100
        winShow % win
        if minMax=1
        {
            WinRestore % win
            WinMaximize % win
        }
        else if minMax=-1
            WinMinimize % win
        return
    }

    _desktopChange(){
        static prevWindow:=0
        if winActive("Task View ahk_class Windows.UI.Core.CoreWindow ahk_exe explorer.exe")
            return prevWindow
        n:=this.getcurrentDesktopNumber()
        if (prevWindow!=n AND prevWindow!=0)
        {
            this.toast.show("Desktop " n)
            for hwnd in this.pinnedWindowList
                this._hideShow(hwnd)
            for proc in this.pinnedAppList
            {
                winget, hwnd, list, % "ahk_exe " proc
                loop % hwnd
                    this._hideShow(hwnd%A_Index%)
            }
        }
        prevWindow:=n
        return n
    }

    _isModernApp(hwnd){
        return winExist("ahk_class ApplicationFrameWindow ahk_id" hwnd) ; true if it is a modern app
    }
    _modernAppsWorkaround(keys){
        static tv:="Task View ahk_class Windows.UI.Core.CoreWindow ahk_exe explorer.exe"
        WinActivate ahk_id %hwnd%
        send #{Tab}
        winwaitActive % tv
        sleep 500 ; Tweak this if context menu disappears too fast

        SetKeyDelay, 200 ; Tweak this if some clicks dont register
        sendEvent {AppsKey}%keys%{space}
        if winActive(tv)
            send #{Tab}
        WinWaitNotActive % tv
        return
    }

    isPinnedWindow(hwnd){
        return this.pinnedWindowList.hasKey(hwnd)
    }
    isPinnedApp(hwnd){
        winget, p, ProcessName, % "ahk_id " hwnd
        return this.pinnedAppList.hasKey(p)
    }
    pinWindow(hwnd){
        if this._isModernApp(hwnd) && !this.isPinnedWindow(hwnd)
                this._modernAppsWorkaround("{down 3}")
        return this.pinnedWindowList[hwnd]:=True ; The hwnd are stored as the key (rather than value) for easier access
    }
    UnPinWindow(hwnd){
        if this._isModernApp(hwnd) && this.isPinnedWindow(hwnd)
                this._modernAppsWorkaround("{down 2}")
        return this.pinnedWindowList.Delete(hwnd)
    }
    pinApp(hwnd){
        winget, p, ProcessName, % "ahk_id " hwnd
        if this._isModernApp(hwnd) && !this.isPinnedApp(p){
                this._modernAppsWorkaround("{down 4}")
                p.=" "
        }
        return this.pinnedAppList[p]:=True
    }
    unPinApp(hwnd){
        winget, p, ProcessName, % "ahk_id " hwnd
        if this._isModernApp(hwnd) && this.isPinnedApp(p)
                this._modernAppsWorkaround("{down 3}")
        return this.pinnedAppList.Delete(p)
    }

    getDesktopCount(){
        this._refreshDesktopList()
        return this.desktopCount
    }
    getCurrentDesktopNumber(){
        this._refreshDesktopList()
        return this.currentDesktopNumber
    }

    _desktopNumber(n, wrap:=True){
        max:=this.getDesktopCount()
        if wrap
        {
            while n<=0
                n+=max
            return mod(n-1, max) +1
        }

        if n<=0
            return 1
        if (n>max)
        {
            loop % n-max
                send #^d       ; Create extra desktops
            sleep 100
        }
        return n
    }
    goToDesktopNumber(n, wrap:=True) { ; If wrap=True, goToDesktopNumber(desktopCount+1)=goToDesktopNumber(1)
        if !(n is "number")
            return 0
        n:=this._desktopNumber(n, wrap), m:=this.getCurrentDesktopNumber()
        loop % n-m
            send #^{Right}
        loop % m-n
            send #^{Left}
        return n
    }
    moveWindowToDesktopNumber(n, hwnd, wrap:=False){ ;And go there
        modern:=this._isModernApp(hwnd)
        if modern && !this.isPinnedWindow(hwnd) && !this.isPinnedApp(hwnd) && n!=this.currentDesktopNumber
            return this._moveModernWindowToDesktopNumber(n, hwnd, wrap)

        n:=this.goToDesktopNumber(n,wrap)

        if !modern && n!=this.currentDesktopNumber
            this._hideShow(hwnd)
        return n
    }
    _moveModernWindowToDesktopNumber(n, hwnd, wrap:=True){
        if !(n is "number")
            return 0
        WinActivate ahk_id %hwnd%
        n:=this._desktopNumber(n,wrap), m:=this.currentDesktopNumber
        if n=m ;Window is already in the correct desktop
            return n

        this._modernAppsWorkaround("{down 2}{right}{down " n-(n<m?1:2) "}")
        WinActivate ahk_id %hwnd%
        return n
    }


    MoveWindowAndGoToDesktopNumber(n,win_hwnd,wrap:=True){
        active:=winActive(win_hwnd)
        if this.MoveWindowToDesktopNumber(n, win_hwnd, wrap){
            ;this.GoToDesktopNumber(n,wrap)
            if(active)
                winactivate, ahk_id %win_hwnd%
            return n
        } else return 0
    }

    ;---------------------------------------------------------
    GoToDesktopPrev(wrap:=True) {
        return this.GoToDesktopNumber(this.GetCurrentDesktopNumber()-1, wrap)
    }
    GoToDesktopNext(wrap:=True) {
        return this.GoToDesktopNumber(this.GetCurrentDesktopNumber()+1, wrap)
    }
    MoveWindowToDesktopPrev(win_hwnd,wrap:=True) {
        return this.MoveWindowToDesktopNumber(this.GetCurrentDesktopNumber()-1, win_hwnd, wrap)
    }
    MoveWindowToDesktopNext(win_hwnd,wrap:=True) {
        return this.MoveWindowToDesktopNumber(this.GetCurrentDesktopNumber()+1, win_hwnd, wrap)
    }
    MoveWindowAndGoToDesktopPrev(win_hwnd,wrap:=True) {
        return this.MoveWindowAndGoToDesktopNumber(this.GetCurrentDesktopNumber()-1, win_hwnd, wrap)
    }
    MoveWindowAndGoToDesktopNext(win_hwnd,wrap:=True) {
        return this.MoveWindowAndGoToDesktopNumber(this.GetCurrentDesktopNumber()+1, win_hwnd, wrap)
    }

    pinWindowToggle(hwnd){
        if this.isPinnedWindow(hwnd)
            this.UnPinWindow(hwnd)
        else this.pinWindow(hwnd)
        return this.isPinnedWindow(hwnd)
    }
    pinAppToggle(hwnd){
        if this.isPinnedApp(hwnd)
            this.unPinApp(hwnd)
        else this.pinApp(hwnd)
        return this.isPinnedApp(hwnd)
    }
}