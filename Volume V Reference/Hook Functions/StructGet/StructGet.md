# StructGet

StructGet
V-1003
Flags
Output Variables
StructFill sets the following output variables:
If auto-creation is off, a field can not be initialized if the corresponding global variable, string variable, or 
wave does not exist. If auto-creation is on, a field can not be initialized if there was an error creating the 
global variable or wave.
When using auto-creation, errors are not reported other than via V_Error.
If you unexpectedly get non-zero for V_Error, you can print the structure to see which fields were left null.
See Also 
Structures in Functions on page IV-99
StructGet 
StructGet [/B=b] structVar, waveStruct[[colNum]]
StructGet /S [/B=b] structVar, strStruct
The StructGet operation reads binary numeric data from a specified column of a wave or from a string 
variable and copies the data into the designated structure variable. The source wave or string will have been 
filled beforehand by StructPut.
Parameters
structVar is the name of an existing structure that is to be filled with new data values.
waveStruct is the name of a wave containing binary numeric data that will be used to fill structVar. Use the 
optional colNum parameter to specify a column from the structure wave. The contents of waveStruct are 
created beforehand using StructPut.
strStruct is the name of a string variable containing binary numeric data. The contents of strStruct are 
created beforehand using StructPut.
Flags
Details
The data that are stored in waveStruct and strStruct are in binary format so you can not directly view a 
meaningful representation of their contents by printing them or viewing the wave in a table. To view the 
contents of waveStruct or strStruct you must use StructGet to export them back into a structure and then 
retrieve the members.
/AC=createFlags
Enables auto-creation of globals.
Bit 0 enables creation of numeric and string global variables which are set to 0 and "" 
respectively. Variables are auto-created only if they do not already exist.
Bit 1 enables creation of waves which are created with zero points. Waves are auto-
created only if they do not already exist.
/SDFR=dfr 
Specifies a data folder. If you omit /SDFR, the current data folder used.
See The /SDFR Flag on page IV-80 for details.
V_Flag
The number of NVAR, SVAR and WAVE fields that were successfully initialized.
V_Error
The number of NVAR, SVAR and WAVE fields that could not be initialized. 
/B=b
/S
Reads binary data from a string variable, which was set previously with StructPut.
Sets the byte ordering for reading of structure data.
b=0:
Reads in native byte order.
b=1:
Reads bytes in reversed order.
b=2:
Default; reads data in big-endian, high-byte-first order (Motorola).
b=3:
Reads data in little-endian, low-byte-first order (Intel).
