# acosh

AbortOnValue
V-19
AbortOnRTE has very low overhead and should not significantly slow program execution.
Details
In terms of programming style, you should consider using AbortOnRTE (preceded by a semicolon) on the 
same line as the command that may give rise to an abort condition.
When using AbortOnRTE after a related sequence of commands, then it should be placed on its own line.
When used with try-catch-endtry, you should place a call to GetRTError(1) in your catch section to clear 
the runtime error.
Example
Abort if the wave does not exist:
WAVE someWave; AbortOnRTE
See Also
Flow Control for Aborts on page IV-48 and AbortOnRTE Keyword on page IV-49 for further details.
The try-catch-endtry flow control statement.
AbortOnValue 
AbortOnValue abortCondition, abortCode
The AbortOnValue flow control keyword will abort function execution when the abortCondition is nonzero 
and it will then return the numeric abortCode. No dialog will be displayed when such an abort occurs.
Parameters
abortCondition can be any valid numeric expression using comparison or logical operators.
abortCode is a nonzero numeric value returned to any abort or error handling code by AbortOnValue 
whenever it causes an abort.
Details
When used with try-catch-endtry, you should place a call to GetRTError(1) in your catch section to clear 
the runtime error.
See Also
Flow Control for Aborts on page IV-48 and AbortOnValue Keyword on page IV-49 for further details.
The AbortOnRTE keyword and the try-catch-endtry flow control statement.
abs 
abs(num)
The abs function returns the absolute value of the real number num. To calculate the absolute value of a 
complex number, use the cabs function.
See Also
The cabs function.
acos 
acos(num)
The acos function returns the inverse cosine of num in radians in the range [0,].
In complex expressions, num is complex and acos returns a complex value.
See Also
cos
acosh 
acosh(num)
The acosh function returns the inverse hyperbolic cosine of num. In complex expressions, num is complex 
and acosh returns a complex value.
