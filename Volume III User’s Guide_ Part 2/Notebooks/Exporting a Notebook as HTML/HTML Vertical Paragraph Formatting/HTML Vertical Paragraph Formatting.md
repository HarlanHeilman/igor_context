# HTML Vertical Paragraph Formatting

Chapter III-1 — Notebooks
III-22
The SaveNotebook operation (see page V-823) includes a /H flag which gives you some control over the 
features of the HTML file:
•
The file’s character encoding
•
Whether or not paragraph formatting (e.g., alignment) is exported
•
Whether or not character formatting (e.g., fonts, font sizes) is exported
•
The format used for graphics
When you choose FileSave Notebook As, Igor uses the following default parameters:
•
Character encoding: UTF-8 (see HTML Text Encoding on page III-23)
•
Paragraph formatting is not exported
•
Character formatting is not exported
•
Pictures are exported in the PNG (Portable Network Graphics) format
By default, paragraph and character formatting is not exported because this formatting is often not sup-
ported by some Web browsers, is at cross-purposes with Web browser behavior (e.g., paragraph space-
before and space-after), or is customarily left in the hands of the Web viewer (e.g., fonts and font sizes).
For creating simple Web pages that work with a majority of Web browsers, this is all you need to know 
about Igor’s HTML export feature. To use advanced formatting, to use non-Roman characters, to use dif-
ferent graphics formats, and to cope with diverse Web browser behavior, you need to know more. Unfor-
tunately, this can get quite technical.
HTML Standards
Igor’s HTML export routine writes HTML files that conform to the HTML 4.01 specification, which is avail-
able from:
http://www.w3.org/TR/1999/PR-html40-19990824
It writes style information that conforms to the CSS1 (Cascading Style Sheet - Level 1) specification, which 
is available from:
http://www.w3.org/TR/1999/REC-CSS1-19990111
HTML Horizontal Paragraph Formatting
Tabs mean nothing in HTML. A tab behaves like a single space character. Consequently, you can not rely 
on tabs for notebooks that are intended to be written as HTML files. HTML has good support for tables, 
which make tabs unnecessary. However, Igor notebooks don’t support tables. Consequently, there is no 
simple way to create an HTML file from an Igor notebook that relies on tabs for horizontal formatting.
HTML files are often optimized for viewing on screen in windows of varying widths. When you make the 
window wider or narrower, the browser automatically expands and contracts the width of the text. Conse-
quently, the roles played by the left margin and right margin in notebooks are unnecessary in HTML files. 
When Igor writes an HTML file, it ignores the left and right paragraph margin properties.
HTML Vertical Paragraph Formatting
The behavior of HTML browsers with regard to the vertical spacing of paragraphs makes it difficult to 
control vertical formatting. For historical reasons, browsers typically add a blank line after each paragraph 
(<P>) element and they ignore empty paragraph elements. Although it is possible to partially override this 
behavior, this only leads to more problems.
In an Igor notebook, you would usually use the space-before and space-after paragraph properties in place 
of blank lines to get paragraph spacing that is less than one line. However, because of the aforementioned 
browser behavior, the space-before and space-after would add to the space that the browser already adds 
and you would get more than one line’s space when you wanted less. Consequently, Igor ignores the space-
before and space-after properties when writing HTML files.
