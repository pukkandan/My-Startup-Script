; This file must be in Windows 1252 or UTF-BOM encoding, because of "»"
#include keyRemapFunc.ahk

/*
;===================    Fast Scrolling

#if
~WheelUp::
~WheelDown::
Critical
fastScroll(subStr(A_ThisHotkey, 2))
return
*/


;===================    Capslock Toggled on
#if GetKeyState("CapsLock", "T")
*1::																				; Capslock acts as Numlock for top row numbers
*2::
*3::
*4::
*5::
*6::
*7::
*8::
*9::
*0::
send % "{Blind}{Numpad" subStr(A_ThisHotkey,2) "}"
return
*-::
*=::
	send % "{Blind}{Numpad" ({"*-": "Sub", "*=": "Add"}[A_ThisHotkey]) "}"
return
#if

;===================    CapsLock as Prefix
#if GetKeyState("CapsLock", "P")

r:: ; I forget +F10																; No AppsKey in my laptop
m::																				; Hard to M-Click in trackpad
	prefixUsed("CapsLock")
	SendKeys({r: "{AppsKey}", m: "{MButton}"}[subStr(A_ThisHotkey,0)])
return

Space::																			; Play/Pause all visible video players
	prefixUsed("CapsLock")
	playAllVideoPlayers()
return

/*
n::																				; NetNotify
	prefixUsed("CapsLock")
	netNotify(True,,1000)
return
*/

1::																				; Caps+Num => #Num, since #Num is replaced below
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
	    send {LWin down}
	prefixUsed("CapsLock_Num")

	send % A_ThisHotkey
	setTimer, winUpWhenCapsReleased, 100
return

;===================    R/M Button as Prefix
RETURN
#if getKeyState("RButton","P")

LButton::																		; Switch to next window
	sendWindowBack()
	prefixUsed("RButton")
return

MButton:: winSizer.start("RButton")												; WinSizer (keyboard alternative below)
MButton Up::
	if !winSizer.end()
	    send, #{Tab}
	prefixUsed("RButton")
return

  WheelUp::																		; Go to Prev/Next Desktops
WheelDown::
	(A_ThisHotkey="WheelUp")? taskView.GoToDesktopPrev(): taskView.GoToDesktopNext()
	prefixUsed("RButton")
	sleep 200
	tooltip
return

#if getKeyState("MButton","P") AND !isOver_mouse("ahk_group WG_TaskBar")

  WheelUp::																		; Move window to desktop and go there
WheelDown::
	if (A_ThisHotkey="WheelUp")
		taskView.MoveWindowAndGoToDesktopPrev(WinExist("A"))
	else
		taskView.MoveWindowAndGoToDesktopNext(WinExist("A"))
	prefixUsed("MButton")
	sleep 200
return

#ifWinActive ahk_group WG_RightDrag
~*RButton::
	Critical -1
	prefixUsed(subStr(strReplace(A_ThisHotkey,"~"), 2, 7), False)
return

#ifWinNotActive ahk_group WG_RightDrag
*RButton up::
*MButton up::
	Critical -1
	Thread Priority, 100
	sendPrefixKey(subStr(strReplace(A_ThisHotkey,"~"), 2, 7))
return

#If

;===================    Task View with Keyboard
RETURN
 +#d::
^+#d::
	if (A_ThisHotkey="+#d")
		taskView.CreateNewDesktopsAfterCurrent()
	else
		taskView.CreateNewDesktopsBeforeCurrent()
return

 +#Left::																		; Move window to desktop and go there
+#Right::
	if (A_ThisHotkey="+#Left")
		taskView.MoveWindowAndGoToDesktopPrev(WinExist("A"))
	else
		taskView.MoveWindowAndGoToDesktopNext(WinExist("A"))
return

 !#Left::																		; Move window to desktop
!#Right::
	if (A_ThisHotkey="!#Left")
		taskView.MoveWindowToDesktopPrev(WinExist("A"))
	else
		taskView.MoveWindowToDesktopNext(WinExist("A"))
return

 ^+#Left::																		; Move Desktop
^+#Right::
	if (A_ThisHotkey="^+#Left")
		taskView.MoveCurrentDesktopLeft()
	else
		taskView.MoveCurrentDesktopRight()
return

#1::																			; Go to Desktop by number
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

+#1::																			; Move window to Desktop by number and go there
+#2::
+#3::
+#4::
+#5::
+#6::
+#7::
+#8::
+#9::
+#0::
	taskView.MoveWindowAndGoToDesktopNumber( SubStr(A_ThisHotKey,0)=="0"? 10: SubStr(A_ThisHotKey,0), winExist("A"), False)
return

!#1::																			; Move window to Desktop by number
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

^+#1::																			; Move Desktop
^+#2::
^+#3::
^+#4::
^+#5::
^+#6::
^+#7::
^+#8::
^+#9::
^+#0::
	taskView.MoveCurrentDesktopTo(SubStr(A_ThisHotKey,0)=="0" ?10: SubStr(A_ThisHotKey,0), False)
return


;===================    Over Taskbar
RETURN
#if winActive("ahk_group WG_TaskView") AND isOver_mouse("ahk_group WG_TaskBar")
LButton:: send {Enter}															; When Task Switching
WheelUp:: send ^+!{Tab}
WheelDown:: send ^!{Tab}
MButton Up:: send {Alt Up}{Esc}

#if isOver_mouse("ahk_group WG_TaskBar")
~MButton Up:: send ^!{Tab}														; Alt tab over taskbar

;WheelUp:: Volume_Up
;WheelDown:: Volume_Down
WheelUp:: changeVolume(1)														; Change volume scrolling over taskbar
WheelDown:: changeVolume(-1)
^WheelUp::
^WheelDown::
	changeVolumeBalance(inStr(A_ThisHotkey, "Up")? .1:-.1)
return
#if

/*
;===================    Groupy
RETURN
!CapsLock:: Send #``
!+CapsLock:: Send #^``
*/

/*
;===================    Fences Pages
RETURN
#ifWinActive ahk_group WG_Desktop
WheelUp::
WheelDown::
if getKeyState("LButton","P")
		send % "{LButton Up}!{" (A_ThisHotkey=="WheelUp"?"WheelDown":"WheelUp") "}"
	else
		send {%A_ThisHotkey%}
	return
	#if
*/

;===================    WinSizer
RETURN
+^CapsLock::
	prefixUsed("CapsLock")
	winSizer.start("CapsLock")
return
 ~Ctrl Up::
~Shift Up::
	winSizer.end()
return

;===================    Toggglekeys

RETURN
+~CapsLock::
~NumLock::
~ScrollLock::
~Insert::
	_toggle_key:=str_Replace(A_ThisHotkey,[["~"],["+"]])
	Toast.show({title:{text: (_toggle_key="Insert"?"Overtype":_toggle_key) (GetKeyState(_toggle_key, "T")? " On":" Off")}, sound:True})
return

;===================    Trigger HotStrings (») [Check hotStrings.ahk for details]
RETURN
CapsLock::
	keyWait %A_ThisHotkey%
	if !prefixUsed("CapsLock", False)
		SendKeys("»", 10) ;Used to trigger many hotstrings
return

;===================    Send `n/`t in cases where enter/tab is used for other purposes
/* (See HotStrings for alternate implementation)
#ifWinNotActive ahk_group WG_ShiftEnter
+Enter:: Send `n
#ifWinNotActive ahk_group WG_ShiftSpace
+Space:: Send % "    " ;I prefer 4 spaces instead of tab in some situations instead of tab
#if
*/
;===================    X1 - Ditto & Launcher
RETURN
XButton2::
	Keywait, %A_ThisHotkey%, T0.5
	if ErrorLevel
		runLauncher(False,True)
	else
		activateProgram(PRG_RS_Clipboard)
return

;===================    X2 - winAction & RunText
RETURN
XButton1::
	Keywait, %A_ThisHotkey%, T0.25
	if ErrorLevel
		runTextObj.showGUI()
	else
		winAction.show()
return

;===================    Launcher
RETURN
  LWin:: runlauncher(True)														; LWin => Launcher
#Space:: runLauncher(False,True)												; Open Launcher with pastable text

#ifWinActive ahk_group WG_Launcher
  ~Tab:: 																		; Paste previously selected text
~Space::
	pasteInLauncher(A_ThisHotkey=="~Tab")
return
#if

LWin & RWin:: return															; Allows LWin to be still used as prefix
;+^LWin:: send {Ctrl Up}{Shift Up}{LWin Up}{RWin}								; +^LWin => Win (^Esc already does this)

;===================    Programs/Functions
RETURN
 ^CapsLock:: caseMenu.show()													; caseMenu
 #CapsLock:: activateProgram(PRG_RS_WindowSwitcher)								; WindowSwitch
+#CapsLock:: activateProgram(PRG_RS_TextEditor)									; Text editor
^#CapsLock:: activateProgram(PRG_RS_Calc)										; Calc
 !CapsLock:: cmdInCurrentFolder()												; CMD - WT
^!CapsLock:: cmdInCurrentFolder(,, True)										; CMD - WT
+!CapsLock:: cmdInCurrentFolder(, "-p bash")									; WSL - WT
#!CapsLock:: cmdInCurrentFolder(, "-p powershell")								; Powershell - WT
;^!CapsLock:: runSSH()															; SSH
; CapsLock, +CapsLock, +^CapsLock are used elsewhere

#F1:: Send {F1}																	; Convert #F1 => F1
Volume_Up::																		; Popup for volume
Volume_Down::
	changeVolume({Volume_Up: 1, Volume_Down:-1}[A_ThisHotkey])
return
/*
Volume_Up::																		; fn+Arrow = Volume
Volume_Down::
Volume_Up Up::
Volume_Down Up::
Media_Play_Pause::
Media_Stop::
Suspend, Permit
if inStr(A_ThisHotkey, "Volume") {
	if inStr(A_ThisHotkey, " Up")
		send {Media_Play_Pause}
} else {
	changeVolume({Media_Stop: 1, Media_Play_Pause:-1}[A_ThisHotkey])
}
return
^Media_Play_Pause::
^Media_Stop::
changeVolumeBalance({ Media_Play_Pause:-.1, Media_Stop:.1 }[subStr(A_ThisHotkey, 2)])
return
*/


#WheelUp:: changeVolume(1)														; Volume controls
#WheelDown:: changeVolume(-1)
#^WheelUp::
#^WheelDown::
prefixUsed("Win")
changeVolumeBalance(inStr(A_ThisHotkey, "Up")? .1:-.1)
return

;#ifWinActive ahk_exe vivaldi.exe
NumpadIns::
	send {F13}
	;sleep 1000
	;send ^1
return
#if

#ifWinActive ahk_group WG_Code
AppsKey & Tab::F13
#if

#F5:: dimScreen(+10)															; DimScreen
#F6:: dimScreen(-10)
 #c:: makeMicroWindow()															; MicroWindow
 #f:: listOpenFolders()															; List all open folders
 #w:: winAction.show()															; winAction
 #`:: runTextObj.showGUI()														; runText
 ^`:: activateProgram(PRG_RS_Clipboard)											; Ditto
#^e:: watchExplorerWindows.recover()											; Recover Explorer Window
 #v:: activateProgram(PRG_RS_VideoPlayer)										; Open VideoPlayer
;#r:: activateProgram(PRG_RS_Run)												; Run => Launcher
PrintScreen:: activateProgram(PRG_RS_Screenshot)


#m:: winAction.bind_Window() ? winAction.trayIt()								; TrayIt
#t:: Menu, trayIt, Show															; TrayIt Menu

#^c:: clipboardBuffer(True)
#^v:: clipboardBuffer()
!^v:: sendraw % Clipboard

#if Explorer_getActiveWindow()													; Move Files to Common Folder
 #n:: moveFilesToCommonFolder(strSplit(getSelectedText({path:True}),"`n","`r"))
#^x:: unZipAndDeleteFromExplorer(Explorer_getActiveWindow())					; Unzip open Zip file and delete it
#if


#F7:: Media_Play_Pause 															; Media buttons
#F6:: Media_Prev
#F5:: Media_Next

#if !getKeyState("NumLock","T")
NumpadEnter:: Media_Play_Pause
NumpadAdd:: toggleVolume(.3, A_ThisHotkey)										; Temporarily reduce Volume
#if

~RAlt & RCtrl::
~RCtrl & RAlt::
	;toggleVolume(.5, strSplit(A_ThisHotkey," ")[3])
	highlightMouse()															; Highlight Mouse
return

/*
#Media_Play_Pause::																; Global controls for Music player
	activateProgram(PRG_RS_MusicPlayer)
return

#if ProcessExist(PRG_RS_MusicPlayer.process)
 #F9::  Media_Prev
#F11:: Media_Next
; MusicBee sometimes doesn't respond to Media buttons.
; So I set it's global hotkey to #{F9/10/11}
Media_Prev::       send #{F9}
Media_Play_Pause:: send #{F10}
Media_Next::       send #{F11}
#if
*/

;+^Space:: YouTubePlayPause()													; Play/Pause Youtube
return

;=================== Script Functions - Tray/Pause/Reload/Exit
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
