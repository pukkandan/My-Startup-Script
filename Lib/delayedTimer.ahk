class delayedTimer {
    set(f0,t0,runatStart:=False){
        if !isObject(this.obj)
            this.obj:=[]
        return this.obj.push({f:f0,t:t0,r:runatStart})
    }
    start(){
        for _,timer in this.obj {
            f:=timer.f
            setTimer, % f, % timer.t
        }
        for _,timer in this.obj
            if timer.r
                %f%()
        return this.reset()
    }
    reset(){
        this.obj:=[]
        return 0
    }
}