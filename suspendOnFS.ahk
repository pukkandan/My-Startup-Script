suspendOnFS(){
    if(isFullScreen())
    {
        Suspend, On
        setTimer, hotcorners, Off
        setTimer, netNotify, Off
        setTimer,, Off
        setTimer, resumeOnWin, 100
    }
    return
}
resumeOnWin(){
    if(!isFullScreen())
    {
        Suspend, Off
        setTimer, hotcorners, On
        setTimer, netNotify, On
        setTimer,, Off
        setTimer, suspendOnFS, On
    }
    return
}