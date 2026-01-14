# Windows System Requirements

Chapter III-17 — Miscellany
III-513
IGOR64 can theoretically address about a billion gigabytes. However, actual operating systems impose far 
lower limits. On Windows 10, 64-bit programs can address between 128 GB (home edition) and 512 GB 
(professional edition). On Mac OS X, 64-bit programs can theoretically address the full 64-bit address space.
If you load more data than fits in physical memory, the system starts using "virtual memory", meaning that 
it swaps data between physical memory and disk, as needed. This is very slow. Consequently, you should 
avoid loading more data into memory than can fit in physical memory.
Even if your data fits in physical memory, graphing and manipulating very large waves, such as 10 million, 
100 million, or 1 billion points, will be slow.
All of this boils down to the following rules:
1.
If you don't need to load gigabytes of data into memory at one time then you don't need to worry about 
memory management.
2.
Run IGOR64 unless you rely on 32-bit XOPs that can not be ported to 64 bits. If you are running on Mac-
intosh and rely on 32-bit XOPs, you must run Igor7.
3.
Install enough physical memory to avoid the need for virtual memory swapping.
For further information about very large waves, see IGOR64 Experiment Files on page II-35.
Macintosh System Requirements
Igor Pro requires Mac OS X 10.9.0 or later.
Windows System Requirements
Igor Pro requires Windows 7 or later.

Chapter III-17 — Miscellany
III-514
