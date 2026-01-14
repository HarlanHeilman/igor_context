# Special Menu Characters on Windows

Chapter IV-5 — User-Defined Menus
IV-134
This table shows the special characters and their effect if special character interpretation is enabled. See 
Special Menu Characters on Windows on page IV-134 for Windows-specific considerations.
Whereas it is standard practice to use a semicolon to separate items in a pop-up menu in a control panel, 
graph or simple input dialog, you should avoid using the semicolon in user-defined main-menu-bar 
menus. It is clearer if you use one item per line. It is also necessary in some cases (see Menu Definition 
Syntax on page IV-126).
If special character interpretation is disabled, these characters will appear in the menu item instead of 
having their special effect. The semicolon character is treated as a separator of menu items even if special 
character interpretation is disabled.
Special Menu Characters on Windows
On Windows, these characters are treated as special in menu bar menus but not in pop-up menus in graphs, 
control panels, and simple input dialogs. The following table shows which special characters are supported.
Character 
Behavior
/
Creates a keyboard shortcut for the menu item.
The character after the slash defines the item’s keyboard shortcut. For example, "Low 
Pass/1" makes the item “Low Pass” with a keyboard shortcut for Command-1 
(Macintosh) or Ctrl-1 (Windows). You can also use function keys. To avoid conflicts with 
Igor, use the numeric keys and the function keys only. See Keyboard Shortcuts on page 
IV-136 and Function Keys on page IV-136 for further details.
Keyboard shortcuts are not supported in the graph marquee and layout marquee menus.
-
Creates a divider between menu items.
If a hyphen (minus sign) is the first character in the item then the item will be a disabled 
divider. This can be a problem when trying to put negative numbers in a menu. Use a leading 
space character to prevent this. The string “(-” also disables the corresponding divider.
(
Disables the menu item.
If the first character of the item text is a left parenthesis then the item will be disabled.
!
Adds a mark to the menu item.
If an exclamation point appears in the item, any character after the exclamation point 
adds a checkmark to the left of the menu item. For example:
"Low Pass!*"
makes an item "Low Pass" with an checkmark to the left.
For compatibility with Igor6, use:
"Low Pass!" + num2char(18)
;
Separates one menu item from the next.
Example: "Item 1;Item 2"
Character
Meaning
/
Defines accelerator
-
Divider
(
Disables item
!
Adds mark to item
;
Separates items
