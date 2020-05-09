
Start-Transcript -path $PSScriptRoot\error_log.txt -Append
#starting log to record errors (and other messages)


# ~~step 1- extract polling station names and save them on a textfile~~

foreach ($file in get-ChildItem *.pdf -Recurse) {
pdftotext.exe -simple $file
}



$txts = Get-childitem $PSScriptRoot -Recurse | where {$_.Extension -match "txt"}

$i=1

foreach ($txt in $txts)
{
$fullnametxt = $txt | % { $_.FullName }

$txtfile = Get-Content -Path $fullnametxt

$text_one_line = $txtfile -replace "`n|`r"
#making the text extracted from pdf into a single line string

$trim= ([regex]::Match($text_one_line, 'S*T*A*T*I*O*N: (.+) S*T*R*E*A*M:').Groups[1].Value) -replace "[\s # < > $ % ? . | ^ @ ! % * ' { } / \ :]", ''

#extracting the polling station name, remove spaces and illegal symbols

$txtname = $txt.BaseName

$truncate= $trim -replace '(?<=.{100}).+'
#limit the extracted polling station name to 100 characters to avoid errors when renaming

"`"$txtname.pdf`",`"$truncate`_$i.pdf`"" | Add-Content -Path $PSScriptRoot\list_names.txt 
#sends the original file name and its matching polling station name separated by a comma (to make it a CSV) to a textfile

$i++

}

echo "$trim"
#shows the extracted names on powershell (just to check if they were extracted correctly)





# ~~step 2- add a counter in each line in the textfile (to avoid having new file names that are exactly the same in the next step)~~ 

$b = get-content $PSScriptRoot\list_names.txt

$i=1

$b | foreach-object {$_+$i
$i++
}



# ~~step 3- use the polling station names in the textfile to rename the form 34s~~

$myHeader= 'fileName', 'newName'

Import-Csv $PSScriptRoot\list_names.txt -Header $myHeader | ForEach-Object { 
  if ($file = Resolve-Path "$PSScriptRoot\*\$($_.fileName)") { 
    Rename-Item $file $_.newName 
  } 
}


#~~step 3- log ocr reading errors (failed to rename properly)

$myHeader= echo fileName newName

$csv= Import-Csv $PSScriptRoot\list_names.txt -Header $myHeader 

Foreach ($line in $csv) {
    if ($line.newName -match '^_\d*\.pdf$') {
        Add-Content -path $PSScriptRoot\error_log.txt -Value "ERROR reading $($line.fileName)" 
    }
}




Stop-Transcript
#stop logging error messages(general, not ocr related), etc.
