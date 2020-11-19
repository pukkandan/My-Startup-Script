class delayedTimer {
    set(f0,t0,runatStart:=False){
        if !isObject(this.obj)
            this.obj:=[]
        return this.obj.push({f:f0, t:t0, r:runatStart})
    }
    start(runNow:=False){
        for _,item in this.obj {
            if !item.t
                continue
            f:=item.f
            setTimer, % f, % item.t
        }
        if runNow
            this.firstRun()
    }
    firstRun() {
        this.running:=True
        f:=ObjBindMethod(this,"_firstRun")
        setTimer, % f, -100
    }
    _firstRun(){
        for _,item in this.obj
            if item.r
                item.f.call()
        this.running:=False
        return this.reset()
    }
    reset(){
        return this.obj:=[]
    }
}