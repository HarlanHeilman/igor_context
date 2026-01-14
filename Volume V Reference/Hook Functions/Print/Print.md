# Print

PrimeFactors
V-769
Examples
Function Test()
Variable oldPrefState
Preferences 1; oldPrefState=V_flag
// remember prefs setting
Make wave0=x
Display wave0
// Display uses preferences
Preferences oldPrefState
// put prefs back, like a macro would
End
See Also
Chapter III-18, Preferences.
PrimeFactors 
PrimeFactors [/Q] inNumber
PrimeFactors calculates the prime factors of inNumber. By default factors are printed in the history and are 
also stored in the wave W_PrimeFactors in the current data folder.
Flags
Details
The largest number that this operation can handle is 232-1.
See Also
gcd, RatioFromNumber
Print 
Print [flags] expression [, expression]…
The Print operation prints the evaluated expressions in the history area.
Parameters
An expression can be a wave, a numeric expression (e.g., 3*/4), a string expression (e.g., "Today is " 
+ date()), or a individual structure element or an entire structure variable.
Flags
Details
Numeric expressions are always evaluated in double precision. The /D flag just controls the number of 
digits displayed.
/Q
Suppresses printing of factors in the history area.
/C
Evaluates all numeric expressions as complex.
/D
Prints a greater number of digits.
/F
Prints numeric wave data (1D and 2D waves only) using “nice,” easily readable formatting.
/LEN=len
Sets the string break length to len number of bytes. The default is 200 and len is clipped to 
between 200 and 2500.
/S
Obsolete. Numeric results are printed with a moderate number of digits whether you use /S 
or not. To print more digits, use /D.
/SR
Prints a wave subrange for expressions that start as “waveName[“. Without /SR, such an 
expression is taken as the start of a numeric expression such as wave[3]-wave[2]. (You can 
still use wave[pnt] but only if it does not start the numeric expression.)
Wave subrange printing is not done with /F.
You can specify a single row or column using [r] syntax. For example, to print column 4 of a 
matrix, use:
Print mymat[][4]
