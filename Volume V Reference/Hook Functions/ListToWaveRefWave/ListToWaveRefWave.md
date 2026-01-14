# ListToWaveRefWave

ListToTextWave
V-499
You may include asterisks in matchStr as a wildcard character. Note that matching is case-insensitive. See 
StringMatch for wildcard details.
ListSepStr is optional. If omitted it defaults to ";".
See Also
The GrepList, StringMatch, StringFromList, and WhichListItem functions.
ListToTextWave
ListToTextWave(listStr, separatorStr)
The ListToTextWave function returns a free text wave containing the individual list items in listStr.
See Free Waves on page IV-91 for details on free waves.
The ListToTextWave function was added in Igor Pro 7.00.
Parameters
listStr is a string that contains any number of substrings separated by a common string separator.
separatorStr is the separator string that separates one item in the list from the next. It is usually a single 
semicolon character but can be any string.
Details
The ListToTextWave function returns a free wave so it can't be used on the command line or in a macro. If 
you need to convert the free wave to a global wave use MoveWave.
For lists with a large number of items, using ListToTextWave and then retrieving the substrings 
sequentially from the returned text wave is much faster than retrieving the substrings using 
StringFromList.
The reverse operation, converting the contents of a text wave into a string list, can be accomplished using 
wfprintf like this:
WAVE/T tw
String list
wfprintf list, “%s\r”, tw
// Carriage-return separated list
Example
Function Test(num, separator)
Variable num
String separator
// Usually ";"
// Build a string list using separator
String list = ""
Variable i
for(i=0; i<num; i+=1)
list += "item_" + num2str(i) + separator
endfor
// Convert to a text wave and print its elements
Wave/T w = ListToTextWave(list, separator)
Print numpnts(w)
for(i=0; i<num; i+=1)
Print i, w[i]
endfor
End
See Also
ListToWaveRefWave, WaveRefWaveToList, wfprintf
Using Strings as Lists on page IV-172, StringFromList, MoveWave, Free Waves on page IV-91
ListToWaveRefWave
ListToWaveRefWave(stringList [, options])
The ListToWaveRefWave function returns a free wave containing a wave reference for each entry in 
stringList that corresponds to an existing wave.
The ListToWaveRefWave function was added in Igor Pro 7.00.
