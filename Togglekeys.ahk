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

    caseChange(type){ ; type: U=UPPER, L=Lower, T=Title, S=Sentence, I=Invert
        text:=caseChange(getSelectedText(), type)
        oldClip:=ClipboardAll
        clipboard:=text
        Send ^v
        sleep 100
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