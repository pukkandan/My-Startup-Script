getSelectedText()
{
 /* Returns selected text without disrupting the clipboard. However, if the clipboard contains a large amount of data, some of it may be lost
 */
    clipOld:=ClipboardAll
    Clipboard:=""
    Send, ^c
    ClipWait, 0.1, 1
    clipNew:=Clipboard
    Clipboard:=clipOld

    ;Special for explorer
    WinGet, w, ID, A
    WinGetClass, c, ahk_id %w%
    if c in Progman,WorkerW,Explorer,CabinetWClass
        SplitPath, clipNew,,,, clipNew2

    Return clipNew2?clipNew2:clipNew
}