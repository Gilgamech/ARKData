#This is just a data file, for HTML code to live in.


#Arkdata params
#[CmdletBinding()]
#Param(
#
#   [Parameter(Mandatory=$True,Position=1)]
#   [string]$servername
#   [ipaddress]$serverip,
   
#   [Parameter(Mandatory=$True,Position=2)]
#   [string]$arkplayer
#   [int]$serverport
#)


#Import Arkdata module
#ipmo ".\arkdata.ps1"
#ipmo ".\arkdatawebparts.ps1"

#$datestartpart = (get-date) 
#Build webpage
$toppart = @'
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/> 
<title>
'@

#servername for title 
$Subtitle = @'
</title>
<link rel='shortcut icon' href='/ark/favicon.ico' type='image/x-icon'/ >
<meta http-equiv="refresh" content="60">
<link rel="stylesheet" type="text/css" charset="utf-8" href="/ark/arkdata.css">
<link rel="stylesheet" type="text/css" charset="utf-8" href="/ark/arkdatam.css" media="handheld" />
<script  type="text/css" charset="utf-8" src="/ark/sorttable.js"></script>
</head>
<body>
<H1>Welcome to Arkdata</h1>
<h4>Gil's player and tribe tracker</H4>
<h4>Page auto-refreshes every minute.</h4>
<h4>Report also generates every minute. Latest report: </h4>
<H2>
'@

$gilgaheader = @'
</title>
<link rel='shortcut icon' href='//gilgamech.com/favicon.ico' type='image/x-icon'/ >
<meta http-equiv="refresh" content="60">
<link rel="stylesheet" type="text/css" charset="utf-8" href="//gilgamech.com/gilgamech.css">
<link rel="stylesheet" type="text/css" charset="utf-8" href="/ark/arkdata2.css">
<link rel="stylesheet" type="text/css" charset="utf-8" href="/ark/arkdatam.css" media="handheld" />
<script  type="text/css" charset="utf-8" src="/ark/sorttable.js"></script>
</head>
<body>
<div class = "top">
<a href="/">Gilgamech</a> <a href="/">Technologies</a>
</div>
<p class="menu">
    <a href="/">Home</a> |
	<a href="/ark/index.html">ARKdata!</a> | 
	<a href="minecraft.html">Minecraft!</a> | 
    <a href="game.html">Game Page (under development)</a> | 
	<a href="video.html">Video (under development)</a> |
	<a href="clock.html">Concept clock (under development)</a> |
</p>

<H1>Welcome to Arkdata</h1>
<h4>Gil's player and tribe tracker</H4>
<h4></h4>
<h4>Servers currently being tracked:</h4>
'@

$servernamepart = @'
</H2>
<h5>Latest report date:</h5>
<table>
'@

$middlepartone = @'
</table>

<h5>Newest data payload:</h5>
<table>
'@

$serverone = @'
<H2><a href="/ark/
'@ #"

$servertwo = @'
.html">
'@ #"

$serverthree = @'
</a></H2>
'@

$endpart = @'
<h5></h5>
<table>
<h2>Page still under development.</h2>
'@



# servername goes here 

$servernamepart = @'
</H2>
<h5>Latest report date:</h5>
<table>
'@

#$arkdataBaseDir = "C:\Dropbox\Docs\ARK"
#$serverFolder = "$arkdataBaseDir\$servername"
#$arkd = & "$arkdataBaseDir\bin\arkdataoutput.ps1" 
#$arkd = & "$arkdataBaseDir\bin\arkdataoutput.ps1" $servername
#$arkd = Get-ARKDataPlayers $servername

#If there are no players, don't do anything.
#Shows timestamp if people are playing, otherwise sleeping.
#if ($arkd -ne $null) { 

#<h5>Report ends</h5>
$middlepartone = @'
</table>

<h5>Newest data payload:</h5>
<table>
'@

#$ts = ((Dir -file $serverFolder).name[-1])

#Parse the filename back into the .NET datetime object
#$latestpayload = get-date -year $ts.split("-")[0] -month $ts.split("-")[1] -day $ts.split("-")[2] -hour $ts.split("-")[3] -minute $ts.split("-")[4] -second $ts.split("-")[5].split(".")[0]

#$latestpayload = get-date -year $newestfile[-1].CurrentTime.split("-")[0] -month $newestfile[-1].CurrentTime.split("-")[1] -day $newestfile[-1].CurrentTime.split("-")[2] -hour $newestfile[-1].CurrentTime.split("-")[3] -minute $newestfile[-1].CurrentTime.split("-")[4] -second $newestfile[-1].CurrentTime.split("-")[5]

$middlepartreporttime = @'
</table>
<h2>Current ingame time is about: 
'@

#Current server time
#$servertime = (convertfrom-json (gc ($serverfolder + "\" + (Dir $serverFolder | Sort CreationTime -Descending | Select Name -First 1).name))).rules.daytime_s
#Parse hour and minute
#$hour = $servertime.split(":")[0].tostring()
#$minute = $servertime.split(":")[1].tostring()
#Gametime is 28 minutes to an RL minute, so our time is at least 28 minutes late. 
#$compensatetime = (28 + 28 )
#Take servertime and recombine with compensatetime to try to be accurate.
#$servertimeoutput = (get-date -hour $hour -minute $minute).AddMinutes($compensatetime)

$middlepartservertimenoon = @'
</h2>
<h4>Report took 
'@


$middlepartservertimenight = @'
 seconds to generate.</h4>
<h3>
'@

#Time to midday calculations
#$midday = get-date -hour 12 -minute 00 -day ($servertimeoutput.day + 1 )
#$timetomidday = new-timespan -start $servertimeoutput -end $midday
#$ttmd = ($timetomidday.hours * 60 + $timetomidday.Minutes)/28

$middlepartreport = @'
 minutes until The Midday Sound.<br>
'@

#Time to night calculations
#$night = get-date -hour 21 -minute 50 -day ($servertimeoutput.day +  1)
#$timetonight = new-timespan -start $servertimeoutput -end $night
#$ttmn = ($timetonight.hours * 60 + $timetonight.Minutes)/28

$middlepartservertimemorning = @'
 minutes until nighttime.<br>
'@

#Time to morning calculations
#$morning = get-date -hour 5 -minute 15 -day ($servertimeoutput.day + 1)
#$timetomorning = new-timespan -start $servertimeoutput -end $morning
#$ingametimetomorning = ( $timetomorning.hours.tostring() + ":" + $timetomorning.minutes)
#$ttmm = ($timetomorning.hours * 60 + $timetomorning.Minutes)/28
#$ttmrl = get-date -minute ((get-date).minute + $ttmm)

$middlepartttm = @'
 minutes until tomorrow morning.</h3> 
<h5>28 ingame minutes equals 1 minute.<br>
1 ingame day is 52 minutes long.<br>
This makes the ingame day 1456 minutes <br>
instead of Earth's 1440 minute day.</h5>
'@

#$playerspart = Table of Steam name, ARK name, Tribe name, TimeF goes here
#$playerspart = $arkd | sort "Tribe name" | select "Steam name", "ARK name", "Tribe name", @{N='Time Played'; E={$_.TimeF}} | ConvertTo-Html -fragment 


$middlepart2 = @'
<h4>Tribe data gathered lovingly by humans from ingame chat.</h4>

<h3>Count of online players in each tribe.</h3>
'@

#Count of tribes by number of players online
#$tribespart = ($arkd)."Tribe name" | Group-Object | sort "count" -descending | select "count", "name" | ConvertTo-Html -fragment | out-string | Add-HTMLTableAttribute  -AttributeName 'class' -Value 'sortable'


#$middlepartcount = @'
#<h4>"???" means never seen on ingame chat. <br>
#"#N\A" means No Tribe or Unknown.</h4>
#<h3>Players seen in the past 5 minutes, who are not currently playing:</h3>
#'@

#Tribes table

$middlepartplayercount = @'
<h3> Player count: 
'@

#$playercount = $arkd.Count
#Player count


$middlepart5m = @'
</h3>
<h4>"???" means never seen on ingame chat. <br>
"#N\A" means No Tribe or Unknown.</h4>
<h2>!Seen</h2>
<h3>Players seen in the past 24 hours, who are not currently playing:</h3>
<table class="sortable">
'@

$middlepart24h = @'
</table>
<h3> Players seen: 
'@

#24h player count
#$playerslast24h = Get-ARKDataPlayersLastDay $servername | where { $_."Last Session Ended" -gt (get-date).addhours(-24)}
#$playerslast24h = (& "$arkdataBaseDir\bin\arkdataoutlast24h.ps1" $servername) | where { $_."Last Session Ended" -gt (get-date).addhours(-24)}
#$playerslast24w = $playerslast24h | sort "Last Session Ended" -descending | ConvertTo-Html -Fragment
#$playercount24h = $playerslast24h.Count



$playerserver  = @'
</h3>
'@
#}

#$serverlogpath = "$arkdataBaseDir\assets\$servername.txt"
#$serverlog = "string"
#if (test-path $serverlogpath) { 
#$serverlog = import-csv $serverlogpath  | select "Server Log (Manually updated)" | ConvertTo-Html -Fragment
#} else {
#$serverlog = ""
#}

$tailpart = @'
<br>
<br>
<br>
<h4>Website errors? Bad data? Advertising questions? <a href="mailto:arkdataproject@gilgamech.com">Email me!</a><br>
Copyright 2016 Gilgamech Technologies.</h4>
<h6></h6>
<br>
<p class="banner">
    <a href=https://imgur.com/gallery/A0Oqmx8><img src=https://i.imgur.com/A0Oqmx8.png title="C1ick h34r ph0r m04r inph0" /></a>
</p>
</body></html>
'@


#$webdir = "$arkdataWebDir\$servername.html" 

#Webpage Stamping
#$toppart > $webdir #Top down to webpage title
#$servername >> $webdir #Servername
#$Subtitle >> $webdir #Title down to "$servername"
#$servername >> $webdir #Servername
#$servernamepart >> $webdir #Post servername tags
#if ($arkd -ne $null) { 
#$dateendpart = (get-date) # ----------------------------------------------> End timestamp
#($dateendpart  | select datetime | ConvertTo-Html -fragment)[3] >> $webdir #Report Datestamp
#$middlepartone >> $webdir #Newest data payload
#($latestpayload  | select datetime | ConvertTo-Html -fragment)[3] >> $webdir #Payload datestamp
#$middlepartreporttime >> $webdir #Current ingame time is approx
#$servertimeoutput.ToString("HH:mm")  >> $webdir #Server ingame time
#$middlepartservertimenoon >> $webdir #Report took: 
#($dateendpart - $datestartpart).seconds  >> $webdir #Report took this many seconds
#$middlepartservertimenight >> $webdir #seconds to generate
#[math]::truncate($ttmd) >> $webdir #TTMD Time to midday
#$middlepartreport >> $webdir #minutes until The Midday Sound
#[math]::truncate($ttmn) >> $webdir #TTMN Time to nighttime
#$middlepartservertimemorning >> $webdir #minutes until nighttime
#[math]::truncate($ttmm) >> $webdir #TTMM Time to morning
#$middlepartttm >> $webdir #minutes until tomorrow morning. 28 min...1440 etc.
#$middlepart2 >> $webdir #Tribe data gathered lovingly...
#$tribespart >> $webdir #Count of tribes online
#$middlepartplayercount >> $webdir #Player count:
#$playercount >> $webdir #Count of arkd
#$middlepart5m >> $webdir #"???" means never seen...
#$playerslast24w >> $webdir #Players seen last 24h by session ended date
#$middlepart24h >> $webdir #Players seen:
#$playercount24h >> $webdir #Count of Players seen last 24h
#$playerserver >> $webdir #Players seen closing tag
#} else {
##Sleeping output is very cacheable.
#"<h2>Nobody's playing right now,<br> so Arkdata is sleeping.</h2>" >> $webdir
#}
#
#if ($serverlog -ne "") {
#$serverlog >> $webdir #Manual serverlog text file
#}
#$tailpart >> $webdir #Footer - Website errors...down to ad.
