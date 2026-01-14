# Enabling and Disabling Special Character Interpretation

Chapter IV-5 — User-Defined Menus
IV-135
In general, Windows does not allow using Ctrl+<punctuation> as an accelerator. Therefore, in the following 
example, the accelerator will not do anything:
Menu "Macros"
"Test/["
// "/[" will not work on Windows.
End
On Windows, you can designate a character in a menu item as a mnemonic keystroke by preceding the 
character with an ampersand:
Menu "Macros"
"&Test", Print "This is a test"
End
This designates “T” as the mnemonic keystroke for Test. To invoke this menu item, press Alt and release it, 
press the “M” key to highlight the Macros menu, and press the “T” key to invoke the Test item. If you hold 
the Alt key pressed while pressing the “M” and “T” keys and if the active window is a procedure window, 
Igor will not execute the item’s command but rather will bring up the procedure window and display the 
menu definition. This is a programmer’s shortcut.
Note:
The mnemonic keystroke is not supported on Macintosh. For this reason, if you care about cross-
platform compatibility, you should not use ampersands in your menu items.
On Macintosh, if you include a single ampersand in a menu item, it does not appear in the menu 
item. If you use a double ampersand, it appears as a single ampersand.
Enabling and Disabling Special Character Interpretation
The interpretation of special characters in menu items can sometimes get in the way. For example, you may 
want a menu item to say “m/s” or “A<B”. With special character interpretation enabled, the first of these 
would become “m” with “s” as the keyboard shortcut and the second would become “A” in a bold typeface.
Igor provides WaveMetrics-defined escape sequences that allow you to override the default state of special char-
acter interpretation. These escape sequences are case sensitive and must appear at the very start of the menu item:
The most common use for this will be in a user-defined menu bar menu in which the default state is on and 
you want to display a special character in the menu item text itself. That is what you can do with the “\\M0” 
escape sequence.
Another possible use on Macintosh is to create a disabled menu item in a control panel, graph or simple input 
dialog pop-up menu. The default state of special character interpretation in pop-up menus is off. To disable 
the item, you either need to turn it on, using “\\M1” or to use the technique described in the next paragraph.
What if we want to include a special character in the menu item itself and have a keyboard shortcut for that 
item? The first desire requires that we turn special character interpretation off and the second requires that 
we turn it on. The WaveMetrics-defined escape sequence can be extended to handle this. For example:
"\\M0:/1:m/s"
The initial “\\M0” turns normal special character interpretation off. The first colon specifies that one or more 
special characters are coming. The /1 makes Command-1 (Macintosh) or Ctrl+1 (Windows) the keyboard short-
cut for this item. The second colon marks the end of the menu commands and starts the regular menu text 
which is displayed in the menu without special character interpretation. The final result is as shown above.
Any of the special characters can appear between the first colon and the second. For example:
Escape Code
Effect
Example
"\\M0"
Turns special character 
interpretation off.
"\\M0m/s"
"\\M1"
Turns special character 
interpretation on.
"\\M1m/s"
