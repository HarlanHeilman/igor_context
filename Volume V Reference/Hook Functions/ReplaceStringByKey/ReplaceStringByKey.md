# ReplaceStringByKey

ReplaceStringByKey
V-800
See Also
ReplaceStringByKey, CmpStr, StringMatch, strsearch, TrimString, ReplaceString
ReplaceStringByKey 
ReplaceStringByKey(keyStr, kwListStr, newTextStr [, keySepStr
[, listSepStr [, matchCase]]])
The ReplaceStringByKey function returns kwListStr after replacing the text value of the keyword-value pair 
specified by keyStr. kwListStr should contain keyword-value pairs such as "KEY=value1,KEY2=value2" 
or "Key:value1;KEY2:value2", depending on the values for keySepStr and listSepStr.
Use ReplaceStringByKey to add or modify text information in a string containing a 
"key1:value1;key2:value2;" style list such as those returned by functions like AxisInfo or TraceInfo.
If keyStr is not found in kwListStr, then the key and the value are appended to the end of the returned string.
keySepStr, listSepStr, and matchCase are optional; their defaults are ":", ";", and 0 respectively.
Details
The actual string appended is:
[listSepStr] keyStr keySepStr newTextStr listSepStr
The optional leading list separator listSepStr is added only if kwListStr does not already end with a list separator.
kwListStr is searched for an instance of the key string bound by a “;” on the left and a “:” on the right. The 
text up to the next “;” is replaced by newTextStr.
If newTextStr is "", any existing value is deleted, but the key, the key separator, and the list separator are 
retained. To remove a keyword-value pair, use the RemoveByKey function.
kwListStr is treated as if it ends with a listSepStr even if it doesn’t.
Searches for keySepStr and listSepStr are always case-sensitive. Searches for keyStr in kwListStr are case-
insensitive. Setting the optional matchCase parameter to 1 makes the comparisons case-sensitive.
In Igor6, only the first byte of keySepStr and listSepStr was used. In Igor7 and later, all bytes are used.
If listSepStr is specified, then keySepStr must also be specified. If matchCase is specified, keySepStr and 
listSepStr must be specified.
Examples
Print ReplaceStringByKey("KY", "KY:a;KZ:c", "b") 
// prints "KY:b;KZ:c"
Print ReplaceStringByKey("KY", "ky=a;", "b", "=")
// prints "ky=b;"
Print ReplaceStringByKey("KY", "KY:a,", "b", ":", ",")// prints "KY:b,"
Print ReplaceStringByKey("ky", "ZZ:a,", "b", ":", ",")// prints "ZZ:a,ky:b,"
Print ReplaceStringByKey("kz", "KZ:a,", "b", ":", ",")// prints "KZ:b,"
Print ReplaceStringByKey("kz", "KZ:a,", "b", ":", ",", 1)// prints "KZ:a,kz:b,"
See Also
The ReplaceString, ReplaceNumberByKey, NumberByKey, StringByKey, ItemsInList, RemoveByKey, 
AxisInfo, IgorInfo, SetWindow, and TraceInfo functions.
