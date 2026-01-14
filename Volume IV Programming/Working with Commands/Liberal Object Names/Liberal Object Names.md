# Liberal Object Names

Chapter IV-1 — Working with Commands
IV-2
Overview
You can execute commands by typing them into the command line and pressing Return or Enter.
You can also use a notebook for entering commands. See Notebooks as Worksheets on page III-4.
You can type commands from scratch but often you will let Igor dialogs formulate and execute commands. You 
can view a record of what you have done in the history area of the command window and you can easily reenter, 
edit and reexecute commands stored there. See Command Window Shortcuts on page II-13 for details.
Multiple Commands
You can place multiple commands on one line if you separate them with semicolons. For example:
wave1= x; wave1= wave2/(wave1+1); Display wave1
You don’t need a semicolon after the last command but it doesn’t hurt.
Comments
Comments start with //, which end the executable part of a command line. The comment continues to the 
end of the line.
Maximum Length of a Command
The total length of the command line can not exceed 2500 bytes.
There is no line continuation character in the command line. However, it is nearly always possible to break 
a single command up into multiple lines using intermediate variables. For example:
Variable a = sin(x-x0)/b + cos(y-y0)/c
can be rewritten as:
Variable t1 = sin(x-x0)/b
Variable t2 = cos(y-y0)/c
Variable a = t1 + t2
Parameters
Every place in a command where Igor expects a numeric parameter you can use a numeric expression. Sim-
ilarly for a string parameter you can use a string expression. In an operation flag (e.g., /N=<number>), you 
must parenthesize expressions. See Expressions as Parameters on page IV-12 for details.
Liberal Object Names
In general, object names in Igor are limited to a restricted set of characters. Only letters, digits and the 
underscore character are allowed. Such names are called “standard names”. This restriction is necessary to 
identify where the name ends when you use it in a command.
For waves and data folders only, you can also use “liberal” names. Liberal names can include almost any 
character, including spaces and dots (see Liberal Object Names on page III-501 for details). However, to 
define where a liberal name ends, you must quote them using single quotes.
In the following example, the wave names are liberal because they include spaces and therefore they must 
be quoted:
'wave 1' = 'wave 2'
// Right
wave 1 = wave 2
// Wrong - liberal names must be quoted
(This syntax applies to the command line and macros only, not to user-defined functions in which you must 
use Wave References to read and write waves.)
