isOver_mouse(WinTitle:="A"){ ;If ahk_id is passed, dont use ahk_id prefix or any other options
    MouseGetPos, , , Win
    if WinTitle is number
        return (win==WinTitle)
    else return WinExist(WinTitle " ahk_id " Win)
}

isOver_coord(win,pos){
    CoordMode, Mouse, Screen        ;Mouse co-ords are specified in global co-ords
    WinGetPos, x, y, w, h, % win
    ; msgbox, %x%, %y%, %w%, %h%
    ; msgbox, % mpos[1] "|" mpos[2]
    if ((pos[1]>=x) and (pos[1]<=x+w) and (pos[2]>=y) and (pos[2]<=y+h))
        return True
    return false
}
