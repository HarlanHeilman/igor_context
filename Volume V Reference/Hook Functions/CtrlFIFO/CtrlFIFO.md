# CtrlFIFO

CtrlFIFO
V-120
Details
The user function you specify via the proc keyword must have the following format:
Function myFunc(s)
STRUCT WMBackgroundStruct &s
…
The members of the WMBackgroundStruct are:
You may also specify a user function that takes a user-defined STRUCT as long as the first elements of the 
structure match the WMBackgroundStruct or, preferably, if the first element is an instance of 
WMBackgroundStruct. Use the started field to determine when to initialize the additional fields. Your 
structure may not include any String, WAVE, NVAR, DFREF or other fields that reference memory that is 
not part of the structure itself.
If you specify a user-defined structure that matches the first fields rather than containing an instance of 
WMBackgroundStruct, then your function will fail if, in the future, the size of the built-in structure 
changes. The value of MAX_OBJ_NAME is 255 but this may also change. It was changed from 31 to 255 in Igor 
Pro 8.00.
Your function should return zero unless it wants to stop in which case it should return 1.
You can call CtrlNamedBackground within your background function. You can even switch to a different 
function if desired.
Use the status keyword to obtain background task information via the S_info variable, which has the format:
NAME:name;PROC:fname;RUN:r;PERIOD:p;NEXT:n;QUIT:q;FUNCERR:e;
When parsing S_info, do not rely on the number of key-value pairs or their order. RUN, QUIT, and FUNCERR 
values are 1 or 0, NEXT is the tick count for the next firing of the task. QUIT is set to 1 when your function 
returns a nonzero value and FUNCERR is set to 1 if your function could not be used for some reason. 
See Also
See Background Tasks on page IV-319 for examples.
Demos
Choose FileExample ExperimentsProgrammingBackground Task Demo.
CtrlFIFO 
CtrlFIFO FIFOName [, key = value]…
The CtrlFIFO operation controls various aspects of the named FIFO.
Parameters
Base WMBackgroundStruct Structure Members
Member
Description
char name[MAX_OBJ_NAME+1]
Background task name.
uint32 curRunTicks
Tick count when task was called.
int32 started
TRUE when CtrlNamedBackground start is issued. You may clear 
or set to desired value.
uint32 nextRunTicks
Precomputed value for next run but user functions may change this.
close
Closes the FIFO’s output or review file (if any).
deltaT=dt
Documents the data acquisition rate.
doffset=dataOffset
Used only with rdfile. Offset to data. If not provided offset is zero.
dsize=dataSize
Used only with rdfile. Size of data in bytes. If not provided, then data size is 
assumed to be the remainder of file. If this assumption is not valid then 
unexpected results may be observed.
flush
New data in FIFO is flushed to disk immediately.
