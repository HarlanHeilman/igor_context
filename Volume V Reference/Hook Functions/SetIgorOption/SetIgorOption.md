# SetIgorOption

SetIgorMenuMode
V-851
See Also
The SetWindow operation and User-Defined Hook Functions on page IV-280.
Independent Modules on page IV-238.
SetIgorMenuMode 
SetIgorMenuMode MenuNameStr, MenuItemStr, Action
The SetIgorMenuMode operation allows an Igor programmer to disable or enable Igor’s built-in menus and 
menu items. This is useful for building applications that will be used by end-users who shouldn’t have 
access to all Igor’s extensive and confusing functionality.
Parameters
Details
All menu names and menu item text are in English. This ensures that code developed for a localized version 
of Igor will run on all versions. Note that no trailing “...” is used in MenuItemStr.
The SetIgorMenuModeProc.ipf procedure file includes procedures and commands that disable or enable 
every menu and item possible. It is in your Igor Pro folder, in WaveMetrics Procedures:Utilities. It is not 
intended to be used as-is. You should make a copy and edit the copy to include just the parts you need.
The text of some items in the File menu changes depending on the type of the active window. In these cases 
you must pass generic text as the MenuItemStr parameter. Use “Save Window”, “Save Window As”, “Save 
Window Copy”, “Adopt Window” and “Revert Window” instead of “Save Notebook” or “Save Procedure”, 
etc. Use “Page Setup” instead of “Page Setup For All Graphs”, etc. Use “Print” instead of “Print Graph”, etc.
The EditInsert File menu item was previously named Insert Text. For compatibility reasons, you can specify 
either "Insert File" or "Insert Text" as MenuItemStr to modify this item.
See Also
DoIgorMenu, ShowIgorMenus, HideIgorMenus
The SetIgorMenuModeProc.ipf WaveMetrics procedure file contains SetIgorMenuMode commands for every 
menu and menu item. You can load it using
#include <SetIgorMenuModeProc>
SetIgorOption 
SetIgorOption [mainKeyword,] keyword= value
SetIgorOption [mainKeyword,] keyword= ?
The SetIgorOption operation makes unusual and temporary changes to Igor Pro's behavior. The behavior 
changes are of interest to advanced users only and last only until you end the Igor session.
The details of the syntax depend on the keyword and are documented where the alternate behaviors are 
described.
SetIgorOption is not compilable. To use it in a user-defined function, you need to use Execute.
In most cases the current value of a setting can be read using the keyword=? syntax.
For example, the IndependentModuleDev keyword is used to enable editing of procedure files that 
implement independent modules: 
MenuNameStr
The name of an Igor menu, like “File”, “Graph”, or “Load Waves”.
MenuItemStr
The text of an Igor menu item, like “Copy” (in the Edit menu) or “New Graph” (in the 
Windows menu). For menu items in submenus, such as the “Load Waves” submenu 
in the “Data” menu, MenuItemStr is the name of the submenu.
Action
One of DisableItem, EnableItem, DisableAllItems, or EnableAllItems.
DisableItem and EnableItem disable or enable just the single item named by 
MenuNameStr and MenuItemStr. If MenuItemStr is "", then the menu itself is disabled.
DisableAllItems and EnableAllItems disable and enable all the items in the menu 
named by MenuNameStr.
