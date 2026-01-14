# PrintSettings

PrintNotebook
V-775
PrintNotebook 
PrintNotebook [flags] notebookName
The PrintNotebook operation prints the named notebook window.
Parameters
notebookName is either kwTopWin for the top notebook window, the name of a notebook window or a host-
child specification (an hcSpec) such as Panel0#nb0. See Subwindow Syntax on page III-92 for details on 
host-child specifications.
Flags
Details
If no /B flag is given, the default method of handling HiRes PICTs is used (/B=1). Printing of HiRes PICTs is 
not well supported on the Macintosh, so by default it prints them using temporary high resolution bitmaps. 
If a future version of the Mac OS improves in this respect, we will change the default method to print directly.
See Also
Chapter III-1, Notebooks.
The PrintSettings, PrintGraphs, PrintTable and PrintLayout operations.
PrintSettings 
PrintSettings [/I /M /W=winName] [copySource=source, orientation=o, 
margins={left,top,right,bottom}, scale=s, colorMode=m, getPrinterList, 
getPrinter, setPrinter=printerNameStr, getPageSettings, getPageDimensions]
The PrintSettings operation gets or sets parameters associated with printing, such as a list of available 
printers or page setup information for a particular window.
An exception is the graphMode and graphSize keyword pair which affect printing of all graphs. This pair 
was added in Igor Pro 7.00.
Prior to Igor Pro 7.00, PrintSettings applied to a page layout affected the size and orientation of the layout 
page. In Igor Pro 7.00 and later, the size and orientation of the layout page are independent of print settings. 
See Page Layout Page Sizes on page II-478 for details.
When getting or setting page setup information, PrintSettings acts on a particular window called the 
destination window. The destination window is the top graph, table, page layout, or notebook window or 
the window specified by the /W flag.
PrintSettings can not act on page setup records associated with the command window, procedure 
windows, help windows, control panel, XOP windows, or any type of window other than graphs, tables, 
page layouts, and notebooks.
The PrintSettings operation services the keywords in the order shown above, not in the order in which they 
appear in the command. Thus, for example, the getPageSettings and getPageDimensions keywords report 
the settings after all other keywords are executed.
/B=hiResMethod
/P=(startPage,endPage)
Specifies a page range to print. 1 is the first page.
/S=selection
Macintosh only; this flag has no effect on Windows.
hiResMethod=1:
Print HiRes PICTs using high resolution bitmaps.
hiResMethod=0:
Don’t print HiRes PICTs using high resolution 
bitmaps.
hiResMethod=-1:
Print using the default method. Prints HiRes PICTs 
using high resolution bitmaps and is the same as 
method 1.
Controls what is printed.
selection=0:
Print entire notebook (default).
selection=1:
Print selection only.

PrintSettings
V-776
Flags
Keywords
/I
Measurements are in inches. If both /I and /M are omitted, measurements are in 
points.
/M
Measurements are in centimeters. If both /I and /M are omitted, measurements are 
in points.
/W=winName
Acts on the page setup record of the graph, table, page layout, or notebook window 
identified by winName. If winName is omitted or if winName is "", then it used the 
page setup for the top window.
colorMode=m
Sets the color mode for the page setup to monochrome (m=0) or to color (m=1).
This keyword does nothing on Macintosh because it is not supported by Mac OS X.
copySource=source
getPageDimensions
Returns page dimensions via the string variable S_value, which contains keyword-
value pairs that can be extracted using NumberByKey and StringByKey. See 
Details for keyword-value pair descriptions.
getPageSettings
Returns page setup settings in the string variable S_value, which contains keyword-
value pairs that can be extracted using NumberByKey and StringByKey. See 
Details for keyword-value pair descriptions.
getPrinter
Returns the name of the selected printer for the destination window in the string 
variable S_value. On Macintosh the returned value will be "" if the setPrinter 
keyword was never used on the destination window. This means that the window 
will use the operating system’s “current printer”.
getPrinterList
graphMode=g
The graphMode keyword was added in Igor Pro 7.00.
graphSize={left, top, width, height}
Copies page setup settings from the specified source to the destination window. 
source can be the name of a graph, table, page layout, or notebook window or it 
can be one of the following special keywords:
Default_Settings:
Sets the page setup record to the default for the associated 
printer as specified by the printer driver.
Factory_Settings:
Sets the page setup record to the WaveMetrics factory 
default. This is the page setup you get when creating a new 
window with user preferences turned off.
Preferred_Settings: Sets the page setup record to the user preferred page setup. 
This is the page setup you get when creating a new 
window with user preferences turned on. Because there is 
only one page setup for all graphs and one page setup for 
all tables, this has no effect when the destination window 
is a graph or table. It does work for layouts and notebooks.
Returns a semicolon-separated list of printer names in the string variable S_value.
Mac OS X:
Returns a list of printers added through Print Center.
Windows:
Returns the names of any local printers and names of 
network printers to which the user has made previous 
connections.
Sets the printing mode for graphs:
1:
Fill page
2:
Same size
3:
Same aspect ratio
4:
Custom size as set by graphSize keyword
5:
Same size or shrink to fit page (default)

PrintSettings
V-777
Sets the custom graph size used when graphMode is 4. Parameters are in points 
unless /I or /M is used.
Invoking the graphSize keyword automatically sets the graphMode to 4.
left and top are clipped so that they are no smaller than the minimum allowed by the 
printer driver. width and height are not clipped.
This setting is not saved and is set to a default value when Igor starts.
The graphSize keyword was added in Igor Pro 7.00.
margins={left, top, right, bottom}
Sets the page margins. Dimensions are in points unless /I or /M is used.
This setting is ignored for notebook windows. Use the Notebook operation 
pageMargins keyword instead.
The margins are clipped so that they are no smaller than the minimum allowed by 
the printer driver and no larger than one-half the size of the paper.
The terms left, top, right, and bottom refer to the sides of the page after possible 
rotation for landscape orientation.
Passing zero for all four margins sets the margins to the minimum margin allowed 
by the printer.
On Macintosh only, passing -1 for all four margins sets the margins to whatever 
minimum margin is allowed by the printer, even if the printer is changed later. This 
is how Igor Pro behaved on Macintosh prior to the creation of the PrintSettings 
operation, when the minimum printer margins were always used.
orientation=o
Sets the paper orientation to portrait (o=0) or to landscape (o=nonzero).
scale=s
In Igor Pro 7 and later, the scale keyword returns an “unimplemented” error, unless 
s=100, because it is currently not supported. Let us know if this feature is important 
to you. Though s=100 does not generate an error, it does nothing. You can still set 
the scaling manually using the Page Setup dialog.
setPrinter=printerNameStr
Sets the selected printer for the destination window.
SetPrinter attempts to preserve orientation, margins, scale, and color mode but 
other settings may revert to the default state.
printerNameStr is a name as returned by the getPrinterList keyword and may not be 
identical to the name displayed in various dialogs. For example, on Mac OS X, the 
printer name “DESKJET 840C” is returned by getPrinterList as “DESKJET_840C”. 
The latter is the “Queue Name” displayed by the Mac OS X Print Center or Printer 
Setup Utility programs.
If you receive an error when using setPrinter, use the getPrinterList keyword to 
verify that the printer name you are using is correct. Verify that the printer is 
connected and turned on.
Windows printer names are sometimes UNC names of the form 
“\\Server\Printer”. You must double-up backslashes when using a UNC name in 
a literal string. See UNC Paths on page III-451 for details.
If printerNameStr is "", the printer for the destination window is set to the default 
state. This means different things depending on the operating system:
Mac OS X:
The destination window will use the operating system’s 
“current printer”, as if the setPrinter keyword had never 
been used.
Windows:
The destination window will use the system default 
printer.

PrintSettings
V-778
Details
All graphs in the current experiment share a single page setup record so if you change the page setup for 
one graph, you change it for all graphs.
All tables in the current experiment share a single page setup record.
Each page layout window has its own page setup record.
Each notebook window has its own page setup record.
The keyword-value pairs for the getPageSettings keyword are as follows:
The keyword-value pairs for the getPageDimensions keyword are as follows:
Examples
For an example using the PrintSettings operation, see the PrintSettings Tests example experiment file in the 
“Igor Pro Folder:Examples:Testing” folder.
Here are some simple examples showing how you can use the PrintSettings operation.
Function GetOrientation(name)
// Returns 0 (portrait) or 1 (landscape)
String name
// Name of graph, table, layout or notebook
PrintSettings/W=$name getPageSettings
Variable orientation = NumberByKey("ORIENTATION", S_value)
return orientation
End
Function SetOrientationToLandscape(name)
String name
// Name of graph, table, layout or notebook
PrintSettings/W=$name orientation=1
End
Function/S GetPrinterList()
PrintSettings getPrinterList
return S_value
End
Function SetPrinter(destWinName, printerName)
String destWinName, printerName
PrintSettings/W=$destWinName setPrinter=printerName
return 0
End
Keyword
Information Following Keyword
ORIENTATION: 0 if the page is in portrait orientation, 1 if it is in landscape orientation.
MARGINS:
The left, top, right, and bottom margins in points, separated by commas.
These margins are ignored for notebook windows. Use the Notebook operation 
pageMargins keyword instead.
SCALE:
The page scaling expressed in percent. 50 means that the graphics are drawn at 50% of 
their normal size.
COLORMODE:
0 for black&white, 1 for color. This is not supported on Macintosh and always returns 1.
Keyword
Information Following Keyword
PAPER:
The left, top, right, and bottom coordinates of the paper in points, separated by 
commas. The top and left are negative numbers so that the page can start at (0,0).
PAGE:
The left, top, right, and bottom coordinates of the page in points, separated by commas. The 
term page refers to the part of the paper inside the margins. The top/left corner of the page 
is always at (0, 0).
PRINTAREA:
The left, top, right, and bottom coordinates of the page in points, separated by commas. 
The print area is the part of the paper on which printing can occur, as determined by 
the printer. This is equal to the paper inset by the minimum supported margins. The top 
and left are negative numbers so that the page can start at (0,0).
