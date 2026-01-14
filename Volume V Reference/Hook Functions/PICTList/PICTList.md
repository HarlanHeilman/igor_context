# PICTList

Pi
V-742
When identifying a subwindow with graphNameStr, see Subwindow Syntax on page III-92 for details on 
forming the window hierarchy.
Details
The pcsr result is not affected by any X axis.
See Also
The hcsr, qcsr, vcsr, xcsr, and zcsr functions.
Programming With Cursors on page II-321.
Pi 
Pi
The Pi function returns  (3.141592…).
PICTInfo 
PICTInfo(pictNameStr)
The PICTInfo function returns a string containing a semicolon-separated list of information about the 
named picture. If the named picture does not exist, then "" is returned. Valid picture names can be found 
in the Pictures dialog.
Details
The string contains six pieces of information, each prefaced by a keyword and colon and terminated with a 
semicolon.
Examples
Print PICTInfo("PICT_0")
will print the following in the history area:
TYPE:PICT;BYTES:55734;WIDTH:468;HEIGHT:340;PHYSWIDTH:468;PHYSHEIGHT:340;
See Also
The ImageLoad operation for loading PICT and other image file types into waves, and the PICTList 
function. The StringFromList operation for parsing the information string.
See Pictures on page III-509 and Pictures Dialog on page III-510 for general information on picture 
handling.
PICTList 
PICTList(matchStr, separatorStr, optionsStr)
The PICTList function returns a string containing a list of pictures based on matchStr and optionsStr 
parameters. See Details for information on listing pictures in graphs, panels, layouts, and the picture gallery.
Details
For a picture name to appear in the output string, it must match matchStr and also must fit the requirements of 
optionsStr. separatorStr is appended to each picture name as the output string is generated.
Keyword
Information Following Keyword
TYPE
One of: “PICT”, “PNG”, “JPEG”, “Enhanced metafile”, “Windows metafile”, “DIB”, 
“Windows bitmap”, or “Unknown type”.
BYTES
Amount of memory used by the picture.
WIDTH
Width of the picture in pixels.
HEIGHT
Height of the picture in pixels.
PHYSWIDTH
Physical width of the picture in points.
PHYSHEIGHT
Physical height of the picture in points.
