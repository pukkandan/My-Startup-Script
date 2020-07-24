listOpenFolders(){
    winCurrent:="ahk_id " winExist("A")
    pathList:={}

    Menu, listOpenFolders, Add
    Menu, listOpenFolders, DeleteAll

    i:=0
    for win in Explorer_GetAllWindowObjects() {
        i++
        path:=Explorer_GetWindowObjectPath(win, true)
        if !path || pathList.hasKey(path)
            continue
        pathList[path]:=True
        ;msgbox % pathList.hasKey(path) "`n" pathList[path] "`n" path

        act:=func("listOpenFolders_pastePath").bind(path "\", winCurrent)
        Menu, listOpenFolders, Add, % (i>9?"":"&") (i==10?"1&0":i) " " path, % act
    }
    
    Menu, listOpenFolders, Show
    return
}

listOpenFolders_pastePath(path, win){
    winGetClass, c, % ahk_id %win%
    pasteText(path,,,win)
    if c=="#32770"
        send {Return}
}

;=============================================

moveFilesToCommonFolder(list){
    Toast.show({title:{text:"Move to Folder"}, life:100})

    n:=list.length()
    if (!n) {
        return 1
    } else if (n==1) {
        folder:=list[1]
        SplitPath, folder,, folder
    } else {
        folder:=regexReplace(str_CommonPart(list), "[^\\a-zA-Z0-9]+$")    
    }
    
    if (subStr(folder,0)=="\") {
        path:=substr(folder,1,-1), folder:=""
    } else {
        SplitPath, folder, folder, path
    }
    text:=str_splitIntoLines(path "\", 50)
    InputBox, folder, Move %n% files into:, % text ,, , % 100+25*str_countLines(text) ,,,,, % folder
    if ErrorLevel
        return 2

    folder:=path "\" folder
    FileCreateDir % folder
    for _,file in list {
        SplitPath, file , fileName
        if instr(FileExist(file), "D") {
            FileMoveDir, % file, % folder "\" fileName
        } else {
            FileMove, % file, % folder "\" fileName, false
        }
    }
    return 0
}

;=============================================

runOrSend(title, key, path, paste:=False, sendAfter:=""){
    SplitPath, path, exe
    win:="ahk_exe " exe

    if (paste) {
        text:=subStr(getSelectedText({clean:True}), 1, 300)
    }

    if !processExist(exe) {
        Toast.show("Starting " title " . . .")
        ShellRun(path)
        DetectHiddenWindows, On
        Winwait, % win ,, 5
        ;if ErrorLevel
        ;    return
    }

    Toast.show(title)
    send % key

    DetectHiddenWindows, Off
    Winwait, % win ,, 2
    if ErrorLevel
        return
    sleep, 100
    WinActivate, % win
    if (paste) {
        send, ^a
        pasteText(text)
    }
    if (sendAfter)
        send, % sendAfter
    return
}

runLauncher(toggle, getText){
    key:="!{F2}"
    path:="D:\AKJ\Progs\Keypirinha\bin\x64\keypirinha-x64.exe"
    win:="Keypirinha", exclude:=" - "
    
    SplitPath, path, exe
    win.=" ahk_exe " exe
    if getText
        text:=keepSelectedText()

    if WinActive(win,,exclude) {
        send {Esc}
        if toggle
            return
    }

    runOrSend("Launcher", key, path,, getText? "{BackSpace}" :"")

    if !getText
        return
    WinWaitActive, % win,, 2, % exclude
    sleep 100
    tooltip(!text? "Nothing Selected": "Press SPACE/TAB to paste :`n" text
        , {no:3, y:(text?-50:-25), x:0, mode:"Window"}  )
    f:=func("_runLauncher_tooltipOff").bind(False, win, exclude)
    setTimer, %f%, 1000
    setTimer, %f%, On
    return
}
_runLauncher_tooltipOff(force:=False, win:="", exclude:=""){
        if !force && WinActive(win,,, exclude)
            return
        tooltip(,{no:3})
        keepSelectedText(-1)
        return
}

keepSelectedText(new:=True){ ; -1 to delete text
    static text:=""
    ;tooltip % text
    if (new==-1)
        return text:=""
    if (new)
        return text:=subStr(getSelectedText({clean:True, clip:True, path:False}), 1, 300)
    if (text) {
        pasteText(text)
        ;_runLauncher_tooltipOff(True)
        return text
    }
}

;=============================================

processExist(p){ ;This function is available natively in v2
    Process exist, % p
    return ErrorLevel
}

;=============================================

runSSH(){
    InputBox, param, SHH, parameters?,,, 128,,,,,-CX 14173002@10.2.60.11
    ShellRun("ssh.exe",param,,,"RunAs")
    return
}

;=============================================

makeMicroWindow(){
    hwnd:=WinExist("A")
    win:="ahk_id " hwnd
    WinGetClass, winclass, % this.win
    if (winclass="WorkerW" OR winclass="Shell_TrayWnd" OR !winexist(win))
        Toast.show("No Window")
    else {
        new microWindow(hwnd)
        Toast.show("microWindow")
    }
    return
}


;=============================================

activateVideoPlayer() {
    win:=WinExist("ahk_exe PotPlayerMini64.exe")
    if win
        WinActivate, ahk_id %win%
    else
        ShellRun("D:\Program Files\Potplayer\PotplayerMini64.exe") ;, Clipboard)
}

;=============================================

playAllVideoPlayers(){
    DetectHiddenWindows, off
    active:=winExist("A")
    WinGet, l, list, ahk_exe PotPlayerMini64.exe ahk_class PotPlayer64
    loop %l%
    {
        w:="ahk_id " l%A_Index%
        WinGet, m, MinMax, % w
        ;msgbox %w%`n%m%
        if (m!=-1) {
            winActivate % w
            Send, +{F12} ; Set +{F12} to play/pause in potplayer. Media_Play_Pause doesnt work if it is set as global
            sleep 10 ; Sleep makes the different players drift out of sync slowly, but the send becomes much more reliable
        }
    }
    sleep 10
    winActivate, ahk_id %active%
    return
}

;=============================================

YouTubePlayPause(){ ;Using https://www.streamkeys.com/ is way better
    Thread, NoTimers
    wid:=WinExist(" - YouTube ahk_exe chrome.exe ahk_class Chrome_WidgetWin_1")
    if !wid
        return
    ControlGet, cid, Hwnd,,Chrome_RenderWidgetHostHWND1, ahk_id %wid%
    if !cid
        return
    IfWinNotActive, ahk_exe chrome.exe
    {
        ControlFocus,,ahk_id %cid%
        ControlSend,, k , ahk_id %cid%
    } else {
        WinGet, wid, id, A
        ControlGetFocus, cid_old, ahk_id %wid%
        ControlGet, cid_old, Hwnd,, %cid_old%, ahk_id %wid%
        ControlFocus,,ahk_id %cid%
        send, k
        sleep, 100
        ControlFocus,,ahk_id %cid_old%
    }
    return
}

;=============================================

prefixUsed(key, set:=True) {
    static prefix:={}

    ret:=prefix[key]
    prefix[key]:=set
    
    return ret ; returns previous value
}

winUpWhenCapsReleased() {
    if GetKeyState("CapsLock", "P")
        return
    
    SetTimer,, Off
    send {LWin Up}
    prefixUsed("CapsLock_Num", False)
}