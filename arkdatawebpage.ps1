$arkdatapath = "C:\Dropbox\Docs\ARK\"
$serverFolder = "C:\Dropbox\Docs\ARK\PvP-Hardcore-OfficialServer92"
$arkd = & "$arkdatapath\bin\arkdataoutput.ps1"
$playerspart = $arkd | sort "Tribe name" | select "Steam name", "ARK name", "Tribe name", @{N='Time Played'; E={$_.TimeF}} | ConvertTo-Html -fragment 
#$playerspart = $arkd | sort "Tribe name" | select "Steam name", "ARK name", "Tribe name", "TimeF" | ConvertTo-Html -fragment 
$tribespart = ($arkd)."Tribe name" | Group-Object | sort "count" -descending | select "count", "name" | ConvertTo-Html -fragment 
$playerslast5m = & "$arkdatapath\bin\arkdataoutlast5m.ps1" | sort "Tribe name" | ConvertTo-Html -Fragment
$playerslast60m = & "$arkdatapath\bin\arkdataoutlast60m.ps1" | sort "Tribe name" | ConvertTo-Html -Fragment
$playerslast24h = & "$arkdatapath\bin\arkdataoutlast24h.ps1" | sort "Tribe name" | ConvertTo-Html -Fragment
#$playerslast5m = (import-csv "$serverFolder\player\.5.txt") | ConvertTo-Html -Fragment
#$playerslast60m = (import-csv "$serverFolder\player\.60.txt") | ConvertTo-Html -Fragment
#$playerslast24h = (import-csv "$serverFolder\player\.1440.txt") | ConvertTo-Html -Fragment

#Set up server time display
#Bring in the last server time (this data is 60 seconds old)
$servertime = (convertfrom-json (gc ($serverfolder + "\" + (Dir $serverFolder | Sort CreationTime -Descending | Select Name -First 1).name))).rules.daytime_s
#Parse hour and minute
$hour = $servertime.split(":")[0].tostring()
$minute = $servertime.split(":")[1].tostring()
#Gametime is 28 minutes to an RL minute, so our time is at least 28 minutes late. 
$compensatetime = (28 + 20 )
#Take servertime and recombine with compensatetime to try to be accurate.
$servertimeoutput = (get-date -hour $hour -minute $minute).AddMinutes($compensatetime)

#Time to morning calculations
$morning = get-date -hour 5 -minute 15 -day ($servertimeoutput.day + 1)
$timetomorning = new-timespan -start $servertimeoutput -end $morning
$ingametimetomorning = ( $timetomorning.hours.tostring() + ":" + $timetomorning.minutes)
$ttmm = ($timetomorning.hours * 60 + $timetomorning.Minutes)/28
#$ttmrl = get-date -minute ((get-date).minute + $ttmm)

#Time to night calculations
$night = get-date -hour 21 -minute 45 -day ($servertimeoutput.day +  1)
$timetonight = new-timespan -start $servertimeoutput -end $night
$ttmn = ($timetonight.hours * 60 + $timetonight.Minutes)/28

#Time to midday calculations
$midday = get-date -hour 12 -minute 00 -day ($servertimeoutput.day + 1 )
$timetomidday = new-timespan -start $servertimeoutput -end $midday
$ttmd = ($timetomidday.hours * 60 + $timetomidday.Minutes)/28

#player count
$playercount = $arkd.Count

$toppart = @'
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/> 
<title>PvP-Hardcore-OfficialServer92</title>
<link rel='shortcut icon' href='/92/favicon.ico' type='image/x-icon'/ >
<meta http-equiv="refresh" content="60">
<link rel="stylesheet" type="text/css" charset="utf-8" href="/92/player/test.css">
<link rel="stylesheet" type="text/css" charset="utf-8" href="/92/player/mtest.css" media="handheld" />
</head>
<body>
<H1>Welcome to Arkdata</h1>
<h4>Gil's player and tribe tracker</H4>
<h4>Page auto-refreshes every minute.</h4>
<h4>Report also generates every minute. Latest report: </h4>
<H2>PvP-Hardcore-OfficialServer92</H2>
<table class="center">
'@

#Shows timestamp if people are playing, otherwise sleeping.

$middlepartone = @'
</table>

<h2>Current server time is about: 
'@

#Current server time

$middlepartservertimenoon = @'
</h2>
<h3>
'@
$middlepartservertimenight = @'
 minutes until The Midday Sound.<br>
'@
$middlepartservertimemorning = @'
 minutes until nighttime.<br>
'@

$middlepartttm = @'
 minutes until tomorrow morning.</h3> 
<h5>28 minutes ingame equals 1 minute.<br>
1 ingame day is 52 minutes long.</h5>
'@

#$playerspart = Table of Steam name, ARK name, Tribe name, TimeF goes here

$middlepart2 = @'
<h4>Tribe data gathered lovingly by humans from ingame chat.</h4>

<h3>Count of online players in each tribe.</h3>
'@

#Count of tribes by number of players online


$middlepartcount = @'
<h4>"???" means never seen on ingame chat. <br>
"#N\A" means No Tribe or Unknown.</h4>

<h3>Players seen in the past 5 minutes, who are not currently playing:</h3>

'@

#Tribes table

$middlepartplayercount = @'
<h3> Player count: 
'@

#Player count

$middlepart5m = @'
</h3>
<h4>"???" means never seen on ingame chat. <br>
"#N\A" means No Tribe or Unknown.</h4>
<h2>!Seen</h2>
<h3>Players seen in the past 5 minutes, who are not currently playing:</h3>


<h2>
'@
#players last 5 
$middlepart60m = @'

<h3>Players seen in the past 60 minutes, who are not currently playing:</h3>


<h2>
'@

#Players last 60 

$middlepart24h = @'

<h3>Players seen in the past 24 hours, who are not currently playing:</h3>


<h2>
'@

#List of player names

$tailpart = @'
</h2>

<br>
<h4>Website errors? Bad data? Advertising questions? <a href="mailto:arkdataproject@gilgamech.com">Email me!</a><br>
Copyright 2016 Gilgamech Technologies.</h4>
<br>
<p class="banner">
    <a href=https://imgur.com/gallery/A0Oqmx8><img src=https://i.imgur.com/A0Oqmx8.png title="C1ick h34r ph0r m04r inph0" /></a>
</p>
</body></html>
'@

if ($arkd -ne $null) { 
$datepart = (get-date | select datetime | ConvertTo-Html -fragment)[3] 
} else {
$datepart = "<h2>Nobody's playing right now,<br> so Arkdata is sleeping.</h2>" 
}

$toppart > "$serverFolder\player\test.html"
$datepart >> "$serverFolder\player\test.html"
$middlepartone >> "$serverFolder\player\test.html"
$servertimeoutput.ToString("HH:mm")  >> "$serverFolder\player\test.html"
$middlepartservertimenoon >> "$serverFolder\player\test.html"
[math]::truncate($ttmd) >> "$serverFolder\player\test.html"
$middlepartservertimenight >> "$serverFolder\player\test.html"
[math]::truncate($ttmn) >> "$serverFolder\player\test.html"
$middlepartservertimemorning >> "$serverFolder\player\test.html"
[math]::truncate($ttmm) >> "$serverFolder\player\test.html"
$middlepartttm >> "$serverFolder\player\test.html"
$playerspart >> "$serverFolder\player\test.html"
$middlepart2 >> "$serverFolder\player\test.html"
$tribespart >> "$serverFolder\player\test.html"
$middlepartplayercount >> "$serverFolder\player\test.html"
$playercount >> "$serverFolder\player\test.html"
$middlepart5m >> "$serverFolder\player\test.html"
$playerslast5m >> "$serverFolder\player\test.html"
$middlepart60m >> "$serverFolder\player\test.html"
$playerslast60m >> "$serverFolder\player\test.html"
$middlepart24h >> "$serverFolder\player\test.html"
$playerslast24h >> "$serverFolder\player\test.html"
$tailpart >> "$serverFolder\player\test.html"

