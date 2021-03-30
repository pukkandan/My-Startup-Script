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
	gotoPath:= 
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

runOrSend(title, key, path, paste:=False, sendAfter:=""){
	;msgbox %title%`n%key%`n%path%`n%paste%`n%sendAfter%
	exe:=path(path).file
	win:="ahk_exe " exe

	if (paste) {
		text:=subStr(getSelectedText({clean:True}), 1, 300)
	}

	if !processExist(exe) {
		Toast.show("Starting " title " . . .")
		ShellRun(path)
		DetectHiddenWindows, On
		Winwait, % win ,, 5
		;if ErrorLevel
		;    return
	}

	Toast.show(title)
	if !winExist(win)
		send % key

	DetectHiddenWindows, Off
	Winwait, % win ,, 2
	if ErrorLevel
		return
	sleep, 100
	WinActivate, % win
	if (paste) {
		send, ^a
		pasteText(text)
	}
	if (sendAfter)
		send, % sendAfter
	return
}

runLauncher(toggle:=True, getText:=False){
	static tooltipOff:=Func("_runLauncher_tooltipOff")
	if getText
		text:=keepSelectedText()

	if WinActive("ahk_group WG_Launcher") {
		send {Esc}
		if toggle
			return
	}
	PRG_RS_Launcher[5]:=getText? "{BackSpace}" :""
	runOrSend(PRG_RS_Launcher*)

	if !getText
		return
	WinWaitActive, ahk_group WG_Launcher,, 2
	sleep 100
	tooltip(!text? "Nothing Selected": "Press SPACE/TAB to paste :`n" subStr(text, 1, 150)
		, {no:3, y:(text?-50:-25), x:0, mode:"Window"}  )
	setTimer, % tooltipOff, 1000
	setTimer, % tooltipOff, On
	return
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
	InputBox, param, SHH, parameters?,,, 128,,,,,-CX 14173002@10.2.60.11
	ShellRun("ssh.exe",param,,,"RunAs")
	return
}

cmdInCurrentFolder(wsl:=False, admin:=True) { ;as admin 
	path:=Explorer_getWindowPath(Explorer_getLastWindow())
	tooltip((wsl?"wsl """:"cmd """) path """")
	ShellRun(A_COMSPEC, (path? "/k cd /d " path :"") (wsl&&path? " && " :"") (wsl? "wsl.exe" :""),, admin?"RunAs":"")
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

activateVideoPlayer() {
	win:=WinExist("ahk_group WG_VideoPlayer")
	if (!win) {
		DetectHiddenWindows, On
		win:=WinExist("ahk_group WG_VideoPlayer")
		;DetectHiddenWindows, Off
	}
	if win
		WinActivate, ahk_id %win%
	else
		ShellRun(PRG_VideoPlayer) ;, Clipboard)
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
			Send, % PRG_RS_VideoPlayer[2] ; Set it to play/pause in potplayer. Media_Play_Pause doesnt work if it is set as global
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
	SoundGet, currentvol
	if (vol<1)
		vol*=currentVol
	sleep % t0
	_toggleVolume_setVol(vol, currentVol, t1, key, True)
	
	KeyWait, % key
	SoundGet, vol
	_toggleVolume_setVol(currentVol, vol, t2, key, False)

	SoundSet % currentVol
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
			SoundSet % now
			tooltip("Volume = " floor(now), {no:5})
		}
	}
	return

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