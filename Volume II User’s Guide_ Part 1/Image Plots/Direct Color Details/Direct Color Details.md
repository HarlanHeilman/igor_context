# Direct Color Details

Chapter II-16 — Image Plots
II-401
colorIndexWaveRow = floor(nRows*(log(zImageValue)-log(xMin))/(log(xmax)-log(xMin)))
where,
nRows = DimSize(colorIndexWave,0)
xMin = DimOffset(colorIndexWave,0)
xMax = xMin + (nRows-1) * DimDelta(colorIndexWave,0)
Displaying image data in log mode is slower than in linear mode.
Example: Point-Scaled Color Index Wave
// Create a point-scaled, unsigned 16-bit integer color index wave
Make/O/W/U/N=(1,3) shortindex
// initially 1 row; more will be added
shortindex[0][]= {{0},{0},{0}}
// black in first row
shortindex[1][]= {{65535},{0},{0}}
// red in new row
shortindex[2][]= {{0},{65535},{0}}
// green in new row
shortindex[3][]= {{0},{0},{65535}}
// blue in new row
shortindex[4][]= {{65535},{65535},{65535}}
// white in new row
// Generate sample data and display it using the color index wave
Make/O/N=(30,30)/B/U expmat
// /B/U makes unsigned byte image
SetScale/I x,-2,2,"" expmat
SetScale/I y,-2,2,"" expmat
expmat= 4*exp(-(x^2+y^2))
// test image ranges from 0 to 4
Display;AppendImage expmat
ModifyImage expmat cindex=shortindex
Direct Color Details
Direct color images use a 3D RGB wave with 3 color planes containing absolute values for red, green and 
blue or a 3D RGBA wave that adds an alpha plane. Generally, direct color waves are either unsigned 8 bit 
integers or unsigned 16 bit integers.
For 8-bit integer waves, 0 represents zero intensity and 255 represents full intensity. For alpha, 0 represents fully 
transparent and 255 represents fully opaque.
For all other number types, 0 represents zero intensity but 65535 represents full intensity. For alpha, 0 represents 
fully transparent and 65535 represents fully opaque. Out-of-range values are clipped to the limits.
Try the following example, executing each line one at a time:
Make/O/B/U/N=(40,40,3) matrgb
NewImage matrgb
matrgb[][][0]= 127*(1+sin(x/8)*sin(y/8))
// Specify red, 0-255
matrgb[][][1]= 127*(1+sin(x/7)*sin(y/6))
// Specify green, 0-255
matrgb[][][2]= 127*(1+sin(x/6)*sin(y/4))
// Specify blue, 0-255
-2
-1
0
1
2
-2
-1
0
1
2
