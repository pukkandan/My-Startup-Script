;#include <Taskview>
;TaskView.__new()

Explorer_winActive(desktop:=False) {
	w:=winActive("ahk_group WG_Explorer")
	if desktop && !w
		w:=winActive("ahk_group WG_Desktop")
	return w
}

Explorer_GetAllWindowsInfo(opt*) {
	ret:=[]
	for win in Explorer_GetAllWindowObjects(){
		;msgbox % "explorer " Explorer_GetWindowObjectPath(win)
		ret.push({ hwnd:win.hwnd, path:Explorer_GetWindowObjectPath(win, opt*)
				 , desktop:TaskView.GetWindowDesktopNumber(win.hwnd)		})
	}
	return ret
}

Explorer_GetPath(hwnd, opts*) {
	if !WinExist("ahk_group WG_Explorer ahk_id " hwnd)
		return False
	for win in Explorer_GetAllWindowObjects() {
		if win.hwnd!=hwnd
			continue
		return Explorer_GetWindowObjectPath(win, opts*)
	}
	return False
}

;=========================================================

Explorer_GetAllWindowObjects() {
    return ComObjCreate("Shell.Application").Windows
}

Explorer_GetWindowObjectPath(winObj, ignoreSpecial:=False) {
	static replace:=[ ["ftp://.*@", "ftp://", True], ["file:///"], ["/", "\"] ]
	if (!winObj.LocationURL) {
		if ignoreSpecial
			return False
		hw:=A_DetectHiddenWindows 
	    DetectHiddenWindows, On
	    WinGetTitle, t, % "ahk_id " winObj.hwnd
	    path:= Explorer_getSpecialFolderPath(t)
		;msgbox % t "`n" path
	    DetectHiddenWindows, % hw
	} else
		path:= URI_Decode(str_Replace(winObj.LocationURL, replace))
	return path
}

;=========================================================

Explorer_getSpecialFolderPath(name){
	static special:="" 
	if !special
		special:=_Explorer_specialFolderList()
	return special[name]	
}

_Explorer_specialFolderList(){
	ret:={} ;In single line, it gives error "expression too long"
	ret["3D Objects"] := "shell:::{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"
	ret["Add Network Location"] := "shell:::{D4480A50-BA28-11d1-8E75-00C04FA31A86}"
	ret["Administrative Tools"] := "shell:::{D20EA4E1-3957-11d2-A40B-0C5020524153}"
	ret["Applications"] := "shell:::{4234d49b-0245-4df3-b780-3893943456e1}"
	ret["AutoPlay"] := "shell:::{9C60DE1E-E5FC-40f4-A487-460851A8D915}"
	ret["Backup and Restore (Windows 7)"] := "shell:::{B98A2BEA-7D42-4558-8BD1-832F41BAC6FD}"
	ret["BitLocker Drive Encryption"] := "shell:::{D9EF8727-CAC2-4e60-809E-86F80A666C91}"
	ret["Bluetooth Devices"] := "shell:::{28803F59-3A75-4058-995F-4EE5503B023C}"
	ret["Color Management"] := "shell:::{B2C761C6-29BC-4f19-9251-E6195265BAF1}"
	ret["Command Folder"] := "shell:::{437ff9c0-a07f-4fa0-af80-84b6c6440a16}"
	ret["Common Places FS Folder"] := "shell:::{d34a6ca6-62c2-4c34-8a7c-14709c1ad938}"
	ret["Control Panel"] := "shell:::{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}"
	ret["Control Panel (All Tasks)"] := "shell:::{ED7BA470-8E54-465E-825C-99712043E01C}"
	ret["Control Panel (always Category view)"] := "shell:::{26EE0668-A00A-44D7-9371-BEB064C98683}"
	ret["Control Panel (always Icons view)"] := "shell:::{21EC2020-3AEA-1069-A2DD-08002B30309D}"
	ret["Credential Manager"] := "shell:::{1206F5F1-0569-412C-8FEC-3204630DFB70}"
	ret["Date and Time"] := "shell:::{E2E7934B-DCE5-43C4-9576-7FE4F75E7480}"
	ret["Default Programs"] := "shell:::{17cd9488-1228-4b2f-88ce-4298e93e0966}"
	ret["Set Default Programs"] := "shell:::{17cd9488-1228-4b2f-88ce-4298e93e0966} -Microsoft.DefaultPrograms\pageDefaultProgram"
	ret["Set Associations"] := "shell:::{17cd9488-1228-4b2f-88ce-4298e93e0966} -Microsoft.DefaultPrograms\pageFileAssoc"
	ret["delegate folder that appears in Computer"] := "shell:::{b155bdf8-02f0-451e-9a26-ae317cfd7779}"
	ret["Desktop"] := "shell:::{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}"
	ret["Device Manager"] := "shell:::{74246bfc-4c96-11d0-abef-0020af6b0b7a}"
	ret["Devices and Printers"] := "shell:::{A8A91A66-3A7D-4424-8D24-04E180695C7A}"
	ret["Documents"] := "shell:::{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}" ;Also ::{d3162b92-9365-467a-956b-92703aca08af}
	ret["Downloads"] := "shell:::{088e3905-0323-4b02-9826-5d99428e115f}" ;Also ::{374DE290-123F-4565-9164-39C4925E467B}
	ret["Ease of Access Center"] := "shell:::{D555645E-D4F8-4c29-A827-D93C859C4F2A}"
	ret["Use the computer without a display"] := "shell:::{D555645E-D4F8-4c29-A827-D93C859C4F2A} -Microsoft.EaseOfAccessCenter\pageNoVisual"
	ret["Make the computer easier to see"] := "shell:::{D555645E-D4F8-4c29-A827-D93C859C4F2A} -Microsoft.EaseOfAccessCenter\pageEasierToSee"
	ret["Use the computer without a mouse or keyboard"] := "shell:::{D555645E-D4F8-4c29-A827-D93C859C4F2A} -Microsoft.EaseOfAccessCenter\pageNoMouseOrKeyboard"
	ret["Make the mouse easier to use"] := "shell:::{D555645E-D4F8-4c29-A827-D93C859C4F2A} -Microsoft.EaseOfAccessCenter\pageEasierToClick"
	ret["Make the keyboard easier to use"] := "shell:::{D555645E-D4F8-4c29-A827-D93C859C4F2A} -Microsoft.EaseOfAccessCenter\pageKeyboardEasierToUse"
	ret["Use text or visual alternatives for sounds"] := "shell:::{D555645E-D4F8-4c29-A827-D93C859C4F2A} -Microsoft.EaseOfAccessCenter\pageEasierWithSounds"
	ret["Get recommendations to make your computer easier to use (cognitive)"] := "shell:::{D555645E-D4F8-4c29-A827-D93C859C4F2A} -Microsoft.EaseOfAccessCenter\pageQuestionsCognitive"
	ret["Get recommendations to make your computer easier to use (eyesight)"] := "shell:::{D555645E-D4F8-4c29-A827-D93C859C4F2A} -Microsoft.EaseOfAccessCenter\pageQuestionsEyesight"
	ret["E-mail (default e-mail program)"] := "shell:::{2559a1f5-21d7-11d4-bdaf-00c04f60b9f0}"
	ret["Favorites"] := "shell:::{323CA680-C24D-4099-B94D-446DD2D7249E}"
	ret["File Explorer Options"] := "shell:::{6DFD7C5C-2451-11d3-A299-00C04F8EF6AF}"
	ret["File History"] := "shell:::{F6B6E965-E9B2-444B-9286-10C9152EDBC5}"
	ret["Folder Options"] := "shell:::{6DFD7C5C-2451-11d3-A299-00C04F8EF6AF}"
	ret["Font Settings"] := "shell:::{93412589-74D4-4E4E-AD0E-E0CB621440FD}"
	ret["Fonts"] := "shell:::{BD84B380-8CA2-1069-AB1D-08000948F534}"
	ret["Frequent folders"] := "shell:::{3936E9E4-D92C-4EEE-A85A-BC16D5EA0819}"
	ret["Games Explorer"] := "shell:::{ED228FDF-9EA8-4870-83b1-96b02CFE0D52}"
	ret["Get Programs"] := "shell:::{15eae92e-f17a-4431-9f28-805e482dafd4}"
	ret["Help and Support"] := "shell:::{2559a1f1-21d7-11d4-bdaf-00c04f60b9f0}"
	ret["HomeGroup (settings)"] := "shell:::{67CA7650-96E6-4FDD-BB43-A8E774F73A57}"
	ret["HomeGroup (users)"] := "shell:::{B4FB3F98-C1EA-428d-A78A-D1F5659CBA93}"
	ret["Hyper-V Remote File Browsing"] := "shell:::{0907616E-F5E6-48D8-9D61-A91C3D28106D}"
	ret["Indexing Options"] := "shell:::{87D66A43-7B11-4A28-9811-C86EE395ACF7}"
	ret["Infared (if installed)"] := "shell:::{A0275511-0E86-4ECA-97C2-ECD8F1221D08}"
	ret["Installed Updates"] := "shell:::{d450a8a1-9568-45c7-9c0e-b4f9fb4537bd}"
	ret["Intel Rapid Storage Technology (if installed)"] := "shell:::{E342F0FE-FF1C-4c41-BE37-A0271FC90396}"
	ret["Internet Options (Internet Explorer)"] := "shell:::{A3DD4F92-658A-410F-84FD-6FBBBEF2FFFE}"
	ret["Libraries"] := "shell:::{031E4825-7B94-4dc3-B131-E946B44C8DD5}"
	ret["Location Information (Phone and Modem Control Panel)"] := "shell:::{40419485-C444-4567-851A-2DD7BFA1684D}"
	ret["Location Settings"] := "shell:::{E9950154-C418-419e-A90A-20C5287AE24B}"
	ret["Media Servers"] := "shell:::{289AF617-1CC3-42A6-926C-E6A863F0E3BA}"
	ret["Mouse Properties"] := "shell:::{6C8EEC18-8D75-41B2-A177-8831D59D2D50}"
	ret["Music"] := "shell:::{1CF1260C-4DD0-4ebb-811F-33C572699FDE}" ;Also ::{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}
	ret["My Documents"] := "shell:::{450D8FBA-AD25-11D0-98A8-0800361B1103}"
	ret["Network"] := "shell:::{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}"
	ret["Network and Sharing Center"] := "shell:::{8E908FC9-BECC-40f6-915B-F4CA0E70D03D}"
	ret["Advanced sharing settings"] := "shell:::{8E908FC9-BECC-40f6-915B-F4CA0E70D03D} -Microsoft.NetworkAndSharingCenter\Advanced"
	ret["Media streaming options"] := "shell:::{8E908FC9-BECC-40f6-915B-F4CA0E70D03D} -Microsoft.NetworkAndSharingCenter\ShareMedia"
	ret["Network Connections"] := "shell:::{7007ACC7-3202-11D1-AAD2-00805FC1270E}" ;Also ::{992CFFA0-F557-101A-88EC-00DD010CCC48}
	ret["Network (WorkGroup)"] := "shell:::{208D2C60-3AEA-1069-A2D7-08002B30309D}"
	ret["Notification Area Icons"] := "shell:::{05d7b0f4-2121-4eff-bf6b-ed3f69b894d9}"
	ret["NVIDIA Control Panel (if installed)"] := "shell:::{0bbca823-e77d-419e-9a44-5adec2c8eeb0}"
	ret["Offline Files Folder"] := "shell:::{AFDB1F70-2A4C-11d2-9039-00C04F8EEB3E}"
	ret["OneDrive"] := "shell:::{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
	ret["Pen and Touch"] := "shell:::{F82DF8F7-8B9F-442E-A48C-818EA735FF9B}"
	ret["Personalization"] := "shell:::{ED834ED6-4B5A-4bfe-8F11-A626DCB6A921}"
	ret["Color and Appearance"] := "shell:::{ED834ED6-4B5A-4bfe-8F11-A626DCB6A921} -Microsoft.Personalization\pageColorization"
	ret["Desktop Background"] := "shell:::{ED834ED6-4B5A-4bfe-8F11-A626DCB6A921} -Microsoft.Personalization\pageWallpaper"
	ret["Pictures"] := "shell:::{24ad3ad4-a569-4530-98e1-ab02f9417aa8}" ;Also ::{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}
	ret["Portable Devices"] := "shell:::{35786D3C-B075-49b9-88DD-029876E11C01}"
	ret["Power Options"] := "shell:::{025A5937-A6BE-4686-A844-36FE4BEC8B6D}"
	ret["System settings"] := "shell:::{025A5937-A6BE-4686-A844-36FE4BEC8B6D} -Microsoft.PowerOptions\pageGlobalSettings"
	ret["Edit Plan settings"] := "shell:::{025A5937-A6BE-4686-A844-36FE4BEC8B6D} -Microsoft.PowerOptions\pagePlanSettings"
	ret["Previous Versions Results Folder"] := "shell:::{f8c2ab3b-17bc-41da-9758-339d7dbf2d88}"
	ret["printhood delegate folder"] := "shell:::{ed50fc29-b964-48a9-afb3-15ebb9b97f36}"
	ret["Printers"] := "shell:::{2227A280-3AEA-1069-A2DE-08002B30309D}" ;Also ::{863aa9fd-42df-457b-8e4d-0de1b8015c60}
	ret["Problem Reporting Settings"] := "shell:::{BB64F8A7-BEE7-4E1A-AB8D-7D8273F7FDB6}\pageSettings"
	ret["Programs and Features"] := "shell:::{7b81be6a-ce2b-4676-a29e-eb907a5126c5}"
	ret["Public"] := "shell:::{4336a54d-038b-4685-ab02-99bb52d3fb8b}"
	ret["Quick access"] := "shell:::{679f85cb-0220-4080-b29b-5540cc05aab6}"
	ret["File Explorer"] := "shell:::{679f85cb-0220-4080-b29b-5540cc05aab6}" ; Same as Quick Access
	ret["Recent folders"] := "shell:::{22877a6d-37a1-461a-91b0-dbda5aaebc99}"
	ret["Recovery"] := "shell:::{9FE63AFD-59CF-4419-9775-ABCC3849F861}"
	ret["Recycle Bin"] := "shell:::{645FF040-5081-101B-9F08-00AA002F954E}"
	ret["Region"] := "shell:::{62D8ED13-C9D0-4CE8-A914-47DD628FB1B0}"
	ret["RemoteApp and Desktop Connections"] := "shell:::{241D7C96-F8BF-4F85-B01F-E2B043341A4B}"
	ret["Remote Printers"] := "shell:::{863aa9fd-42df-457b-8e4d-0de1b8015c60}"
	ret["Removable Storage Devices"] := "shell:::{a6482830-08eb-41e2-84c1-73920c2badb9}"
	;ret[﻿"Results Folder"] := "shell:::{2965e715-eb66-4719-b53f-1672673bbefa}"
	ret["Run"] := "shell:::{2559a1f3-21d7-11d4-bdaf-00c04f60b9f0}"
	ret["Search (File Explorer)"] := "shell:::{9343812e-1c37-4a49-a12e-4b2d810d956b}"
	ret["Search (Modern)"] := "shell:::{2559a1f8-21d7-11d4-bdaf-00c04f60b9f0}"
	ret["Security and Maintenance"] := "shell:::{BB64F8A7-BEE7-4E1A-AB8D-7D8273F7FDB6}"
	ret["Set Program Access and Computer Defaults"] := "shell:::{2559a1f7-21d7-11d4-bdaf-00c04f60b9f0}"
	ret["Show Desktop"] := "shell:::{3080F90D-D7AD-11D9-BD98-0000947B0257}"
	ret["Sound"] := "shell:::{F2DDFC82-8F12-4CDD-B7DC-D4FE1425AA4D}"
	ret["Speech Recognition"] := "shell:::{58E3C745-D971-4081-9034-86E34B30836A}"
	ret["Storage Spaces"] := "shell:::{F942C606-0914-47AB-BE56-1321B8035096}"
	ret["Sync Center"] := "shell:::{9C73F5E5-7AE7-4E32-A8E8-8D23B85255BF}"
	ret["Sync Setup Folder"] := "shell:::{2E9E59C0-B437-4981-A647-9C34B9B90891}"
	ret["System"] := "shell:::{BB06C0E4-D293-4f75-8A90-CB05B6477EEE}"
	ret["System Icons"] := "shell:::{05d7b0f4-2121-4eff-bf6b-ed3f69b894d9} \SystemIcons"
	ret["System Restore"] := "shell:::{3f6bc534-dfa1-4ab4-ae54-ef25a74e0107}"
	ret["Tablet PC Settings"] := "shell:::{80F3F1D5-FECA-45F3-BC32-752C152E456E}"
	ret["Task View"] := "shell:::{3080F90E-D7AD-11D9-BD98-0000947B0257}"
	ret["Taskbar and Navigation properties"] := "shell:::{0DF44EAA-FF21-4412-828E-260A8728E7F1}"
	ret["Taskbar page in Settings"] := "shell:::{0DF44EAA-FF21-4412-828E-260A8728E7F1}"
	ret["Text to Speech"] := "shell:::{D17D1D6D-CC3F-4815-8FE3-607E7D5D10B3}"
	ret["This PC"] := "shell:::{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
	ret["Troubleshooting"] := "shell:::{C58C4893-3BE0-4B45-ABB5-A63E4B8C8651}"
	ret["History"] := "shell:::{C58C4893-3BE0-4B45-ABB5-A63E4B8C8651} -Microsoft.Troubleshooting\HistoryPage"
	ret["User Accounts"] := "shell:::{60632754-c523-4b62-b45c-4172da012619}"
	ret["User Accounts (netplwiz)"] := "shell:::{7A9D77BD-5403-11d2-8785-2E0420524153}"
	ret["User Pinned"] := "shell:::{1f3427c8-5c10-4210-aa03-2ee45287d668}"
	ret["%UserProfile%"] := "shell:::{59031a47-3f72-44a7-89c5-5595fe6b30ee}"
	ret["Videos"] := "shell:::{A0953C92-50DC-43bf-BE83-3742FED03C9C}" ;Also ::{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}
	ret["Web browser (default)"] := "shell:::{871C5380-42A0-1069-A2EA-08002B30309D}"
	ret["Windows Defender Firewall"] := "shell:::{4026492F-2F69-46B8-B9BF-5654FC07E423}"
	ret["Allowed apps"] := "shell:::{4026492F-2F69-46B8-B9BF-5654FC07E423} -Microsoft.WindowsFirewall\pageConfigureApps"
	ret["Windows Mobility Center"] := "shell:::{5ea4f148-308c-46d7-98a9-49041b1dd468}"
	ret["Windows Features"] := "shell:::{67718415-c450-4f3c-bf8a-b487642dc39b}"
	ret["Windows To Go"] := "shell:::{8E0C279D-0BD1-43C3-9EBD-31C3DC5B8A77}"
	ret["Work Folders"] := "shell:::{ECDB0924-4208-451E-8EE0-373C0956DE16}"
	return ret
}