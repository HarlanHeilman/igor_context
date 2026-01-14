# Graphs and High-Resolution Displays

Chapter III-17 — Miscellany
III-507
If speed is an issue, you can try GraphicsTechnology=2 to use the older GDI interface. However, transpar-
ency is not honored - colors will be opaque regardless of the alpha value (see Color Blending on page 
III-498 for a discussion of alpha).
In GDI+ mode, EMF export uses a hybrid format, called “dual EMF”, that contains both GDI+ and, for com-
patibility, the older GDI. In GraphicsTechnology=2 mode, only the older GDI-only style is exported. In Qt 
graphics mode, GDI+ is used for rendering the EMF for export, resulting in the dual EMF format. Some 
applications don’t work well with EMF+ or dual EMF. In that case, try setting GraphicsTechnology=2 (old 
GDI mode) to export an EMF without the EMF+ component.
Our experience indicates that plain EMF is rendered better by GDI mode. In Qt graphics, the best rendering 
technology is chosen based on the contents of the picture you are pasting.
Regardless of the selected technology, exporting as EMF on Windows uses native interfaces.
Graphics Technology on Macintosh
On Macintosh, there is only one native format, Core Graphics, also known as Quartz (GraphicsTechnol-
ogy=1), and it works the same as in Igor Pro 6.3. The native picture format is PDF.
High-resolution screen graphics on Retina displays is supported in Qt graphics technology mode only.
PDF pictures pasted into Igor are also rendered using Quartz. This produces the same picture regardless of 
the chosen Igor graphics technology, except on a Retina display, in which case the PDF is rendered on-
screen at high-resolution only when using Qt graphics.
SVG Graphics
In Qt mode (GraphicsTechnology=3), SVG (Scalable Vector Graphics) is available as an alternative object-
based picture format. This can replace EMF and PDF whenever the destination program supports it. In Qt 
mode, other imported object-based pictures (PDF on Macintosh, EMF on Windows) are rendered as high-
resolution bitmap images.
In native graphics modes, imported SVG pictures are rendered as high-resolution bitmap images using Qt 
graphics.
Regardless of the selected technology, exporting as SVG format is rendered using Qt.
High-Resolution Displays
High-resolution screen graphics is supported in Qt graphics technology mode only.
Macintosh Retina and Windows high-resolution displays, also called Retina, 4K, 5K, Ultra HD, and Quad 
HD, bring a more pleasing visual experience but also present performance challenges. Depending on the 
operating system, graphics technology, and your actual data, graph updates can be thousands of times 
slower. This situation is expected to be temporary as operating systems optimize high-resolution graphics. 
See the “Graphs and High-Resolution Displays” topic in the release notes for the latest information.
On Windows, prior to Igor Pro 7, control panels were drawn using pixels for coordinates. Now, when the 
resolution exceeds 96 DPI, those coordinates are taken to be points. This prevents panels from appearing 
tiny on high-resolution displays. See Control Panel Resolution on Windows on page III-456 for more infor-
mation.
Graphs and High-Resolution Displays
Macintosh Retina and Windows high-resolution displays bring a more pleasing visual experience but also 
present performance challenges. Previously, one point lines were one pixel wide. Now, on high-resolution 
displays, such lines are two pixels wide and, depending on the operating system, graphics technology and 
the actual data, drawing can be thousands of times slower.
