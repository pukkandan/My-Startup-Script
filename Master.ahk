Suspend, On
#include %A_ScriptDir%  ;Sets dir for includes
#include Directives.ahk
; #include <byteWord>
#include <ini>
#include <Toast>
#include <DelayedTimer>
#include <ReloadScriptOnEdit>

tooltip("ReloadScriptOnEdit",{life:500})
delayedTimer.set(func("ReloadScriptOnEdit").bind([A_ScriptDir "\*.ahk",A_ScriptDir "\*.ini"]), 2000, True)
delayedTimer.start() ;Dont delay

tooltip("Tray",{life:500})
#include Tray.ahk
trayMenu()

tooltip("Suspend_on_FS",{life:500})
#include suspendonFS.ahk
delayedTimer.set("suspendOnFS", 100)

tooltip("winProbe",{life:500})
#include winProbe.ahk
; winProbe.activate()

tooltip("dimScreen",{life:500})
#include dimScreen.ahk
; dimScreen(120)

tooltip("Taskview",{life:500})
#include Taskview.ahk
taskView.__new()

tooltip("Hotcorners",{life:500})
#include hotcorners.ahk
delayedTimer.set("hotcorners", 100)

tooltip("winSizer",{life:500})
#include winSizer.ahk
winSizer.__new()

tooltip("UnwantedPopupBlocker",{life:500})
#include UnwantedPopupBlocker.ahk
delayedTimer.set("UnwantedPopupBlocker", 100)

; tooltip("Transparent",{life:500})
; #include Transparent.ahk
; delayedTimer.set(Func("Transparent_Taskbar").bind(240), 500)
; delayedTimer.set(Func("Transparent_Windows").bind(250), 500)
; delayedTimer.set("Transparent_ImageGlass", 500)

tooltip("PIP",{life:500})
#include PIP.ahk
PIP.__new([  {title:"ahk_exe PotPlayerMini64.exe ahk_class PotPlayer64" ,type:"V"}
            ,{title:"ahk_exe PotPlayer.exe ahk_class PotPlayer64"       ,type:"V"}
            ,{title:"ahk_exe chrome.exe"                                ,type:"C"}     ])
delayedTimer.set(ObjbindMethod(PIP,"run"), 100)

tooltip("Togglekeys",{life:500})
#include Togglekeys.ahk
delayedTimer.set(Func("CapsLockOffTimer").bind(60000), 1000)
caseMenu.__new()

tooltip("MicroWindows",{life:500})
#include microWindows.ahk

tooltip("WinAction",{life:500})
#include winAction.ahk
winAction.__new("winAction.ini")    ; Multiple winaction can be created by using obj1:=new winaction("iniName.ini"), ...

tooltip("RunText",{life:500})
#include runText.ahk  ;Refactor!!
global runTextObj:=new runText("Runtext.ini")

tooltip("Internet",{life:500})
#include internet.ahk
delayedTimer.set("netNotify", 5000, True)


tooltip("autoUpdate",{life:500})
#include autoUpdate.ahk
delayedTimer.set("autoUpdate", 3600000, True)

;Required for mouseRemap
GroupAdd, right_drag, ahk_exe mspaint.exe
GroupAdd, right_drag, ahk_exe mspaint1.exe
GroupAdd, right_drag, ahk_exe cmd.exe
GroupAdd, right_drag, ahk_exe vivaldi.exe

tooltip
delayedTimer.start()
suspend, Off
Toast.show("Script Loaded")

;============================== End of auto-execute
#include keyRemap.ahk
#include *i hotStrings.ahk ;Has personal data in this file

RETURN
Exit:
ExitApp
return
