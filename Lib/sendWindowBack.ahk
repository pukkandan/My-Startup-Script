; Send current window back and activate (?) the window just behind
; When activate=True, it is effectively the same as Alt+Tab but switches only within the current desktop

sendWindowBack(activate:=True){
    winget ids, list
    activeID:=winExist("A")
    loop % ids {
        if (activeID!=ids%A_Index%)
            continue
        i:=A_Index+1
        if (!activate){
            ; Send active window one step back without activating the window behind
            winset AlwaysOntop, On, % "ahk_id " ids%i%
            winset AlwaysOntop, Off, % "ahk_id " ids%i%
        } else
            winActivate % "ahk_id " ids%i%
        break
    }
    return activeID ; Return the id of the window that was previously active
}