dimScreen(p:=0){
    static hwnd:=0, t:=0, e:=False
    if p is not Number  ;The tray name gets passed as param
        p:=0
    t:= p||t? (t>-p? (t+p>250?250:t+p) :0) :75,  e:= t? (p?True:!e) :False
    ; tooltip, % t "," e "," p
    if !hwnd {
        Gui, DimScreenGUI:New, +ToolWindow -Disabled -SysMenu -Caption +E0x20 +AlwaysOnTop +hwndhwnd
        Gui, DimScreenGUI:Color, 0x000000
        Gui, DimScreenGUI:Show, % "NoActivate X0 Y0 W" . A_ScreenWidth "H" . A_ScreenHeight
    }
    if (e) {
        WinSet, Transparent, % t, ahk_id %hwnd%
        Toast.show("Dimscreen " t "/255")
        Gui, DimScreenGUI:Show, NoActivate
        Menu, Tray, Check, &Dim Screen
    }
    else {
        Gui, DimScreenGUI:Hide
        Toast.show("Dimscreen Off")
        Menu, Tray, UnCheck, &Dim Screen
    }
    return hwnd
}