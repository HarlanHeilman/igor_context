# Direct Reference to Globals

Chapter IV-3 — User-Defined Functions
IV-114
Text After Flow Control
Prior to Igor Pro 4, Igor ignored any extraneous text after a flow control statement. Such text was an error, 
but Igor did not detect it.
Igor now checks for extra text after flow control statements. When found, a dialog is presented asking the 
user if such text should be considered an error or not. The answer lasts for the life of the Igor session.
Because previous versions of Igor ignored this extra text, it may be common for existing procedure files to have 
this problem. The text may in many cases simply be a typographic error such as an extra closing parenthesis:
if( a==1 ))
In other cases, the programmer may have thought they were creating an elseif construct:
else if( a==2 )
even though the “if(a==2)” part was simply ignored. In some cases this may represent a bug in the program-
mer’s code but most of the time it is asymptomatic.
Global Variables Used by Igor Operations
The section Local Variables Used by Igor Operations on page IV-61 explains that certain Igor operations 
create and set certain special local variables. Very old procedure code expects such variables to be created 
as global variables and must be rewritten.
Also explained in Local Variables Used by Igor Operations on page IV-61 is the fact that some operations, 
such as CurveFit, look for certain special local variables which modify the behavior of the operations. For his-
toric reasons, operations that look for special variables will look for global variables in the current data folder 
if the local variable is not found. This behavior is unfortunate and may be removed from Igor some day. New 
programming should use local variables for this purpose.
Direct Reference to Globals
The section Accessing Global Variables and Waves on page IV-65 explains how to access globals from a 
procedure file. Very old procedure files may attempt to reference globals directly, without using WAVE, 
NVAR, or SVAR statements. This section explains how to update such procedures.
Here are the steps for converting a procedure file to use the runtime lookup method for accessing globals:
1.
Insert the #pragma rtGlobals=3 statement, with no indentation, at or near the top of the procedure 
in the file.
2.
Click the Compile button to compile the procedures.
3.
If the procedures use a direct references to access a global, Igor will display an error dialog indicat-
ing the line on which the error occurred. Add an NVAR, SVAR or WAVE reference.
4.
If you encountered an error in step 3, fix it and return to step 2.
