# #pragma

#ifdef-#endif
V-17
#ifdef-#endif 
#ifdef symbol
<TRUE part>
[#else
<FALSE part>]
#endif
A #ifdef-#endif conditional compilation statement evaluates symbol. When symbol is defined the code in 
TRUE part is compiled, or if undefined then the optional FALSE part is compiled.
Details
Conditional compiler directives must be either entirely outside or inside function definitions; they cannot 
straddle a function fragment. Conditionals cannot be used within Macros.
symbol must be defined before the conditional with #define.
See Also
The #define statement and Conditional Compilation on page IV-108 for more usage details.
#ifndef-#endif 
#ifndef symbol
<TRUE part>
[#else
<FALSE part>]
#endif
An #ifndef-#endif conditional compilation statement evaluates symbol. When symbol is undefined the code 
in TRUE part is compiled, or if defined then the optional FALSE part is compiled.
Details
Conditional compiler directives must be either entirely outside or inside function definitions; they cannot 
straddle a function fragment. Conditionals cannot be used within Macros.
symbol must be defined before the conditional with #define.
See Also
The #define statement and Conditional Compilation on page IV-108 for more usage details.
#include 
#include "file spec" or <file spec>
A #include statement in a procedure file automatically opens another procedure file. You should use 
#include in any procedure file that you write if it requires that another procedure file be open. A #include 
statement must always appear flush against the left margin in a procedure window.
Parameters
The ".ipf" extension must be omitted from both "file spec" and <file spec>.
The <file spec> syntax is used to include a WaveMetrics procedure file in "Igor Pro Folder/WaveMetrics 
Procedures". file spec is the name of the procedure file without the extension.
The "file spec" syntax is used to include a user procedure file typically in "Igor Pro User Files/User 
Procedures". If file spec is the name of or a partial path to the file, Igor interprets it as relative to the "User 
Procedures" folder. If file spec is a full path then it specifies the exact path to the file without the extension.
See Also
The Include Statement on page IV-166 for usage details.
Igor Pro User Files on page II-31.
#pragma 
#pragma pragmaName = value
#pragma introduces a compiler directive, which is a message to the Igor procedure compiler. A #pragma 
statement must always appear flush against the left margin in a procedure window.
