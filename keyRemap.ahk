#include keyRemapFunc.ahk

;===================    CapsLock as Prefix
#if GetKeyState("CapsLock", "P")

r:: ; I forget +F10                                  ; No AppsKey in my laptop
m::                                                  ; Hard to M-Click in trackpad
	prefixUsed("CapsLock")
	SendLevel 1
	sendEvent % {r: "{AppsKey}", m: "{MButton}"}[subStr(A_ThisHotkey,0)]
return

Space::                                              ; Play/Pause all visible video players 
	prefixUsed("CapsLock")
	playAllVideoPlayers() 
return

n::                                                  ; NetNotify
	prefixUsed("CapsLock")
	netNotify(True,,1000)
return

1::													 ; Caps+Num => #Num since #Num is replaced below
2::
3::
4::
5::
6::
7::
8::
9::
0::
	prefixUsed("CapsLock")
	if !prefixUsed("CapsLock_Num", False)
	    send % "{LWin down}"
	prefixUsed("CapsLock_Num")

	send % A_ThisHotkey
	setTimer, winUpWhenCapsReleased, 100
return

;===================    R/M Button as Prefix
RETURN
#if getKeyState("RButton","P")

LButton::                                            ; Switch to next window
	sendWindowBack()
	silentKeyRelease_Mouse("R")
return

MButton:: winSizer.start("RButton")                  ; WinSizer
MButton Up::
	if !winSizer.end()
	    send, #{Tab}
	silentKeyRelease_Mouse("R")
return

WheelUp::                                            ; Go to Prev/Next Desktops
WheelDown::
	(A_ThisHotkey="WheelUp")? taskView.GoToDesktopPrev(True): taskView.GoToDesktopNext(False)
	silentKeyRelease_Mouse("R")
	sleep 200
return

#if getKeyState("MButton","P")

WheelUp::                                            ; Move window to desktop and go there
WheelDown::
	(A_ThisHotkey="WheelUp")? taskView.MoveWindowAndGoToDesktopPrev(WinExist("A"),True): taskView.MoveWindowAndGoToDesktopNext(WinExist("A"),False)
	silentKeyRelease_Mouse("M")
	sleep 200
return

#ifWinNotActive ahk_group right_drag

*RButton up::                                        ; Dont Block RButton
	Critical
	if !{"MButton":0,"MButton Up":0,"WheelUp":0,"WheelDown":0,"LButton":0}.haskey(A_PriorKey)
	    send % "{Blind}{RButton}"
return

#If

;===================    Task View with Keyboard
RETURN
+#Left::                                             ; Move window to desktop
+#Right::
	if (A_ThisHotkey="+#Left")
		taskView.MoveWindowAndGoToDesktopPrev(WinExist("A"),True)
	else
		taskView.MoveWindowAndGoToDesktopNext(WinExist("A"),False)
return

!#Left::                                             ; Move window to desktop and go there
!#Right::
	if (A_ThisHotkey="!#Left")
		taskView.MoveWindowToDesktopPrev(WinExist("A"),True)
	else
		taskView.MoveWindowToDesktopNext(WinExist("A"),False)
return

#1::                                                 ; Go to Desktop by number
#2::
#3::
#4::
#5::
#6::
#7::
#8::
#9::
#0::
	taskView.GoToDesktopNumber(SubStr(A_ThisHotKey,0)=="0" ?10: SubStr(A_ThisHotKey,0), False)
return

+#1::                                                ; Move window to Desktop by number
+#2::
+#3::
+#4::
+#5::
+#6::
+#7::
+#8::
+#9::
+#0::
	taskView.MoveWindowAndGoToDesktopNumber( SubStr(A_ThisHotKey,0)=="0"? 10: SubStr(A_ThisHotKey,0), winActive("A"), False)
return

!#1::                                                ; Move window to Desktop by number and go there
!#2::
!#3::
!#4::
!#5::
!#6::
!#7::
!#8::
!#9::
!#0::
	taskView.MoveWindowToDesktopNumber(SubStr(A_ThisHotKey,0)=="0" ?10: SubStr(A_ThisHotKey,0), sendWindowBack(), False)
return


;===================    Over Taskbar
RETURN
#if isOver_mouse("ahk_class Shell_TrayWnd ahk_exe Explorer.exe")
~MButton::send ^!{Tab}^+!{Tab}                      ; Alt tab over taskbar
WheelUp::send ^+!{Tab}
WheelDown::send ^!{Tab}

#if winActive("Task Switching ahk_class MultitaskingViewFrame ahk_exe Explorer.EXE") AND isOver_mouse("ahk_class Shell_TrayWnd ahk_exe Explorer.exe")        ; When Task Switching
LButton::send {Enter}
MButton::send {Alt Up}{Esc}
#if

/*
;===================    Groupy
RETURN
!CapsLock::Send #``
!+CapsLock::Send #^``
*/

;===================    Fences Pages
RETURN
#if winActive("ahk_class WorkerW ahk_exe explorer.exe") AND getKeyState("LButton","P")
WheelUp::
WheelDown::
	send % "{LButton Up}!{" (A_ThisHotkey=="WheelUp"?"WheelDown":"WheelUp") "}"
return
#if

;===================    Toggglekeys

RETURN
+~CapsLock::
~NumLock::
~ScrollLock::
~Insert::
	Toast.show( {title:{text:str_Replace(A_ThisHotkey,[["~"],["+"]]) (GetKeyState(str_Replace(A_ThisHotkey,[["~"],["+"]]),"T")? " On":" Off")}, sound:True})
return

;===================    Trigger HotStrings (») [Check hotStrings.ahk for details]
RETURN
CapsLock::
	keyWait %A_ThisHotkey%
	if prefixUsed("CapsLock", False)
	    return
	SendLevel 1
	sendEvent » ;Used to trigger many hotstrings
return

;===================    Send `n/`t in cases where enter/tab is used for other purposes
#ifWinNotActive ahk_exe Mathematica.exe
+Enter::Send `n
;#if !winActive("ahk_exe sublime_text.exe")
;+Tab::Send % "    " ;I prefer 4 spaces instead of tab in some situations where I need to use +tab
#if

;===================    X1 - Ditto & Launcher
RETURN
XButton2::
	Keywait, %A_ThisHotkey%, T0.5
	if !ErrorLevel {
	    runOrSend("Ditto" ,"^``", "D:\Program Files\Ditto\Ditto.exe")
	} else {
	    goSub #Space ; Check "Launcher"
	}
return

;===================    X2 - winAction & RunText
RETURN
XButton1::
	Keywait, %A_ThisHotkey%, T0.25
	if !ErrorLevel {
#w:: 	winAction.show()
	} else {
#`:: 	runTextObj.showGUI()
	}
return
#if

;===================    Launcher
RETURN
LWin::                                              ; LWin => Launcher
#Space::                                            ; Open Launcher with pastable text
	runLauncher(A_ThisHotkey=="LWin", A_ThisHotkey!="LWin")
return

#ifWinActive Keypirinha ahk_exe keypirinha-x64.exe
~Tab::                                              ; Paste previously selected text
~Space:: 
	keepSelectedText(False)
return
#if

~LWin & RWin:: return                               ; Allows LWin to be still used as prefix
;+^LWin:: send {Ctrl Up}{Shift Up}{LWin Up}{RWin}   ; +^LWin => Win (^Esc already does this)
return

;===================    Programs/Functions
RETURN
;                                                   ; Run => Launcher
;#r:: runOrSend("Run" ,"!{f2}", "D:\AKJ\Progs\Keypirinha\bin\x64\keypirinha-x64.exe", False, "{>} ")

;                                                   ; WindowSwitch
 #CapsLock:: runOrSend("WindowSwitch" ,"!{f2}", "D:\AKJ\Progs\Keypirinha\bin\x64\keypirinha-x64.exe", False, "{»}{Tab}")
+#CapsLock:: ShellRun("notepad.exe")                ; Notepad
^#CapsLock:: ShellRun("calc1.exe")                  ; Calc
 !CapsLock:: ShellRun("cmd.exe",,,"RunAs")          ; cmd
^!CapsLock:: runSSH()                               ; SSH
+!CapsLock:: ShellRun("wsl.exe",,,"RunAs")          ; WSL
 ^CapsLock:: caseMenu.show()                        ; caseMenu
; CapsLock, +CapsLock are used elsewhere

#F1:: Send {F1}                                     ; Convert #F1 => F1
#F5:: dimScreen(+10)                                ; DimScreen
#F6:: dimScreen(-10)
 #c:: makeMicroWindow()                             ; MicroWindow
 #f:: listOpenFolders()                             ; List all open folders
#^e:: watchExplorerWindows.recover()				; Recover Explorer Window
#v:: activateVideoPlayer()                          ; Open VideoPlayer


#m:: winAction.bind_Window() ? winAction.trayIt()   ; TrayIt
#t:: Menu, trayIt, show                             ; TrayIt Menu

#ifwinactive ahk_exe explorer.exe                   ; Move Files to Common FOlder
#n:: moveFilesToCommonFolder(strSplit(getSelectedText({path:True}),"`n","`r"))
#if



#F10::                                              ; Global controls for Music player
#Media_Play_Pause::
	runOrSend("Music Player" ,"{Media_Play_Pause}", "D:\Program Files\MusicBee\MusicBee.exe")
return

#if ProcessExist("MusicBee.exe")
#F9::  Media_Prev
#F11:: Media_Next
; MusicBee sometimes doesn't respond to Media buttons.
; So I set it's global hotkey to #{F9/10/11}
;Media_Prev::       send #{F9}
;Media_Play_Pause:: send #{F10}
;Media_Next::       send #{F11}
#if

;+^Space:: YouTubePlayPause()                       ; Play/Pause Youtube
return

;===================    Script Functions - Tray/Pause/Reload/Exit
RETURN
#+t::
	updateTray(0, A_ScreenHeight-200)
	sleep, 300
	Menu, Tray, Show
return

#+p::
	Suspend, Permit
	SCR_Pause()
return

#+r:: Reload
#+q:: ExitApp
return