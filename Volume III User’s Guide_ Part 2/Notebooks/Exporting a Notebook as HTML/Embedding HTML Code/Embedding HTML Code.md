# Embedding HTML Code

Chapter III-1 — Notebooks
III-23
The minimum line height property is written as the CSS1 line-height property, which does not serve exactly 
the same purpose. This will work correctly so long as the minimum line height that you specify is greater 
than or equal to the natural line height of the text.
HTML Character Formatting
In an Igor notebook, you might use different fonts, font sizes, and font styles to enhance your presentation. 
An HTML file is likely to be viewed on a wide range of computer systems and it is likely that your enhance-
ments would be incorrectly rendered or would be a hindrance to the reader. Consequently, it is customary 
to leave these things to the person viewing the Web page.
If you use the SaveNotebook operation (see page V-823) and enable exporting font styles, only the bold, 
underline and italic styles are supported.
In notebooks, the vertical offset character property is used to create subscripts and superscripts. When writing 
HTML, Igor uses the CSS vertical-align property to represent the notebook’s vertical offset. The HTML property 
and the Igor notebook property are not a good match. Also, some browsers do not support the vertical-align 
property. Consequently, subscripts and superscripts in notebooks may not be properly rendered in HTML. In 
this case, the only workaround is to use a picture instead of using the notebook subscript and superscript.
HTML Pictures
If the notebook contains one or more pictures, Igor writes PNG or JPEG picture files to a “media” folder. 
For example, if the notebook contains two pictures and you save it as “Test.htm”, Igor writes the file 
Test.htm and creates a folder named TestMedia. It stores in the TestMedia folder two picture files: Pic-
ture0.png (or .jpg) and Picture1.png (or .jpg). The names of the picture files are always of the form Pic-
ture<N> where N is a sequential number starting from 0. If the folder already exists when Igor starts to store 
pictures in it, Igor deletes all files in the folder whose names start with “Picture”, since these files are most 
likely left over from a previous attempt to create the HTML file.
When you choose Save Notebook As from the File menu, Igor always uses the PNG format for pictures. If 
you want to use the JPEG format, you must execute a SaveNotebook operation (see page V-823) from the 
command line, using the /S=5 flag to specify HTML and the /H flag to specify the graphics format.
PNG is a lossless format that is excellent for storing web graphics and is supported by virtually all recent 
web browsers. JPEG is a lossy format commonly used for web graphics. We recommend that you use PNG.
HTML does not support Igor’s double, triple, or shadow picture frames. Consequently, when writing 
HTML, all types of notebook frames are rendered as HTML thin frames.
HTML Text Encoding
By default, Igor uses UTF-8 text encoding when you save a notebook as HTML. For historical reasons, the 
SaveNotebook operation /H flag allows you to specify other text encodings. However, there is no reason to 
use anything other than UTF-8.
Embedding HTML Code
If you are knowledgeable about HTML, you may want to access the power of HTML without completely 
giving up the convenience of having Igor generate HTML code for you. You can do this by embedding 
HTML code in your notebook, which you achieve by simply using a ruler named HTMLCode.
Normally, Igor translates the contents of the notebook into HTML code. However, when Igor encounters a 
paragraph whose ruler is named HTMLCode, it writes the contents of the paragraph directly into the 
HTML file. Here is a simple example:
Living things are generally classified into 5 kingdoms:
<OL>
<LI>Monera
<LI>Protista
<LI>Fungi
