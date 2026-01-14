# Searching Igor Files

Chapter II-1 — Getting Help
II-3
When Igor starts up, it automatically creates help windows by opening the Igor help files stored in "Igor 
Pro Folder/Igor Help Files" and in "Igor Pro User Files/Igor Help Files". You can display a help window 
using the Help Files tab of the Help Browser or by choosing it from the Help Windows submenu in the Help 
menu.
To see a list of topics in open help files, use the Igor Help Browser Help Topics tab.
To search all installed help files, whether open or not, use the Igor Help Browser Search Igor Files tab.
Hiding and Killing a Help Window
When you click the close button in a help window, Igor hides it.
Usually there is no reason to kill a help file, but if you want to kill one, you must press Option (Macintosh) 
or Alt (Windows) while clicking the close button.
Executing Commands from a Help Window
Help windows often show example Igor commands. To execute a command or a section of commands from 
a help window, select the command text and press Control-Enter or Control-Return. This sends the selected 
text to the command line and starts execution.
Tooltips
Igor provides tooltips for various icons, dialog items, and other visual features. You can turn these tips on 
or off using the Show Tooltips checkbox in the Miscellaneous Settings dialog. To display this setting, choose 
MiscMiscellaneous Settings and select the Help category.
You can also use tooltips to get information about traces in graphs and columns in tables. Use 
GraphShow Trace Info Tags and TableShow Column Info Tags to turn these tips on and off.
Searching Igor Files
You can search Igor help files and procedure files using the Search Igor Files tab of the Igor Help Browser.
The search expression can consist of one or more (up to 8) terms. Terms are separated by the word “and”. 
Here are some examples:
The second example finds the exact phrase “spline interpolation” while the third example finds sections 
that contain the words “spline” and “interpolation”, not necessarily one right after the other.
The only keyword supported in the search expression is “and”. Quotation marks in the search expression 
don’t mean anything special and should not be used.
If your search expression includes more than one term, a text box appears in which you can enter a number 
that defines what “and” means. For example, if you enter 10, this means that the secondary terms must 
appear within 10 paragraphs of the primary term to constitute a hit. A value of 0 means that the terms must 
appear in the same paragraph. In a plain text file, such as a procedure file, a paragraph is a single line of 
text. Blank lines count as one paragraph.
To speed up searches when entering multiple search terms, enter the least common term first. For example, 
searching help files for “hidden and axis and graph” is faster than searching for “graph and axis and 
hidden” because “hidden” is less common than “graph”.
interpolation
One term
spline interpolation
One term
spline and interpolation
Two terms
spline and interpolation and smoothing
Three terms
