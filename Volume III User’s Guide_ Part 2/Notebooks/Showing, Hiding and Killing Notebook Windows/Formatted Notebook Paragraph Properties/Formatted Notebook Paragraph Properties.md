# Formatted Notebook Paragraph Properties

Chapter III-1 — Notebooks
III-7
Three modes are available: points, spaces, and mixed. In points mode, you specify the default tab width for 
all paragraphs in units of points. In the Document Settings dialog, you can enter this setting in inches, cen-
timeters, or points, but it is always stored as points. Prior to Igor Pro 9.00, this was the only mode available.
In spaces mode, you specify the default tab width for all paragraphs in units of spaces.
In mixed mode, you specify the default tab width for paragraphs controlled by proportional fonts in units 
of points and for paragraphs controlled by monospace fonts in units of spaces.
Specifying default tabs in spaces is mostly of use for indentation and alignment of comments in notebooks 
that show Igor code such as Igor help files.
For formatted notebooks, the space character unit used in spaces mode and in mixed mode for monospace 
fonts is the width of a space character in the ruler font for a given paragraph. For plain text notebooks, it is 
the width of a space character in the notebook font.
In a formatted notebook, the ruler displays explicit tab stops and default tab stops. You can adjust default 
tab stops by dragging one of them. This sets either the default tab width in points or in spaces, depending 
on the units used for default tabs by the current paragraph. Default tabs in points are relative to the position 
of zero on the ruler. Default tabs in spaces are relative to the ruler's left margin.
When you create a new notebook window, Igor applies your preferred default tab width settings. There are 
separate preferences for plain text notebooks and formatted text notebooks. You can set preferences for a 
given type of notebook by first using the Document Settings dialog to apply the desired settings to a 
window of that type and then choosing NotebookCapture Notebook Prefs as explained under Notebook 
Preferences on page III-30.
Igor stores document settings separately for each formatted text notebook file. In Igor Pro 9.00 and later, it 
stores the default tab width mode, width in points, and width in spaces settings. Older versions of Igor 
support only default tabs specified in points and ignore the other settings.
Igor does not store document settings for plain text notebook files, so your preferred default tab width set-
tings for plain text notebooks apply to all plain text notebook files subsequently opened.
Notebook Paragraph Properties
A set of paragraph properties is called a “ruler”. In some word processors, this is called a “style”. The 
purpose of rulers is to make it easy to keep the formatting of a notebook consistent. This is described in 
more detail under Working with Rulers on page III-11.
Formatted Notebook Paragraph Properties
The paragraph properties for a formatted notebook are all under your control and can be different for each 
paragraph. A new formatted notebook has one ruler, called the Normal ruler. You can control the proper-
ties of the Normal ruler and you can define additional rulers.
The ruler font, ruler text size, ruler text style and ruler text color can be set using the pop-up menu on the 
left side of the ruler. They set the default text format for paragraphs governed by the ruler. You can use the 
Notebook menu to override these default properties. The Notebook menu permits you to hide or show the 
ruler in a formatted notebook.
The paragraph properties for formatted notebooks are:
Paragraph Property
Description
First-line indent
Horizontal position of the first line of the paragraph.
Left margin
Horizontal position of the paragraph after the first line.
Right margin
Horizontal position of the right side of the paragraph.
