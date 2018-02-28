class delayedTimer {
    set(f0,t0,runatStart:=False){
        if !isObject(this.obj)
            this.obj:=[]
        return this.obj.push({f:f0,t:t0,r:runatStart})
    }
    start(){
        for _,item in this.obj {
            f:=item.f
            setTimer, % f, % item.t
        }
        for _,item in this.obj
            if item.r
                %f%()
        return this.reset()
    }
    reset(){
        this.obj:=[]
        return 0
    }
}