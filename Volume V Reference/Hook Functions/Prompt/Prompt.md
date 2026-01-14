# Prompt

Prompt
V-782
The actual transformation uses Eqs. (22-4) and (22-5) with k' given by (22-3). Here we specify the height H 
is units of sphere radius. The tilt of the plane is specified by omega and gamma following the notation of 
Snyder page 175.
The parameters actually specified by the command are:
/P={H,omega,gamma,deltax,deltay }
H is the height (in radii) above the surface of the earth, gamma is the azimuth east of north of the Y axis, and 
omega is the tilt angle or the angle between the projection plane and the tangent plane. The x output will be 
limited to ± deltax and the y output will be limited to the range ± deltay.
Mercator
This projection requires the following parameters:
/P={minLong,maxLong,minLat,maxLat}
If /P is not specified, the default is {0,360,-90,90}
Note that this projection flips the sign of y when cos(longitude-long_0) changes sign. If you are plotting a 
continuous path in which consecutive points exhibit the sign change, you should add a NaN entry in the 
wave so that the path does not wrap.
Albers Equal Area Conic
This projection requires:
/P={minLong, maxLong, minLat, maxLat, Phi1, Phi2} 
Phi1 and Phi2 are the specification of the two standard parallels, the other four parameters determine the 
boundary of the map area for display.
References 
Snyder, John P., Map Projections—A Working Manual, U.S.G.S. Professional Paper 1395, U.S. Government 
Printing Office, Washington D.C., 1987, reprinted 1989, 1994, 1997 with corrections.
See Also
“Transforming Data into a Common Spatial Reference” in the “IgorGIS Help” file.
Prompt 
Prompt variableName, titleStr [, popup, menuListStr]
The Prompt command is used in functions for the simple input dialog and in macros for the missing 
parameter dialog. Prompt supplies text to describe variableName to the user, and optionally provides a pop-
up menu of choices for the value of variableName.
Parameters
variableName is the name of a macro input parameter or function variable.
titleStr is a string or string expression containing the text to present in the dialog to describe what variableName 
is. titleStr is limited to 255 bytes.
The optional keyword popup is used to provide a pop-up list of choices for the values of variableName. If 
popup is used, then menuListStr is required.
menuListStr is a string or string expression that contains a semicolon-separated list of choices for the value 
of variableName. If variableName is a string, choosing from this list will set the string to the selection. If it is a 
numeric variable, then it is set to the item number of the selection (if the first item is selected, the numeric 
variable is set to 1, etc.).
Details
In macros, there must be a blank line after the set of input parameter declarations and prompt statements 
and there must not be any blank lines within the set.
In user-defined functions, Prompt may be used anywhere within the body of the function, but must precede 
any DoPrompt that uses the Prompt variable.
menuListStr may be continued on succeeding lines only in macros, as long as no comment is appended to 
the Prompt line. The additional lines should start with a semicolon, and are appended to the menuListStrs 
on preceding lines.
