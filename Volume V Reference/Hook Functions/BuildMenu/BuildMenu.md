# BuildMenu

break
V-54
break 
break
The break flow control keyword immediately terminates execution of a loop, switch, or strswitch. 
Execution then continues with code following the loop, switch, or strswitch.
See Also
Break Statement on page IV-48, Switch Statements on page IV-43, and Loops on page IV-45 for usage 
details.
BrowseURL 
BrowseURL [/Z] urlStr
The BrowseURL operation opens the Web browser or FTP browser on your computer and asks it to display 
a particular Web page or to connect to an FTP server.
BrowseURL sets a variable named V_flag to zero if the operation succeeds and to nonzero if it fails. This, in 
conjunction with the /Z flag, can be used to allow procedures to continue to execute if an error occurs.
Parameters
urlStr specifies a Web page or FTP server directory to be browsed. It is constructed of a naming scheme (e.g., 
“http://” or “ftp://”), a computer name (e.g., “www.wavemetrics.com” or “ftp.wavemetrics.com” or 
“38.170.234.2”), and a path (e.g., “/Test/TestFile1.txt”). See Examples for sample usage.
Flags
Examples
// Browse a Web page.
String url = "http://www.wavemetrics.com/News/index.html"
BrowseURL url
// Browse an FTP server.
String url = "ftp://ftp.wavemetrics.com/pub/test"
BrowseURL url
See Also
URLRequest
BuildMenu 
BuildMenu menuNameStr
The BuildMenu operation rebuilds the user-defined menu items in the specified menu the next time the 
user clicks in the menu bar.
Parameters
menuNameStr is a string expression containing a menu name or "All".
Details
Call BuildMenu when you’ve defined a custom menu using string variables for the menu items. After you 
change the string variables, call BuildMenu to update the menu.
BuildMenu "All" rebuilds all the menu items and titles and updates the menu bar.
Under the current implementation, if menuNameStr is not "All", Igor will rebuild all user-defined menu 
items if BuildMenu is called for any user-defined menu.
See Also
Dynamic Menu Items on page IV-129.
/Z
Errors are not fatal. Will not abort procedure execution if the URL is bad or if the 
server is down. Your procedure can inspect the V_flag variable to see if the transfer 
succeeded. V_flag will be zero if it succeeded or nonzero if it failed.
Syntactic errors, such as omitting the URL altogether or omitting quotes, are still fatal.
