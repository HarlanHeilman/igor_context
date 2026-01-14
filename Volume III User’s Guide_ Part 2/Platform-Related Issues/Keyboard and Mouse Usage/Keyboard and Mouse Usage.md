# Keyboard and Mouse Usage

Chapter III-15 — Platform-Related Issues
III-452
“server” is the name of the file server and “share” is the name of the top-level shared volume or directory 
on that server.
Because Igor treats a backslash as an escape character, in order to reference this from an Igor command, you 
would have to write:
"\\\\server\\share\\directory\\filename"
As described in the preceding section, you could also use Macintosh HFS path syntax by using a colon in 
place of two backslashes. However, you can not do this for the “\\server\share” part of the path. Thus, 
using Macintosh HFS syntax, you would write:
"\\\\server\\share:directory:filename"
Unix Paths
Unix paths use the forward slash character as a path separator. Igor does not recognize Unix paths. Use 
Macintosh HFS paths instead.
Keyboard and Mouse Usage
This section describes how keyboard and mouse usage differs on Macintosh versus Windows. It is intended 
to help Igor users more easily adapt when switching platforms.
There are three main differences between Macintosh and Windows input mechanisms:
1. The Macintosh mouse may have one button and the Windows mouse has two.
2. The Macintosh keyboard has four modifier keys (Shift, Command, Option, Control) while the Win-
dows keyboard has three (Shift, Ctrl, Alt).
3. The Macintosh keyboard has Return and an Enter keys while the Windows keyboard (usually) has 
two Enter keys.
For the most part, Igor maps between Macintosh and Windows input as follows:
In notebooks, procedure windows and help windows, pressing Control-Return or Control-Enter executes 
the selected text or, if there is no selection, to execute the line of text containing the caret.
Macintosh
Windows
Macintosh
Windows
Shift
Shift
Return
Enter
Command
Ctrl
Enter
Enter
Option
Alt
Control-click
Right-click
Control
<not mapped>
