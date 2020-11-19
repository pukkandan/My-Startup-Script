; Send current window back and activate (?) the window just behind
; When activate=True, it is effectively the same as Alt+Tab but switches only within the current desktop

sendWindowBack(activate:=True){
    activeID:=winExist("A")
    winget ids, list
    loop % ids {
        if (activeID!=ids%A_Index%)
            continue
        i:=A_Index+1
        win:="ahk_id " ids%i%
        WinGetTitle, title, % win
        if !title
            continue
        ; Send active window one step back without activating the window behind
        ; This is somethimes needed in addition to winactivate
        winset AlwaysOntop, On, % win
        winset AlwaysOntop, Off, % win
        if activate
            winActivate % win
        break
    }
    return activeID ; Return the id of the window that was previously active
}