# Make

Make
V-526
WaveMetrics provides Igor Technical Note 006, “DSP Support Macros” which uses the magsqr function to 
compute the magnitude of FFT data, and Power Spectral Density with options such as windowing and 
segmenting. See the Technical Notes folder. Some of the techniques discussed there are available as Igor 
procedure files in the “WaveMetrics Procedures:Analysis:” folder.
Make 
Make [flags] waveName [, waveName]…
Make [flags] waveName [= {n0,n1,…}]…
Make [flags] waveName [= {{n0,n1,…},{n0,n1,…},…}]…
The Make operation creates the named waves. Use braces to assign data values when creating the wave.
Flags
/B
Makes 8-bit signed integer waves or unsigned waves if /U is present.
/C
Makes complex waves.
/D
Makes double precision waves.
/DF
Wave holds data folder references.
See Data Folder References on page IV-78 for more discussion.
/FREE[=nm]
Creates a free wave. Allowed only in functions and only if a simple name or wave 
reference structure field is specified.
See Free Waves on page IV-91 for further discussion.
If nm is present and non-zero, then waveName is used as the name for the free wave, 
overriding the default name '_free_'. The ability to specify the name of a free wave 
was added in Igor Pro 9.00 as a debugging aid - see Free Wave Names on page IV-95 
and Wave Tracking on page IV-207 for details.
/I
Makes 32-bit signed integer waves or unsigned waves if /U is present.
/L
Makes 64-bit signed integer waves or unsigned waves if /U is present. Requires Igor 
Pro 7.00 or later.
/N=n
n is the number of points each wave will have. If n is an expression, it must be 
enclosed in parentheses: Make/N=(myVar+1) aNewWave
/N=(n1, n2, n3, n4)
n1, n2, n3, n4 specify the number of rows, columns, layers and chunks each wave will 
have. Trailing zeros can be omitted (e.g., /N=(n1, n2, 0, 0) can be abbreviated as 
/N=(n1, n2)).
/O
Overwrites existing waves in case of a name conflict. After an overwrite, you cannot 
rely on the contents of the waves and you will need to reinitialize them or to assign 
appropriate values.
/R
Makes real value waves (default).
/T
Makes text waves.
/T=size
Makes text waves with pre-allocated storage.
size is the number of bytes preallocated by Igor for each element in each text wave. The 
waves are not initialized - it is up to you to initialize them.
Preallocation can dramatically speed up text wave assignment when the wave has a 
very large number of points but only when all strings assigned to the wave are exactly 
the same size as the preallocation size.
/U
Makes unsigned Integer waves.
/W
Makes 16-bit signed integer waves or unsigned waves if /U is present.
