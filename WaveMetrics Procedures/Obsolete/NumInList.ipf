// NumInList
#pragma version=1.1
//	Version 1.1:
//		Requires Igor Pro 3.13, uses new built-in strings-as-lists functions.
// Returns number of items in the list
// For example, Print NumInList("ab;cd;ef",";") prints 3
Function NumInList(str, separator)
	String str, separator
	
	return ItemsInList(str,separator)
End
