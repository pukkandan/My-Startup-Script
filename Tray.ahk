trayMenu(){
    ifexist %SCR_Name%.ico                         ;Main Icon
        Menu, Tray, Icon, %SCR_Name%.ico,,0
    Menu, Tray, Tip, % " "  ;Tray tip is shown using tooltip 20

    Menu, Tray, NoStandard                          ;No standard menu
    Menu, Tray, Add, &Reload Script, SCR_Reload
    Menu, Tray, Add, &Active, SCR_Pause
    Menu, Tray, Check, &Active
    Menu, Tray, Add, &Edit Script, SCR_Edit
    Menu, Tray, Add, Edit v&2 Script, SCR_Edit2
    Menu, Tray, Add, Open &Folder, SCR_OpenFolder
    Menu, Tray, Add, AHK &Help, AHK_Help
    Menu, Tray, Add, AHK &v2 Help, AHK_Help2
    Menu, Tray, Default, AHK &Help

    Menu, Tray, Add
    act:=func("netNotify").bind(False,,0)
    Menu, Tray, Add, &Net Status, % act
    Menu, Tray, Add, &Dim Screen, dimScreen
    Menu, TrayIt, Add
    Menu, Tray, Add, &TrayIt, :TrayIt
    Menu, Tray, Add
    act:=ObjBindMethod(winProbe,"toggle")
    Menu, Tray, Add, &Window Probe, % act
    act:=ObjBindMethod(winProbe,"toggle")
    Menu, Tray, Add, Deb&ug, DebugVars
    Menu, Tray, MainWindow
    Menu, AHK, Standard
    Menu, Tray, Add, AH&K, :AHK
    Menu, Tray, Add, E&xit, Exit

    trayListen()
    ;setTimer, trayListen, 1000  ;for better Stability
}
DebugVars(){
    ShellRun(path(A_ScriptDir).dir "\DebugVars\DebugVars.ahk")
}
AHK_Help(){
    ShellRun(SCR_AHKDir "\AutoHotkey.chm")
}
SCR_OpenFolder(){
    ShellRun(A_ScriptDir)
}
SCR_Edit(){
    ShellRun(A_ScriptDir "\" SCR_Name ".sublime-project")
}
SCR_Reload(){
    Reload
}
SCR_Pause(){
    Suspend
    Menu, Tray, ToggleCheck, &Active
    Tooltip(,{no:20})
    Tooltip()
    Pause, Toggle, 1
    return
}


AHK_Help2(){
    ShellRun(SCR_AHKDir "_v2\AutoHotkey.chm")
}
SCR_Edit2(){
    ShellRun( path(A_ScriptDir).dir "\" SCR_Name "_v2\" SCR_Name ".sublime-project")
}

;==========================================
trayListen(){
    OnMessage(0x404, "mouseOverTray")  ;Mouse over tray icon
}
mouseOverTray(wParam,lParam){
    if (lParam=0x201) {         ; Single click
    } else if (lParam=0x203) {    ; Double click
    } else if (lParam=0x205) {    ; Right click
    } else updateTray()
    return
}
updateTray(mx0:="",my0:=""){
    static mx, my, timer:=0
    if (mx0="" or my0="") {
        if A_TickCount-timer>1000
            MouseGetPos, mx, my
            timer:=A_TickCount
    } else mx:=mx0, my:=my0

    tip:=SCR_Name " Script`n"

    obj:=Togglekeys_check()
    tip.="ToggleKeys: " (obj.n?"N":"") (obj.c?"C":"") (obj.s?"S":"") (obj.i?"I":"") "`n"

    obj:=netNotify(False,False)
    if (obj.status!="") {
        tip.="Internet: " (["No Connection","Connected, no Internet","Internet access (no VPN)","Internet access through VPN"][obj.status+2]) "`n"
        if obj.status>=0
            tip.="Public IP: " obj.ipInfo.ip (obj.ipInfo.loc?" (" obj.ipInfo.loc ")":"") "`nLocal IP: [ " obj.ipInfo.ipl " ]" "`n"
    }
    obj:=func("showTrayTip").bind(tip,mx,my)
    setTimer, % obj, -200
    return
}
showTrayTip(tip,mx,my){
    ToolTip(tip, { x:mx,y:my-50,no:20,life:200, color:{bg:"0x222222",text:"0xFFFFFF"}, font:{size:10} })
}
