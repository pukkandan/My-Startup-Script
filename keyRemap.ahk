;===================    WinSizer
RETURN
#if getKeyState("RButton","P")
MButton::
isPressed("RButton")
winSizer.start("RButton")
return
MButton Up::
isPressed("RButton")
if !winSizer.end()
    send, #{Tab}
return
#if

;===================    TaskView
RETURN
#if getKeyState("MButton","P")                      ; Move window b/w desktops
WheelUp::
WheelDown::
(A_ThisHotkey="WheelUp")? taskView.MoveToDesktopPrev(WinExist("A"),True): taskView.MoveToDesktopNext(WinExist("A"),False)
sleep 200
return

#if getKeyState("RButton","P")                            ; Switch Windows
WheelUp::
WheelDown::
isPressed("RButton")
if (A_ThisHotkey="WheelUp") {
    ; if (taskView.GetCurrentDesktopNumber()=1)  ;Wrap
    ;     taskView.GoToDesktopNumber(0)
    send % "#^{Left}"
} else {
    ; if (taskView.GetCurrentDesktopNumber()=taskView.GetDesktopCount())
    ;     taskView.GoToDesktopNumber(1)
    send % "#^{Right}"
}
sleep 200
return

#IfWinNotActive, ahk_group right_drag
*RButton up::
Critical
; tooltip, % """" rbutton_pressed_as_modifier """" A_PriorHotkey
if !isPressed("RButton",False)
    send, {Blind}{RButton}
else if A_PriorHotkey not in MButton,MButton Up,WheelUp,WheelDown
    send, {Blind}{RButton}
return
#IfWinNotActive

isPressed(key,check:=True){
    /*
    Checks if the key is pressed and stores that info
     */
    static pressed:={}
    if check
        pressed[key]:=getkeystate(key,"P")
    return pressed.haskey(key)?pressed[key]:False
}
wasPressed(key){
    return isPressed(key,False)
}

;===================    Over Taskbar
RETURN
#if isOver_mouse("ahk_class Shell_TrayWnd")   ; Alt tab over taskbar
WheelUp::
WheelDown::
send % A_ThisHotkey="WheelUp" ? "^+!{Tab}" : "^!{Tab}"
return
MButton Up:: Send +^{Esc}    ; Task manager

#if winActive("ahk_class MultitaskingViewFrame") AND isOver_mouse("ahk_class Shell_TrayWnd")        ; When Task Switching
LButton::send, {Enter}
#if

;===================    Ditto & Listary
RETURN
XButton2::
; Tooltip("Ditto")
Keywait, %A_ThisHotkey%, T0.5
; ToolTip
if !ErrorLevel {
    Process, Exist, Ditto.exe
    if ErrorLevel {
        Toast.show("Ditto")
        Send, ^``
    }
    else {
        Toast.show("Starting Ditto . . .")
        Run, D:\Program Files\Ditto\Ditto.exe
    }
} else {
    !Space:: runListary()
}
return
runListary(){
    Toast.show("Listary")
    text:=getSelectedText()
    text:=text?text:Clipboard
    text:=RegExReplace(RegExReplace(text, "[`t`n]| +"," "), "^ | $|`r")
    text:=strlen(text)<100?text:""
    Process, Exist, Listary.exe
    if !ErrorLevel {
        Run, D:\Program Files\Listary\Listary.exe
        DetectHiddenWindows, On
        Winwait, ahk_exe Listary.exe,, 2
        if ErrorLevel
            return
    }
    send, ^#``
    DetectHiddenWindows, Off
    Winwait, ahk_exe Listary.exe,,2
    if ErrorLevel
        return
    sleep, 10
    ; pasteText(text, "ahk_exe Listary.exe")
    sendRaw,% text
    send, ^a
    return
}
return
;===================    winAction & RunText
RETURN
XButton1::
; Tooltip("winAction")
Keywait, %A_ThisHotkey%, T0.25
Tooltip
if !ErrorLevel {
    #w:: winAction.show()
} else {
    !`:: runTextObj.showGUI()
}
return

;===================    Tray Menu
RETURN
^#t::
updateTray(0,A_ScreenHeight-200)
sleep, 300
Menu, Tray, Show
return
;===================    Invert F1
RETURN
#F1::Send, {F1}
return
;===================    Open Potplayer
RETURN
#v::Run, D:\Program Files\Potplayer\PotplayerMini64.exe %Clipboard%
return

;===================    Open MusicBee
RETURN
#F10::
DetectHiddenWindows, On
if !winExist("ahk_exe MusicBee.exe") {
    Toast.show("Starting MusicBee")
    Run, D:\Program Files\MusicBee\MusicBee.exe
    WinWait, ahk_exe MusicBee.exe
    Sleep, 1000
}
Toast.show("Play/Pause")
Send, {Media_Play_Pause}
return

;===================    Listary launcher
; RETURN
; ~LWin & RWin::Return    ;Prevents LWin from trigerring when #... (eg: #Tab) is used
; LWin UP:: Send, #``
; return

;===================    Toggglekeys and CaseMenu
RETURN
CapsLock::
keywait, Capslock, T0.2
if (ErrorLevel){
    ^CapsLock::
    caseMenu.show()
    return
}
SetCapsLockState, % GetKeyState("Capslock","T")?"Off":"On"
~NumLock::
~ScrollLock::
~Insert::
  Toast.show( strReplace(A_ThisHotkey,"~") (GetKeyState(strReplace(A_ThisHotkey,"~"),"T")? " On":" Off") )
return

;===================    NetNotify
RETURN
#n:: netNotify(False,,1000)

;===================    DimScreen
RETURN
#F2:: dimScreen(+25)
#F3:: dimScreen(-25)

;===================    Play/Pause Youtube
/*
RETURN
+^Space::
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
*/

RETURN
;===================    Notepad
#CapsLock:: Run notepad.exe
#^CapsLock:: Run calc1.exe