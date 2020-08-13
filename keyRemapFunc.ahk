listOpenFolders(){
    winCurrent:="ahk_id " winExist("A")
    ;ControlGetFocus, ctrlCurrent, ahk_id %winCurrent%
    pathList:={}

    Menu, listOpenFolders, Add
    Menu, listOpenFolders, DeleteAll

    i:=0
    for win in Explorer_GetAllWindowObjects() {
        path:=Explorer_GetWindowObjectPath(win, true)
        if !path || pathList.hasKey(path)
            continue
        pathList[path]:=True
        ;msgbox % pathList.hasKey(path) "`n" pathList[path] "`n" path

        act:=func("listOpenFolders_pastePath").bind(path "\", winCurrent) ;, ctrlCurrent)
        Menu, listOpenFolders, Add, % (i>9?"":"&") (i==10?"1&0":i) " " path, % act
        i++
    }
    if !i
        Toast.show("No Folders Open")
    Menu, listOpenFolders, Show
    return
}

listOpenFolders_pastePath(path, win){
    winGetClass, c, % win
    pasteText(path,,,win)
    if(c="#32770")
        send {Return}
}

;=============================================

moveFilesToCommonFolder(list){
    Toast.show({title:{text:"Move to Folder"}, life:100})

    n:=list.length()
    if !n
        return 1
    else if (n==1)
        folder:=path(list[1]).dir
    else
        folder:=regexReplace(str_CommonPart(list), "[^\\a-zA-Z0-9]+$")
    
    if (subStr(folder,0)=="\") {
        path:=substr(folder,1,-1), folder:=""
    } else {
        pathObj:=path(folder)
        path:=pathObj.dir, folder:=pathObj.file
    }

    text:=str_splitIntoLines(path "\", 50)
    InputBox, folder, Move %n% files into:, % text ,, , % 100+25*str_countLines(text) ,,,,, % folder
    if ErrorLevel
        return 2

    folder:=path "\" folder
    FileCreateDir % folder
    for _,file in list {
        fileName:=path(file).file
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
    ;msgbox %title%`n%key%`n%path%`n%paste%`n%sendAfter%
    exe:=path(path).file
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

runLauncher(toggle:=True, getText:=False){
    static tooltipOff:=Func("_runLauncher_tooltipOff")
    if getText
        text:=keepSelectedText()

    if WinActive("ahk_group WG_Launcher") {
        send {Esc}
        if toggle
            return
    }
    PRG_RS_Launcher[5]:=getText? "{BackSpace}" :""
    runOrSend(PRG_RS_Launcher*)

    if !getText
        return
    WinWaitActive, ahk_group WG_Launcher,, 2
    sleep 100
    tooltip(!text? "Nothing Selected": "Press SPACE/TAB to paste :`n" subStr(text, 1, 150)
        , {no:3, y:(text?-50:-25), x:0, mode:"Window"}  )
    setTimer, % tooltipOff, 1000
    setTimer, % tooltipOff, On
    return
}
_runLauncher_tooltipOff(force:=False){
        if !force && WinActive("ahk_group WG_Launcher")
            return
        tooltip(,{no:3})
        keepSelectedText(-1)
        return
}

keepSelectedText(new:=True, again:=True){ ; new = -1 to delete text, "" to return text without doing anything 
    static text:="", pasted:=False
    ;tooltip % text
    if (new=="")
        return text
    else if (new==-1)
        text:=""
    else if new {
        pasted:=False
        text:=subStr(getSelectedText({clean:True, clip:True, path:False}), 1, 300)
    } else if text {
        if !again && pasted
            return False
        pasted:=True
        pasteText(text)
    }
    return text
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

cmdInCurrentFolder(wsl:=False) { ;as admin 
    path:=Explorer_GetPath(winExist("A"))
    ShellRun(A_COMSPEC, (path? "/k cd /d " path :"") (wsl&&path? " && " :"") (wsl? "wsl.exe" :""),, "RunAs")
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
    win:=WinExist("ahk_group WG_VideoPlayer")
    if (!win) {
        DetectHiddenWindows, On
        win:=WinExist("ahk_group WG_VideoPlayer")
    }
    if win
        WinActivate, ahk_id %win%
    else
        ShellRun(PRG_VideoPlayer) ;, Clipboard)
}

;=============================================

playAllVideoPlayers(){
    DetectHiddenWindows, off
    active:=winExist("A")
    WinGet, l, list, ahk_group WG_VideoPlayer
    loop %l%
    {
        w:="ahk_id " l%A_Index%
        WinGet, m, MinMax, % w
        ;msgbox %w%`n%m%
        if (m!=-1) {
            winActivate % w
            Send, % PRG_RS_VideoPlayer[2] ; Set it to play/pause in potplayer. Media_Play_Pause doesnt work if it is set as global
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
    wid:=WinExist(" - YouTube ahk_group WG_Browser")
    if !wid
        return
    ControlGet, cid, Hwnd,,Chrome_RenderWidgetHostHWND1, ahk_id %wid%
    if !cid
        return
    IfWinNotActive, ahk_group WG_Browser
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