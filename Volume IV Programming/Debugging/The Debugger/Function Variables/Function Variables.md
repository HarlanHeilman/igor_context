# Function Variables

Chapter IV-8 — Debugging
IV-220
Function Variables
The SlowSumWaveFunction example below illustrates how different kinds of variables in functions are 
classified:
User-defined variables in functions include all items passed as parameters (numerator in this example) and 
any local strings and variables.
Local variables exist while a procedure is running, and cease to exist when the procedure returns; they 
never exist in a data folder like globals do.
NVAR, SVAR, WAVE, Variable/G and String/G references point to global variables, and therefore, aren’t 
listed as user-defined (local) variables.
Use “Igor-created variables” to show local variables that Igor creates for functions when they call an oper-
ation or function that returns results in specially-named variables. The WaveStats operation (see page 
V-1082), for example, defines V_adev, V_avg, and other variables to contain the statistics results:
