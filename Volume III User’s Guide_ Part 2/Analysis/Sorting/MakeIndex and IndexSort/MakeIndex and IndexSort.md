# MakeIndex and IndexSort

Chapter III-7 — Analysis
III-134
Single-key text sort:
Sort tsrc,tdest
// nw1 not used
Execute this to scramble tdest again:
tdest= tsrc + " " + num2str(nw1)
Execute this to see a two key sort (nw1 breaks ties):
Sort {tsrc,nw1},tdest
The reason that “hello 3” sorts after “hello 2” is because nw1[0] = 3 is greater than nw1[2] = 2.
You can sort by more than two keys by specifying more than two waves inside the braces.
MakeIndex and IndexSort
The MakeIndex and IndexSort operations are infrequently used. You will normally use the Sort operation.
Applications of MakeIndex and IndexSort include:
•
Sorting large quantities of data
•
Sorting individual waves from a group one at a time
•
Accessing data in sorted order without actually rearranging the data
•
Restoring data to the original ordering
The MakeIndex operation creates a set of index numbers. IndexSort can then use the index numbers to rearrange 
data into sorted order. Together they can be used to sort just like the Sort operation but with an extra wave and 
an extra step.
The advantage is that once you have the index wave you can quickly sort data from a given set of waves at 
any time. For example, if you have hundreds of waves you can not use the normal sort operation on a single 
command line. Also, when writing procedures it is sometimes more convenient to loop through a set of 
waves one at a time than to try to generate a single command line with multiple waves.
You can also use the index values to access data in sorted order without using the IndexSort operation. For 
example, if you have data and index waves named wave1 and wave1index, you can access the data in 
sorted order on the right hand side of a wave assignment like so:
wave1[wave1index[p]]
If you create an index wave, you can undo a sort and restore data to the original order. To do this, simply 
use the Sort operation with the index wave as the sort key.
Like the Sort operation, the MakeIndex operation can handle multiple sort keys.
Point
tsrc
nw1
tdest
0
hello
3
hello 3
1
there
5
there 5
2
hello
2
hello 2
3
there
1
there 1
Point
tsrc
nw1
tdest
0
hello
3
hello 3
1
there
5
hello 2
2
hello
2
there 1
3
there
1
there 5
Point
tsrc
nw1
tdest
0
hello
3
hello 2
1
there
5
hello 3
2
hello
2
there 1
3
there
1
there 5
