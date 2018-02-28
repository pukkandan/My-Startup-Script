# My Startup Script

## [Libraries](Lib)

* **[ini](Lib\ini.ahk)**  
Provides an easier and object-oriented way to use `iniRead`, `iniWrite`, and `iniDelete`.

* **[Toast](Lib\Toast.ahk)**  
Provides a class for creating multiple customizable _Toasts_ (not related to Toast Notifications), used to show various notifications.  [Inspired by: [Engunneer](https://autohotkey.com/board/topic/21510-toaster-popups/#entry140824)]

* **[DelayedTimer](Lib\DelayedTimer.ahk)**  
Allows to create timers without activating them and then activate them all at once. Used to make sure timers don't interrupt the auto-execute section of the script. Also, due to the way it is implemented, it allows for complex expressions to be used as  timers unlike `setTimer`.

* **[GetSelectedText](Lib\getSelectedText.ahk)**  
Gets the selected text without messing up the clipboard (much). This isn't a fool-proof method, but is the best way I could think of.

* **[IsFullScreen](Lib\isFullScreen.ahk)**  
Checks if a window is running in Full screen. Can also optionally detect "Windowed Borderless Mode"

* **[IsOver](Lib\isOver.ahk)**  
    * **isOver_mouse**: Checks if mouse is over a particular window.
    * **isOver_coord**: Checks if a window is over a specified global co-ordinates.

* **[ReloadAsAdmin](Lib\reloadAsAdmin.ahk)**  
    * **reloadAsAdmin**: Reloads the script with administrator permissions
    * **reloadAsAdmin_Task**: Reloads the script with administrator permissions using scheduled tasks. The advantage over the original method is that UAC prompt occurs only the first time the script is elevated. [Code by: [SKAN](http://ahkscript.org/boards/viewtopic.php?t=4334)]

* **[ReloadScriptOnEdit](Lib\ReloadScriptOnEdit.ahk)**  
Asks to reload the script when one of the specified file is edited (uses the _Archive_ flag). [Inspired by: [Avi Aryan](avi-aryan.github.com/ahk/functions/ahkini.html)]

* **[ResourceIDOfIcon](Lib\ResourceIDOfIcon.ahk)**  
Gets the ResourceID of an icon from its Index No. [Code by: [Lexikos](https://autohotkey.com/board/topic/27668-how-to-get-the-icon-group-number/?p=177730)]

* **[Tooltip](Lib\Tooltip.ahk)**  
Provides customizable Tooltips.
    * **Life**: Tooltip is removed automatically after a certain period of time
    * **Format**: Allows changing of background/text font, color etc of the tooltips. This has been disabled temporarily till I can sort out some bugs. [Code by: [Lexikos](https://autohotkey.com/boards/viewtopic.php?t=4777)]

* **[URI](Lib\URI.ahk)**  
`URI_Encode` and `URI_Decode` functions. [Code by: [GeekDude](http://goo.gl/0a0iJq)]

* **[UrlDownload](Lib\urlDownload.ahk)**  
Creates Asynchronous download request and saves the reply text in a variable. Unlike `UrlDownladToFile`, the script doesnot become unresponsive while the URL is downloading.[Code from: [AHK Documentation](https://autohotkey.com/docs/commands/URLDownloadToFile.htm#Examples)]

* **[PasteText](Lib\pasteText.ahk)**  
_Work in Progress_

## Files

* **[Master](Master.ahk)**  
Calls all the other files. None of the other files are supposed to be run by themselves, and many times are interdependent with each other.

* **[Directives](Directives.ahk)**  
Sets up various global settings for the script, as well as define the super-global variables `SCR_Name` and `SCR_hwnd`.

* **[Tray](Tray.ahk)**  
Creates and updates the Tray Icon, Menu and Tip.

* **[SuspendOnFS](suspendonFS.ahk)**  
Suspends hotkeys in FullScreen.

* **[WinProbe](winProbe.ahk)**  

* **[TaskView](Taskview.ahk)**  

* **[HotCorners](hotcorners.ahk)**  
Provides Hot Corner functionality.

* **[WinSizer](winSizer.ahk)**  
Resize/Move Windows. [Inspired by: [NiftyWindows](http://www.enovatic.org/products/niftywindows/features/)]

* **[UnwantedPopupBlocker](UnwantedPopupBlocker.ahk)**  
    * Blocks SublimeText's "This is an unregistered copy" popup
    * Blocks Chrome's "Disable developer mode extensions" popup

* **[Transparent](Transparent.ahk)**  
    * **Transparent_Taskbar**: Makes Taskbar semi-transparent when mouse is not over it.
    * **Transparent_Windows**: Makes all windows defined in `TransGroup` (and not in `noTransGroup`) semi-transparent.
    * **Transparent_ImageGlass**: Makes ImageGlass' Background Transparent.

* **[PIP](PIP.ahk)**  

* **[ToggleKeys](Togglekeys.ahk)**  

* **[MicroWindows](microWindows.ahk)**  

* **[WinAction](winAction.ahk)**  

* **[RunText](runText.ahk)**  

* **[Internet](internet.ahk)**  

* **[AutoUpdate](autoUpdate.ahk)**  
Auto-updates AutoHotKey

* **[KeyRemap](keyRemap.ahk)**  
Defines all the Hotkeys
