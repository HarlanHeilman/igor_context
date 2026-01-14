# Notebook (Document Properties)

Notebook (Document Properties)
V-696
Notebook
(Document Properties) 
Notebook document property parameters
This section of Notebook relates to setting the document properties of the notebook.
adopt=a
backRGB=(r,g,b[,a]) Sets background color. r, g, b, and a specify the color and optional opacity as RGBA 
Values. Alpha (a) is accepted but ignored.
changeableByCommandOnly=c
defaultTab=dtwp
dtwp is the default tab width in points.
The defaultTab keyword sets the default tab mode to 1 meaning that the default tab 
width for all paragraphs is specified in units of points. See the defaultTab2 keyword 
for further discussion.
defaultTab2={mode,dtwp,dtws}
Controls the width of default tab stops.
The defaultTab2 keyword was added in Igor Pro 9.00.
Specify -1 for mode to leave the mode unchanged.
The space character unit used in mode 2 and in mode 3 for monospace fonts is the 
width of a space character in the ruler font for a given paragraph. Plain text notebooks 
have only one ruler so the space character width is the same for all paragraphs. 
Formatted text notebooks can have many rulers and each has an associated space 
character width.
dtwp is the default tab width in points. It is used in mode 1 and in mode 3 for 
proportional fonts. Specify -1 for dtwp to leave the default tab width in points 
unchanged.
dtws is the default tab width in spaces. It is used in mode 2 and in mode 3 for 
monospace fonts. Specify -1 for dtws to leave the default tab width in spaces 
unchanged.
See Notebook Default Tabs on page III-6 for further discussion.
Adopts a notebook if it is a file saved to disk. Adopting a notebook makes it part 
of the packed experiment file, which becomes more self-contained; if you send the 
experiment to a colleague you will not need to send a notebook file.
a=0:
Checks only whether the notebook is adoptable. Sets V_flag to 0 if 
the notebook is already adopted or to 1 if it is adoptable.
a=1:
Checks only whether the notebook is adoptable. Sets V_flag to 0 if 
the notebook is already adopted or to 1 if it is adoptable.
This changeableByCommandOnly property is used to prevent manual 
modifications to the notebook but allow modifications using commands.
See Notebook Read/Write Properties on page III-10 for details.
c=0:
Turn changeableByCommandOnly off.
c=1:
Turn changeableByCommandOnly on.
mode is defined as follows:
mode=1:
Points mode: The default tab width for all paragraphs is specified in 
units of points by dtwp.
mode=2:
Spaces mode: The default tab width for all paragraphs is specified in 
units of spaces by dtws.
mode=3:
Mixed mode: The default tab width for paragraphs controlled by 
proportional fonts is specified in units of points by dtwp. The default 
tab width for paragraphs controlled by monospace fonts is specified 
in units of spaces by dtws.

Notebook (Document Properties)
V-697
magnification=m
pageMargins={left, top, right, bottom}
Sets page margins in points. left, top, right, and bottom are distances from the respective 
edges of the physical page.
This setting overrides the margins set via the the page setup dialog and the 
PrintSettings operation margins keyword.
rulerUnits=r
showRuler=s
Hides (s=0) or shows (s=1) the ruler.
startPage=sp
Sets the starting page number for printing.
statusWidth=sw
As of Igor7, because of changes to the layout of notebook windows, this keyword does 
nothing.
In Igor6 it set the width in points of the status area on the left of the horizontal scroll 
bar.
userKillMode=k
writeBOM=w
writeProtect=wp
Specifies the desired magnification in percent (between 25 and 500). Otherwise, m 
can be one of these special values:
m=1:
Default magnification.
m=2:
Default magnification.
In Igor Pro 6 this specified the no-longer-supported Fit Width mode.
m=3:
Default magnification.
In Igor Pro 6 this specified the no-longer-supported Fit Page mode.
Sets the units for the ruler:
r=0:
Points.
r=1:
Inches.
r=2:
Centimeters.
Specifies window behavior when the user attempts to close it.
k=0:
Normal with dialog (default).
k=1:
Clicking the close button kills the notebook with no dialog.
k=2:
Clicking the close button does nothing.
k=3:
Clicking the close button hides the notebook with no dialog.
Sets the document's writeBOM property which determines if Igor writes a byte 
order mark when saving the notebook. This applies to plain text notebooks only 
and is ignored for formatted text notebooks.
See Byte Order Marks on page III-471 for details.
This keyword was added in Igor Pro 7.00.
w=-1:
Does not change writeBOM flag.
w=0:
Sets writeBOM to false.
w=1:
Sets writeBOM to true.
The write-protect property is used to prevent inadvertent manual changes to the 
notebook.
See Notebook Read/Write Properties on page III-10 for details.
wp=0:
Turn write-protect off.
wp=1:
Turn write-protect on.
