miscRespond(){
    ; Restart processes when dead
    process_watchdog(PRG_RS_GPG_Agent)
    process_watchdog({process: "eartrumpet.exe", name: "EarTrumpet"})

    ; ==========================================================================
    ; Move Control Center to left
    if winActive("ahk_group WG_TrayMenu") ; NB: WinExist/WinMove does not work for these windows without ID
        WinMove % winactive("Control Center")? -10: 54

    ; ==========================================================================
    ; Close image viewer when out of focus
    /*
    win:=winExist("ahk_group WG_ImageViewer")
    if win && !winActive("ahk_id " win) {
        WinGetPos,, y,, h
        if (y==0 && h==A_ScreenHeight)
            winclose
    }
    */

    ; ==========================================================================
    ; Do not mute when 0 volume
    if !VA_GetMasterVolume()
        VA_SetMasterMute(false)

    ; ==========================================================================
    ; Close unwanted popups
	IfWinExist, (UNREGISTERED) ahk_group WG_Sublime
    {
		WinGetTitle, t
		WinSetTitle % StrReplace(t, " (UNREGISTERED)")
	}

    while winExist("ahk_group WG_unwantedEsc") {
        winactivate
        send, {esc}
    }

    winHide ahk_group WG_unwantedHide
    winClose ahk_group WG_unwantedClose
    winClose ahk_group WG_unwantedCloseRegex

    DetectHiddenWindows On
    winClose ahk_group WG_unwantedClose
    SetTitleMatchMode Regex
    winClose ahk_group WG_unwantedCloseRegex

    return
}

process_watchdog(spec) {
	if !processExist(spec.process)
		activateProgram(spec)
}
