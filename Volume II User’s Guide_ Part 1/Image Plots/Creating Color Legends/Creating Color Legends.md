# Creating Color Legends

Chapter II-16 — Image Plots
II-402
// Switch to floating point, image turns black
Redimension/S matrgb
// Scale floating point to 0..65535 range
matrgb *= 256
Because the appearance of a direct color image is completely determined by the image data, the Modify 
Image Appearance dialog has no effect on direct color images, and the dialog appears blank.
Creating Color Legends
You can create a color legend using a color scale annotation. For background information, see Legends on 
page III-42 and Color Scales on page III-47 sections.
We will demonstrate with a simple image plot:
Make/O/N=(30,30) expmat
SetScale/I x,-2,2,"" expmat; SetScale/I y,-2,2,"" expmat
expmat= exp(-(x^2+y^2))
// data ranges from 0 to 1
Display;AppendImage expmat
// by default, left and bottom axes
ModifyGraph width={Plan,1,bottom,left},mirror=0
This creates the following image, using the autoscaled Grays color table:
Choose GraphAdd Annotation to display the Add Annotation dialog.
Choose “ColorScale” from the Annotation pop-up menu.
Switch to the Frame tab and set the Color Bar Frame Thickness to 0 and the Annotation Frame to None.
Switch to the Position tab, check the Exterior checkbox, and set the Anchor to Right Center.
Click Do It. Igor executes:
ColorScale/C/N=text0/F=0/A=RC/E image=expmat,frame=0.00
This generates the following image plot:
 
-2
-1
0
1
2
-2
-1
0
1
2
