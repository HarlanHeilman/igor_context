# DataFolderDir

DataFolderDir
V-141
We have encountered two different definitions for the Morlet wavelet in the literature. The first is a complex 
function (MorletC) and the second is real (Morlet). Instead of choosing one of these definitions we 
implemented both so you may choose the appropriate wavelet.
See Also
For discrete wavelet transforms use the DWT operation. The WignerTransform and FFT operations.
For further discussion and examples see Continuous Wavelet Transform on page III-282.
References
Torrence, C., and G.P. Compo, A Practical Guide to Wavelet Analysis, Bulletin of the American Meteorological 
Society, 79, 61-78, 1998.
The Torrence and Compo paper is also online at: 
<http://paos.colorado.edu/research/wavelets/>.
DataFolderDir 
DataFolderDir(mode [, dfr ])
The DataFolderDir function returns a string containing a listing of some or all of the objects contained in 
the current data folder or in the data folder referenced by dfr.
Parameters
mode is a bitwise flag for each type of object. Use -1 for all types. Use a sum of the bit values for multiple 
types.
dfr is a data folder reference.
Details
The returned string has the following format:
1.
FOLDERS:name,name,…;<CR>
2.
WAVES:name,name,…;<CR>
3.
VARIABLES:name,name,…;<CR>
4.
STRINGS:name,name,…;<CR>
Where <CR> represents the carriage return character.
Tip
This function is mostly useful during debugging, used in a Print command. For finding the contents of a data 
folder programmatically, it will be easier to use the functions CountObjects and GetIndexedObjName.
Examples
Print DataFolderDir(8+4)
// prints variables and strings
Print DataFolderDir(-1)
// prints all objects
See Also
Chapter II-8, Data Folders.
Setting Bit Parameters on page IV-12 for information about bit settings.
Desired Type
Bit Number
Bit Value
All
-1
Data folders
0
1
Waves
1
2
Numeric variables
2
4
String variables
3
8
