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
Transparent_Taskbar(trans){
    static DefaultGUIColor := DllCall("GetSysColor", "Int", COLOR_3DFACE, "UInt")  ;Get UI Color

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

;------------------------------------------------------------------------------------------------
Transparent_ImageGlass(){
    WinGet, max , MinMax, ahk_exe ImageGlass.exe
    if max
        WinSet, Transcolor, 3C3C3C, ahk_exe ImageGlass.exe
    else
        WinSet, Transcolor, Off, ahk_exe ImageGlass.exe
}