;Critical
reloadAsAdmin_Task()
Suspend, On

#include %A_ScriptDir%  ;Sets dir for includes
#include globals.ahk ; Must be before directives
#include Directives.ahk

#include <ini>
#include <Toast>
#include <DelayedTimer>
#include Modules.ahk

#include <ReloadScriptOnEdit>
Modules.add(ReloadScriptOnEdit, 2000, ["*.ahk", "*.ini"])

tooltip("Tray",{life:500})
#include Tray.ahk
trayMenu()

tooltip("Suspend_on_FS",{life:500})
#include suspendonFS.ahk
delayedTimer.set(Func("suspendOnFS").bind([
        ,"ahk_group WG_VideoPlayer"
        ,"ahk_group WG_Browser"           ]), 100)

#include winProbe.ahk
Modules.add(winProbe)
; winProbe.activate()

#include dimScreen.ahk
Modules.add("dimScreen", 0)
; dimScreen(120)

#include <Taskview>
;#include <Taskview_Temp>
Modules.add(TaskView,, true)

#include hotcorners.ahk
Modules.add("hotCorners", 100)

#include winSizer.ahk
Modules.add(winSizer)
;winSizer.__new()

#include windowRespond.ahk
Modules.add("windowRespond", 1000)

#include Transparent.ahk
Modules.add("Transparent_TaskbarGlass", 500, 4)
;Modules.add("Transparent_Windows", 500, 240)
;Modules.add("Transparent_MaxBG", 500, "  - ImageGlass ahk_exe ImageGlass.exe","222A30")
;Modules.add("Transparent_MaxBG", 500, "ahk_exe nomacs.exe"    ,"1f2021")

#include PIP.ahk
Modules.add(PIP, 100, [
	, { title: "ahk_group WG_VideoPlayer", maxHeight: 0.8    , type: "VJTHD" }
    , { title: "ahk_group WG_Browser_PIP"     				 , type: "CJTH " }
    , { title: "ahk_group WG_Console", set: 2                , type: "  THD" }
    , { title: "ahk_group WG_Calc"   , set: 3, maxheight: 530, type: "N    " }
    , { title: "ahk_exe notepad.exe" , set: 4, maxheight: 1  , type: "    D" }    ])

#include Togglekeys.ahk
Modules.add("CapsLockOffTimer", 1000, 60000)
Modules.add(caseMenu)

#include microWindows.ahk
Modules.add(microWindow, 0)

#include winAction.ahk
Modules.add(winAction,, "winAction.ini")
; Multiple winaction can be created by using obj1:=new winaction("iniName.ini"), ...

#include watchExplorerWindows.ahk
Modules.add(watchExplorerWindows, 300000, "explorerWindows")

#include runText.ahk  ;Needs serious Refactoring!!
Modules.add(runText, 0)
global runTextObj:=new runText("Runtext.ini")

;#include internet.ahk
;Module.add("netNotify", -5000, False)

changeVolumeBalance(VA_GetMasterVolume(2)/VA_GetMasterVolume(1), True, False)
Modules.add("changeVolume", 5000, 0, False, False)

#include watchdog.ahk
Modules.add("process_watchdog", 5000, PRG_GPG_Agent, "--daemon",,, 0)

#include autoUpdate.ahk
Modules.add("autoUpdate", 3600000) ;Put in firstrun, but without blocking

Modules.initialize()
Modules.startTimers()

suspend Off
Modules.firstRun()

RETURN

;============================== End of auto-execute
#include keyRemap.ahk
#include hotStrings.ahk
#include *i hotStrings-Private.ahk ;Has personal data in this file

RETURN
Exit:
ExitApp
return
