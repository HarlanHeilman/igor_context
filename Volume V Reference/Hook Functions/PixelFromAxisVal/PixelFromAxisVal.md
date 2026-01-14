# PixelFromAxisVal

Picture
V-743
The name of each picture is compared to matchStr, which is some combination of normal characters and the 
asterisk wildcard character that matches anything. For example:
matchStr may begin with the ! character to return items that do not match the rest of matchStr. For example:
The ! character is considered to be a normal character if it appears anywhere else, but there is no practical 
use for it except as the first character of matchStr.
optionsStr is used to further qualify the picture.
Use "" accept all pictures in the Pictures Dialog that are permitted by matchStr.
Use the WIN: keyword to limit the pictures to the named or target window:
Examples
See Also
The ImageLoad operation for loading PICT and other image file types into waves, and the PICTInfo 
function. Also the StringFromList function for retrieving items from lists.
See Pictures on page III-509 and Pictures Dialog on page III-510 for general information on picture 
handling.
Picture 
Picture pictureName
The Picture keyword introduces an ASCII code picture definition of binary image data.
See Also
Proc Pictures on page IV-56 for further information.
PixelFromAxisVal 
PixelFromAxisVal(graphNameStr, axNameStr, val)
The PixelFromAxisVal function returns the local graph pixel coordinate corresponding to the axis value in 
the graph window or subwindow.
Parameters
graphNameStr can be "" to refer to the top graph window.
"*"
Matches all picture names.
"xyz"
Matches picture name xyz only.
"*xyz"
Matches picture names which end with xyz.
"xyz*"
Matches picture names which begin with xyz.
"*xyz*"
Matches picture names which contain xyz.
"abc*xyz"
Matches picture names which begin with abc and end with xyz.
"!*xyz"
Matches picture names which do not end with xyz.
"WIN:"
Match all pictures displayed in the top graph, panel, or layout.
"WIN:windowName"
Match all pictures displayed in the named graph, panel, or layout window.
PICTList("*",";","")
Returns a list of all pictures in the Pictures Dialog.
PICTList("*", ";","WIN:")
Returns a list of all pictures displayed in the top panel, graph, or 
layout.
PICTList("*_bkg", ";", "WIN:Layout0")
Returns a list of pictures whose names end in “_bkg” and which are 
displayed in Layout0.
