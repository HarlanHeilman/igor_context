# Notebook (Miscellaneous)

Notebook (Headers and Footers)
V-698
Notebook
(Headers and Footers) 
Notebook headers and footers
You can turn headers and footers on and off and position headers and footers using the keywords in this 
section.
There is currently no way to set the content of headers and footers except manually through the Document 
Settings dialog. You may be able to use stationery files to create files with specific headers and footers.
Notebook
(Miscellaneous) 
Notebook miscellaneous parameters
This section of Notebook relates to setting miscellaneous properties of the notebook.
footerControl={defaultFooter, firstFooter, evenOddFooter}
defaultFooter is 1 to turn the default footer on, 0 to turn it off.
firstFooter is 1 to turn the first page footer on, 0 to turn it off.
evenOddFooter is 1 to turn different footers for even and odd pages on, 0 to use the 
same footer for even and odd pages.
footerPos=pos
pos is the position of the footer relative to the bottom of the page in points.
headerControl={defaultHeader , firstHeader , evenOddHeader}
defaultHeader is 1 to turn the default header on, 0 to turn it off.
firstHeader is 1 to turn the first page header on, 0 to turn it off.
evenOddHeader is 1 to turn different headers for even and odd pages on, 0 to use the 
same header for even and odd pages.
headerPos=pos
pos is the position of the header relative to the top of the page in points.
autoSave=v
frameInset= i
Specifies the number of pixels by which to inset the frame of a notebook subwindow. 
Does not affect a normal notebook window.
This keyword was added in Igor Pro 7.00.
Controls auto-save mode.
This affects notebook subwindows in control panels only. Use autoSave=0 if you 
do not want the notebook's contents to be saved and restored when the control 
panel is recreated. Otherwise the notebook subwindow’s contents will be restored 
when recreated.
v=0:
Notebook subwindow contents will not be saved in recreation 
macros.
v=1:
Notebook subwindow contents will be saved in recreation macros 
(default).

Notebook (Miscellaneous)
V-699
frameStyle= f
status={messageStr, flags}
Sets the message in the status area at the bottom left of the notebook window.
If all bits are zero, the message stays until a new message comes along. All other bits 
are reserved for future use and should be zero. See Setting Bit Parameters on page 
IV-12 for details about bit settings.
updating={flags, r}
Sets parameters related to the updating of special characters.
All other bits are reserved for future use and should be zero. See Setting Bit 
Parameters on page IV-12 for details about bit settings.
r is the update rate in seconds for updating date and time special characters.
These settings have no effect on the updating of special characters in headers or 
footers. These characters are always automatically updated when the document is 
printed.
We recommend that you leave automatic updating off (set bit 0 of the flags parameter 
to 1) so that updating occurs only via the specialUpdate keyword or via the Special 
menu.
visible=v
Specifies the frame style for a notebook subwindow. Does not affect a normal 
notebook window.
The last three styles are fake 3D and will look best if the background color behind 
the subwindow is a light shade of gray.
This keyword was added in Igor Pro 7.00.
f=0:
None.
f=1:
Single.
f=2:
Double.
f=3:
Triple.
f=4:
Shadow.
f=5:
Indented.
f=6:
Raised.
f=7:
Text well.
flags is interpreted bitwise. Message is erased when:
Bit 0:
Selection changes.
Bit 1:
Window is activated.
Bit 2:
Window is deactivated.
Bit 3:
Document is modified.
flags is interpreted bitwise:
Bit 0:
Suppress automatic periodic updating of date and time special 
characters. By default this bit is set so date and time special characters 
are updated only when the user explicitly requests it or during printing 
when they appear in headers and footers.
Bit 1:
Allow manual updating of special characters via the specialUpdate 
keyword or via the Special menu. By default this is cleared so manual 
updating is not allowed.
Sets notebook visibility.
v=0:
Hides notebook.
v=1:
Shows notebook but does not make it top window.
v=2:
Shows notebook and makes it top window.
