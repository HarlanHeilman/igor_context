# Igor Extensions

Chapter I-1 — Introduction to Igor Pro
I-5
Built-In Routines 
Each of Igor's built-in routines is categorized as a function or as an operation.
A built-in function is an Igor routine, such as sin, exp or ln, that directly returns a result. A built-in operation 
is a routine, such as Display, FFT or Integrate, that acts on an object and may create new objects but does 
not directly return a result.
A good way to get a sense of the scope of Igor's built-in routines is to scan the sections Built-In Operations 
by Category on page V-1 and Built-In Functions by Category on page V-7 in the reference volume of this 
manual.
For getting reference information on a particular routine it is usually most convenient to choose 
HelpCommand Help and use the Igor Help Browser.
User-Defined Procedures
A user-defined procedure is a routine written in Igor’s built-in programming language by entering text in 
a procedure window. It can call upon built-in or external functions and operations as well as other user-
defined procedures to manipulate Igor objects. Sets of procedures are stored in procedure files.
Igor Extensions
An extension is a “plug-in” - a piece of external C or C++ code that adds functionality to Igor. For historical 
reasons, we use the term “XOP” to refer to an Igor extension. “XOP” is a contraction of “external operation”. 
The terms “XOP” and “Igor extension” are synonymous.
You can create Igor procedures by entering text in a procedure window.
Procedures can call operations, functions or other 
procedures. They can also perform waveform arithmetic.
Each procedure has a name which 
you use to invoke it.
