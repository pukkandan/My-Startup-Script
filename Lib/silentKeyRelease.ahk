silentKeyRelease_Mouse(key,delay:=200){
    obj:=func("_silentKeyRelease").bind(key, True)
    setTimer % obj, -%delay%
    return
}
/* ; UNTESTED
silentKeyRelease_Keyboard(key,delay:=200){
    obj:=func("_silentKeyRelease").bind(key)
    setTimer % obj, -%delay%
    return
}
*/

_silentKeyRelease(key, mouse:=False){
	if (mouse) {
    	ControlClick,, ahk_pid 0,, % key,, U
	} else {
		ControlSend,, {%key% up}, ahk_pid 0
	}
    return
}