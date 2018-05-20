; Windows RS5 builds broke virtual-desktop-accessor.dll used in TaskView.ahk. This is a workaround to get the same functionality.

; This script may work in slightly unexpected ways when used with sets.

; The windows/apps are not actually pinned. The script moves them to the current desktop each time desktop is changed. As a result, the windows option "Show this windows/app on all desktop" work independently of the "pin app/window" feature of this script.

; The windows API for moving windows b/w desktops can't be used. So, as a workaround, we winHide the window to be moved, move to the new desktop, and then winshow it causing it to appear in the new desktop. As a result, window cannot be moved without actually going to the new desktop.

class TaskView { ; There should only be one object for this
    static pinnedWindowList:={}, pinnedAppList:={}
    init(){ ; SHOULD be called
        return this.__new()
    }
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
        WinGet, minMax, MinMax, % win
        winHide % win
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

    isPinnedWindow(hwnd){
        return this.pinnedWindowList.hasKey(hwnd)
    }
    isPinnedApp(hwnd){
        winget, p, ProcessName, % "ahk_id " hwnd
        return this.pinnedAppList.hasKey(p)
    }
    pinWindow(hwnd){
        return this.pinnedWindowList[hwnd]:=True ; The hwnd are stored as the key for easier access
    }
    unPinWindow(hwnd){
        return this.pinnedWindowList.Delete(hwnd)
    }
    pinApp(hwnd){
        winget, p, ProcessName, % "ahk_id " hwnd
        return this.pinnedAppList[p]:=True
    }
    unPinApp(hwnd){
        winget, p, ProcessName, % "ahk_id " hwnd
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
    goToDesktopNumber(n, wrap:=True) {
        if !(n is "number")
            return 0
        n:=this._desktopNumber(n, wrap), m:=this.getCurrentDesktopNumber()
        loop % n-m
            send #^{Right}
        loop % m-n
            send #^{Left}
        return n
    }
    moveWindowToDesktopNumber(n, hwnd, wrap:=True){ ;And go there
        n:=this.goToDesktopNumber(n,wrap)
        if n!=this.currentDesktopNumber
            this._hideShow(hwnd)
        return n
    }

    goToDesktopPrev(wrap:=True) {
        return this.goToDesktopNumber(this.getCurrentDesktopNumber()-1, wrap)
    }
    goToDesktopNext(wrap:=True) {
        return this.goToDesktopNumber(this.getCurrentDesktopNumber()+1, wrap)
    }
    moveToDesktopPrev(hwnd, wrap:=True) {
        n:=this.moveWindowToDesktopNumber(this.getCurrentDesktopNumber()-1, hwnd, wrap)
        winActivate % win
        return n
    }
    moveToDesktopNext(hwnd, wrap:=True) {
        n:=this.moveWindowToDesktopNumber(this.getCurrentDesktopNumber()+1, hwnd, wrap)
        winActivate % win
        return n
    }

    pinWindowToggle(hwnd){
        if this.isPinnedWindow(hwnd)
            this.unPinWindow(hwnd)
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