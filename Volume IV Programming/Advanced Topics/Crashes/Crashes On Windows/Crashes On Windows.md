# Crashes On Windows

Chapter IV-10 — Advanced Topics
IV-341
Crash Logs on Mac OS X
When a crash occurs on Mac OS X, most of the time the system is able to generate a crash log. You can 
usually find it at:
/Users/<user>/Library/Logs/DiagnosticReports/Igor Pro_<date>_<machinename>.crash
where <user> is your user name.
The /Users/<user>/Library folder is hidden. To reveal the DiagnosticReports folder:
1. Choose Finder->Go to Folder
2. Enter ~/Library/Logs/DiagnosticReports
3. Click Go
Send this log as an attachment when reporting a crash.
Crashes On Windows
When a crash occurs on Windows, Igor attempts to write a crash report that may help WaveMetrics deter-
mine and fix the cause of the crash. If Igor is able to write a crash report, it displays a dialog showing the 
location of the crash report on disk. The location is in your Igor preferences folder and will be something 
like:
C:\Users\<user>\AppData\Roaming\WaveMetrics\Igor Pro 8\Diagnostics\Igor Crash Reports.txt
If the "Igor Crash Reports.txt" file already exists when a crash occurs, Igor appends a new report to the exist-
ing file.
Igor may also write a minidump file to the same folder. A minidump file, which has a ".dmp" extension, 
contains additional information about the crash. There will typically be one minidump file for each crash.
When a crash occurs, Igor attempts to open the Diagnostics folder on your desktop to make it easy for you 
to find the report and minidump files.
Please send the "Igor Crash Reports.txt" file, along with the minidump files related to the current crash, as 
email attachments to WaveMetrics support. If possible, include instructions for reproducing the crash and 
any other details that may help us understand what you were doing leading to the crash.
Once the problem has been resolved, if you want to reduce clutter and reclaim disk space, you can delete 
the Diagnostics folder and its contents. Igor will recreate the folder if necessary.
There may be cases where Igor is not able to write a crash report. This would happen if a library, security 
software or the operating system has overridden Igor's crash handler for some reason.

Chapter IV-10 — Advanced Topics
IV-342
