#ARKData
#Versions:
#1.5 - 
#1.4 - Upgraded to functions with cmdlets.
#1.3 - Upgrade to fully param'd scripts (removal of hardcodes) for easy use with any server. Just feed an IP and it figures out the rest.
#1.2 - Upgrade to data system allows "Players seen last 24h" view
#1.1 - Upgrade scheduling engine allows once-a-minute actions
#1.0 - Page online

#Init settings
#Import webparts data file for webpage stamping
$ARKDataBinDir = (Get-Location).path
$ARKDataDataDir = "D:\ARKData"
#$ARKDataDataDir = "C:\Dropbox\Docs\ARK"
$ARKDataWebDir = "C:\Dropbox\Public\html5\ARK"

#ipmo "$arkdataBinDir\arkdatawebparts.ps1"

#To run, open Powershell and run these 2 lines, without the hash/pound sign (#)
#ipmo ".\arkdata.ps1"
#Run-ARKDataTask
#servers: 
#
# 




#++++ DON'T TOUCH ANYTHING DOWN HERE OR YOU MIGHT BREAK IT +++ 
#++++ DON'T TOUCH ANYTHING DOWN HERE OR YOU MIGHT BREAK IT +++ 
#++++ DON'T TOUCH ANYTHING DOWN HERE OR YOU MIGHT BREAK IT +++ 
#++++ DON'T TOUCH ANYTHING DOWN HERE OR YOU MIGHT BREAK IT +++ 
#++++ DON'T TOUCH ANYTHING DOWN HERE OR YOU MIGHT BREAK IT +++ 

#Functions 

function Start-ARKDataTask
{

start-job { ipmo "C:\Dropbox\Public\Scripts\Powershell\ARK\arkdata.ps1" ; Run-ARKDataTask -serverip "24.16.204.32" -serverport 27015 }
start-job { ipmo "C:\Dropbox\Public\Scripts\Powershell\ARK\arkdata.ps1" ; Run-ARKDataTask -serverip "72.251.237.140" -serverport 27019 }

while ($true) {
foreach ($job in (get-job) ){
cls ;
write-host "Date:" (get-date)  "Job:" $Job.name "Length:"  $recjob.length # "Has data:" $recjob.hasmoredata ; 
get-job | where {$_.State -match "Running"} | select ID, State, HasMoreData, Command | FL ; 
$recjob = receive-job $job.id
if  ($recjob.length -gt 3) {
$recjob[-3..-1]
} else {
$recjob
} #end if 
sleep 10
} #end foreach
} #end while
} #end Start-ARKDataTask

function Get-ARKDataTask
{
while ($true) {
foreach ($job in (get-job) ){
cls ;
write-host "Date:" (get-date)  "Job:" $Job.name "Length:"  $job.length "Has data:" $job.HasMoreData ; 
get-job | where {$_.State -match "Running"} | select ID, State, HasMoreData, Command | FL ; 
$recjob = receive-job $job.id
if  ($recjob.length -gt 3) {
$recjob[-3..-1]
} else {
$recjob
} #end if 
sleep 10
} #end foreach
} #end while
} #end Get-ARKDataTask

function Run-ARKDataTask
{
Param(

   [Parameter(Mandatory=$True,Position=1)]
#   [string]$servername,
   [ipaddress]$serverip,
   
   [Parameter(Mandatory=$True,Position=2)]
#   [string]$arkplayer
   [int]$serverport
) #end params


#always runs
$ARKDataBinDir
while ($true) {
$ARKDataBinDir = "C:\Dropbox\Public\Scripts\Powershell\ARK"

#run these tasks
#arkdata scraper, downloads and parses data packet, outputs to files.
#[string]$servername = & "$ARKDataBinDir\arkdatascrape.ps1" $serverip $serverport

$arkdata = Get-ArkDataPayload $serverip $serverport 
[string]$servername = Get-ArkDataServerName $arkdata
Test-ARKDataHostDirs $servername
Out-ARKDataPlayerFiles $arkdata
Out-ARKDataTribeDB $arkdata


#arkdata webpage generator. Calls arkdata output data combiner.
Out-ArkDataWebpage $servername

#arkdata player reports, these take a long time.
Get-ARKDataPlayersLastDay $servername

#Main page
#Do this stuff once an hour: 
if ((get-date).minute -eq 0 ) {
Out-ARKDataIndex
Get-ARKDataDedicatedServers
} #end if 
#pause 60
$sleeptime = 60-(get-date).second
Sleep ($sleeptime)
}#end while

} #end Run-ARKDataTask


#Parses the OfficialServer.ini files into objects - each OfficialServer has 4 OfficialServers running on it - ports 27015-27019
function Import-ArkDataINI 
{
Param ([Parameter(Mandatory=$True,Position=1)][string]$file) #end param

#init objection object array
[array]$objection = @{} ; 

$fileline = $file.Split([System.Environment]::NewLine) | where { $_.length -gt 4} | select -Unique
#parse each line and populate internal servername and IP
foreach ($line in  $fileline) {
$linesplit = ($line.split(" /") | where { $_.length -gt 4} | select -Unique)

[string]$servername = ($linesplit[1])
[ipaddress]$serverip = ($linesplit[0])

#Add a line to the array, create columns for Name, Value, Type
#$objection += "" ; 
$objection += "" | select ServerName, ServerIP #, Type ; 
#Math out the index of the new line
$arrayspot = ( $objection.length -1 )
#Populate Name
$objection[ $arrayspot ].ServerName = $servername 
$objection[ $arrayspot ].ServerIP = $serverip 

} #end foreach
#return
$objection
} #end function


#I got this online somewhere. I don't even use it. This is to add some attribute to my dynamic tables.
Function Add-HTMLTableAttribute
{
    Param
    (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]
        $HTML,

        [Parameter(Mandatory=$true)]
        [string]
        $AttributeName,

        [Parameter(Mandatory=$true)]
        [string]
        $Value

    )


    $xml=[xml]$HTML
    $attr=$xml.CreateAttribute($AttributeName)
    $attr.Value=$Value
    $xml.table.Attributes.Append($attr) | Out-Null
    Return ($xml.OuterXML | out-string)
}


function Get-ARKDataPlayers
#Concatenates .tribe.csv and latest ARKdata file to show tribes and playtimes of active players.
{
Param([Parameter(Mandatory=$True,Position=1)][string]$servername)

$serverFolder = "$ARKDataDataDir\$servername"
$tribe = import-csv "$ARKDataDataDir\assets\.tribe.csv"
#get latest scrape, parse, data for players with names
$players = (convertfrom-json (gc ($serverfolder + "\" + (Dir $serverFolder | Sort CreationTime -Descending | Select Name -First 1).name))).players
$players2 = ($players | where {$_.name -ne ""}).name
$playerinfo = $players2

#foreach ($player in $players2) { 
$players2 | foreach-object { $player = $_ ; 
#write-host $player ;

[array]$playerdata = $tribe | where {$_."Steam name" -eq $player } | select "Steam name",  "ARK name", "Tribe name"; 
#write-host $playerdata ;
if ($playerdata -ne $null) {

$playerdata =  $playerdata | Add-Member @{TimeF=($players | where {$_.name -eq $player} | select TimeF).TimeF} -PassThru

return $playerdata #| FT ;

} else { 
#Have to add in some kind of values here.

$playerdata =  $playerdata | Add-Member @{"Steam name"=$player} -PassThru
$playerdata =  $playerdata | Add-Member @{"ARK name"="???"} -PassThru
$playerdata =  $playerdata | Add-Member @{"Tribe name"="#N\A"} -PassThru
$playerdata =  $playerdata | Add-Member @{TimeF=($players | where {$_.name -eq $player} | select TimeF).TimeF} -PassThru

#send back player data
return $playerdata #| FT ;

} #end if/else
}; #end foreach



} #end function Get-ARKDataPlayers



function Get-ARKDataPlayersLastDay
{
Param(

   [Parameter(Mandatory=$True,Position=1)]
   [string]$servername
)
#Concatenates .tribe.csv and latest ARKdata file to show tribes and playtimes of active players.
$serverFolder = "$ARKDataDataDir\$servername"
$tribe = import-csv "$ARKDataDataDir\assets\.tribe.csv"
$file = ".1440.txt"
#get latest scrape, parse, data for players with names
$players = import-csv ($serverfolder + "\player\$file") 

$currentplayers = (convertfrom-json (gc ($serverfolder + "\" + (Dir $serverFolder | Sort CreationTime -Descending | Select Name -First 1).name))).players.name | where {$_ -ne ""} 

#foreach ($player in $players2) { 
$players | foreach-object { $player = $_ ; 
#write-host $player ;

foreach ($current in $currentplayers) { 

#If they're in both lists, don't write.
if ($current -eq $player.name ) {return} 

} #end if

[array]$playerdata = $tribe | where {$_."Steam name" -eq $player.name } | select "Steam name",  "ARK name", "Tribe name"; 

#write-host $playerdata ;
if ($playerdata -ne $null) {

$playername = $player.name 

$playertime = get-date -format yyyy-MM-dd-HH-mm-ss

if (Test-Path "$serverFolder\player\$playername.csv") {
$playertime = Import-Csv "$serverFolder\player\$playername.csv" | select Name, Time, TimeF, CurrentTime

if ($playertime.CurrentTime.count -gt 1) {
$playerlasttime  = $playertime.CurrentTime[-1] 
$playerlastsession = $playertime.TimeF[-1]
}else{
$playerlasttime  = $playertime.CurrentTime 
$playerlastsession = $playertime.TimeF
} #end inner IF 


} else{
$playerlasttime = get-date -format yyyy-MM-dd-HH-mm-ss
$playerlastsession = "00:00"

} #end IF 

$playerlasttime = get-date -year $playerlasttime.split("-")[0] -month $playerlasttime.split("-")[1] -day $playerlasttime.split("-")[2] -hour $playerlasttime.split("-")[3] -minute $playerlasttime.split("-")[4] -second $playerlasttime.split("-")[5]


$playerdata =  $playerdata | Add-Member @{"Last Session Ended"=$playerlasttime} -PassThru
$playerdata =  $playerdata | Add-Member @{"Session Duration"=$playerlastsession} -PassThru
return $playerdata #| FT ;

} else { 
#Have to add in some kind of values here.

$playername = $player.name 
$playerlasttime  = Import-Csv "$serverFolder\player\$playername.csv"
$playerdata =  $playerdata | Add-Member @{"Steam name"=$player.name} -PassThru
$playerdata =  $playerdata | Add-Member @{"ARK name"="???"} -PassThru
$playerdata =  $playerdata | Add-Member @{"Tribe name"="#N\A"} -PassThru
$playerdata =  $playerdata | Add-Member @{"Last Session Ended"=$playerlasttime} -PassThru

#send back player data
return $playerdata #| FT ;
}#end if
}; #end $players foreach-object 
} #end Get-ARKDataPlayersLastDay




function Output-ArkDataPlayerTime 
#Doesn't work.
{

[CmdletBinding()]
Param(

   [Parameter(Mandatory=$True,Position=1)]
   [string]$servername,
   
  [Parameter(Mandatory=$True,Position=2)]
   [string]$arkplayer
)
#Inits
$sessioncount = 0 ; 
$prevTime = 9999; 
$totalTime = 0 ; 
$firstday = "00-00-00-00-00-00";
$lastday = "00-00-00-00-00-00";
#Folders
$serverFolder = "$ARKDataDataDir\$servername"
$players = import-csv "$serverFolder\player\$arkplayer.csv"
#Get the first time in the thing
if  ( $players.length -gt 1) 
{
$firstday = $players[0].CurrentTime
$lastday = $players[-1].CurrentTime
} else {
$firstday = $players.CurrentTime
$lastday = $players.CurrentTime
}

foreach ($pltime in ($players.Time)) { 
if ([int]$prevTime -gt [int]$pltime) { 
[int]$sessioncount += 1 ; 
[int]$totalTime = [int]$prevTime + [int]$totalTime 
} ; 
[int]$prevTime = [int]$pltime   
} ; 

$firstdayc = get-date -year $firstday.split("-")[0] -month $firstday.split("-")[1] -day $firstday.split("-")[2] -hour $firstday.split("-")[3] -minute $firstday.split("-")[4] -second $firstday.split("-")[5]

$lastdayc = get-date -year $lastday.split("-")[0] -month $lastday.split("-")[1] -day $lastday.split("-")[2] -hour $lastday.split("-")[3] -minute $lastday.split("-")[4] -second $lastday.split("-")[5]

$totalsec = [timespan]::FromSeconds($totalTime)
$fromsectohours = ($totalsec).totalhours
$lasttofirstdays = ($lastdayc - $firstdayc)
[int]$lasttofirstdaysstr = $lasttofirstdays.TotalDays.ToString()
[int]$timediffpercent = $totalsec.TotalDays / $lasttofirstdays.TotalDays * 100
$fromsectohoursstr = [int]$fromsectohours

$arkplayer + " played for " + $fromsectohoursstr + " hours in " + $sessioncount + " sessions, across " + $lasttofirstdaysstr + " days - that's " + $timediffpercent + " % of the time." >> "$serverFolder/player/.arkplayer.txt"

} #end 



Function Out-ARKDataPlayerFiles
{
Param(
   [Parameter(Mandatory=$True,Position=1)]
   [object]$arkdata,
   [Parameter(Mandatory=$True,Position=1)]
   [string]$arkhost
)
#get latest scrape, parse, data for players with names
$players = $arkdata.players | where {$_.name -ne ""} 

#Populates the player files
foreach ($player in $players) {
#Cleanse brackets that break things
$playername = $player.name -replace '[][]','-'; 

#Get the current time, add to $player
$arktime = get-date -format yyyy-MM-dd-HH-mm-ss
$player = $player | Add-Member @{CurrentTime=$arktime} -passthru
#$player = $player | Add-Member @{debug1=$true} -passthru

#write file
Export-Csv -path "$ARKDataDataDir\$arkhost\player\$playername.csv" -append -InputObject $player -force

}#end foreach
}#end Out-ARKDataPlayerFiles
 
 
function Out-ARKDataTribeDB
{
Param(
   [Parameter(Mandatory=$True,Position=1)]
   [object]$arkdata
)
#get latest scrape, parse, data for players with names
$players = $arkdata.players | where {$_.name -ne ""} 

#Who's online but not in .tribe.csv?
foreach ($player in $players) {

$playername = $player.name -replace '[][]','-'; 
$tribe = import-csv "$ARKDataDataDir\assets\.tribe.csv"

#JOIN .tribe.csv with the $arkdata packet, adds ARK name and Tribe name to online players.
$playerdata = $tribe | where {$_."Steam name" -eq $playername } | select "Steam name" ;

if ( $playerdata."Steam name".length -le 0 ) { #write-host $player.name } } 

#Add default values
$addplayer = $player.name + ",???,#N/A"
$addplayer = $addplayer | Add-Member @{"Steam name"=$playername} -passthru
$addplayer = $addplayer | Add-Member @{"ARK name"="???"} -passthru
$addplayer = $addplayer | Add-Member @{"Tribe name"="#N\A"} -passthru
$addplayer = $addplayer | Add-Member @{"First seen"=$arktime} -passthru

#Update the CSV with the missing players
Export-Csv -path "$ARKDataDataDir\assets\.tribe.csv" -append -InputObject $addplayer -force

} #end IF
} #end foreach
} #end Out-ARKDataTribeDB
function Test-ARKDataHostDirs
{
Param ([Parameter(Mandatory=$True,Position=1)][string]$arkhost) #end param
#Make directories if not there
if(!(test-path "$ARKDataDataDir\$arkhost")){
md "$ARKDataDataDir\$arkhost";  #Main dir
md "$ARKDataDataDir\$arkhost\2";  #Second data source subdir
md "$ARKDataDataDir\$arkhost\player\" #Player file subdir
}
}



function Get-ArkDataServerName
{
Param(
   [Parameter(Mandatory=$True,Position=1)]
   [object]$arkdata,
   [Parameter(Position=2)]
   [switch]$json
)

#Parse directory name, create if not there
if ($json) {
$arkdata = (ConvertFrom-Json $arkdata)
}
$arkhost = ($arkdata.info.hostname.split(" "))[0]
$arkhost
}

#Get-ArkdataFileDate 2016-03-16-00-07-02
Function Get-ArkdataFileDate
{
Param(
   [Parameter(Mandatory=$True,Position=1)]
   [string]$FileName
)
get-date -year $FileName.split("-")[0] -month $FileName.split("-")[1] -day $FileName.split("-")[2] -hour $FileName.split("-")[3] -minute $FileName.split("-")[4] -second $FileName.split("-")[5]
}



function Get-ArkDataPayload
{
Param(
   [Parameter(Mandatory=$True,Position=1)]
   [ipaddress]$serverip,
   [Parameter(Mandatory=$True,Position=2)]
   [int]$serverport
)
 #Set date time and server vars
$serveripport = $serverip.IPAddressToString + ":" + $serverport
$serveraddy =  ("http://arkservers.net/api/query/" + $serveripport  )
#Pull in the Arkdata payload
while ($arkdatapayload -eq $null) {
$arkdatapayload = (& C:\Dropbox\Programs\util\curl-7.47.1\curl.exe $serveraddy -H "Cookie:__cfduidd1aedc5f2f5b5e85d206deff1506866c71456079535" -H "DNT: 1" -H "Accept-Encoding: sdch" -H "Accept-Language: en-US,en;q=0.8" -H "User-Agent: Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.87 Safari/537.36" -H "Accept: */*" -H "Referer: $serveraddy"  -H "X-Requested-With: XMLHttpRequest" -H "Connection: keep-alive")
if ($arkdatapayload -eq $null) {
sleep 5
} #end IF
} #end WHILE

#Pull in the Ark2data payload
while ($ark2datapayload -eq $null) {
$ark2datapayload = (& C:\Dropbox\Programs\util\curl-7.47.1\curl.exe "https://api.ark.bar/server/$serveripport" )
if ($ark2datapayload -eq $null) {
sleep 5
} #end IF
} #end WHILE

#Convert arkdatapayload to usable format
$arkdata = (ConvertFrom-Json $arkdatapayload)
$arkhost = ($arkdata.info.hostname.split(" "))[0]
#$arkhost = Get-ArkDataServerName $arkdata 
Test-ARKDataHostDirs $arkhost
$arktime = get-date -format yyyy-MM-dd-HH-mm-ss
$arkdatapayload > "$ARKDataDataDir\$arkhost\$arktime.txt"
$ark2datapayload > "$ARKDataDataDir\$arkhost\2\$arktime.txt"
#Return $arkdata
$arkdata
}

Function Out-ARKDataIndex
{
$servers = (gci "$ARKDataWebDir\*.html").basename | where { $_ -notmatch "index" }
$servertitle = "ARKData server page"
$indexfile = "$ARKDataWebDir\index.html" 

$toppart > $indexfile #Header
$servertitle >> $indexfile #Title
$gilgabanner >> $indexfile #Gilgamech Technologies banner
$indexsubpage >> $indexfile #Servers being tracked:
foreach ($server in $servers) {
$serverone >> $indexfile #HTML before servername to set up link
$server >> $indexfile
$servertwo >> $indexfile #HTML to close link and set up text display
$server >> $indexfile
$serverthree>> $indexfile #HTML after servername to close text display
} #end foreach
$endpart >> $indexfile #Page still under development
$tailpart >> $indexfile #Footer and banner ads
} #end Out-ARKDataIndex

function Get-ARKDataDedicatedServers
{
if ((get-date).minute -eq 0 ) {
while ($arkdedicatedservers -eq $null) {
$arkdedicatedservers = ( invoke-webrequest "http://arkdedicated.com/officialservers.ini").content
$arktime = get-date -format yyyy-MM-dd-HH-mm-ss
$arkdedicatedservers > "$ARKDataDataDir\dedServers\$arktime-officialservers.ini"
if ($arkdedicatedservers -eq $null) {
sleep 60
} #end inner IF
} #end WHILE
} #end outer IF
} #end Get-ARKDataDedicatedServers



Function Out-ArkDataWebpage
{
Param(
   [Parameter(Mandatory=$True,Position=1)]
   [string]$servername
)

$datestartpart = (get-date) 
$serverFolder = "$ARKDataDataDir\$servername"
$arkd = Get-ARKDataPlayers $servername
#Shows timestamp if people are playing, otherwise sleeping.
if ($arkd -ne $null) { 
#Parse the filename back into the .NET datetime object
$ts = ((Dir -file $serverFolder).name[-1])
$latestpayload = get-date -year $ts.split("-")[0] -month $ts.split("-")[1] -day $ts.split("-")[2] -hour $ts.split("-")[3] -minute $ts.split("-")[4] -second $ts.split("-")[5].split(".")[0]
#Current server time
$servertime = (convertfrom-json (gc ($serverfolder + "\" + (Dir $serverFolder | Sort CreationTime -Descending | Select Name -First 1).name))).rules.daytime_s
#Parse hour and minute
$hour = $servertime.split(":")[0].tostring()
$minute = $servertime.split(":")[1].tostring()
#Gametime is 28 minutes to an RL minute, so our time is at least 28 minutes late. 
$compensatetime = (28 + 28 )
#Take servertime and recombine with compensatetime to try to be accurate.
$servertimeoutput = (get-date -hour $hour -minute $minute).AddMinutes($compensatetime)
#Time to midday calculations
$midday = get-date -hour 12 -minute 00 -day ($servertimeoutput.day + 1 )
$timetomidday = new-timespan -start $servertimeoutput -end $midday
$ttmd = ($timetomidday.hours * 60 + $timetomidday.Minutes)/28
#Time to night calculations
$night = get-date -hour 21 -minute 50 -day ($servertimeoutput.day +  1)
$timetonight = new-timespan -start $servertimeoutput -end $night
$ttmn = ($timetonight.hours * 60 + $timetonight.Minutes)/28
#Time to morning calculations
$morning = get-date -hour 5 -minute 15 -day ($servertimeoutput.day + 1)
$timetomorning = new-timespan -start $servertimeoutput -end $morning
$ingametimetomorning = ( $timetomorning.hours.tostring() + ":" + $timetomorning.minutes)
$ttmm = ($timetomorning.hours * 60 + $timetomorning.Minutes)/28
#$middlepartttm  minutes until tomorrow morning.
#$playerspart = Table of Steam name, ARK name, Tribe name, TimeF goes here
$playerspart = $arkd | sort "Tribe name" | select "Steam name", "ARK name", "Tribe name", @{N='Time Played'; E={$_.TimeF}} | ConvertTo-Html -fragment 
#$middlepart2 Tribe data gathered lovingly by humans from ingame chat.
#Count of tribes by number of players online
$tribespart = ($arkd)."Tribe name" | Group-Object | sort "count" -descending | select "count", "name" | ConvertTo-Html -fragment | out-string | Add-HTMLTableAttribute  -AttributeName 'class' -Value 'sortable'
#Tribes table
#$middlepartplayercount Player count: 
$playercount = $arkd.Count
#$middlepart5m = "???" means never seen on ingame chat. 
#$middlepart24h =  Players seen: 
#24h player count
} #end if ($arkd -ne $null)
#Had to move these beow the End If to get the player count in the title. 
$playerslast24h = Get-ARKDataPlayersLastDay $servername | where { $_."Last Session Ended" -gt (get-date).addhours(-24)}
$playerslast24w = $playerslast24h | sort "Last Session Ended" -descending | ConvertTo-Html -Fragment
$playercount24h = $playerslast24h.Count


#Load the serverlog if you made one
$serverlogpath = "$ARKDataDataDir\assets\$servername.txt"
$serverlog = "string"
if (test-path $serverlogpath) { 
$serverlog = import-csv $serverlogpath  | select "Server Log (Manually updated)" | ConvertTo-Html -Fragment
} else {
$serverlog = ""
}
#Create page title (Player count and servername)
if ($playercount) {
$title = $playercount.tostring() + " playing on " + $servername 
} else {
$title = "0 playing on " + $servername 
}

#Webpage Stamping
$webdir = "$ARKDataWebDir\$servername.html" 
$toppart > $webdir #Top down to webpage title
$title >> $webdir #Servername as webpage title 
$gilgabanner >> $webdir #Gilgamech Technologies banner
#$Subtitle >> $webdir #Title down to "$servername"
$serversubpage  >> $webdir #Latest report: 
$servername >> $webdir #Servername
$servernamepart >> $webdir #Post servername tags
if ($arkd -ne $null) { 
$dateendpart = (get-date) # ----------------------------------------------> End timestamp
($dateendpart  | select datetime | ConvertTo-Html -fragment)[3] >> $webdir #Report Datestamp
$middlepartone >> $webdir #Newest data payload
($latestpayload  | select datetime | ConvertTo-Html -fragment)[3] >> $webdir #Payload datestamp
$middlepartreporttime >> $webdir #Current ingame time is approx
$servertimeoutput.ToString("HH:mm")  >> $webdir #Server ingame time
$middlepartservertimenoon >> $webdir #Report took: 
($dateendpart - $datestartpart).seconds  >> $webdir #Report took this many seconds
$middlepartservertimenight >> $webdir #seconds to generate
[math]::truncate($ttmd) >> $webdir #TTMD Time to midday
$middlepartreport >> $webdir #minutes until The Midday Sound
[math]::truncate($ttmn) >> $webdir #TTMN Time to nighttime
$middlepartservertimemorning >> $webdir #minutes until nighttime
[math]::truncate($ttmm) >> $webdir #TTMM Time to morning
$middlepartttm >> $webdir #minutes until tomorrow morning. 28 min...1440 etc.
$playerspart >> $webdir #Players online
$middlepart2 >> $webdir #Tribe data gathered lovingly...
$tribespart >> $webdir #Count of tribes online
$middlepartplayercount >> $webdir #Player count:
$playercount >> $webdir #Count of arkd
$middlepart5m >> $webdir #"???" means never seen...
$playerslast24w >> $webdir #Players seen last 24h by session ended date
$middlepart24h >> $webdir #Players seen:
$playercount24h >> $webdir #Count of Players seen last 24h
$playerserver >> $webdir #Players seen closing tag
} else {
#Sleeping output is very cacheable.
"<h2>Nobody's playing right now,<br> so Arkdata is sleeping.</h2>" >> $webdir
}

if ($serverlog -ne "") {
$serverlog >> $webdir #Manual serverlog text file
}
$tailpart >> $webdir #Footer - Website errors...down to ad.

} #end Out-ArkDataWebpage






#+++++ WEBPARTS DOWN HERE +++++
#+++++ WEBPARTS DOWN HERE +++++
#+++++ WEBPARTS DOWN HERE +++++
#+++++ WEBPARTS DOWN HERE +++++
#+++++ WEBPARTS DOWN HERE +++++







$toppart = @'
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/> 
<title>
'@

$gilgabanner = @'
</title>
<link rel='shortcut icon' href='//gilgamech.com/favicon.ico' type='image/x-icon'/ >
<meta http-equiv="refresh" content="60">
<link rel="stylesheet" type="text/css" charset="utf-8" href="//gilgamech.com/gilgamech.css">
<link rel="stylesheet" type="text/css" charset="utf-8" href="/ark/arkdata.css">
<link rel="stylesheet" type="text/css" charset="utf-8" href="/ark/arkdatam.css" media="handheld" />
<script  type="text/css" charset="utf-8" src="/ark/sorttable.js"></script>
</head>
<body>
<div class = "top">
<a href="/">Gilgamech Technologies</a>
</div>
<p class="menu">
    <a href="/">Home</a> |
	<a href="/ark/index.html">ARKdata!</a> | 
	<a href="/minecraft.html">Minecraft!</a> | 
    <a href="/game.html">Game Page (under development)</a> | 
	<a href="/video.html">Video (under development)</a> |
	<a href="/clock.html">Concept clock (under development)</a> |
</p>
<H1>Welcome to Arkdata</h1>
<h4>Gil's player and tribe tracker</H4>
'@

$indexsubpage = @'
<h4></h4>
<h4>Servers currently being tracked:</h4>
'@

$serversubpage = @'
<h4>Page auto-refreshes every minute.</h4>
<h4>Report also generates every minute. Latest report: </h4>
<H2>
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
'@
#<h2>Page still under development.</h2>


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


$middlepartreporttime = @'
</table>
<h2>Current ingame time is about: 
'@


$middlepartservertimenoon = @'
</h2>
<h4>Report took 
'@


$middlepartservertimenight = @'
 seconds to generate.</h4>
<h3>
'@

$middlepartreport = @'
 minutes until The Midday Sound.<br>
'@

$middlepartservertimemorning = @'
 minutes until nighttime.<br>
'@

$middlepartttm = @'
 minutes until tomorrow morning.</h3> 
<h5>28 ingame minutes equals 1 minute.<br>
1 ingame day is 52 minutes long.<br>
This makes the ingame day 1456 minutes <br>
instead of Earth's 1440 minute day.</h5>
'@

$middlepart2 = @'
<h4>Tribe data gathered lovingly by humans from ingame chat.</h4>

<h3>Count of online players in each tribe.</h3>
'@
$middlepartplayercount = @'
<h3> Player count: 
'@


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

$playerserver  = @'
</h3>
'@

$tailpart = @'
<br>
<br>
<br>
<h4>Website errors? Bad data? Advertising questions? <a href="mailto:arkdataproject@gilgamech.com">Email me!</a><br>
Copyright 2016 Gilgamech Technologies.</h4>
<h6></h6>
<br>
<p class="banner">
    <a href="/ark/A0Oqmx8.png"><img src="/ark/A0Oqmx8.png" title="C1ick h34r ph0r m04r inph0" /></a>
</p>
</body></html>
'@
#    <a href=https://imgur.com/gallery/A0Oqmx8><img src=https://i.imgur.com/A0Oqmx8.png title="C1ick h34r ph0r m04r inph0" /></a>
