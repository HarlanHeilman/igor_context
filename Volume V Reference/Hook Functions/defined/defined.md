# defined

defined
V-152
See Also
The Default Text Encoding on page III-465, Text Encoding Names and Codes on page III-490
defined 
defined(symbol)
The defined function returns 1 if the symbol is defined 0 if the symbol is not defined.
symbol is a symbol possibly created by a #define statement or by SetIgorOption poundDefine=symbol.
symbol is a name, not a string. However you can use $ to convert a string expression to a name.
Details
The defined function can be used in three ways:
Outside of a procedure using a #if statement
Inside a procedure using a #if statement
Inside a procedure using an if statement
For example:
#define DEBUG
#if defined(DEBUG)
// Outside of a function with #if
Constant kSomeConstant = 100
#else
Constant kSomeConstant = 50
#endif
Function Test1()
// Inside a function with #if
#if defined(DEBUG)
Print "Debugging"
#else
Print "Not debugging"
#endif
End
Function Test1()
// Inside a function with if
if (defined(DEBUG))
Print "Debugging"
else
Print "Not debugging"
endif
End
In these examples, we could have just as well used #ifdef instead of the defined function. For logical 
combinations of conditions however, only defined will do:
#if (defined(SYMBOL1) && defined(SYMBOL2)
. . .
#endif
When used in a procedure window, defined(symbol ) returns 1 if symbol is defined at the time the line is 
compiled. In a given procedure file, only the following symbols are visible:
Symbols defined earlier in that procedure file *
Symbols defined in the built-in procedure window † 
Predefined symbols (see Predefined Global Symbols on page IV-110)
Symbols defined by SetIgorOption poundDefine=symbol
* When used in the body of a procedure, as opposed to outside of a procedure, a symbol defined anywhere 
in a given procedure window is visible. However, to avoid depending on this confusing exception, you 
should define all symbols before they are referenced in a procedure file.
† Symbols defined in the built-in procedure window are not available to independent modules.
When the defined function is used from the command line, only symbols defined in the built-in procedure 
window, predefined symbols, and symbols defined using SetIgorOption are visible.
