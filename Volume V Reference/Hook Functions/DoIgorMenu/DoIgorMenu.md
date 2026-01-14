# DoIgorMenu

DoIgorMenu
V-166
See Also
The Abort operation.
DoIgorMenu 
DoIgorMenu [/C /OVRD] MenuNameStr, MenuItemStr
The DoIgorMenu operation allows an Igor programmer to invoke Igor’s built-in menu items. This is useful 
for bringing up Igor’s built-in dialogs under program control.
Parameters
Flags
Using both the /C and the /OVRD flag in one command is not permitted.
Details
All menu names and menu item text are in English to ensure that code developed for a localized version of 
Igor Pro will run on all versions. Note that no trailing “…” is used in MenuItemStr.
V_flag is set to 1 if the corresponding menu item was enabled, which usually means the menu item was 
successfully selected. Otherwise V_flag is 0. V_flag does not reflect the success or failure of the resulting 
dialog, if any.
V_isInvisible, added in Igor Pro 7, is set to 1 if the corresponding menu item was invisible. This is fairly rare 
- in most cases V_isInvisible will be set to 0. Invisible menu items are items like FileAdopt All which are 
hidden unless the user presses the shift key while summoning the menu. This is different from menus items 
hidden by HideIgorMenus for which V_isInvisible is set to 0.
S_value, added in Igor Pro 9.00, is set to the translated menu item text. This can be useful for always-enabled 
menu items that toggle between to states like Show Tools and Hide Tools.
If the menu item selection displays a dialog that generates a command, clicking the Do It button executes the 
command immediately without using the command line as if Execute/Z operation had been used. Clicking the 
To Cmd Line button appends the command to the command line rather than inserting the command at the front.
MenuNameStr
The name of an Igor menu or submenu, like “File”, “Graph”, or “Load Waves”.
MenuItemStr
The text of an Igor menu item, like “Copy” (in the Edit menu) or “New Graph” (in the 
Windows menu) or “Load Igor Binary” (in the Load Waves submenu).
If you include /C, MenuItemStr can be "".
/C
Just Checking. The menu item is not invoked, but V_flag is set to 1 if the item was 
enabled or to 0 if it was not enabled.
In Igor Pro 9.01 and later, if MenuItemStr is "", then V_Flag, V_isInvisible, and S_value 
pertain to the menu instead of a menu item.
/OVRD
Tells Igor to skip checks that it normally does before executing the menu command 
specified by MenuNameStr and MenuItemStr. You are responsible for ensuring that the 
menu command you are invoking is appropriate under conditions existing at 
runtime.
The main use for the /OVRD flag is to allow an advanced programmer to invoke a 
menu command for a menu that is currently hidden when dealing with subwindows. 
For example, if you have a graph subwindow in a control panel which is in operate 
mode, the Graph menu is not visible in the menu bar. Normally the user could not 
invoke an item, such as Modify Trace Appearance.
/OVRD allows you to invoke the menu command, but it is up to you to verify that it 
is appropriate. In the Modify Trace Appearance example, you should invoke the 
menu command only if the active window or subwindow is a graph that contains at 
least one trace.
/OVRD was added in Igor Pro 7.00.
