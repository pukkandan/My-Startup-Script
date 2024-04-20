autoUpdate(path:="", download:=True, install:=False, openCLog:=True){
    regexMatch(Download("https://autohotkey.com/download/1.1/version.txt"),"^\d+\.\d+\.\d+(\.\d+)?$",v)
    if !v
        return -1
    else if (v<=A_AhkVersion){
        if FileExist("ahk.exe") {  ;Last run was an update
            if path
                FileMove, ahk.exe, %path%\AutoHotkey_%v%_setup.exe, 0 ;Dont replace
            FileDelete, ahk.exe ;If exe still exists
            Toast.show({title:{text:"AHK Updated"}, life:openHelp?500:0})
            if openCLog
                ShellRun(PRG_RS_CHM.process, "mk:@MSITStore:" SCR_AHKDir "\AutoHotkey.chm::/docs/AHKL_ChangeLog.htm")
            return 2
        }
        else return 0
    }

    Toast.show({title:{text:"AHK v" v " Available"}, life:download?500:0})
    if (download) {
        while !fileExist("ahk.exe")
            Download_toFile("https://github.com/Lexikos/AutoHotkey_L/releases/latest/download/AutoHotkey_" v "_setup.exe", "ahk.exe")
        Toast.show({title:{text:"AHK v" v " Downloaded"}, life:install?500:0})
        if (install) {
            run *RunAs ahk.exe /s /r /IsHostApp
        } else {
            msgbox, 0x4, AHK v%v%, Update AHK?
            IfMsgBox Yes
                run *RunAs ahk.exe /s /r /IsHostApp
        }
    }

    return 1
}

;autoUpdate()  ; Test
