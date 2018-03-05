Transparent_windows(tr){
    GroupAdd, TransGroup, ahk_class CabinetWClass ahk_exe explorer.exe

    GroupAdd, noTransGroup, ahk_class SysShadow
    GroupAdd, noTransGroup, ahk_class Dropdown
    GroupAdd, noTransGroup, ahk_class SysDragImage

    onExit(Func("_Transparent_windows_EXIT").bind(tr))

    WinGet windows, List
    Loop %windows%{
        wid := windows%A_Index%

        IfWinNotExist, ahk_group TransGroup ahk_id %wid%
            continue
        IfWinExist, ahk_group noTransGroup ahk_id %wid%
            continue

        winget, trans, Transparent, ahk_id %wid%
        if !trans
            winset, Transparent, % tr, ahk_id %wid%
    }
    return
}

_Transparent_windows_EXIT(tr){
    WinGet windows, List
        Loop %windows% {
            wid := windows%A_Index%
            IfWinNotExist, ahk_group TransGroup ahk_id %wid%
                continue
            IfWinExist, ahk_group noTransGroup ahk_id %wid%
                continue
            winget, trans, Transparent, ahk_id %wid%
            if (trans=tr)
                winset, Transparent, Off, ahk_id %wid%
        }
        return
}

;------------------------------------------------------------------------------------------------
/* ; Use Transparent_TaskbarGlass
Transparent_Taskbar(trans){
    static DefaultGUIColor := DllCall("GetSysColor", Int, 15, UInt)  ;Get UI Color

    if isOver_mouse("ahk_class Shell_TrayWnd")   ;Mouse over taskbar
        WinSet, Transparent, % trans, ahk_class Shell_TrayWnd   ;Make taskbar slightly transparent (Automatically removes transcolor)
    else
        WinSet, TransColor, DefaultGUIColor 160, ahk_class Shell_TrayWnd    ;Make taskbar transparent and remove UI Color
    onExit("_Transparent_Taskbar_EXIT")
    Return
}

_Transparent_Taskbar_EXIT(){
    WinShow,ahk_class Shell_TrayWnd ;Shows Taskbar incase it had been hidden
    WinSet, Transparent, Off, ahk_class Shell_TrayWnd   ;and remove its transparency
    return
}
*/

;------------------------------------------------------------------------------------------------
Transparent_MaxBG(title:="A",color:="F0F0F0"){
    WinGet, max , MinMax, % title
    if max
        WinSet, Transcolor, % color, % title
    else
        WinSet, Transcolor, Off, % title
}

;------------------------------------------------------------------------------------------------
Transparent_TaskbarGlass(accent_state:=4, gradient_color:=0x40000000) { ;ABGR color
/*
    0   No color, Fully Transparent
    1   Colored , Fully opaque
    2   Colored , Translucent
    3   No Color, Blurred (since ithas no color, transparency cant be controlled)
    4   Colored , Blurred
*/
    static pad := (A_PtrSize=8?4:0), WCA_ACCENT_POLICY := 19, ACCENT_SIZE := VarSetCapacity(ACCENT_POLICY, 16, 0)

    NumPut(accent_state, ACCENT_POLICY, 0, "int")
    NumPut(gradient_color, ACCENT_POLICY, 8, "int")

    VarSetCapacity(WINCOMPATTRDATA, 8 + 2*pad + A_PtrSize, 0)
    NumPut(WCA_ACCENT_POLICY, WINCOMPATTRDATA, 0, "int")
    NumPut(&ACCENT_POLICY, WINCOMPATTRDATA, 4 + pad, "ptr")
    NumPut(ACCENT_SIZE, WINCOMPATTRDATA, 4 + pad + A_PtrSize, "uint")
    if DllCall("user32\SetWindowCompositionAttribute", ptr, WinExist("ahk_class Shell_TrayWnd"), ptr, &WINCOMPATTRDATA)
        return true
    else return false
}