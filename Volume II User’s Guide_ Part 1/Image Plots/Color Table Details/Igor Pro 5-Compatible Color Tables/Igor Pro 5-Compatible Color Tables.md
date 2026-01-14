# Igor Pro 5-Compatible Color Tables

Chapter II-16 — Image Plots
II-396
Igor Pro 4-Compatible Color Tables
Igor Pro 4 supported 10 built-in color tables: Grays, Rainbow, YellowHot, BlueHot, BlueRedGreen, Red-
WhiteBlue, PlanetEarth, Terrain, Grays16, and Rainbow16. These color tables have 100 color levels except 
for Grays16 and Rainbow16, which only have 16 levels.
Igor Pro 5-Compatible Color Tables
Igor Pro 5 added 256-color versions of the eight 100-level color tables in Igor Pro 4 (Grays256, Rainbow256, 
etc.), new gradient color tables, and new special-purpose color tables.
Igor Pro 5 Gradient Color Tables
These are 256-color transitions between two or three colors.
Color Table Name
Colors
Notes
Red
256
Black  red  white.
Green
256
Black  green  white.
Blue
256
Black  blue  white.
Cyan
256
Black  cyan  white.
Magenta
256
Black  magenta  white.
Yellow
256
Black  yellow  white.
Copper
256
Black  copper  white.
Gold
256
Black  gold  white.
CyanMagenta
256
RedWhiteGreen
256
BlueBlackRed
256

Chapter II-16 — Image Plots
II-397
Igor Pro 5 Special-Purpose Color Tables
The special purpose color tables are ones that will find use for particular needs, such as coloring a digital eleva-
tion model (DEM) of topography or for spectroscopy. These color tables can have any number of color entries.
The following table summarizes the various special-purpose color tables.
Color Table Name
Colors
Notes
Geo
256
Popular mapping color table for elevations. Sea level is around 50%.
Geo32
32
Quantized to classify elevations. Sea level is around 50%.
LandAndSea
255
Rapid color changes above sea level, which is at exactly 50%. Ocean depths 
are blue-gray.
LandAndSea8
8
Quantized, sea level is at about 22%.
Relief
255
Slower color changes above sea level, which is at exactly 50%. Ocean 
depths are black.
Relief19
19
Quantized, sea level is at about 47.5%.
PastelsMap
301
Desaturated rainbow-like colors, having a sharp greenyellow color 
change at sea level, which is around 66.67%. Ocean depths are faded purple.
PastelsMap20
20
Quantized. Sea level is at about 66.67%.
Bathymetry9
9
Colors for ocean depths. Sea level is at 100%.
BlackBody
181
Red  Yellow  Blue colors calibrated to black body radiation colors 
(neglecting intensity). The color table range is from 1,000 K to 10,000 K. 
Each color table entry represents a 50 K interval.
Spectrum
201
Rainbow-like colors calibrated to the visible spectrum when the color table 
range is set from 380 to 780 nm (wavelength). Each color table entry represents 
2nm. Colors do not completely fade to black at the ends of the color table.
SpectrumBlack
476
Rainbow-like colors calibrated to the visible spectrum when the color table 
range is set from 355 to 830 nm (wavelength). Each color table entry 
represents 1 nm. Colors fade to black at the ends of the color table.
Cycles
201
Ten grayscale cycles from 0 to 100% to 0%.
Fiddle
254
Some randomized colors for “fiddling” with an image to detect faint 
details in the image.
Pastels
256
Desaturated Rainbow.
