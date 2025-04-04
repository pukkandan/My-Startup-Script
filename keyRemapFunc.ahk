listOpenFolders(){
	winCurrent:="ahk_id " winExist("A")
	;ControlGetFocus, ctrlCurrent, ahk_id %winCurrent%
	pathList:={}

	Menu, listOpenFolders, Add
	Menu, listOpenFolders, DeleteAll

	i:=0
	for _,win in Explorer_GetAllWindows() {
		path:=Explorer_GetWindowPath(win, true)
		if !path || pathList.hasKey(path)
			continue
		pathList[path]:=True
		;msgbox % pathList.hasKey(path) "`n" pathList[path] "`n" path

		act:=func("listOpenFolders_pastePath").bind(path "\", winCurrent) ;, ctrlCurrent)
		Menu, listOpenFolders, Add, % (i>9?"":"&") (i==10?"1&0":i) " " path, % act
		i++
	}
	if !i
		Toast.show("No Folders Open")
	Menu, listOpenFolders, Show
	return
}

listOpenFolders_pastePath(path, win){
	if getKeyState("LCtrl", "P") ; Copy to clipboard, dont paste
		return Clipboard:=path

	winGetClass, c, % win
	opts:={waitWin: win}
	if (c="#32770" or c="CabinetWClass") ; In explorer window or filepicker
		opts.win:=win, opts.cntrl:="Edit1"
	pasteText(path, opts)
	if opts.cntrl
		controlSend % opts.cntrl, {Return}, % opts.win
}

;=============================================

moveFilesToCommonFolder(list){
	Toast.show({title:{text:"Move to Folder"}, life:100})

	n:=list.length()
	if !n
		return 1
	else if (n==1)
		folder:=path(list[1]).dir
	else
		folder:=regexReplace(str_CommonPart(list), "[^\\a-zA-Z0-9]+$")

	if (subStr(folder,0)=="\") {
		path:=substr(folder,1,-1), folder:=""
	} else {
		pathObj:=path(folder)
		path:=pathObj.dir, folder:=pathObj.file
	}

	text:=str_splitIntoLines(path "\", 50)
	InputBox, folder, Move %n% files into:, % text ,, , % 100+25*str_countLines(text) ,,,,, % folder
	if ErrorLevel
		return 2

	folder:=path "\" folder
	FileCreateDir % folder
	for _,file in list {
		fileName:=path(file).file
		if instr(FileExist(file), "D") {
			FileMoveDir, % file, % folder "\" fileName
		} else {
			FileMove, % file, % folder "\" fileName, false
		}
	}
	return 0
}

;=============================================

runLauncher(toggle:=True, getText:=False){
	static tooltipOff:=Func("_runLauncher_tooltipOff")
	if getText
		text:=keepSelectedText()

	if WinActive("ahk_group WG_Launcher") {
		send {Esc}
		if toggle
			return
	}
	activateProgram(PRG_RS_Launcher, {send: getText? "{BackSpace}" :""})

	if !getText
		return
	WinWaitActive, ahk_group WG_Launcher,, 2
	sleep 100
	tooltip(!text? "Nothing Selected": "Press SPACE/TAB to paste :`n" subStr(text, 1, 150)
			, {no:3, y:(text?-50:-25), x:0, mode:"Window"}  )
	setTimer, % tooltipOff, 1000
	setTimer, % tooltipOff, On
	if text {
		pasteText(text)
		send ^a
	}
}
pasteInLauncher(again:=True){
	if keepSelectedText(False, again)
		tooltip("Press TAB to paste :`n" subStr(keepSelectedText(""), 1, 150), {no:3, y:-50, x:0, mode:"Window"})
}
_runLauncher_tooltipOff(force:=False){
		if !force && WinActive("ahk_group WG_Launcher")
			return
		tooltip(,{no:3})
		keepSelectedText(-1)
		return
}

keepSelectedText(new:=True, again:=True){ ; new = -1 to delete text, "" to return text without doing anything
	static text:="", pasted:=False
	;tooltip % text
	if (new=="")
		return text
	else if (new==-1)
		text:=""
	else if new {
		pasted:=False
		text:=subStr(getSelectedText({clean:True, clip:True, path:False}), 1, 300)
	} else if text {
		if !again && pasted
			return False
		pasted:=True
		pasteText(text)
	}
	return text
}

;=============================================

processExist(p){ ;This function is available natively in v2
	Process exist, % p
	return ErrorLevel
}

;=============================================

runSSH(){
	InputBox, param, SHH, parameters?,,, 128,,,,,-CX%A_Space%
	if !ErrorLevel
		ShellRun("ssh.exe", param,,, "RunAs")
	return
}

; [Deprecated]
cmdInCurrentFolder(exe:="wt", args:="", admin:=False) {
	path:=Explorer_getWindowPath(Explorer_getLastWindow())
	if (!path)
		path := "D:\Trash"
	tooltip(exe (admin?"* ":" ") args " : " path)
	ShellRun(exe, args, path, admin?"RunAs":"")
	sleep 1000
	tooltip()
}

;=============================================

makeMicroWindow(){
	hwnd:=WinExist("A")
	win:="ahk_id " hwnd
	WinGetClass, winclass, % this.win
	if (winclass="WorkerW" OR winclass="Shell_TrayWnd" OR !winexist(win))
		Toast.show("No Window")
	else {
		new microWindow(hwnd)
		Toast.show("microWindow")
	}
	return
}

;=============================================

playAllVideoPlayers(){
	;DetectHiddenWindows, off
	active:=winExist("A")
	WinGet, l, list, ahk_group WG_VideoPlayer
	loop %l%
	{
		w:="ahk_id " l%A_Index%
		WinGet, m, MinMax, % w
		;msgbox %w%`n%m%
		if (m!=-1) {
			winActivate % w
			Send, % PRG_RS_VideoPlayer.play ; Set it to play/pause in potplayer. Media_Play_Pause doesnt work if it is set as global
			sleep 10 ; Sleep makes the different players drift out of sync slowly, but the send becomes much more reliable
		}
	}
	sleep 10
	winActivate, ahk_id %active%
	return
}

;=============================================

YouTubePlayPause(){ ;Using https://www.streamkeys.com/ is way better
	Thread, NoTimers
	wid:=WinExist(" - YouTube ahk_group WG_Browser")
	if !wid
		return
	ControlGet, cid, Hwnd,,Chrome_RenderWidgetHostHWND1, ahk_id %wid%
	if !cid
		return
	IfWinNotActive, ahk_group WG_Browser
	{
		ControlFocus,,ahk_id %cid%
		ControlSend,, k , ahk_id %cid%
	} else {
		WinGet, wid, id, A
		ControlGetFocus, cid_old, ahk_id %wid%
		ControlGet, cid_old, Hwnd,, %cid_old%, ahk_id %wid%
		ControlFocus,,ahk_id %cid%
		send, k
		sleep, 100
		ControlFocus,,ahk_id %cid_old%
	}
	return
}

;=============================================

prefixUsed(key, set:=True) { ;-1 to keep it unchanged
	static prefix:={}
	if !inStr("|Win|CapsLock|RButton|MButton|", "|" key "|")  ; Sanity check
		msgbox prefixUsed: Invalid key %key%

	ret:=prefix[key]
	if (set>-1)
		prefix[key]:=set

	return ret ; returns previous value
}

sendPrefixKey(key) {
	if !prefixUsed(key, False)
		send {%key%}
}

winUpWhenCapsReleased() {
	if GetKeyState("CapsLock", "P")
		return

	SetTimer,, Off
	send {LWin Up}
	prefixUsed("CapsLock_Num", False)
}

;=============================================

toggleVolume(vol, key, t0:=0, t1:=200, t2:=500) {
	currentvol:=VA_GetMasterVolume(1)
	if (vol<1)
		vol*=currentVol
	sleep % t0
	_toggleVolume_setVol(vol, currentVol, t1, key, True)

	KeyWait, % key
	vol:=VA_GetMasterVolume(1)
	_toggleVolume_setVol(currentVol, vol, t2, key, False)

	changeVolume(currentVol, True)
	Tooltip("",{no:5})
}

_toggleVolume_setVol(to, from, t, key, cndn){
	if t {
		diff:=to-from, wait:=max(50, t/abs(diff)), step:=diff*wait/t
		loop % t/wait {
			sleep % wait
			if (getKeyState(key,"P")!=cndn)
				break
			now:=from + step*A_Index
			changeVolume(now, True)
			tooltip("Volume = " floor(now), {no:5})
		}
	}
	return

}

changeVolume(diff, absolute:=False, tip:=True, fast:=True){ ; Force balance
	static lastToast
	static self:={}
	if (fast && diff && !absolute) {
		send % "{Volume_" (diff>0? "Up":"Down") " " abs(diff) "}"
		if !self[tip]
			self[tip]:= func("changeVolume").bind(0, False, tip)
		obj:=self[tip]
		setTimer % obj, -1000
		return
	}
	bal:=changeVolumeBalance()
	vol:= round(absolute?diff: VA_GetMasterVolume(1)+diff)
	VA_SetMasterVolume(vol, 1)
	VA_SetMasterVolume(vol*bal, 2)
	if tip {
		tip:="Volume = " round(VA_GetMasterVolume(1)) (bal==1?"": ", " round(VA_GetMasterVolume(2)) " (" round(bal, 1) ")")
		(currentToast:=new Toast()).show(tip)
		lastToast.close(), lastToast:=currentToast
	}
}

changeVolumeBalance(diff:=0, absolute:=False, args*){
	static bal:=1
	if !diff
		return bal
	bal:= absolute?diff: bal+diff
	changeVolume(0, False, args*)
	return bal
}

;=============================================

clipboardBuffer(get:=False) {
	static buffer:=[], len:=0, pos:=0, tt:={no:6, life:500}
	if get {
		x:=getSelectedText({keep:True, path:True}), buffer:=[]
		loop parse, x, `n, `r
			if (A_LoopField!="")
				buffer.push(A_LoopField)
		len:=buffer.length(), pos:=0
		if len
			tooltip("Copied " len " items", tt)
		else
			tooltip("No item copied", tt)
	} else {
		/*
		while (buffer[1]=="") {
			buffer.removeAt(1)
			if (++pos>len)
				break
		}
		*/
		if (!len or ++pos>len)
			return tooltip("No item in buffer", tt)
		tooltip("Paste " pos "/" len "`n" subStr(_getSelectedText_process(buffer[1], {clean:True, path:True}), 1, 500), tt)
		pasteText(buffer[1], {keep:true})
		buffer.RemoveAt(1)
	}
}

;=============================================

unZipAndDeleteFromExplorer(win){
	static tt:={no:7, life:500}
	if !win
		return tooltip("Not in explorer", tt)

	zip:=Explorer_getWindowPath(win), pathObj:=path(zip)
	if (pathObj.ext != "zip")
		return tooltip("Not a ZIP file`n" zip, tt)
	dir:=pathObj.dir "\" pathObj.name
	if fileExist(dir)
		return tooltip("Folder exists`n" dir)
	FileCreateDir % dir
	listOpenFolders_pastePath(dir, "ahk_id " win)

	Toast.show({title:{text:"Extracting"}, life:0})
	zip_unzip(zip, dir)
	Toast.close()
	FileRecycle % zip
}

;=============================================

fastScroll(key, timeout:=100, max:=5) {
	static counter:=1
	if (A_TimeSincePriorHotkey>timeout || A_ThisHotkey!=A_PriorHotkey) {
		counter:=1
		return
	}

	speed := Min(++counter, max) - 1

	Tooltip("Scroll: " speed+1, {life: 300})
	if (speed)
		Send {%key% %speed%}
}

;=============================================

highlightMouse() {
	static SIZE:=50, TIME:=300, DELAY:=30
	static FRAMES:=TIME//DELAY

	MouseGetPos x, y
	Gui Circle:+ToolWindow -Caption +AlwaysOnTop +Hwndhwnd
	Gui Circle:Show, % "NA x" x " y" y " w1 h1" ; Hide flicker
	Gui Circle:Color, FFFF00

	Loop % FRAMES {
		Critical
		r := SIZE * (1 - (A_Index - 1)/FRAMES)
		WinSet Region, % "E 0-0 W" 2*r " H" 2*r, ahk_id %hwnd%
		Gui Circle:Show, % "NA x" x-r " y" y-r " w" 2*r " h" 2*r

		Sleep % DELAY
		MouseGetPos x, y
	}
	Critical Off
	Gui Circle:Destroy
	keyWait RAlt
}
