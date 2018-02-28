class delayedTimer {
    set(f0,t0){
        if !isObject(this.f)
            this.f:=[], this.t:=[]
        return this.t.push(t0), this.f.push(f0)
    }
    start(){
        for i,f0 in this.f
            setTimer, % f0, % this.t[i]
        return this.reset()
    }
    reset(){
        this.f:=[], this.t:=[]
        return 0
    }
}