$arkpath = "C:\Dropbox\Docs\ARK\"
$serverFolder = "$arkpath\PvP-Hardcore-OfficialServer92-(v236.0)"


$toppart = @'
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>PvP-Hardcore-OfficialServer92-(v236.0)</title>
<link rel='shortcut icon' href='/92/favicon.ico' type='image/x-icon'/ >
</head>
<body background="/92/bg.jpg">
<H1>PvP-Hardcore-OfficialServer92-(v236.0)</H1>
<H2>Welcome to Gil's player and tribe tracker</H2>
<table>
'@


$datepart = (get-date | select datetime | ConvertTo-Html -fragment)[3] 

$playerspart = "$arkpath\bin\arkoutput.ps1" | sort "Tribe name" | select "ARK name", "Tribe name", "TimeF" | ConvertTo-Html -fragment 

$tribespart = ("$arkpath\bin\arkoutput.ps1")."Tribe name" | Group-Object | select "count", "name" | ConvertTo-Html -fragment 

$tailpart = @'
</table>
</body></html>
'@


$toppart > "$serverFolder\player\test.html"
$datepart >> "$serverFolder\player\test.html"
$playerspart >> "$serverFolder\player\test.html"
$tribespart >> "$serverFolder\player\test.html"
$tailpart >> "$serverFolder\player\test.html"


#$arkpath = "C:\Dropbox\Docs\ARK\"
#$serverFolder = "$arkpath\PvP-Hardcore-OfficialServer92-(v236.0)"

#get-date | select datetime | ConvertTo-Html > "$serverFolder\player\test.html"

#"$arkpath\bin\arkoutput.ps1" | sort "Tribe name" | select "ARK name", "Tribe name", "TimeF" | ConvertTo-Html >> "$serverFolder\player\test.html"

#("$arkpath\bin\arkoutput.ps1")."Tribe name" | Group-Object | select "count", "name" | ConvertTo-Html >> "$serverFolder\player\test.html"

