# JacobiSn

JacobiCn
V-465
S_path uses Macintosh path syntax (e.g., “hd:FolderA:FolderB:”), even on Windows. It includes a 
trailing colon.
When JCAMPLoadWave presents an Open File dialog and the user cancels, V_flag is set to 0 and S_fileName is 
set to "".
In addition, if the /V flag is used, variables are created corresponding to JCAMP-DX labels in the header. 
See Variables Set By JCAMPLoadWave on page II-168 for details.
Example
Function LoadJCAMP(pathName, fileName)
String pathName
// Name of Igor symbolic path or ""
String fileName
// Full path, partial path or simple file name
JCAMPLoadWave/P=$pathName fileName
if (V_Flag == 0)
Print "No waves were loaded"
return -1
endif
NVAR VJC_NPOINTS
Printf "Number of points: %d\r", VJC_NPOINTS
SVAR SJC_YUNITS
Printf "Y Units: %s\r", SJC_YUNITS
return 0
End
See Also
Loading JCAMP Files on page II-168
JacobiCn
JacobiCn(x, k)
The JacobiCn function returns the Jacobian elliptic function cn(x,k) for real x and modulus k with 
The JacobiCn function was added in Igor Pro 7.00.
See Also
JacobiSn
Reference
F. W. J. Olver, D. W. Lozier, R. F. Boisvert, and C. W. Clark, editors, NIST Handbook of Mathematical Functions, 
chapter 22. Cambridge University Press, New York, NY, 2010.
JacobiSn
JacobiSn(x, k)
The JacobiSn function returns the Jacobian elliptic function sn(x,k) for real x and modulus k with 
The JacobiSn function was added in Igor Pro 7.00.
See Also
JacobiCn
Reference
F. W. J. Olver, D. W. Lozier, R. F. Boisvert, and C. W. Clark, editors, NIST Handbook of Mathematical Functions, 
chapter 22. Cambridge University Press, New York, NY, 2010.
0 < k2 <1.
0 < k2 <1.
