class delayedTimer {
    set(f0,t0,runatStart:=False){
        if !isObject(this.obj)
            this.obj:=[]
        return this.obj.push({f:f0,t:t0,r:runatStart})
    }
    start(r:=False){
        for _,item in this.obj {
            if !item.t
                continue
            f:=item.f
            setTimer, % f, % item.t
        }
        if r {
            f:=ObjBindMethod(this,"firstRun")
            setTimer, % f, -100
        }
        return
    }
    firstRun(){
        for _,item in this.obj {
            if item.r {
                f:=item.f
                %f%()
            }
        }
        return this.reset()
    }
    reset(){
        return this.obj:=[]
    }
}