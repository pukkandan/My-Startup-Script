suspendOnFS(exceptions:=""){
    if(isFullScreen(,1))
    {
        setTimer, hotcorners, Off
        setTimer, netNotify, Off
        setTimer,, Off
        setTimer, resumeOnWin, 100

        ; Apply exceptions only for hotkeys
        for _,win in exceptions
            if winActive(win)
                return 1
        Suspend, On
        return 2
    }
    return 0
}
resumeOnWin(){
    if(!isFullScreen(,1))
    {
        Suspend, Off
        setTimer, hotcorners, On
        setTimer, netNotify, On
        setTimer,, Off
        setTimer, suspendOnFS, On
    }
    return
}