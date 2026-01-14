// <Keyword-Value>
#pragma version=1.2
//	Version 1.2:
//		Requires Igor Pro 3.13, uses new built-in strings-as-lists functions.

// StrByKey parses "key:value;key2:value2;" list
// Returns the string value string given the corresponding key
//
Function/S StrByKey(key,str)
	String key,str
	
	return StringByKey(key,str)
End

// NumByKey parses "key:value;key2:value2;" list
// Returns the numeric value of the string given the corresponding key, or NaN
//
Function/D NumByKey(key,str)
	String key,str
	
	return NumberByKey(key,str)
End

// ReplaceStrByKey replaces "<key>:<str>;" in the list, or adds it to the start of the list
// list is usually a global string containing lots of settings,
// each setting with a unique key.
// Note: we ASSUME that key and str do not contain either the ':' or ';' character
// (if it does, the list is damaged). Any other character, however, is okay.
// Returns the new list.
//
// Usage: listStr= ReplaceStrByKey(listStr,"DayOfWeek","Monday")
//
Function/S ReplaceStrByKey(list,key,str)	
	String list,key,str

	return ReplaceStringByKey(key, list,str)
End

// ReplaceNumByKey replaces "<key>:<value>;" in the list,
//  or adds it to the start of the list
// Returns the new list.
//
// Usage: listStr= ReplaceNumByKey(listStr,"angle of attack",3.14159/16)
//
Function/S ReplaceNumByKey(list,key,num)
	String list,key
	Variable num

	return ReplaceNumberByKey(key,list,num)
End

// DeleteByKey removes "<key>:<str>;" from the list, if it exists.
// Returns the new list.
//
// Usage: listStr= DeleteByKey(listStr,"key to delete")
//
Function/S DeleteByKey(list,key)	
	String list,key

	return RemoveByKey(key,list) 
End


