activateProgram(spec, overrides:=""){
	if !overrides
		overrides := {}
	for k, v in spec
		if !overrides.HasKey(k)
			overrides[k] := v
	spec := overrides

	if !spec.process {
		msgbox % "Invalid spec: " spec.name
	}

	static popup = new Toast({message: {offset: [], def_size: 10}})
	static tip := new ToolTip_Group({x: 0, y: A_ScreenHeight - 300})

	tip.show("Waiting for " spec.name)
	win:= spec.win " ahk_exe " spec.process

	if (spec.alwaysRun || !processExist(spec.process)) {
		if (spec.at_path || spec.pass_path) {
			path:=Explorer_getWindowPath(Explorer_getLastWindow())
			if (!path)
				path := "D:\Trash"
		}

		popup.show({title: {text: "Starting " spec.name}, message: {text: path? [path] :[]}})
		ShellRun( spec.run? spec.run: spec.process
				, spec.args (spec.pass_path? " " path :"")
				, path, admin?"RunAs":"", spec.visible)

		process wait, % spec.process, 5
		DetectHiddenWindows, On
		Winwait, % win ,, 5
	}

	DetectHiddenWindows, % !spec.alwaysRun && !spec.trigger
	if (spec.trigger && !winExist(win))
		send, % spec.trigger

	Winwait, % win,, 2
	if ErrorLevel
		return tip.hide()
	sleep, 100

	WinActivate, % win
	if (spec.send)
		send, % spec.send
	tip.hide()
}
