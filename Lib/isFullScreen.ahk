isFullScreen(title:="A", pseudo:=0) {
    if !(win:=winExist(title))
        return false
    win:="ahk_id " win
    WinGet, WinMinMax, MinMax, % win
    WinGetPos, x, y, w, h, % win

    if (WinMinMax=0 OR pseudo=1) AND (x=0) AND (y=0) AND (w=A_ScreenWidth) AND (h=A_ScreenHeight) {
        WinGetClass, c, % win
        WinGet, pr, ProcessName, % win
        SplitPath, pr,,, ext
        if (c="Progman") OR (c="WorkerW") OR (ext="scr")
            return false
        ; Msgbox, %pseudo% %WinMinMax% %x% %y% %w% %h%`n%c% %ext% %pr%
        return true
    }
    ; Msgbox, %pseudo% %WinMinMax% %x% %y% %w% %h%
    return false
}