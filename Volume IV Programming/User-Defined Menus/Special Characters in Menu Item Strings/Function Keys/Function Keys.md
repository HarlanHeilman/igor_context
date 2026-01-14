# Function Keys

Chapter IV-5 — User-Defined Menus
IV-136
Menu "Macros"
"\\M0:/1:(Cmd-1 on Macintosh, Ctrl+1 on Windows)"
"\\M0:(:(Disabled item)"
"\\M0:!*:(Checked)"
"\\M0:/2!*:(Cmd-2 on Macintosh, Ctrl+2 on Windows and checked)"
End
The \\M escape code affects just the menu item currently being defined. In the following example, special 
character interpretation is enabled for the first item but not for the second:
"\\M1(First item;(Second item"
To enable special character interpretation for both items, we need to write:
"\\M1(First item;\\M1(Second item"
Keyboard Shortcuts
A keyboard shortcut is a set of one or more keys which invoke a menu item. In a menu item string, a key-
board shortcut is introduced by the / special character. For example:
Menu "Macros"
"Test/1"
// The keyboard shortcut is Cmd-1 (Macintosh)
End
// or Ctrl+1 (Windows).
All of the plain alphabetic keyboard shortcuts (/A through /Z) are used by Igor.
Numeric keyboard shortcuts (/0 through /9) are available for use in user menu definitions as are Function 
Keys, described below.
You can define a numeric keyboard shortcut that includes one or more modifier keys. The modifier keys 
are:
For example:
Menu "Macros"
"Test/1"
// Cmd-1, Ctrl+1
"Test/S1"
// Shift-Cmd-1, Ctrl+Shift+1.
"Test/O1"
// Option-Cmd-1, Ctrl+Alt+1
"Test/OS1"
// Option-Shift-Cmd-1, Ctrl+Shift+Alt+1
End
Function Keys
Most keyboards have function keys labeled F1 through F12. In Igor, you can treat a function key as a key-
board shortcut that invokes a menu item.
Note:
Mac OS X reserves nearly all function keys for itself. In order to use function keys for an 
application, you must check a checkbox in the Keyboard control panel. Even then the OS will 
intercept some function keys.
Note:
On Windows, Igor uses F1 for help-related operations. F1 will not work as a keyboard shortcut on 
Windows. Also, the Windows OS reserves Ctrl-F4 and Ctrl-F6 for closing and reordering windows. 
On some systems, F12 is reserved for debugging.
Here is a simple function key example:
Menu "Macros"
"Test/F5"
// The keyboard shortcut is F5.
End
Macintosh:
Shift (S), Option (O), Control (L)
Windows:
Shift (S), Alt (O), Meta (L)
(Meta is often called the “Windows key”.
