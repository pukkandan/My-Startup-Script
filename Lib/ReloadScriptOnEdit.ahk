class ReloadScriptOnEdit {
	__module_init(args*){
		this.__new(args*)

		this.__module := {	runTimerAtStart: True
						  , timerFn: ObjBindMethod(this, "run")
						  , suspendOnFullScreen: True
						  , fullScreenExceptions: []
						  , onFullScreen: False
						  , onWindowed: False 						}
	}
	__new(files:="", option:="RF") { ;option can be a combination of DFR
		if !files
			files:=["*"]
		this.files := files
		this.option:= option

		this.neverCleaned:=True
	}

	_ask(file) {
		static title, text
		if !title {
			title := SCR_Name " - Reload this script?"
			text  := "A file related to the script " SCR_Name " has changed.`nScript file:`n" A_ScriptFullPath "`n`nChanged file:`n"
		}

		if file {
			MsgBox, 0x24, % title, % text file
			IfMsgBox, Yes
				return true
		}
		return False
	}

	run() {
		if this.neverCleaned
			return this.clean()
		for _,f in this.files
			if changed:=this.check(f)
				break
		if this._ask(changed)
			Reload
		else this.clean()
	}

	check(filePatt) {
		Loop, Files, % filePatt, % this.option
			if inStr(A_LoopFileAttrib,"A") && !inStr(A_LoopFileAttrib,"H") && !inStr(A_LoopFileAttrib,"S")
				return A_LoopFileLongPath
		return False
	}

	clean() {
		this.neverCleaned:=False
		for _,f in this.files
			Loop, Files, % f, % this.option
				if !inStr(A_LoopFileAttrib,"H") && !inStr(A_LoopFileAttrib,"S")
					FileSetAttrib, -A, % A_LoopFileLongPath, % inStr(option,"D")?(inStr(option,"F")?2:1):0, % InStr(option,"R")?1:0
	}

}
