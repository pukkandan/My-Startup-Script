/*																	NOTES
All directives(that are settings) and many commands appear here irrespective of its need
The directives/commands that are default are commented by ";;" and those that can break the script by ";~ "
=======================================================================================================================
*/

DetectHiddenWindows, Off        ;Detect Windows that are hidden? Recommended to set whenever needed
;~#CommentFlag ;				;Comment character(s)
;~#DerefChar %  				;Deref character
;~#Delimiter ,  				;Delimiter character
;~#EscapeChar `  				;Escape character
; #ErrorStdOut					;Pipes errors to stdout.
;~#Warn All					    ;Shows warnings. Use for debugging only
;;#ClipboardTimeout 1000		;Time before unresponsive clipboard timesout and gives error
;;#HotkeyInterval 2000			;Interval for #MaxHotkeysPerInterval
; #HotkeyModifierTimeout 0		;Affects the behavior of hotkey modifiers. Not needed when #UseHook is used
; #Hotstring NoMouse			;Mouse is not used to reset hotstrings
; #Hotstring EndChars `n `t		;Hotstrings are triggered by these
#Hotstring * ? B C K0			;Hotstring global settings
#InputLevel 5
SendLevel 5
#InstallKeybdHook				;Installs Keyboard hook
#InstallMouseHook				;Installs Mouse hook
#KeyHistory 100					;maximum number of keyboard and mouse events displayed by the KeyHistory window.
#IfTimeout % SCR_hookTimeOut//10 ;A timeout is implemented to prevent long-running expressions from stalling keyboard input processing. If the timeout value is exceeded, the expression continues to evaluate, but the keyboard hook continues as if the expression had already returned false.
;;#LTrim Off					;Donot left-trim Continuation sections
#MaxHotkeysPerInterval 200		;Rate of hotkey activations beyond which a warning dialog will be displayed
#MaxMem 256						;Allows variables with heavy memory usage. DO NOT FORGET TO EMPTY SUCH VARIABLES AFTER USE
#MaxThreads 255					;Allows for huge number of pseudo-threads to run simultaneously. Disable this if the script uses too much resources
;;#MaxThreadsBuffer Off			;Do not buffer hotkeys beyond its thread capacity
#MaxThreadsPerHotkey 1			;Hotkey can not be launched when it is already running
;Thread, interrupt, 100	        ;Minimum time for interupt
;;Thread, NoTimers, False		;Allows timers to intterupt threads
;;#MenuMaskKey {Ctrl}			;Mask for #!^ keys. Use another key if this causes problems
#NoEnv  						;Donot use default environmental variables. Recommended for performance and compatibility
;~#NoTrayIcon					;Hides tray icon
#Persistent 					;Keeps a script permanently running
#SingleInstance Force 			;Replaces old instance with new one
#UseHook						;For machine level hotkeys. Removes need to use $ in hotkeys
; #WinActivateForce				;Forcefully activates windows. Generally not needed
SendMode Input  				;How the script sends simulated keys. Recommended due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  	;Set script path as working directory. Ensures a consistent starting directory.
Process, Priority,, R 			;Runs Script at High process priority for best performance
SetBatchLines, -1 				;Never sleep for best performance
SetKeyDelay, 0, 0 				;Smallest possible delay
;;SetKeyDelay, 0, 0, Play		;Smallest possible delay
SetMouseDelay, 0 				;Smallest possible delay
;;SetMouseDelay, 0, Play		;Smallest possible delay
SetDefaultMouseSpeed, 0 		;Move the mouse instantly
SetWinDelay, 0 					;Smallest possible delay
SetControlDelay, 0 				;Smallest possible delay
;;AutoTrim,On					;Trim whitespaces from strings
;;StringCaseSense,Off			;Strings are not case-sensitive
SetTitleMatchMode, 2            ;A window's title can contain WinTitle anywhere inside it to be a match
BlockInput, Mouse               ;Keyboard/mouse is blocked during Click, MouseMove, MouseClick, or MouseClickDrag
CoordMode, ToolTip, Screen      ;Tooltip co-ords are specified in global co-ords
CoordMode, Pixel, Screen        ;Co-ords for image/pixelSearch are specified in global co-ords
CoordMode, Mouse, Screen        ;Mouse co-ords are specified in global co-ords
CoordMode, Caret, Screen        ;A_CaretX/Y are specified in global co-ords
CoordMode, Menu, Screen         ;Co-ords for "Menu, Show" are specified in global co-ords
