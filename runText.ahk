;~ #persistent;~ #persistent
;~ #include <ini>
;~ new runText
;~ !Space::
;~ XButton2::runTextObj.showGUI()
;~ return
;~ ;===============================

class runText{
    __new(ini_file:="Runtext.ini"){
        global runTextObj
        runTextObj:=this
        this.settings:=new ini(ini_file)
        this.getGlobalSettings()
        this.createGUI_Frame()
        this.addMainItems()
    }
    getGlobalSettings(){
        this.iconSize:=this.settings.get("Main","IconSize",32)
        , this.waitTimeout:=this.settings.get("Main","WaitTimeout",5)
        , this.GUIminWidth:=Floor(this.settings.get("Main","GUIMinWidth",10))
        , this.GUImaxWidth:=Floor(this.settings.get("Main","GUIMaxWidth",10))

        if this.GUIminWidth<1
            this.GUIminWidth:=1
        if this.GUImaxWidth<1
            this.GUImaxWidth:=A_ScreenWidth//(this.iconSize*2)
        if this.GUIminWidth>this.GUImaxWidth
            this.GUIminWidth:=this.GUImaxWidth

        ;~ Msgbox, % this.iconSize "," this.iconPath "," this.waitTimeout "," this.GUIminWidth "," this.GUImaxWidth
        return
    }
    createGUI_Frame(){
        GUI, RunTextGUI:New, +HwndGUIhwnd -Caption +AlwaysOnTop +ToolWindow
        this.GUIhwnd:=GUIhwnd
        GUI, RunTextGUI:Color, 0x222222
        GUI, RunTextGUI:+LastFoundExist
        WinSet, Trans, 200
        WinSet, TransColor, 0x1F1F1F
        return
    }

    addMainItems(){
        sectListStr:=this.settings.get(), this.sectList:=[]
        Loop, Parse, sectListStr, `n, `r
        {
            if(A_LoopField="Main")
                continue
            i:=this.sectList.length()+1
            this.sectList[i]:=new this.sect(i,A_LoopField)
            if !IsObject(this.sectList[i])
                    this.sectList.removeAt(i)
        }
        return this.sectCount:=i
    }

    putItemsInGUI(){
        global RunText_Edit
        this.GUIwidth:=this.sectCount<this.GUImaxWidth ? this.sectCount : this.GUImaxWidth
        this.GUIwidth:=this.GUIminWidth<this.GUIwidth ? this.GUIwidth : this.GUIminWidth
        this.GUIheight:=(this.iconSize+2)*Ceil(this.sectCount/this.GUIwidth) +2 ;Not including height of edit-box
        this.GUIwidth:=this.GUIwidth*(this.iconSize+2) +2
        w:=this.GUIwidth-2, y:=this.GUIheight
        GUI, RunTextGUI:Add, Edit, vRunText_Edit w%w% h20 Y%y% X1

        for i, itemObj in this.sectList
            this.putIcon(i,itemObj)
        return
    }
    putIcon(i,obj){
        global
        local px, py, name, iconSize:=this.iconSize
        if (i=1)
            px:=2, py:=2
        else if !mod(i-1,this.GUImaxWidth)
            py:="+2", px:=2
        else py:="p+0", px="+2"
        id:=obj.id
        , iconNo:=ResourceIDofIcon(obj.icon,obj.iconNo)
        GUI, RunTextGUI:Add, Picture, x%px% y%py% W%iconSize% H%iconSize% +BackgroundTrans vRunText_%id% gRunTextIconClicked icon%iconNo%
        , % obj.icon
    }

    showGUI(){
        global RunText_Edit, RunTextGUI
        text:=getSelectedText()
        Toast.show("RunText")
        text:=text?text:Clipboard
        text:=RegExReplace(RegExReplace(text, "[`t`n]| +"," "), "^ | $|`r")

        if (!this.GUIwidth)
            this.putItemsInGUI()
        GUI, RunTextGUI:Hide
        CoordMode, Mouse, Screen
        MouseGetPos, m_x, m_y
        RunTextGUIWidth:=this.GUIwidth, RunTextGUIHeight:=this.GUIheight+21
        m_x:=(m_x<A_ScreenWidth -RunTextGUIWidth  ? m_x : A_ScreenWidth -RunTextGUIWidth )
        m_y:=(m_y<A_ScreenHeight-RunTextGUIHeight ? m_y : A_ScreenHeight-RunTextGUIHeight)
        GUI, RunTextGUI:Show, x%m_x% y%m_y% w%RunTextGUIWidth% h%RunTextGUIHeight%

        GuiControl, RunTextGUI:, RunText_Edit, % text
        GuiControl, RunTextGUI:Focus, RunText_Edit
        Send, {end}+{home}
        checkFocusObj:=ObjBindMethod(this, "checkFocus")
        SetTimer, % checkFocusObj , 100
        SetTimer, % checkFocusObj , On
        Tooltip
        return
    }
    GUIhide(){
        RunTextGUIEscape:
        RunTextGUIClose:
        GUI, RunTextGUI:Hide
        return
    }
    iconClickedDummy(){
        RETURN
        RunTextIconClicked:
        global RunTextObj
        sect:=RunTextObj.SectList[substr(A_GuiControl,9)]
        f:=sect.get("Folder")
        static menu:=[]
        if (f){
            if (A_GuiEvent="DoubleClick") {
                ShellRun(f)
                this.GUIhide()
                return
            }
            if (!menu[sect.id]){
                menuName:="runTextMenu_" sect.id
                menu[sect.id]:=menuName
                Menu, % menuName, UseErrorLevel
                Menu, % menuName, Add, ..\, RunTextFileClicked
                icon:=sect.get("icon"), iconNo:=0
                ifNotExist, % icon
                {
                    SplitPath, f,, dir
                    IniRead, icon, %dir%\desktop.ini, .ShellClassInfo, IconResource
                    RegExMatch(icon, ",[ 0-9]*$", iconNo)
                    if iconNo
                        icon:=substr(icon,1,-strlen(iconNo))
                    if substr(icon,1,2)=".\"
                        icon:=dir . substr(icon,2)
                    iconNo:=RegExReplace(iconNo,"[^0-9]")
                }
                Menu, % menuName, Icon, ..\, % icon, % iconNo

                Loop, Files, %f%*, FD
                    if A_LoopFileAttrib not Contains S,H
                    {
                        Menu, % menuName, Add, % A_LoopFileName, RunTextFileClicked
                        icon:="", iconNo:=0
                        if A_LoopFileAttrib contains D
                        {
                           IniRead, icon, %A_LoopFileFullPath%\desktop.ini, .ShellClassInfo, IconResource, A_Space
                           RegExMatch(icon, ",[ 0-9]*$", iconNo)
                           if iconNo
                               icon:=substr(icon,1,-strlen(iconNo))
                           if substr(icon,1,2)=".\"
                               icon:=A_LoopFileFullPath . substr(icon,2)
                           iconNo:=RegExReplace(iconNo,"[^0-9]")
                        } else if (substr(A_LoopFullPath,-3)=".lnk")
                            FileGetShortcut, A_LoopFileFullPath,,,,, Icon, IconNo
                        Menu, % menuName, Icon, % A_LoopFileName, % icon, % iconNo
                    }
            }
            sleep, 100
            Menu, % "runTextMenu_" sect.id, Show
            return
        }
        m:=sect.get("Menu")
        if (m){
            if (!menu[sect.id]){
                menuName:="runTextMenu_" sect.id
                menu[sect.id]:=menuName
                Menu,  % menuName, UseErrorLevel
                Loop, parse, m, % " "
                {
                    subsect:=new runTextObj.sub_sect(sect,A_loopField)
                    Menu, % menuName, Add, % subsect.MenuText, RunTextMenuClicked
                    Menu, % menuName, Icon, % subsect.MenuText, % subsect.icon, % subsect.iconNo
                }
            }
            Menu, % "runTextMenu_" sect.id, Show
            return
        } else
            runTextObj.clickActions(sect)
        return

        RETURN
        RunTextMenuClicked:
        global RunTextObj
        sect:=RunTextObj.SectList[substr(A_ThisMenu,13)]
        name:=StrReplace(StrReplace(A_ThisMenuItem, "_" , "__"), " " , "_")
        runTextObj.clickActions(sect,name "_")
        return

        RETURN
        RunTextFileClicked:
        global RunTextObj
        ShellRun(RunTextObj.SectList[substr(A_ThisMenu,13)].get("Folder") . (A_ThisMenuItem="..\"?"":A_ThisMenuItem))
        return
    }
    clickActions(sect, mod:=""){
        global RunTextObj
        RunTextObj.GUIhide()
        DetectHiddenWindows, On
        loop{
            r:=sect.get(mod "Run" A_Index)
            w:=sect.get(mod "Wait" A_Index)
            s:=sect.get(mod "Send" A_Index)
            if(!r && !w && !s)
                break
            if (r){
                Tooltip("Running """ r """")
                ShellRun(r)
            }
            if (w){
                Tooltip("Waiting for """ w """")
                Winwait, % w,, % RunTextObj.waitTimeout
                if (ErrorLevel){
                    Tooltip("TIMEOUT: Wait for """ w """")
                    Sleep, 500
                    ToolTip,
                    return
                }
                sleep, 100
                if (s){
                    Tooltip("Sending """ s """ to """ w """")
                    WinActivate, % w
                    if sect.get(mod "SendRaw" A_Index)=1
                        SendRaw,% s ;ControlSendRaw is buggy
                    else if sect.get(mod "SendRaw" A_Index)=2
                        pasteText(s,{win:w})
                    else ControlSend,, % s, % w
                }
            } else if (s){
                Tooltip("Sending """ s """")
                if sect.get(mod "SendRaw" A_Index)
                    sendRaw, % s
                else send, % s
            }
            sleep, 20
            Tooltip
        }
    }

    checkFocus(){
        IfWinActive, % "ahk_id " this.GUIhwnd
            return
        setTimer,, Off
        this.GUIhide()
        return
    }

    class sect{
        __new(id,name){ ;parent is runText obj
            global runTextObj
            this.id:=id, this.name:=name, this.encoding:=this.get("encoding",0), this.defaultIcon:="icons\noIcon.ico"
        }

        encodedText[]{
            get{
                global RunText_Edit
                GuiControlGet, text,, RunText_Edit
                enc:=this.get("Encoding","None")
                if (enc="URIDecode")
                    text:=URI_Decode(text)
                if (enc="URIEncode")
                    text:=URI_Encode(text)
                return text
           }
        }
        icon[]{
            get{
                global runTextObj
                val:=this.get("icon")
                SplitPath, val,,, ext
                if ext in exe,dll,ico
                    ifExist, % val
                        return this.icon:=val

                val:=this.get("Folder")
                if !val
                    val:=this.get("Run1")
                SplitPath, val,, dir, ext
                if ext in exe,dll,ico
                    ifExist, % val
                        return this.icon:=val

                if ext=ahk
                    ifExist, % substr(val,1,-4) ".ico"
                        return this.icon:=substr(val,1,-4) ".ico"

                ;~ if (ext){
                ;~     icon_ext:=extensionIcon(ext)
                ;~     ifExist, icon_ext
                ;~         return this.icon:=icon_ext
                ;~ }
                FileGetAttrib, attr, % val
                if attr contains D
                {
                    IniRead, val, %dir%\desktop.ini, .ShellClassInfo, IconResource
                    RegExMatch(val, ",[ 0-9]*$", iconNo)
                    if iconNo
                        val:=substr(val,1,-strlen(iconNo))
                    if substr(val,1,2)=".\"
                        val:=dir . substr(val,2)
                    SplitPath, val,,, ext
                    if ext in exe,dll,ico
                        ifExist, % val
                        {
                            this.iconNoV:=RegExReplace(iconNo,"[^0-9]")
                            return  this.icon:=val
                        }
                }

                val:=this.name . ".ico"
                IfExist, % val
                    return this.icon:=val

                return  this.icon:=this.defaultIcon
            }
        }
        iconNo[]{
            get{
                global runTextObj
                val:=this.get("iconNo",-1)
                if val>=0
                    return this.iconNo:=val
                else{
                    i:=this.icon    ;To run the get of icon[]
                    if this.iconNoV
                        return this.iconNo:=this.iconNoV
                    else return this.iconNo:=0
                }
            }
        }


        get(var,def:=0){
            static properties:=[]
            if properties[this.name,var]
                val:=properties[this.name,var]
            else{
                global runTextObj
                val:=runTextObj.settings.get(this.name,var,def)
                properties[this.name,var]:=val
            }
            IfInString, val, ##
            {
                StringReplace, val, val, ##, % this.encodedText
            }
            return val?val:def
        }
    }

    class sub_sect extends runText.sect{
        __new(parent_sect,name){ ;parent is runText obj
            global runTextObj
            this.name:=name, this.parent:=parent_sect, this.encoding:=this.get("encoding"), this.defaultIcon:=""
        }
        get(var,def:=0){
            static properties:=[]
            if properties[this.parent.name,this.name,var]
                return properties[this.parent.name,this.name,var]
            global runTextObj
            val:=runTextObj.settings.get(this.parent.name,this.name "_" var,def)
            IfInString, val, ##
                StringReplace, val, val, ##, % this.encodedText
            return properties[this.parent.name,this.name,var]:=val?val:def
        }

        MenuText[]{
            get{
                return this.text:=strReplace(regexReplace(this.name,"([^_])_([^_])","$1 $2"),"__","_")
            }
        }
    }

}