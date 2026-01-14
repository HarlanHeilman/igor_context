# The Color Environment

Chapter III-17 — Miscellany
III-497
When the miter limit is sqrt(2), any line join that is more acute than 90 degrees is truncated. Unfortunately, 
the nature of the truncation depends on the Graphics Technology. Core Graphics (Macintosh), GDI (Win-
dows), PDF and Postscript truncate the miter by reverting to a bevel join; Qt graphics and GDI+ (Windows) 
truncate the miter by beveling at the miter limit. If you export graphics using a bitmap format such as PNG 
or JPG, the miter limit is controled by the graphics technology you have chosen (usually Qt graphics) in the 
Miscellaneous Settings dialog. The second picture above was drawn with Qt graphics as a PNG bitmap; the 
very acute intersection is truncated at the miter limit.
You can control the way line ends are drawn using ModifyGraph lOptions keyword, or for drawn lines 
using SetDrawEnv lineCap.
Line caps can be flat, round or square. These pictures show the appearance of each option; the dots show 
where the geometric end of each line is:
The end cap style is applied at the end of each segment of a dashed line:
Square end caps extend the square end of the line beyond the geometric end and in Igor are probably not 
useful.
The Color Environment
Igor has a main color palette that contains colors that you can use for traces in graphs, text, axes, back-
grounds and so on. The main color palette appears as a pop-up menu in a number of dialogs, such as the 
Modify Trace Appearance dialog. This section discusses this palette.
Igor also has color tables and color index waves you can select among when displaying contour plots and 
images. These are discussed in Chapter II-15, Contour Plots, and Chapter II-16, Image Plots. 
You can select a color from the colors presented in a color palette:
You can use the Other button to select colors that are not in the palette. As you use Igor, colors are added 
to the palette in the Recent Colors area.
Flat
ModifyGraph lOptions=0
SetDrawEnv lineCap=0
Round
lOptions=1
lineCap=1
Square
lOptions=2
lineCap=2
