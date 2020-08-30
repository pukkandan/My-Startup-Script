; This file must be in Windows 1252 encoding, not in UTF8/16

;===================    Hot Strings
RETURN
::@»::@gmail.com
::m»::magnet:?xt=urn:btih:
:::»::=:=      ; ":»" => "=:="       :Join Param Seperator
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
::z»::{U+0370} 		; z» = Heta      :Succedes letters in sorting
::0»::{U+263A} 		; 0» = Smiley    :Precedes numbers in sorting

::inf»::{U+221E}	; inf» = Infinity
return