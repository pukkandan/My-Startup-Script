CapsLockOffTimer(t:=60000){
    if (A_TimeIdleKeyboard>t) AND GetKeyState("CapsLock","T") {
        SetCapsLockState,Off
        Toast.show("CapsLock Turned Off")
        return True
    }
    return False
}

class caseMenu{
    __new(){
        for _, j in [["U","&UPPER CASE"],["L","&lower case"],["T","&Title Case"],["S","&Sentence case."],["I","&iNVERT cASE"]] {
            act:=ObjBindMethod(this,"caseChange",j[1])
            Menu, caseMenu, Add, % j[2], % act
        }
        Menu, caseMenu, Add

        for _, i in ["&Capslock","&Numlock","Sc&rollLock","I&nsert"] {
            act:=ObjBindMethod(this,"toggle",strReplace(i,"&"))
            Menu, caseMenu, Add, % i, % act
        }
        return
    }
    show(){
        Toast.show("caseMenu")
        ; sleep, 500
        for _, i in ["&Capslock","&Numlock","Sc&rollLock","I&nsert"]
            Menu, caseMenu, % GetKeyState(strReplace(i,"&"),"T")?"Check":"Uncheck", % i
        Menu, caseMenu, show
        return
    }

    caseChange(type){
        text:=getSelectedText()
        static X:= ["I","AHK","AutoHotkey","Dr","Mr","Ms","Mrs","AKJ"]
                ;list of words that should not be modified for S,T
        if (type="S") { ;Sentence case.
            text := RegExReplace(RegExReplace(text, "(.*)", "$L{1}"), "(?<=[^a-zA-Z0-9_-]\s|\n).|^.", "$U{0}")
        } else if (Type="I") ;iNVERSE
         text:=RegExReplace(text, "([A-Z])|([a-z])", "$L1$U2")
        else text:=RegExReplace(text, "(.*)", "$" Type "{1}")

        if (type="S" OR type="T")
            for _, word in X ;Parse the exceptions
                text:= RegExReplace(text,"i)\b" word "\b", word)

        oldClip:=ClipboardAll
        clipboard:=text
        Send,^v
        Clipboard:=oldClip
        return
    }

    toggle(key){
        if key=Insert
            Send, {Insert}
        else if key=Capslock
            SetCapsLockState, % GetKeyState("CapsLock","T")?"Off":"On"
        else if key=Numlock
            SetNumLockState, % GetKeyState("NumLock","T")?"Off":"On"
        else if key=Scrolllock
            SetScrollLockState, % GetKeyState("ScrollLock","T")?"Off":"On"
        return
    }
}

Togglekeys_check(){
    return {c:getkeyState("Capslock","T"), n:getkeyState("Numlock","T"), s:getkeyState("ScrollLock","T"), i:getkeyState("Insert","T")}
}