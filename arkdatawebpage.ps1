$arkdatapath = "C:\Dropbox\Docs\ARK\"
$serverFolder = "$arkdatapath\PvP-Hardcore-OfficialServer92-(v236.0)"


$toppart = @'
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/> 
<title>PvP-Hardcore-OfficialServer92-(v236.0)</title>
<link rel='shortcut icon' href='/92/favicon.ico' type='image/x-icon'/ >
<meta http-equiv="refresh" content="60">
<link rel="stylesheet" type="text/css" charset="utf-8" href="/92/player/test.css">
</head>
<body>
<H1>PvP-Hardcore-OfficialServer92-(v236.0)</H1>
<H2>Welcome to Gil's player and tribe tracker</H2>
<h4>Page auto-refreshes every minute.</h4>
<h4>Report also generates every minute. Latest report: </h4>
<table>
'@

$datepart = (get-date | select datetime | ConvertTo-Html -fragment)[3] 

$middlepartone = @'
</table>

<h4> Count of online players in each tribe. This "???" means never seen on ingame chat.  This "#N\A" means No Tribe or Unknown. </h4>
'@

$playerspart = & "$arkdatapath\bin\arkdataoutput.ps1" | sort "Tribe name" | select "Steam name", "ARK name", "Tribe name", "TimeF" | ConvertTo-Html -fragment 

$middleparttwo = @'
<h4>Tribe data gathered lovingly by humans from ingame chat.</h4>

'@

$tribespart = (& "$arkdatapath\bin\arkdataoutput.ps1")."Tribe name" | Group-Object | sort "count" -descending | select "count", "name" | ConvertTo-Html -fragment 

$tailpart = @'

<br>
<h4>Website errors? Bad data? Advertising questions? <a href="mailto:arkdataproject@gilgamech.com">Email me!</a></h4>
<h4>Copyright 2016 Gilgamech Technologies.</h4>
<br>
</body></html>
'@


$toppart > "$serverFolder\player\test.html"
$datepart >> "$serverFolder\player\test.html"
$middlepartone >> "$serverFolder\player\test.html"
$playerspart >> "$serverFolder\player\test.html"
$middleparttwo >> "$serverFolder\player\test.html"
$tribespart >> "$serverFolder\player\test.html"
$tailpart >> "$serverFolder\player\test.html"

