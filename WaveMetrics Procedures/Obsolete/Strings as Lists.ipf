// <Strings as Lists>
//
// NOTE:	This procedure file is obsolete (except for PossiblyQuoteList).
//
//			Most of these functions have been replaced by more-capable builtin functions
//			which you can call directly for improved speed.
//
#pragma version=6.1
//
//	Version 6.1:
//		WhichItemInList() now calls built-in WhichListItem function.
//	Version 1.4:
//		Removed obsolete comment chars, slight rewrite of WhichItemInList()
//	Version 1.3:
//		Fixed WhichItemInList bug, where it returned 0 if item not found, instead of -1.
//	Version 1.2:
//		Requires Igor Pro 3.13, uses new built-in strings-as-lists functions.
//		Added WhichItemInList().
//	Version 1.1:
//		Added PossiblyQuoteList to support liberal names.

// GetStrFromList(str, n, separator)
//	Returns the nth substring in str.
//	str is  separated list of strings optionally with separator at the end. For example:
//		"Red;White;Blue;"
//		or
//		"Red;White;Blue"
//	n is zero-based
//
Function/S GetStrFromList(str, n, separator)
	String str,separator
	Variable n
	
	return StringFromList(n, str,separator)
End

// FindItemInList(item, list, separator, offset)
//	Returns offset to start of the item in the list or -1 if not found.
//	Starts searching from offset.
//	The list is expected to be a standard separated list, like "wave0;wave1;wave2;".
//	This is used mostly to check if a given item is in a list.
Function FindItemInList(item, list, separator, offset)
	String item
	String list
	String separator
	Variable offset
	
	return FindListItem(item, list, separator, offset)
End

// WhichItemInList(list,item,separator)
//	Returns zero-based index into list where item was found.
//	Example:
//		Print WhichItemInList("a;b;c;d;", "c", ";")
//		Output:		2
Function WhichItemInList(list,item,separator)
	String list, item, separator
	
	return WhichListItem(item, list, separator)
End


// RemoveItemFromList(item, list, separator)
//	Returns the list with the first instance of item removed.
//	The list is expected to be a standard separated list, like "wave0;wave1;wave2;".
//	If item is "wave1", the returned list would be "wave0;wave2;".
Function/S RemoveItemFromList(item, list, separator)
	String item
	String list
	String separator
	
	return RemoveFromList(item, list, separator)
End


// PossiblyQuoteList(list, separator)
//	Input is a list of names that may contain liberal names.
//	The input list is expected to be a standard separated list, like "wave0;wave1;wave2;".
//	Returns the list with liberal names quoted.
//	Example:
//		Input:		"wave0;wave 1;"
//		Output:		"wave0;'wave 1';"
Function/S PossiblyQuoteList(list, separator)		// Added in version 1.1 of this file.
	String list
	String separator
	
	String item, outputList = ""
	Variable i= 0
	Variable items= ItemsInList(list, separator)
	do
		if (i >= items)			// no more items?
			break
		endif
		item= StringFromList(i, list, separator)
		outputList += PossiblyQuoteName(item) + separator
		i += 1
	while(1)
	return outputList
End
