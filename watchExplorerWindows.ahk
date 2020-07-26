class watchExplorerWindows {
    _module_init(args*){
        this.__new(args*)
		this._module_runTimerAtStart:=True
        this._module_timerFn:=ObjbindMethod(this, "run")
    }
	__new(file:="explorerWindows", firstRun:=True){
		this.file:=file
		this.firstRun:=firstRun
		this.currentWins:={}
		if !firstRun
			this._bindExit()
	}

	run() {
		if this.firstRun
			return this._firstRecover()
		else if this.recoverRunning
			return
		;tooltip("run", {no:5})
		lastCount:=this.currentWinCount
		this.update()
		if !this.writeWinsToFile(false, false) && lastCount>1 && this._recoverAsk()
			this.recover(false, false)
	}

	update() {
		;tooltip("update", {no:5})
		this.currentWinCount:=0
		this.currentWins:={}
		for _,win in Explorer_GetAllWindowsInfo() {
			;msgbox % win.path
			if !this.currentWins[win.path]
				this.currentWins[win.path]:=[]
			this.currentWins[win.path].push({hwnd:win.hwnd, desk:win.desktop})
			this.currentWinCount++
		}
		return
	}

	_recoverAsk(qn:="Recover explorer windows?") {
		;tooltip("_recoverAsk", {no:5})
		ret:=False
		msgbox, 4, Explorer Watcher, % qn
		IfMsgBox, Yes
			ret:=True
		return ret
	}

	_firstRecover() {
		hw:=A_DetectHiddenWindows
		DetectHiddenWindows, On
		WinWait, ahk_group WG_Explorer,, 10
		;msgbox % errorlevel
		DetectHiddenWindows, % hw

		this.recover(, False)
		this.firstRun:=False
		this._bindExit()
	}

	_bindExit(){
		return
		OnExit(objBindMethod(this, "writeWinsToFile", True, False))
	}

	recover(args*) {
		this.recoverRunning:=True
		tooltip("Recovering Explorer Windows...", {no:4})
    	;Toast.show("Recover Explorer")

		ret:=this._recover(args*)
		while !ret
			ret:=this._recover(True, False)
		this.writeWinsToFile(True, True)
		
		tooltip("", {no:4})
		this.recoverRunning:=False
	}
	_recover(update:=True, ask:=True) {
		if (update) 
			this.update()
		wins:= this.getWinsFromFile()
		
		opened:=False
		for path,deskList in wins.clone() {
			if !path
				continue
			diff:= deskList.length() - (this.currentWins[path]? this.currentWins[path].length() :0)
			;msgbox %path%`n%diff%
			if (ask && diff>0) {
				if !this._recoverAsk()
					return True
				else
					ask:=False
			}
			if diff>0
				method:= (subStr(path,1,7)=="shell::" || this.currentWins[path].length())? "explorer.exe" :"explore"
			; explore cant open duplicates and some special windows
			; but explorer.exe opens new process everytime. So this is a compromise
			
			try {
				loop % diff {
					RunWait, %method% "%path%",, Max
					opened:=True
					sleep 1000
				}
			} catch
				wins.delete(path)
			;msgbox % path " " wins.hasKey(path)
		}
		if (opened) {
			sleep 1000
			this.update()
		}

		for path,deskList in wins {
			if !this.currentWins[path]
				return !this._recoverAsk("Failed to open window at:`n" path "`n`nRetry?")

			toMove:=this.currentWins[path].clone()
			moveTo:=[]
			for _,n in desklist {
				found:=False
				for i,m in toMove {
					if (n==m.desk) {
						toMove.removeAt(i)
						found:=True
						break
					}
				}
				if !found
					moveTo.push(n)
			}

			for i,w in toMove {
				if i==1 && ask && !this._recoverAsk("Place explorer windows into correct Desktops?")
					return True
				if !this.currentWins[path]
					return !this._recoverAsk("Window not found!`nRetry?")
				;msgbox % "Moving " path " (" w.hwnd ") to " moveTo[i]
				TaskView.MoveWindowToDesktopNumber(moveTo[i], w.hwnd)
			}
		}
		return True
	}

	writeWinsToFile(update:=True, force:=True) {
		if !force && this.recoverRunning
			return -1
		;tooltip("writeWinsToFile", {no:5})
		if (update) 
			this.update()
		out:=""
		for path,winArr in this.currentWins {
			if !path
				continue
			if subStr(path,1,7)!="shell::"
				hasFolders:=True
			out.= path "`t" str_fromArr(winArr, ",", "desk") "`n"
		}
		if !force && !hasFolders
			return False
		FileMove, % this.file , % this.file ".old" , 1
		fileDelete, % this.file
		fileAppend, % out, % this.file
		return True
	}
	getWinsFromFile() {
		;tooltip("getWinsFromFile", {no:5})
		wins:={}
		Loop, Read, % this.file
		{
			obj:=StrSplit(A_LoopReadLine, "`t", " ", 2)
			if !(obj[1] && obj[2])
				continue
			wins[obj[1]]:= strSplit(obj[2],",", " ")
		}
		return wins
	}

}