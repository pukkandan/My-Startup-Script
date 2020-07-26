; This file must be in Windows 1252 encoding, not in UTF8/16

;===================    Sort chars
RETURN
::z»::{U+0370} ; z» = Heta      :Succedes letters in sorting
::0»::{U+263A} ; 0» = Smiley    :Precedes numbers in sorting
:::»::=:=      ; :» = =:=       :Join Param Seperator
return

;===================    Hot Strings
RETURN
::@»::@gmail.com
::m»::magnet:?xt=urn:btih:

return

;===================    Paste Trackers
RETURN
::tr»::
FileRead trackerList, trackers.txt
temp:=ClipboardAll, Clipboard:=""
clipboard:=trackerList
ClipWait
send ^v
sleep 100
Clipboard:=temp, temp:="", trackerList:=""
return

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
