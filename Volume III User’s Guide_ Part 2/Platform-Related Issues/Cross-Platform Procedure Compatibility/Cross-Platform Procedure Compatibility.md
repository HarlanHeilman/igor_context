# Cross-Platform Procedure Compatibility

Chapter III-15 — Platform-Related Issues
III-454
The second level is Igor’s built-in substitution table which substitutes between fonts normally installed on 
various Macintosh and Windows operating systems. For example, it substitutes Arial (a standard Windows 
font) for Geneva (a standard Macintosh font) if Geneva is not installed (which it usually isn’t on a Windows 
computer).
The user-level substitutions have priority over the built-in substitutions.
The Substitute Font dialog appears when neither level of font substitution specifies a replacement for the 
missing font. You can prevent this dialog from appearing by selecting the Don’t Prompt for Missing Fonts 
checkbox in the Substitute Font dialog.
You can manage font substitutions without waiting for a missing font situation to occur by choosing Misc-
Edit Font Substitutions.
The user-level font substitution table is maintained in the “Igor Font Substitutions.txt” text file in Igor’s 
preferences folder. The file format is:
<name of missing font to replace> = <name of font to use instead>
one entry per line. For example:
Palatino=New Times Roman
spaces or tabs are allowed around the equals sign.
When a missing font is replaced, Igor uses the name of the replacement font instead of the name of the font 
in the command.
The name of the missing font is replaced only in the sense that the altered or created object (window, con-
trol, etc.) uses and remembers only the name of the replacement font. Recreation macros, including exper-
iment recreation procedures, use the name of the replacement font when the experiment is saved. The 
command, however, is unaltered and still contains the name of the missing font.
Cross-Platform Procedure Compatibility
Igor procedures are about 99.5% platform-independent. For the other 0.5%, you need to test which platform 
you are running on and act accordingly. You can use ifdefs to achieve this. For example:
Function Demo()
#ifdef MACINTOSH
Print "We are running on Macintosh"
#else
#ifdef WINDOWS
Print "We are running on Windows"
#else
