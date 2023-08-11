; This file must be in Windows 1252 or UTF-BOM encoding, because of "»"

; Script Name
global SCR_Name  := path(A_ScriptName).name        ;SCR_Name = Name of script file without extension
global SCR_AHKDir:= path(A_AHKpath).dir

;-----------------------------------------------------------------------
; Hook Timeout
global SCR_hookTimeOut
regRead, SCR_hookTimeOut, HKEY_CURRENT_USER\Control Panel\Desktop, LowLevelHooksTimeout
SCR_hookTimeOut := SCR_hookTimeOut?SCR_hookTimeOut:300

;-----------------------------------------------------------------------
; Script PID and HWND
DetectHiddenWindows, On ; Off is called in Directives.ahk
global SCR_PID  := DllCall("GetCurrentProcessId","Uint")

;========================================================================
; Programs
global PRG_CHM					:= "hh.exe"
global PRG_Clipboard			:= "Ditto.exe"
global PRG_Launcher				:= "keypirinha-x64.exe"
global PRG_MusicPlayer			:= "MusicBee.exe"
global PRG_VideoPlayer			:= "PotplayerMini64.exe"
global PRG_TextEditor			:= "subl.exe"
global PRG_Screenshot           := "ShareX.exe"
global PRG_GPG_Agent            := "gpg-agent.exe"

#include *i globals-Private.ahk ; Has personal data in this file

;-----------------------------------------------------------------------
; keyRemapFunc - RunOrSend
global PRG_RS_VideoPlayer 		:=[ "PotPlayer" 	, "+{F12}"	, PRG_VideoPlayer	                ] ;For playAllVideoPlayers()
global PRG_RS_MusicPlayer 		:=[ "MusicBee" 		, "{Media_Play_Pause}"	   , PRG_MusicPlayer	]
global PRG_RS_Clipboard 		:=[ "Ditto" 		, "^``"		, PRG_Clipboard						]
global PRG_RS_Launcher 			:=[ "Launcher"		, "!{F2}"	, PRG_Launcher , False				]
global PRG_RS_Run				:=[ "Run" 			, "!{F2}"	, PRG_Launcher , False , "{>} "		]
global PRG_RS_WindowSwitcher	:=[ "WindowSwitch" 	, "!{F2}"	, PRG_Launcher , False , "{»}{Tab}"	]
global PRG_RS_Screenshot		:=[ "ShareX" 		, "{PrintScreen}"		   , PRG_Screenshot 	]

;========================================================================
; Window Groups

;-----------------------------------------------------------------------
;Explorer
GroupAdd, WG_Explorer		, ahk_class ExploreWClass ahk_exe explorer.exe
GroupAdd, WG_Explorer		, ahk_class CabinetWClass ahk_exe explorer.exe

GroupAdd, WG_Desktop 		, ahk_class WorkerW ahk_exe explorer.exe
GroupAdd, WG_TaskBar 		, ahk_class Shell_TrayWnd ahk_exe explorer.exe

GroupAdd, WG_TaskView		, Task Switching ahk_class MultitaskingViewFrame ahk_exe explorer.exe
GroupAdd, WG_TaskView		, Task View ahk_class Windows.UI.Core.CoreWindow ahk_exe explorer.exe ; Win 10
GroupAdd, WG_TaskView		, Task Switching ahk_class XamlExplorerHostIslandWindow ahk_exe explorer.exe

;-----------------------------------------------------------------------
; keyRemap - RButton Prefixes
GroupAdd, WG_RightDrag		, ahk_exe mspaint.exe
GroupAdd, WG_RightDrag		, ahk_exe mspaint1.exe
;GroupAdd, WG_RightDrag		, ahk_group WG_Browser

;-----------------------------------------------------------------------
; HotStrings - AutoBracket
GroupAdd, WG_AutoBracket	, ahk_exe notepad.exe
GroupAdd, WG_AutoBracket	, ahk_exe mathematica.exe
GroupAdd, WG_AutoBracket	, ahk_group WG_Browser

GroupAdd, WG_NoAngularBrac	, ahk_exe Mathematica.exe

;-----------------------------------------------------------------------
; Transparent - Windows
GroupAdd, WG_Transparent  	, ahk_class CabinetWClass ahk_exe explorer.exe

GroupAdd, WG_NoTransparent	, ahk_class SysShadow
GroupAdd, WG_NoTransparent	, ahk_class Dropdown
GroupAdd, WG_NoTransparent	, ahk_class SysDragImage

;-----------------------------------------------------------------------
; keyRemap - +Enter/Space ; DEPRECATED
GroupAdd, WG_ShiftEnter		, ahk_exe mathematica.exe
;GroupAdd, WG_ShiftSpace, ; Nothing right now

;-----------------------------------------------------------------------
; Programs
GroupAdd, WG_SublimeText		, ahk_exe sublime_text.exe
GroupAdd, WG_SublimeMerge		, ahk_exe sublime_merge.exe

GroupAdd, WG_Sublime			, ahk_group WG_SublimeText
GroupAdd, WG_Sublime			, ahk_group WG_SublimeMerge

GroupAdd, WG_ImageViewer		, ahk_class Qt5QWindowIcon ahk_exe nomacs.exe

GroupAdd, WG_unwantedHide 		, ahk_class ConsoleWindowClass ahk_group WG_VideoPlayerExe

GroupAdd, WG_unwantedClose 		, This is an unregistered copy ahk_class #32770 ahk_group WG_Sublime
GroupAdd, WG_unwantedClose 		, Update Available ahk_class #32770 ahk_group WG_SublimeMerge
GroupAdd, WG_unwantedClose		, Error ahk_class #32770 ahk_exe SdDisplay.exe
GroupAdd, WG_unwantedClose		, Fences ahk_class WindowsForms10.Window.8.app.0.34f5582_r9_ad1 ahk_exe SdDisplay.exe
GroupAdd, WG_unwantedClose		, ahk_class AvIPMDialog ahk_exe ipmGui.exe
GroupAdd, WG_unwantedClose		, Internet Download Manager Registration ahk_exe IDMan.exe
GroupAdd, WG_unwantedClose		, Internet Download Manager ahk_exe IDMan.exe, Internet Download Manager has been registered with a fake Serial Number

GroupAdd, WG_unwantedEsc		, Disable developer mode extensions ahk_group WG_Browser

GroupAdd, WG_unwantedCloseRegex , ahk_class Afx:\w+:b:0000000000010003:0000000000900010:0000000000000000 ahk_group WG_VideoPlayerExe

;-----------------------------------------------------------------------
; Programs
GroupAdd, WG_VideoPlayerExe	, ahk_exe PotPlayerMini64.exe
GroupAdd, WG_VideoPlayerExe	, ahk_exe PotPlayer.exe

GroupAdd, WG_VideoPlayer	, ahk_class PotPlayer64 ahk_group WG_VideoPlayerExe

GroupAdd, WG_Browser		, ahk_exe chrome.exe
GroupAdd, WG_Browser		, ahk_exe vivaldi.exe

GroupAdd, WG_Browser_PIP	, Picture in picture ahk_group WG_Browser
GroupAdd, WG_Browser_PIP	, Picture-in-picture ahk_group WG_Browser

GroupAdd, WG_Console        , ahk_class ConsoleWindowClass
GroupAdd, WG_Console        , ahk_class CASCADIA_HOSTING_WINDOW_CLASS

GroupAdd, WG_Calc			, ahk_exe calc.exe
GroupAdd, WG_Calc			, ahk_exe calc1.exe

GroupAdd, WG_Launcher		, Keypirinha ahk_exe keypirinha-x64.exe,,, % " - "
