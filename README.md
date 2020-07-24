# My Startup Script

Being Rewritten

<!--- 
## [Libraries](Lib)


* **[ini](Lib/INI.ahk)**  
Provides an easier and object-oriented way to use `iniRead`, `iniWrite`, and `iniDelete`.


* **[Toast](Lib/Toast.ahk)**  
Provides a class for creating multiple customizable _Toasts_ (not related to Toast Notifications), used to show various notifications.  [Inspired by: [Engunneer](https://autohotkey.com/board/topic/21510-toaster-popups/#entry140824)]


* **[DelayedTimer](Lib/DelayedTimer.ahk)**  
Allows to create timers without activating them and then activate them all at once. Used to make sure timers don't interrupt the auto-execute section of the script. Also, due to the way it is implemented, it allows for complex expressions to be used as  timers unlike `setTimer`.

    <details> <summary>Usage</summary>
        
    ```AutoHotKey
    delayedTimer.set("function1", 10000)
    ; code block 1
    delayedTimer.set("function2", 10000, True)
    ; code block 2
    delayedTimer.start()
    ; code block 3
    delayedTimer.firstRun()
    ```
    The first two lines define the timers `function1()` and `function2()` with 10s each, but don't start the timer yet. `delayedTimer.start()` tells it to start all the defined timers, and `delayedTimer.firstRun()` tells it to run all the functions whose third parameter is `True` (`function2()`) once, and then reset the list of timers. So, it is essentially the same as:

    ```AutoHotKey
    ; code block 1
    ; code block 2
    setTimer, function1, 10000
    setTimer, function2, 10000
    ;code block 3
    function2()
    ```
    By default, `setTimer` allows you to use function objects, like this:

    ```AutoHotKey
    object_name:=ObjBindMethod(class_name, function_name, arg_1, arg_2)
    ;or object_name:=Func("funcion_name").bind(arg_1, arg_2)
    setTimer, % object_name, 100
    ```
    However, it does **not** allow to use the object directly without defining it in a previous line, like `setTimer, % ObjBindMethod(class_name, function_name, arg_1, arg_2), 100`. However, `delayedTimer()` does allow you to use such objects directly. So, you **can** write `delayedTimer(ObjBindMethod(class_name, function_name, arg_1, arg_2), 100)`.
    </details>


* **[GetSelectedText](Lib/getSelectedText.ahk)**  
Gets the selected text without messing up the clipboard (much). This isn't a fool-proof method, but is the best way I could think of.


* **[IsFullScreen](Lib/IsFullScreen.ahk)**  
Checks if a window is running in Full screen. Can also optionally detect "Windowed Borderless Mode"


* **[IsOver](Lib/IsOver.ahk)**  
    * **isOver_mouse**: Checks if mouse is over a particular window.
    * **isOver_coord**: Checks if a window is over a specified global co-ordinates.


* **[ReloadAsAdmin](Lib/ReloadAsAdmin.ahk)**  
    * **reloadAsAdmin**: Reloads the script with administrator permissions
    * **reloadAsAdmin_Task**: Reloads the script with administrator permissions using scheduled tasks. The advantage over the original method is that UAC prompt occurs only the first time the script is elevated. [Code by: [SKAN](http://ahkscript.org/boards/viewtopic.php?t=4334)]


* **[ReloadScriptOnEdit](Lib/ReloadScriptOnEdit.ahk)**  
Asks to reload the script when one of the specified file is edited (uses the _Archive_ flag). [Inspired by: [Avi Aryan](avi-aryan.github.com/ahk/functions/ahkini.html)]


* **[ResourceIDOfIcon](Lib/ResourceIDOfIcon.ahk)**  
Gets the ResourceID of an icon from its Index No. [Code by: [Lexikos](https://autohotkey.com/board/topic/27668-how-to-get-the-icon-group-number/?p=177730)]


* **[Tooltip](Lib/ToolTip.ahk)**  
Provides customizable Tooltips.
    * **Life**: Tooltip is removed automatically after a certain period of time
    * **Format**: Allows changing of background/text font, color etc of the tooltips. This has been disabled temporarily till I can sort out some bugs. [Code by: [Lexikos](https://autohotkey.com/boards/viewtopic.php?t=4777)]


* **[URI](Lib/URI.ahk)**  
`URI_Encode` and `URI_Decode` functions. [Code by: [GeekDude](http://goo.gl/0a0iJq)]


* **[Download](Lib/Download.ahk)**  
Creates **asynchronous** download request and saves the reply text in a variable. Unlike `UrlDownladToFile`, the script doesnot become unresponsive while the URL is downloading.[Code from: [AHK Documentation](https://autohotkey.com/docs/commands/DownloadToFile.htm#Examples)]


* **[PasteText](Lib/PasteText.ahk)**  
_Work in Progress_


## [Files](../../)


* **[Master](Master.ahk)**  
Calls all the other files. None of the other files are supposed to be run by themselves, and many times are interdependent with each other.


* **[Directives](Directives.ahk)**  
Sets up various global settings for the script, as well as define the super-global variables `SCR_Name`, `SCR_PID` and `SCR_hwnd`.


* **[Tray](Tray.ahk)**  
Creates and updates the Tray Icon, Menu and Tip.


* **[SuspendOnFS](SuspendOnFS.ahk)**  
Suspends hotkeys in FullScreen.


* **[WinProbe](WinProbe.ahk)**  
Similar functionality to Window Spy


* **[TaskView](Taskview.ahk)**  
Provides various functionality related to Windows 10 Virtual Desktops [Inspired by: [Windows 10 Virtual Desktop Enhancer](https://github.com/sdias/win-10-virtual-desktop-enhancer)]


* **[HotCorners](HotCorners.ahk)**  
Provides Hot Corner functionality.


* **[WinSizer](WinSizer.ahk)**  
Resize/Move Windows. [Inspired by: [NiftyWindows](http://www.enovatic.org/products/niftywindows/features/)]
    <details> <summary>Usage</summary>
    
    ```AutoHotKey
    #if !getkeyState("Ctrl", "P")
    MButton::WinSizer.start()
    #if
    MButton Up::
    if WinSizer.end()
        return
    else
        send, {MButton}
    ```
    would enable you to use `Middle Mouse Drag` to resize/move windows, but only when `Ctrl` is not pressed. It will also send normal `MButton` when you don't drag. The window is divided into a 3x3 grid. If your mouse is in the middle cell, the window is moved. Otherwise, it is resized according to which cell the mouse is in.
</details>


* **[UnwantedPopupBlocker](UnwantedPopupBlocker.ahk)**  
    * Blocks SublimeText's `This is an unregistered copy` popup
    * Blocks Chrome's `Disable developer mode extensions` popup


* **[Transparent](Transparent.ahk)**  
    * **Transparent_TaskbarGlass**: Gives Glass effect to Taskbar [Code by: [TaskBar SetAttr](https://github.com/jNizM/AHK_TaskBar_SetAttr)]
    * **Transparent_Windows**: Makes all windows defined in `TransGroup` (and not in `noTransGroup`) translucent.
    * **Transparent_MaxBG**: Makes Background Transparent when window is maximized.


* **[PIP](PIP.ahk)**  


* **[ToggleKeys](ToggleKeys.ahk)**  
[Inspired by: [CapShift](http://www.dcmembers.com/skrommel/download/capshift/)]
    * **CapsLockOffTimer**: Automatically turns CapsLock off after a period of keyboard inactivity.
    * **CaseMenu**: Change the case of selected text.


* **[MicroWindows](MicroWindows.ahk)**  
Creates a live re-sizable PIP copy of a window [Inspired by: [LiveWindows2](https://autohotkey.com/board/topic/71692-an-updated-livewindows-which-can-also-show-video)]


* **[WinAction](WinAction.ahk)**  

* **[RunText](RunText.ahk)**  


* **[Internet](Internet.ahk)**  
Checks Internet Connectivity, IP Addresses (Public and Local IPs) and VPN access (You need to provide an IP group that identifies the VPN), and notifies when there is a change.


* **[AutoUpdate](AutoUpdate.ahk)**  
Auto-updates AutoHotKey


* **[KeyRemap](KeyRemap.ahk)**  
Defines all the Hotkeys


--->