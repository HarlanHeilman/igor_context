#pragma rtGlobals=1		// Use modern global access method.
#include <Strings as Lists>
#include <NumInList>

//  AlphabetizeList(instring, separator)
//  This simple string function takes an input string (instring) and returns an alphabetized
//  version of instring. instring is in the standard format of a list of strings sepatated by a
//  separator character (separator) optionally with a separator at the end. For example:
//               "Red;White;Blue;"
// This function was written for alphabetizing popup lists, but could be used in other situations.
// Written by: boydjd@ctrvax.Vanderbilt.Edu (jamie boyd)
// Version 1.1: Fixed: Alphabetizing a list of one item created a list of two items. jsp

Function/s AlphabetizeList(instring, separator)
	string instring, separator
	
	if( NumInList(instring,separator) < 2 )
		return instring
	endif
	
	string outstring = GetStrFromList(instring, 0, separator)+separator     // will contain the alphabetized output string
	string tempin = ""          // will contain an element of the input string
	string tempout = ""         // will contain an element of the output string 
	                                                                           
	                                    
	variable offset		// offset to insertion point           
	variable ii=1		// position within instring
	variable oi			// position within outstring
	
	// The outer loop sequentially passes every member of
	// the input string (tempin) into the inner loop.
	
	do
	        tempin= GetStrFromList(instring, ii, separator)
	         oi = 0                 // position within outstring
	        
		// The inner loop searches through the output string  (tempout) to find the right 
		// place for the member of the input string passed to it by the outer loop.
	
	        do
	                tempout=(GetStrFromList(outstring, oi, separator))
	                
			// If tempin is alphabetically before tempout, insert it, otherwise, move to the next
			// member of outstring.  Unless tempin is alphabetically first, adjust insertion point
			// by one place for the  leading separator like so:  + (oi != 0)
	
	                if (cmpstr(tempin, tempout) < 0)
	                         offset =  ((FindItemInList(tempout, outstring, separator, 0))-1)
	                         outstring=outstring [0, offset] + tempin + separator + outstring [(offset+(oi != 0)), inf]
	                        break
	                else
	                        oi+=1
	                endif
	        while(oi < NumInList(outstring, separator))
	        
		// If you get all the way to the end of outstring , tempin must be alphabetically last
	
	        if (oi ==  NumInList(outstring, separator))
	                outstring = outstring [0, inf] + tempin + separator
	        endif
	        ii+=1
	while(ii < NumInList(instring, separator))
	return  outstring
end
