# rename_form34


In powershell script

Make sure that the path for pdftotext.exe from Xpdf tools (http://www.xpdfreader.com/download.html) is included in the computer's environment variables. Make sure that it is the only environment variable with pdftotext.exe, or at least be placed at a higher priority than any other pdftotext.exe that may be used by other programs.


This way, pdftotext.exe does not have to be in the working directory.
