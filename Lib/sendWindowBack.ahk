; Send current window back and activate (?) the window just behind
; When activate=True, it is effectively the same as Alt+Tab but switches only within the current desktop

sendWindowBack(activate:=True){
    activeID:=winExist("A")
    is_desktop:= winExist("ahk_group WG_Desktop ahk_id " activeID)
    winget ids, list
    loop % ids {
        if (!is_desktop && activeID!=ids%A_Index%)
            continue
        i:=A_Index+1
        win:="ahk_id " ids%i%
        WinGetTitle, title, % win
        if !title
            continue

        ; Send active window one step back without activating the window behind
        ; This is somethimes needed in addition to winactivate
        winset AlwaysOntop, On, % win
        loop 10 {
            winset AlwaysOntop, Off, % win
            WinGet s, ExStyle, % win
            if !(s & 0x8)
                break
        }
        if activate
            winActivate % win
        break
    }
    return activeID ; Return the id of the window that was previously active
}
