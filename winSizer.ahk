class winSizer {
    __new(){
        this.action:=objBindmethod(this,"run"), act:=this.action, this.running:=False
        , this.toastObj:=new toast({life:0,margin:{x:1,y:1}, title:{size:10}, message:{def_size:8,offset:[4],def_offset:1}})
        setTimer, % act, 100 ;, 10
        setTimer, % act, Off
    }

    start(endOnKeyRelease:="", force:=False){
        if (!force && this.running)
            return false
        this.endOnKeyRelease:=endOnKeyRelease
        MouseGetPos, mx, my, Win
        WinGetClass, winclass, ahk_id %win%
        if (winclass="WorkerW" OR winclass="Shell_TrayWnd" OR !winexist("ahk_id " win))
            return false
        WinGetPos, wx, wy, w, h, ahk_id %win%
        ; Winget, isMax, MinMax, % win    ; Can't be minimized
        this.win:=win, this.mx:=mx, this.my:=my, this.wx:=wx, this.wy:=wy, this.ww:=w, this.wh:=h
        , this.mode:={ x:3*(mx-wx)//w -1 , y:3*(my-wy)//h -1} ;, this.isMax:=isMax
        ; | -1-1 dw dh dx dy |  0-1    dh dy    | +1-1 dw dh    dy |
        ; | -1 0 dw    dx    |  0 0       dx dy | +1 0 dw          |
        ; | -1+1 dw dh dx    |  0+1    dh       | +1+1 dw dh       |
        act:=this.action
        setTimer, % act, On
        ; this.show(mx,my,wx,wy,w,h)
        return true
    }
    
    end(){
        r:=this.running
        if r {
            this.toastObj.close()
            act:=this.action
            setTimer, % act, Off
            this.running:=False
        }
        return r
    }
    
    run(){
        MouseGetPos, x, y
        mode:=this.mode, dx0:=x-this.mx, dy0:=y-this.my, win:= "ahk_id " this.win

        if ( this.running OR abs(dx0)>64 OR abs(dy0)>64 OR getKeyState("Shift","P") ) {
            this.running:=True, dx:=0, dy:=0

            if (mode.x<0) OR (!mode.x and !mode.y)
                dx:=dx0
            if (mode.y<0) OR (!mode.x and !mode.y)
                dy:=dy0
            WinRestore, % win ;Fixes problem of window being detected as maximized, but causes a slight flickering
            WinMove, % win,, % this.wx+dx, % this.wy+dy, % this.ww+dx0*mode.x, % this.wh+dy0*mode.y
            WinSet, Redraw,, % win

            WinGetPos, wx, wy, w, h, % win
            e:= (mode.x OR mode.y)? "Resize " (!mode.x?"|":!mode.y?"--":mode.x*mode.y>0?"\":"/") : "Move"
            this.show(x,y,wx,wy,w,h,e)
        }
        if (this.endOnKeyRelease AND !GetKeyState(this.endOnKeyRelease,"P"))
            return this.end()
        return
    }

    show(mx,my,wx,wy,ww,wh,extra:=""){
        static pad:="    ", mxOld:=-100, myOld:=-100

        if (abs(mxOld-mx)<4) AND (abs(myOld-my)<4) ;Minimize flickering
            return
        mxOld:=mx, myOld:=my

        return this.toastObj.show({title:{text:extra}, pos:{x:mx,y:my}
            ,message:{text:["Mouse : (" substr(pad mx,-4) "," substr(pad my,-4) ")"
                ,"Window:(" substr(pad wx,-4) "," substr(pad wy,-4) ") " substr(pad ww,-4) " x" substr(pad wh,-4) ]} })
    }
}