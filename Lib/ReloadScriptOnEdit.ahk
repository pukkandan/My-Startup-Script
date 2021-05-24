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
		return
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
		return
	}

}

;====================== OLD
/*
_ScriptEdited(files, option, clean:=False){
	if (files="")
		files:=A_ScriptFullPath

	Loop, Files, % files, % option
	{
		if A_LoopFileAttrib contains H,S
			continue
		else if clean
			FileSetAttrib, -A, % A_LoopFileLongPath, % inStr(option,"D")?(inStr(option,"F")?2:1):0, % InStr(option,"R")?1:0
		else if A_LoopFileAttrib contains A
		{
			FileSetAttrib, -A, % A_LoopFileLongPath
			return A_LoopFileLongPath
		}
	}
	return False
}

ReloadScriptOnEdit(files, opt:="RF", clean:=0){	; clean=2 reloads also
	static fName
	if !fName {
		clean:=1 ;Clean on first run
		if SCR_Name
			fName:=SCR_Name
		else
			SplitPath, A_ScriptFullPath,,,, fName, ;fName = Name of file without extension
	}
	if clean {
		for _,f in files
			_ScriptEdited(f,opt,True)
		if (clean=2)
			Reload
		return False
	}

	for _,f in files
		if changed:=_ScriptEdited(f, opt) {
			MsgBox, 0x24, %fName% - Reload this script?, A file related to the script %fName% has changed.`nScript file:`n%A_ScriptFullPath%`n`nChanged file:`n%changed%
			IfMsgBox, Yes
				ReloadScriptOnEdit(files,opt,2)
			else
				ReloadScriptOnEdit(files,opt,1)
		}
	return True
}
*/
