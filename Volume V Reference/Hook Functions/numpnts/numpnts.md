# numpnts

num2str
V-714
num2str 
num2str(num [, formatStr])
The num2str function returns a string representing the number num.
The optional formatStr parameter was added in Igor Pro 9.00.
If you omit formatStr, the precision of the output string is limited to only five decimal places. This can cause 
unexpected and confusing results. For this reason, we recommend that you specify a larger precision with 
formatStr or use num2istr or sprintf for more control of the format and precision of the number conversion.
Parameters
See Also
printf, sprintf, str2num, char2num, num2char
NumberByKey 
NumberByKey(keyStr, kwListStr [, keySepStr [, listSepStr [, matchCase]]])
The NumberByKey function returns a numeric value extracted from kwListStr based on the specified key 
contained in keyStr. kwListStr should contain keyword-value pairs such as "KEY=value1,KEY2=value2" 
or "Key:value1;KEY2:value2", depending on the values for keySepStr and listSepStr.
Use NumberByKey to extract a numeric value from a strings containing "key1=value1;key2=value2;" 
style lists such as those returned by functions like AxisInfo or TraceInfo.
If the key is not found or if any of the arguments is "" or if the conversion to a number fails then it returns NaN.
keySepStr, listSepStr, and matchCase are optional; their defaults are ":", ";", and 0 respectively.
Details
kwListStr is searched for an instance of the key string bound by listSepStr on the left and a keySepStr on the 
right. The text up to the next listSepStr is converted to the returned number.
kwListStr is treated as if it ends with a listSepStr even if it doesn’t.
Searches for keySepStr and listSepStr are always case-sensitive. Searches for keyStr in kwListStr are usually 
case-insensitive. Setting the optional matchCase parameter to 1 makes the comparisons case sensitive.
In Igor6, only the first byte of keySepStr and listSepStr was used. In Igor7 and later, all bytes are used.
If listSepStr is specified, then keySepStr must also be specified. If matchCase is specified, keySepStr and 
listSepStr must be specified.
Examples
Print NumberByKey("AKEY", "AKEY:123;")
// prints 123
Print NumberByKey("BKEY", "AKEY=123;Bkey=456;", "=")
// prints 456
Print NumberByKey("KEY2", "KEY1=123,KEY2=999,", "=", ",")// prints 999
Print NumberByKey("ckey", "CKEY=123;ckey=456;", "=")
// prints 123
Print NumberByKey("ckey", "CKEY=123;ckey=456;", "=", ";", 1)// prints 456
See Also
The StringByKey, RemoveByKey, ReplaceNumberByKey, ReplaceStringByKey, ItemsInList, AxisInfo, 
IgorInfo, SetWindow, and TraceInfo functions.
numpnts 
numpnts(waveName)
The numpnts function returns the total number of data points in the named wave. To find the number of 
elements in a dimension of a multidimensional wave, use the DimSize function.
num
The value to be converted to string representation.
formatStr
Controls the format of the output string. See printf for details on format strings.
formatStr is optional and requires Igor Pro 9.00 or later.
If you omit formatStr, the format used is "%.5g". For more precision use something 
like "%.15g".
