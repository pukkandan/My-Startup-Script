;Critical
Suspend, On
#include %A_ScriptDir%  ;Sets dir for includes
#include Directives.ahk

; #include <byteWord>
#include <ini>
#include <Toast>
#include <DelayedTimer>
#include <ReloadScriptOnEdit>

;tooltip("ReloadScriptOnEdit",{life:500})
;delayedTimer.set(func("ReloadScriptOnEdit").bind([A_ScriptDir "\*.ahk",A_ScriptDir "\*.ini"]), 2000, True)
;delayedTimer.start(True) ;Dont delay

tooltip("Tray",{life:500})
#include Tray.ahk
trayMenu()

tooltip("Suspend_on_FS",{life:500})
#include suspendonFS.ahk
delayedTimer.set(Func("suspendOnFS").bind([
        ,"ahk_exe PotPlayerMini64.exe"
        ,"ahk_exe PotPlayer.exe"
        ,"ahk_exe chrome.exe"
        ,"ahk_exe vivaldi.exe"           ]), 100)

;tooltip("winProbe",{life:500})
#include winProbe.ahk
; winProbe.activate()

tooltip("dimScreen",{life:500})
#include dimScreen.ahk
;dimScreen(120)

tooltip("Taskview",{life:500})
;#include Taskview_Temp.ahk
#include Taskview.ahk
TaskView.__new()

;tooltip("Hotcorners",{life:500})
#include hotcorners.ahk ; Refactor as a class
;delayedTimer.set("hotcorners", 100)

tooltip("winSizer",{life:500})
#include winSizer.ahk
winSizer.__new()

tooltip("UnwantedPopupBlocker",{life:500})
#include UnwantedPopupBlocker.ahk
delayedTimer.set("UnwantedPopupBlocker", 100)

tooltip("Transparent",{life:500})
#include Transparent.ahk
delayedTimer.set(Func("Transparent_TaskbarGlass").bind(4), 500)
;delayedTimer.set(Func("Transparent_Windows").bind(240), 500)
;delayedTimer.set(Func("Transparent_MaxBG").bind("ahk_exe ImageGlass.exe","3C3C3C"), 500)
;delayedTimer.set(Func("Transparent_MaxBG").bind("ahk_exe nomacs.exe"    ,"F0F0F0"), 500)

tooltip("PIP",{life:500})
#include PIP.ahk
PIP.__new([  {title:"ahk_exe PotPlayerMini64.exe ahk_class PotPlayer64"     , type:"VJTD" }
            ,{title:"ahk_exe PotPlayer.exe ahk_class PotPlayer64"           , type:"VJTD" }
            ,{title:"Picture in picture ahk_exe chrome.exe"                 , type:"CJT " }
            ,{title:"Picture in picture ahk_exe vivaldi.exe"                , type:"CJT " }
            ;,{title:"ahk_class ConsoleWindowClass", set:2                   , type:"  TD" }
            ,{title:"ahk_exe calc.exe"            , set:3, maxheight:500    , type:"N   " }
            ,{title:"ahk_exe calc1.exe"           , set:3, maxheight:500    , type:"N   " }     ])
delayedTimer.set(ObjbindMethod(PIP,"run"), 100)

tooltip("Togglekeys",{life:500})
#include Togglekeys.ahk
;delayedTimer.set(Func("CapsLockOffTimer").bind(60000), 1000)
caseMenu.__new()

tooltip("MicroWindows",{life:500})
#include microWindows.ahk

tooltip("WinAction",{life:500})
#include winAction.ahk
winAction.__new("winAction.ini")    ; Multiple winaction can be created by using obj1:=new winaction("iniName.ini"), ...

tooltip("watchExplorer",{life:500})
#include watchExplorerWindows.ahk
delayedTimer.set(ObjbindMethod(watchExplorerWindows, "__new"), 0, True)
delayedTimer.set(ObjbindMethod(watchExplorerWindows, "run"), 300000)


tooltip("RunText",{life:500})
#include runText.ahk  ;Needs serious Refactoring!!
global runTextObj:=new runText("Runtext.ini")

;tooltip("Internet",{life:500})
#include internet.ahk
;delayedTimer.set(Func("netNotify").bind(,false), 5000, True)

tooltip("autoUpdate",{life:500})
#include autoUpdate.ahk
delayedTimer.set(Func("autoUpdate").bind("C:\setup\",True, False, False), 3600000, True)

;Required for mouseRemap
GroupAdd, right_drag, ahk_exe mspaint.exe
GroupAdd, right_drag, ahk_exe mspaint1.exe
GroupAdd, right_drag, ahk_exe cmd.exe
GroupAdd, right_drag, ahk_exe vivaldi.exe
GroupAdd, right_drag, ahk_exe chrome.exe

;Required for HotStrings
GroupAdd, AutoBracket, ahk_exe notepad.exe
GroupAdd, AutoBracket, ahk_exe mathematica.exe
GroupAdd, AutoBracket, ahk_exe chrome.exe
;GroupAdd, AutoBracket, ahk_exe vivaldi.exe

tooltip("Starting Timers",{life:500})
delayedTimer.start(False)
tooltip()
Toast.show("Script Loaded")
suspend Off
delayedTimer.firstRun() ; First run only after resuming script

;============================== End of auto-execute
#include keyRemap.ahk
#include *i hotStrings-Private.ahk ;Has personal data in this file
#include hotStrings.ahk

RETURN
Exit:
ExitApp
return
