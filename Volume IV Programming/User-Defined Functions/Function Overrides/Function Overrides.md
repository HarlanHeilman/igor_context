# Function Overrides

Chapter IV-3 — User-Defined Functions
IV-106
ThreadSafe Functions
A ThreadSafe function is one that can operate correctly during simultaneous execution by multiple threads.
ThreadSafe user functions provide support for multiprocessing and can be used for preemptive multitask-
ing background tasks.
Note:
Writing a multitasking program is for expert programmers only. Intermediate programmers can 
write thread-safe curve-fitting functions and multithreaded assignment statements; see 
Automatic Parallel Processing with MultiThread on page IV-323. Beginning programmers 
should gain experience with regular programming before using multitasking.
You create thread safe functions by inserting the keyword ThreadSafe in front of Function. For example:
ThreadSafe Function myadd(a,b)
Variable a,b
return a+b
End
Only a subset of Igor’s built-in functions and operations can be used in a threadsafe function. Generally, 
numeric or utility functions can be used but those that access windows can not. To determine if a routine is 
ThreadSafe, use the Command Help tab of the Help Browser.
Although file operations are listed as threadsafe, they have certain limitations when running in a threadsafe 
function. If a file load hits a condition that normally would need user assistance, the load is aborted. No 
printing to history is done.
Threadsafe functions can call other threadsafe functions but may not call non-threadsafe functions. Non-
threadsafe functions can call threadsafe functions.
When threadsafe functions execute in the main thread, they have normal access to data folders, waves, and 
variables. But when running in a preemptive thread, threadsafe functions use their own private data fold-
ers, waves, and variables.
When a thread is started, waves can be passed to the function as input parameters. Such waves are flagged 
as being in use by the thread, which prevents any changes to the size of the wave. When all threads under 
a given main thread are finished, the waves return to normal. You can pass data folders between the main 
thread and preemptive threads but such data folders are never shared.
See ThreadSafe Functions and Multitasking on page IV-329 for a discussion of programming with pre-
emptive multitasking threads.
Function Overrides
In some very rare cases, you may need to temporarily change an existing function. When that function is part 
of a package provided by someone else, or by WaveMetrics, it may be undesirable or difficult to edit the orig-
inal function. By using the keyword “Override” in front of “Function” you can define a new function that will 
be used in place of another function of the same name that is defined in a different and later procedure file.
Although it is difficult to determine the order in which procedure files are compiled, the main procedure 
window is always first. Therefore, always define override functions in the main procedure file.
Although you can override static functions, you may run into a few difficulties. If there are multiple files 
with the same static function name, your override will affect all of them, and if the different functions have 
different parameters then you will get a link error.
Here is an example of the Override keyword. In this example, start with a new experiment and create a new 
procedure window. Insert the following in the new window (not the main procedure window).
Function foo()
print "this is foo"
