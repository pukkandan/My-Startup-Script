silentKeyRelease_Mouse(key,delay){
    obj:=func("_silentKeyRelease_Mouse").bind(key)
    setTimer % obj, -%delay%
    return
}
_silentKeyRelease_Mouse(key){
    ControlClick,, ahk_pid 0,, % key,, U
    return
}