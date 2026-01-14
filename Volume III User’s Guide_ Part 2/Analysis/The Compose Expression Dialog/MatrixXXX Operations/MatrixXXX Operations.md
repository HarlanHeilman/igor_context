# MatrixXXX Operations

Chapter III-7 — Analysis
III-138
For example:
wave1 = K0 + wave2
// a wave assignment command
K0 += 1.5 * K1
// a variable assigment command
str1 = "Today is" + date()
// a string assignment command
Table Selection Item
The Destination Wave pop-up menu contains a “_table selection_” item. When you choose “_table selec-
tion_”, Igor assigns the expression to whatever is selected in the table. This could be an entire wave or 
several entire waves, or it could be a subset of one or more waves.
To use this feature, start by selecting in a table the numeric wave or waves to which you want to assign a 
value. Next, choose Compose Expression from the Analysis menu. Choose “_table selection_” in the Desti-
nation Wave pop-up menu. Next, enter the expression that you want to assign to the waves. Notice the 
command that Igor has created which is displayed in the command box toward the bottom of the dialog. If 
you have selected a subset of a wave, Igor will generate a command for that part of the wave only. Finally, 
click Do It to execute the command.
Create Formula Checkbox
The Create Formula checkbox in the Compose Expression dialog generates a command using the := operator 
rather than the = operator. The := operator establishes a dependency such that, if a wave or variable on the right 
hand side of the assignment statement changes, Igor will reassign values to the destination (left hand side). We 
call the right hand side a formula. Chapter IV-9, Dependencies, provides details on dependencies and formulas.
Matrix Math Operations
There are four basic methods for performing matrix calculations: normal wave expressions, the MatrixXXX 
operations, the MatrixOp operation, and the MatrixSparse operation.
Normal Wave Expressions
You can add matrices to other matrices and scalars using normal wave expressions. You can also multiply 
matrices by scalars. For example:
Make matA={{1,2,3},{4,5,6}}, matB={{7,8,9},{10,11,12}}
matA = matA+0.01*matB
gives new values for
matA = {{1.07,2.08,3.09},{4.1,5.11,6.12}}
MatrixXXX Operations
A number of matrix operations are implemented in Igor. Most have names starting with the word “Matrix”. 
For example, you can multiply a series of matrices using the MatrixMultiply operation (page V-548). This 
operation. The /T flag allows you to specify that a given matrix’s data should be transposed before being 
used in the multiplication.
Many of Igor’s matrix operations use the LAPACK library. To learn more about LAPACK see:
LAPACK Users’ Guide, 3rd ed., SIAM Publications, Philadelphia, 1999.
or the LAPACK web site:
http://www.netlib.org/lapack/lug/lapack_lug.html
Unless noted otherwise, LAPACK routines support real and complex, IEEE single-precision and double-
precision matrix waves. Most matrix operations create the variable V_flag and set it to zero if the operation 
is successful. If the flag is set to a negative number it indicates that one of the parameters passed to the 
LAPACK routines is invalid. If the flag value is positive it usually indicates that one of the rows/columns 
of the input matrix caused the problem.
