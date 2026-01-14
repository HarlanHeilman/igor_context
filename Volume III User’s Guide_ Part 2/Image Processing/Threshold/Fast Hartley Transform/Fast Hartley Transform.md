# Fast Hartley Transform

Chapter III-11 — Image Processing
III-364
Hough Transform
The Hough Transform is a mapping algorithm in which lines in image space map to single points in the 
transform space. It is most often used for line detection. Specifically, each point in the image space maps to 
a sinusoidal curve in the transform space. If pixels in the image lie along a line, the sinusoidal curves asso-
ciated with these pixels all intersect at a single point in the transform space. By counting the number of sinu-
soids intersecting at each point in the transform space, lines can be detected. Here is an example of an image 
that consists of one line.
Make/O/B/U/N=(100,100) lineImage
lineImage=(p==q ? 255:0)
// single line at 45 degrees
Newimage lineimage
ImageTransform hough lineImage
Newimage M_Hough
The Hough transform of a family of lines:
lineImage=((p==100-q)|(p==q)|(p==50)|(q==50)) ? 255:0
ImageTransform Hough lineImage
The last image shows a series of bright pixels in the center. The first and last points correspond to lines at 0 
and 180 degrees. The second point from the top corresponds to the line at 45 degrees and so on.
Fast Hartley Transform
The Hartley transform is similar to the Fourier transform except that it uses only real values. The transform 
is based on the cas kernel defined by:
.
The discrete Hartley transform is given by
The Hartley transform has two interesting mathematical properties. First, the inverse transform is identical 
to the forward transform, and second, the power spectrum is given by the expression:
The implementation of the Fast Hartley Transform is part of the ImageTransform operation (see page 
V-417). It requires that the source wave is an image whose dimensions are a power of 2.
ImageTransform /N={18,3}/O padImage Mri
// make the image 256^2 
ImageTransform fht mri
NewImage M_Hartley 
150
100
50
0
100
50
0
150
100
50
0
100
50
0
Single Line
Multiple Lines
cas vx


vx


cos
vx


sin
+
=
H u v



1
MN
--------
f x y



2ux
M
-----
vy
N
-----
–




2ux
M
-----
vy
N
-----
–




sin
+




cos






y
0
=
N
1
–

x
0
=
M
1
–

=
P f
H f

2
H
f
–



2
+
2
----------------------------------------------
=
