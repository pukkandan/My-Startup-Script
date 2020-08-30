class Modules {

	add(mod, timer:="", args*) {
		; timer=0 prevents initialization and
		; negative timer causes firstRun even if not defined in the class. (This is only recomended for functions)

		; mod can be function name (but not a func object), but the functionality will be severely limited
		; When a function name is given:
		; 	the function will be run when initialized if timer isnt given and
		;	the function is used in setTimer if timer is non-zero

		if !this.list
			this.list:={}
		if isObject(mod) ; Assume it is a class
			this.list[mod.__class]:={name:mod.__class, class:mod, timer:timer, args:args}
		else ; Assume it is a function NAME
			this.list[mod]:={name:mod, func:Func(mod).bind(args*), timer:timer, args:args}
			; To check b/w class and fn, check "if (this.list[name].func)"

		;msgbox % (isObject(mod)? mod.__class :"""" mod """") "`n"  timer
		return isObject(mod)? mod.__class :mod ; Return the name
	}

	initialize(opts:="") {
		this.opts:= opts? opts :{}

		for name in this.list {
			tooltip(name, {life:500})
			this._initFn(name)
			this._setTimer(name)
		}
	}
	startTimers() {
		tooltip("Starting Timers", {life:500})
		delayedTimer.start(False)
		fs:=ObjBindMethod(this,"_onFullScreen")
		setTimer, % fs, 1000 
	}
	firstRun() {
		tooltip()
		delayedTimer.firstRun()
		Toast.show("Script Loaded")
	}

	_initFn(name){
		mod:=this.list[name]
		if mod.timer!=0 {
			if mod.func {
				if !mod.timer ; If timer doesnt exist, initialize with the fn
					mod.func.call()
			} else {
				if mod.class.__module_init 
					mod.class.__module_init(mod.args*)
				else
					mod.class.__new(mod.args*)
				this.list[name].obj:= mod.class.__module? mod.class.__module :{}
			}
		}
	}
	_setTimer(name){
		mod:=this.list[name]
		;msgbox % name "`n" !!mod.obj.timerFn
		if mod.timer {
			if mod.func ; If timer is non-zero, set timer for the function
				delayedTimer.set(mod.func, abs(mod.timer), mod.timer<0)
			else if mod.obj.timerFn
				delayedTimer.set(mod.obj.timerFn, abs(mod.timer), mod.timer<0 || mod.obj.runTimerAtStart)
			this.list[name].timerRunning:=True
		}
	}

	_resumeTimer(name){
		mod:=this.list[name]
			obj:= mod.func? mod.func : mod.obj.timerFn
		if mod.timer && obj {
			SetTimer, % obj, On
			this.list[name].timerRunning:=True
		}
	}
	_stopTimer(name){
		mod:=this.list[name]
		obj:= mod.func? mod.func : mod.obj.timerFn
		if mod.timer && obj {
			SetTimer, % obj, Off
			this.list[name].timerRunning:=False
		}
	}
	toggleTimer(name){
		return this.list[name].timerRunning ? this._stopTimer(name) : this._resumeTimer(name)
	}

	_onFullScreen(){
		static lastFS:=false, lastWin
		fs:= isFullScreen(,1) && !isActiveWinInList(this.opts.fullScreenExceptions), win:=WinExist("A")
		if ( fs==lastFS && (!fs || win==lastWin) ) ; Reduce the number of times the loop below needs to run
			return
		else {
			lastFS:=fs
			lastWin:=win
		}

		for name, mod in this.list {
			if !mod.func { ; Dont do anything for functions
				if fs&&mod._fs || !fs&&!mod._fs ; Already triggered
					continue
				if fs && isActiveWinInList(mod.obj.fullScreenExceptions)
					continue
				this.list[name]._fs:=fs ; mark that the mod is in FS/Win mode
				;msgbox % name "`n" mod.class._module_onFullScreen "`n" mod._module_suspendOnFullScreen

				if fs && mod.obj.onFullScreen
					mod.obj.onFullScreen()
				else if !fs && mod.obj.onWindowed
					mod.obj.onWindowed()

				if !mod.obj.suspendOnFullScreen ; Suspend needs to be explicitly defined
					ObjBindMethod(this, fs? "_stopTimer" : "_resumeTimer", name).call()
			}
		}
	}


}