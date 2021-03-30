; This file must be in UTF-BOM encoding

;===================    Reset hotstring on Undo, Cut, Copy
RETURN
~^z::
~^x::
~^v::
~+Del::
~+Ins::
	Hotstring("Reset")
return

;===================    Hot Strings
RETURN
::@»::@gmail.com
::m»::magnet:?xt=urn:btih:
:::»::=:=      		; ":»" => "=:="       		:Join Param Seperator
::#»::{#}:~:text=   ; "#»" => "#:~:text="       :Text Fragments
return

;===================    Paste Trackers
RETURN
::tr»::
pasteTrackers(){
	FileRead trackerList, trackers.txt
	pasteText(trackerList)
	trackerList:=""
	return
}

;===================    Brackets
RETURN
#IfWinActive ahk_group WG_AutoBracket

:b0:{}::
:b0:[]::
:b0:()::
:b0:""::
:b0:''::
:b0:````::
:b0:%%::
:b0:$$::
	Send {Left}
return

:b0:/**/::
	Send {Left 2}
return

:b0:<>::
	ifWinNotActive ahk_group WG_NoAngularBrac
	    Send {Left}
return

; :b0:`n`n::
; Send, {Up}{Tab}
; return

#If

;===================    Symbols
RETURN
::z»::Ͱ 		; z» = Heta      :Succedes letters in sorting
::0»::☺ 		; 0» = Smiley    :Precedes numbers in sorting

::inf»::∞ 		; inf» = Infinity
return

;===================    Send `n/`t in cases where enter/tab is used for other purposes
#InputLevel 0

:X: t»::sendKeys("`t")	; " t»" = Tab, + » = Another Tab ... 
:Xb0:`t»::sendKeys("{Backspace}`t")

:X: n»::sendKeys("`n") 	; " n»" = NewLine, + » = Another line ... 
:Xb0:`n»::sendKeys("{Backspace}`n")

:Xb0: »::sendKeys("{Backspace}   ")		; " »" = 4 Spaces, + » = Another 4 spaces ...



;===================    youtube-dl
#InputLevel 2
:?0:yt-dlp»::[yt-dlp](https://github.com/yt-dlp/yt-dlp)
:?0:animelover1984/youtube-dl»::[animelover1984/youtube-dl](https://github.com/animelover1984/youtube-dl)
:?0:youtube-dl»::[youtube-dl](https://github.com/ytdl-org/youtube-dl)
:?0:youtube-dlc»::[youtube-dlc](https://github.com/blackjack4494/yt-dlc)

:X?0:y»::sendKeys("yt-dlp")
:X?0:ydlp»::sendKeys("yt-dlp")
:X?0:ydal»::sendKeys("animelover1984/youtube-dl")
:X?0:ydlc»::sendKeys("youtube-dlc")
:X?0:dlc»::sendKeys("youtube-dlc")
:X?0:ydl»::sendKeys("youtube-dl")






/* Example how to create hotkey chains

#InputLevel 0
:X:a»::sendKeys("first")			; a»   = first
:X:first»::sendKeys("second")		; a»»  = second
::second»::third					; a»»» = third

*/