; Send current window back and activate (?) the window just behind
; When activate=True, it is effectively the same as Alt+Tab but switches only within the current desktop

sendWindowBack(activate:=True){
    activeID:=winExist("A")
    reached := winExist("ahk_group WG_Desktop ahk_id " activeID)  ; desktop

    winget ids, list
    loop % ids {
        if (!reached) {
            if (activeID==ids%A_Index%)
                reached:=True
            continue
        }

        win:="ahk_id " ids%A_Index%
        WinGetTitle, title, % win
        if !title
            continue

        ; Send active window one step back without activating the window behind
        ; This is somethimes needed in addition to winactivate
        Critical
        winset AlwaysOntop, On, % win
        loop 10 {
            winset AlwaysOntop, Off, % win
            WinGet s, ExStyle, % win
            if !(s & 0x8)
                break
        }
        Critical Off

        if activate
            winActivate % win
        break
    }
    return activeID ; Return the id of the window that was previously active
}
