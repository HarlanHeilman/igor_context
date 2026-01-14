# Creating Links

Chapter IV-10 — Advanced Topics
IV-257
Igor knows that it has hit the end of the current topic when it finds the related-topics declaration or when 
it finds a new topic declaration. In either case, it proceeds to compile the next topic. It continues compiling 
until it hits the end of the file.
When compiling the help file, Igor may encounter syntax that it can’t understand. For example, if you have 
a related-topics declaration paragraph, Igor will expect the next paragraph to be a topic declaration. If it is 
not, Igor will stop the compilation and display an error dialog. You need to open the file as a notebook, fix 
the error, save and kill it and then reopen it as a help file.
Another error that is easy to make is to fail to use the plain text format for syntactic elements like bullet-tab, 
“Related Topics:” or the comma and space between related topics. If you run into a non-obvious compile error 
in a topic, subtopic or related topics declaration, recreate the declaration by copying from a working help file.
The help files supplied by WaveMetrics contain a large number of rulers to define various types of paragraphs 
such as topic paragraphs, subtopic paragraphs, related topic paragraphs, topic body paragraphs and so on. 
The Igor Help File Template contains many but not all of these rulers. If you find that you need to use a ruler 
that exists in a WaveMetrics help file but not in your help file then copy a paragraph governed by that ruler 
from the WaveMetrics help file and paste it into your file. This transfers the ruler to your file.
Creating Links
A link is text in an Igor help file that, when clicked, takes the user to some other place in the help. Igor con-
siders any pure blue, underlined text to be a link. Pure blue means that the RGB value is (0, 0, 65535). By 
convention links use the Geneva font on Macintosh and the Arial font on Windows.
To create a link, select the text in the notebook that you are preparing to be a help file. Then choose Make Help 
Link from the Notebook menu. This sets the text format for the selected text to pure blue and underlined.
The link text refers to another place in the help using one of these forms:
•
The name of a help topic (e.g., Command Window)
•
The name of a help subtopic (e.g., History Area)
•
A combined topic and subtopic (e.g., Command Window[History Area])
Use the combined form if there is a chance that the help topic or subtopic name by itself may be ambiguous. 
For example, to refer to the Preferences operation, use Operations[Preferences] rather than Preferences by 
itself.
When the user double-clicks a link, Igor performs the following search:
1.
If the link is a topic name, Igor goes to that topic.
2.
If the link is in topic[subtopic] form, Igor goes to that subtopic.
3.
If steps 1 and 2 fail, Igor searches for a subtopic with the same name as the link. First, it searches for a 
subtopic in the current topic. If that fails, it searches for a subtopic in the current help file. If that fails, it 
searches for a subtopic in all help files.
4.
If step 3 fails, Igor searches all help files in the Igor Pro folder. If it finds the topic in a closed help file, it 
opens and displays it.
5.
If step 4 fails, Igor searches all help files in the Igor Pro User Files folder. If it finds the topic in a closed 
help file, it opens and displays it.
6.
If all of the above fail, Igor displays a dialog saying that the required help file is not available.
You can create a link in a help file that will open a Web page or FTP site in the user’s Web or FTP browser. 
You do this by entering the Web or FTP URL in the help file while you are editing it as a notebook. The URL 
must appear in this format:
<http://www.wavemetrics.com>
<ftp://ftp.wavemetrics.com>
The URL must include the angle brackets and the “http://”, “https://” or “ftp://” protocol specifier. Support 
for https was added in Igor Pro 7.02.
