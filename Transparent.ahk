Transparent_windows(tr){
    onExit(Func("_Transparent_windows_EXIT").bind(tr))

    WinGet windows, List
    Loop %windows%{
        wid := windows%A_Index%

        IfWinNotExist, ahk_group WG_Transparent ahk_id %wid%
            continue
        IfWinExist, ahk_group WG_NoTransparent ahk_id %wid%
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
            IfWinNotExist, ahk_group WG_Transparent ahk_id %wid%
                continue
            IfWinExist, ahk_group WG_NoTransparent ahk_id %wid%
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
Transparent_MaxBG(title:="A", color:="F0F0F0", frameless:=False){
    win := "ahk_id " WinExist(title)
    WinGet, max , MinMax, % win
    if (max && winActive(win)) {
        frame:=GetKeyState("LShift", "P")? "+": "-"
        WinSet, Transcolor, % color, % win
    }
    else {
        frame:="+"
        WinSet, Transcolor, Off, % win
    }
    if frameless and frame
        WinSet, Style, %frame%0x800000, % win
}

;------------------------------------------------------------------------------------------------
Transparent_TaskbarGlass(state:=-4, color:=0x40000000) { ;ABGR color
; Note: Resets when Start menu is active. So set as timer. Even then, it won't work while startmenu/taskview is active

/*  state
    ------------
    0   No color, Fully Opaque
    1   Colored , Fully opaque
    2   Colored , Translucent
    3   No Color, Blurred (since it has no color, transparency can't be controlled)
    4   Colored , Blurred
   <0   (2,0x01000000) when on desktop and (|state|,color) otherwise
*/

    static ACCENT_POLICY, WINCOMPATTRDATA, state_old, color_old
    , pad := (A_PtrSize=8?4:0), WCA_ACCENT_POLICY := 19, ACCENT_SIZE := VarSetCapacity(ACCENT_POLICY, 16, 0)
    , SWCA:= DllCall("GetProcAddress", "Ptr", DllCall("LoadLibrary", "Str", "user32.dll", "Ptr"), "AStr", "SetWindowCompositionAttribute", "Ptr")

    if(state<0){
        WinGetClass c, A
        if(c="Progman" OR c="WorkerW" OR c="Shell_TrayWnd"){
            state:=2, color:=0x01000000
        } else state:=-state
    }

    if (state_old!=(state:=mod(state,5)) OR color_old!=color) {
        state_old:=state, color_old:=color
        NumPut(state, ACCENT_POLICY, 0, "int")
        NumPut(color, ACCENT_POLICY, 8, "int")
        VarSetCapacity(WINCOMPATTRDATA, 8 + 2*pad + A_PtrSize, 0)
        NumPut(WCA_ACCENT_POLICY, WINCOMPATTRDATA, 0, "int")
        NumPut(&ACCENT_POLICY, WINCOMPATTRDATA, 4 + pad, "ptr")
        NumPut(ACCENT_SIZE, WINCOMPATTRDATA, 4 + pad + A_PtrSize, "uint")
    }

    return DllCall(SWCA, "ptr", WinExist("ahk_class Shell_TrayWnd"), "ptr", &WINCOMPATTRDATA)
}
