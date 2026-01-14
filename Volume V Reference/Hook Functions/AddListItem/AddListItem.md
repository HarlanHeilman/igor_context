# AddListItem

AddFIFOData
V-20
AddFIFOData 
AddFIFOData FIFOName, FIFO_channelExpr [, FIFO_channelExpr]…
The AddFIFOData operation evaluates FIFO_channelExpr expressions as double precision floating point 
and places the resulting values into the named FIFO.
Details
There must be one FIFO_channelExpr for each channel in the FIFO.
See Also
FIFOs are used for data acquisition. See FIFOs and Charts on page IV-313.
Other operations used with FIFOs: NewFIFO, NewFIFOChan, CtrlFIFO, and FIFOStatus.
AddFIFOVectData 
AddFIFOVectData FIFOName, FIFO_channelKeyExpr [, FIFO_channelKeyExpr]…
The AddFIFOVectData operation is similar to AddFIFOData except the expressions use a keyword to allow 
either a single numeric value for a normal channel or a wave containing the data for a special image vector 
channel.
Details
There must be one FIFO_channelKeyExpr for each channel in the FIFO.
A FIFO_channelKeyExpr may be one of:
num = numericExpression
vect = wave
For best results, the wave should have the same number of points as used to define the FIFO channel and 
the same number type. See the NewFIFOChan operation.
See Also
FIFOs and Charts on page IV-313.
AddListItem 
AddListItem(itemStr, listStr [, listSepStr [, itemNum]])
The AddListItem function returns listStr after adding itemStr to it. listStr should contain items separated by 
listSepStr, such as “abc;def;”.
Use AddListItem to add an item to a string containing a list of items separated by a string (usually a single 
ASCII character), such as those returned by functions like TraceNameList or AnnotationList, or to a line 
from a delimited text file.
listSepStr and itemNum are optional; their defaults are “;” and 0, respectively.
Details
By default itemStr is added to the start of the list. Use the optional list index itemNum to add itemStr at a 
different location. The returned list will have itemStr at the index itemNum or at ItemsInList(returnedListStr)-1 
when itemNum equals or exceeds ItemsInList(listStr).
itemNum can be any value from -infinity (-Inf) to infinity (Inf). Values from -infinity to 0 prepend itemStr 
to the list, and values from ItemsInList(listStr) to infinity append itemStr to the list.
itemStr may be "", in which case an empty item (consisting of only a separator) is added.
If listSepStr is "", then listStr is returned unchanged (unless listStr contains only list separators, in which 
case an empty string ("") is returned).
listStr is treated as if it ends with a listSepStr even if it doesn’t.
In Igor6, only the first byte of listSepStr was used. In Igor7 and later, all bytes are used.
Examples
Print AddListItem("hello","kitty;cat;")
// prints "hello;kitty;cat;"
Print AddListItem("z", "b,c,", ",", 1)
// prints "b,z,c,"
Print AddListItem("z", "b,c,", ",", 999)
// prints "b,c,z,"
