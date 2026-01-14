# Project

ProcGlobal
V-781
Procedure File Version Information on page IV-166, The ModuleName Pragma on page IV-54
SetIgorOption IndependentModuleDev=1 on page IV-239, Invisible Procedure Windows Using 
Independent Modules on page III-402
ProcGlobal 
ProcGlobal#procPictureName
The ProcGlobal keyword is used with Proc Pictures to avoid possible naming conflicts with any other global 
pictures in the experiment. When you add a picture to an experiment using the Pictures dialog, such a 
picture is global in scope and may potentially have the same name as a Proc Picture. When a Proc Picture 
is global (and only then), you should use the ProcGlobal keyword to make sure that the Proc Picture is used 
with your code and to avoid confusion with pictures in the Pictures dialog.
See Also
See Proc Pictures on page IV-56 for details. Pictures Dialog on page III-510.
Project 
Project [/C={long,lat}/M=method /P={p1,p2,…}] longitudeWave, latitudeWave
The Project operation calculates projections of XY data, which most often are longitude and latitude waves 
of geographic coordinates. The output waves are W_XProjection and W_YProjection. Longitude and 
Latitude are in degrees.
Parameters
longitudeWave is the name of the wave supplying the longitude or equivalent coordinates. latitudeWave is 
the name of the wave supplying the latitude or equivalent coordinates.
Flags
Gnomonic
Here there is one extra parameter that defines the boundaries based on the angle. The specific expression 
for the limit is that cos(c) in Eq. (5-3) of Snyder is greater than the specified parameter:
/P={cos(c)}
The actual transformation uses Eqs. (22-4) and (22-5) of Snyder with k' given by (22-3).
General Perspective
Here there is one extra parameter that defines the boundaries based on the angle. The specific expression 
for the limit is that cos(c) in Eq. (5-3) of Snyder is greater than the specified parameter.
/C={long,lat}
Specifies longitude and latitude center of projection. By default long=0 and lat=90.
/M=method
/P={p1,p2,…}
One or more parameters required by a particular projection. See the following 
sections for parameters required by the various projections.
Indicates the type of projection. method can be one of the following:
0:
Orthographic (default).
1:
Stereographic.
2:
Gnomonic.
3:
General perspective.
4:
Lambert equal area.
5:
Equidistant.
6:
Mercator.
7:
Transverse Mercator.
8:
Albers Equal Area conic.
9:
Eckert IV (Igor Pro 9.00 or later)
10:
Winkel III (Igor Pro 9.00 or later)
