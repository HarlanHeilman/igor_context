# FontList

FontList
V-256
FMaxFlat/SYM 0.25, 0.05, coefs
// Make symmetrical FIR filter
Display coefs
// Analyze the filter's frequency response
FFT/OUT=3/PAD={256}/DEST=coefs_FFT coefs
Display coefs_FFT
// Filter response for 1Hz sample rate
// Make sample data: a sweep from 0 to 20500 Hz
Make/O/N=1000 data= sin(p*p/1000*pi/2)
// 0 to fs/2
SetScale/P x, 0, 1/41000, "s" data
// 41000 Hz sample rate
Display data
// Analyse unfiltered data's frequency content
FFT/OUT=3/PAD={1000}/DEST=data_FFT data
// Data frequency response
Display data_FFT
// Apply filter to copy of data
Duplicate/O data, filtered; DelayUpdate
FilterFIR/DIM=0/COEF=coefs filtered
Display filtered
// Analyse filtered data's frequency content
FFT/OUT=3/PAD={1000}/DEST=filtered_FFT filtered
// Filtered data frequency response
Display filtered_FFT
TileWindows/O=1
// Tile Graphs
References
Elliot, Douglas F.,contributing editor, Handbook of Digital Signal Processing Engineering Applications, 
Academic Press, San Diego, CA, 1987.
Kaiser, J.F., Design subroutine (MXFLAT) for symmetric FIR low pass digital filters with maximally flat pass and 
stop bands.
IEEE Digital Signal Processing Committee, Editor, Programs for Digital Signal Processing, IEEE Press, New 
York, 1979.
See Also
Remez, FilterFIR
FontList 
FontList(separatorStr [, options])
The FontList function returns a list of the installed fonts, separated by the characters in separatorStr.
Parameters
A maximum of 10 bytes from separatorStr are appended to each font name as the output string is generated. 
separatorStr is usually ";".
Use options to limit the returned font list according to font type. It is restricted to returning only scalable 
fonts (TrueType, PostScript, or OpenType), which you can do with options = 1.
To get a list of nonscalable fonts (bitmap or raster), use:
String bitmapFontList = RemoveFromList(FontList(";",1), FontList(";"))
(Most Mac OS X fonts are scalable, so bitmapFontList may be empty.)
Examples
Function SetFont(fontName)
String fontName
Prompt fontName,"font name:",popup,FontList(";")+"default;"
DoPrompt "Pick a Font", fontName
Print fontName
Variable type= WinType("")
// target window type
String windowName= WinName(0,127)
if((type==1) || (type==3) || (type==7))
// graph, panel, layout
Print "Setting drawing font for "+windowName
Execute "SetDrawEnv fname=\""+fontName+"\""
else
if( type == 5 )
// notebook
Print "Setting font for selection in "+windowName
Notebook $windowName font=fontName
endif
