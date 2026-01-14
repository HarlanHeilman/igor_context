# Exporting a Notebook as HTML

Chapter III-1 — Notebooks
III-21
You can save an Igor plain or formatted notebook as an RTF file and you can open an RTF file as an Igor 
formatted notebook. You may find it useful to collect text and pictures in a notebook and to later transfer it 
to your word processor for final editing.
An RTF file is a plain text file that contains RTF codes. An RTF file starts with “\rtf”. Other codes define the 
text, pictures, document formats, paragraph formats, and text formats and other aspects of the file.
When Igor writes an RTF file from a notebook, it must generate a complex sequence of codes. When it reads 
an RTF file, it must interpret a complex sequence of codes. The RTF format is very complicated, has evolved 
and allows some flexibility. As a result, each program writes and interprets RTF codes somewhat differ-
ently. Because of this and because of the different feature sets of different programs, RTF translation is 
sometimes imperfect and requires that you do manual touchup.
Saving an RTF File
To create an RTF file, choose Save Notebook As from the File menu. Select Rich Text Format from the Save 
File dialog’s file type pop-up menu, and complete the save.
The original notebook file, if any, is not affected by saving as RTF, and the notebook retains its connection 
to the original file.
Opening an RTF File
When Igor opens a plain text file as a notebook, it looks for the “\rtf” code that identifies the file as an RTF 
file. If it sees this code, it displays a dialog asking if you want to convert the rich text codes into an Igor for-
matted notebook.
If you answer Yes, Igor creates a new, formatted notebook. It then interprets the RTF codes and sets the 
properties and contents of the new notebook accordingly. When the conversion is finished, you sometimes 
need to fix up some parts of the document that were imperfectly translated.
If you answer No, Igor opens the RTF file as a plain text file. Use this to inspect the RTF codes and, if you 
are so inclined, to tinker with them.
Exporting a Notebook as HTML
Igor can export a notebook in HTML format. HTML is the format used for Web pages. For a demo of this 
feature, choose FileExample ExperimentsFeature DemosWeb Page Demo.
This feature is intended for two kinds of uses. First, you can export a simple Igor notebook in a form suitable 
for immediate publishing on the Web. This might be useful, for example, to automatically update a Web 
page or to programmatically generate a series of Web pages.
Second, you can export an elaborate Igor notebook as HTML, use an HTML editor to improve its formatting 
or tweak it by hand, and then publish it on the Web. It is unlikely that you could use Igor alone to create an 
elaborately formatted Web page because there is a considerable mismatch between the feature set of HTML 
and the feature set of Igor notebooks. For example, the main technique for creating columns in a notebook 
is the use of tabs. But tabs mean nothing in HTML, which uses tables for this purpose.
Because of this mismatch between notebooks and HTML, and so your Web page works with a wide variety 
of Web browsers, we recommend that you keep the formatting of notebooks which you intend to write as 
HTML files as simple as possible. For example, tabs and indentation are not preserved when Igor exports 
HTML files, and you can’t rely on Web browsers to display specific fonts and font sizes. If you restrict your-
self to plain text and pictures, you will achieve a high degree of browser compatibility.
There are two ways to export an Igor notebook as an HTML file:
•
Choose FileSave Notebook As
•
Using the SaveNotebook/S=5 operation
