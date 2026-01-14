# Using the Wave Note

Chapter II-5 — Waves
II-84
Don’t Use the Destination Wave as a Source Wave
You may get unexpected results if the destination of a wave assignment statement also appears in the right-
hand expression. Consider these examples:
wave1 -= wave1(5)
wave1 -= vcsr(A)
// where cursor A is on wave1
Each of these examples is an attempt to subtract the value of wave1 at a particular point from every point 
in wave1. This will not work as expected because the value of wave1 at that particular point is altered 
during the assignment. At some point in the assignment, wave1(5) or vcsr(A) will return 0 since the value 
at that point in wave1 will have been subtracted from itself.
You can get the desired result by using a variable to store the value of wave1 at the particular point.
Variable tmp
tmp = wave1(5); wave1 -= tmp
tmp = vcsr(A); wave1 -= tmp
Wave Dependency Formulas
You can cause a wave assignment statement to “stick” to the wave by substituting “:=” for “=” in the state-
ment. This causes the wave to become dependent upon the objects referenced in the expression. For exam-
ple:
Variable/G gAngularFrequency = 5
wave1 := sin(gAngularFrequency*x)
// Note ":="
Display wave1
If you now execute “gAngularFrequency = 8” you will see the wave automatically update. Similarly if you 
change the wave’s X scaling using the SetScale operation (see page V-853), the wave will be automatically 
recalculated for the new range of X values.
Dependencies should be used sparingly if at all. Overuse creates a web of interactions that are difficult to 
understand and difficult to debug. It is better to explicitly update the target when necessary.
See Chapter IV-9, Dependencies, for further discussion.
Using the Wave Note
One of the properties of a wave is the wave note. This is just some plain text that Igor stores with each wave. 
The note is empty when you create a wave. There is no limit on its length.
You can inspect and edit a wave note using the Data Browser. You can set or get the contents of a wave note 
from an Igor procedure using the Note operation (see page V-694) or the note function (see page V-694).
Originally we thought of the wave note as a place for an experimenter to store informal comments about a 
wave and it is fine for that purpose. However, over time both we and many Igor users have found that the 
wave note is also a handy place to store additional, user-defined properties of a wave in a structured way. 
These additional properties are editable using the Data Browser but they can also be used and manipulated 
by procedures.
To do this, you store keyword-value pairs in the wave note. For example, a note might look like this:
CELLTYPE:rat hippocampal neuron
PATTERN:1VN21
TREATMENT:PLACEBO
You could then write Igor functions to set the CELLTYPE, PATTERN and TREATMENT properties of a 
wave. You can retrieve such properties using the StringByKey function.
