#ARKData version 2.0
#
#Init settings
$ARKDataBinDir = (Get-Location).path #Where Arkdata.ps1 is ran from. Currently also hardcoded on line 294.
$ARKDataDataDir = "D:\ARKData" #Where Arkdata stores its data files.
$ARKDataWebDir = "C:\Dropbox\Public\html5\ARK" #Where Arkdata writes its website files.
#
#
#
#
#
# 
#++++ DON'T TOUCH ANYTHING DOWN HERE OR YOU MIGHT BREAK IT +++ 
#++++ DON'T TOUCH ANYTHING DOWN HERE OR YOU MIGHT BREAK IT +++ 
#++++ DON'T TOUCH ANYTHING DOWN HERE OR YOU MIGHT BREAK IT +++ 
#++++ DON'T TOUCH ANYTHING DOWN HERE OR YOU MIGHT BREAK IT +++ 
#++++ DON'T TOUCH ANYTHING DOWN HERE OR YOU MIGHT BREAK IT +++ 

#region always runs
#Test if paths are valid:
if (!(test-path $ARKDataDataDir)) { 
write-host $ARKDataDataDir "is not a valid directory, please check `$ARKDataDataDir in your init settings at the top of Arkdata.ps1. 
Did not load Arkdata module." -f "Red"
break
} elseif (!(test-path $ARKDataWebDir)) 
{ write-host $ARKDataWebDir "is not a valid directory, please check `$ARKDataWebDir in your init settings at the top of Arkdata.ps1. 
Did not load Arkdata module." -f "Red"
break
}else {
(cat "$ARKDataBinDir\arkdata.ps1" | Select-String "function") | select -skip 1
write-host "Directories validated." -f "Yellow"
write-host "Type " -f "Yellow" -nonewline; write-host "Start-ARKDataTask" -f  "Green" -nonewline; write-host " to start Arkdata." -f "Yellow"
}
#endregion

#region Functions 
function Start-ArkdataTask
{

#Noob Friendly!Wiped 1/6 PVPVE 10xT 3xG 5xExp-72ndLegion - (v253
start-job { ipmo "C:\Dropbox\repos\ARKData\arkdata.ps1" ; Run-ArkdataTask -serverip "104.156.227.231" -serverport 27040 }

#GILARK
#start-job { ipmo "C:\Dropbox\Public\Scripts\Powershell\ARK\Arkdata.ps1" ; Run-ArkdataTask -serverip "24.16.204.32" -serverport 27015 }

#PvP-Hardcore-OfficialServer92
#start-job { ipmo "C:\Dropbox\Public\Scripts\Powershell\ARK\Arkdata.ps1" ; Run-ArkdataTask -serverip "72.251.237.140" -serverport 27015 }

#PvP-Hardcore-OfficialServer90
#start-job { ipmo "C:\Dropbox\Public\Scripts\Powershell\ARK\Arkdata.ps1" ; Run-ArkdataTask -serverip "72.251.237.140" -serverport 27019 }

#The-Asia-OfficialServer527
#start-job { ipmo "C:\Dropbox\Public\Scripts\Powershell\ARK\Arkdata.ps1" ; Run-ArkdataTask -serverip "115.182.255.34" -serverport 27015 }

#The-Asia-OfficialServer528
#start-job { ipmo "C:\Dropbox\Public\Scripts\Powershell\ARK\Arkdata.ps1" ; Run-ArkdataTask -serverip "115.182.255.34" -serverport 27017 }

#The-Asia-OfficialServer529
#start-job { ipmo "C:\Dropbox\Public\Scripts\Powershell\ARK\Arkdata.ps1" ; Run-ArkdataTask -serverip "115.182.255.34" -serverport 27019 }

 
Get-ArkdataTask
} #end Start-ArkdataTask


function Get-ArkdataTask
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
} #end Get-ArkdataTask

function Run-ArkdataTask
{
Param(

   [Parameter(Mandatory=$True,Position=1)]
#   [string]$servername,
   [ipaddress]$serverip,
   
   [Parameter(Mandatory=$True,Position=2)]
#   [string]$arkplayer
   [int]$serverport
) #end params

$ArkdataBinDir
while ($true) {
$ArkdataBinDir = "C:\Dropbox\Public\Scripts\Powershell\ARK"

#run these tasks
#Arkdata scraper, downloads and parses data packet, outputs to files.
$Arkdata = Get-ArkdataPayload $serverip $serverport 
[string]$servername = Get-ArkdataServerName $Arkdata
Test-ArkdataHostDirs $servername
Out-ArkdataPlayerFiles $Arkdata
Out-ArkdataTribeDB $Arkdata

#Create the .1440.txt file.
Out-ArkdataPlayersFile $servername
#Start-Process -filepath powershell.exe -argumentlist 'Out-ArkdataPlayersFile $servername'

#Arkdata webpage generator. Calls Arkdata output data combiner.
Out-ArkdataWebpage $servername

#Arkdata player reports, these take a long time.
Get-ArkdataPlayersLastDay $servername

#Main page
#Do this stuff once an hour: 
if ((get-date).minute -eq 0 ) {
Out-ArkdataIndex
Get-ArkdataDedicatedServers
} #end if 
#pause 60
$sleeptime = 60-(get-date).second
Sleep ($sleeptime)
}#end while

} #end Run-ArkdataTask
function Get-ArkdataPayload
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
while ($Arkdatapayload -eq $null) {
$Arkdatapayload = (& C:\Dropbox\Programs\util\curl-7.47.1\curl.exe $serveraddy -H "Cookie:__cfduidd1aedc5f2f5b5e85d206deff1506866c71456079535" -H "DNT: 1" -H "Accept-Encoding: sdch" -H "Accept-Language: en-US,en;q=0.8" -H "User-Agent: Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.87 Safari/537.36" -H "Accept: */*" -H "Referer: $serveraddy"  -H "X-Requested-With: XMLHttpRequest" -H "Connection: keep-alive")
if ($Arkdatapayload -eq $null) {
sleep 5
} #end IF
} #end WHILE

#Convert Arkdatapayload to usable format
$Arkdata = (ConvertFrom-Json $Arkdatapayload)
$arkhost = ($Arkdata.info.hostname.split(" "))[0]
#$arkhost = Get-ArkdataServerName $Arkdata 
Test-ArkdataHostDirs $arkhost
$arktime = get-date -format yyyy-MM-dd-HH-mm-ss
$Arkdatapayload > "$ArkdataDataDir\$arkhost\$arktime.txt"
#$ark2datapayload > "$ArkdataDataDir\$arkhost\2\$arktime.txt"
#Return $Arkdata
$Arkdata
}
<#
#>

#Parses the OfficialServer.ini files into objects - each OfficialServer has 4 OfficialServers running on it - ports 27015-27019
function Import-ArkdataINI
{
Param (
[Parameter(Mandatory=$True,Position=1)]
[string]$Filename
) #end param
$filecontents = gc $Filename 

#init objection object array
[array]$objection = @{} ; 

$fileline = $filecontents.Split([System.Environment]::NewLine) | where { $_.length -gt 4} | select -Unique
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
} #end Import-ArkDataINI 


#I got this online somewhere. I don't even use it. This is to add some attribute to my dynamic tables.
#Got from https://www.reddit.com/r/PowerShell/comments/2nni5r/the_power_of_converttohtml_and_css_part_2/
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
$playerdata =  $playerdata | Add-Member @{"ARK name"="$player ???"} -PassThru
$playerdata =  $playerdata | Add-Member @{"Tribe name"="#N\A"} -PassThru
$playerdata =  $playerdata | Add-Member @{TimeF=($players | where {$_.name -eq $player} | select TimeF).TimeF} -PassThru

#send back player data
return $playerdata #| FT ;

} #end if/else
}; #end foreach



} #end Get-ARKDataPlayers



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
$playerdata =  $playerdata | Add-Member @{"ARK name"="$player ???"} -PassThru
$playerdata =  $playerdata | Add-Member @{"Tribe name"="#N\A"} -PassThru
$playerdata =  $playerdata | Add-Member @{"Last Session Ended"=$playerlasttime} -PassThru

#send back player data
return $playerdata #| FT ;
}#end if
}; #end $players foreach-object 

} #end Get-ArkdataPlayersLastDay


#$player24 = gc "$serverFolder\player\.24h.txt"
#$player24.length
#This gets the player count
Function Out-ArkdataPlayersFile
{
Param(

   [Parameter(Mandatory=$True,Position=1)]
   [string]$servername
)
$serverFolder = "$ArkdataDataDir\$servername"
#$serverFolder = "C:\Dropbox\Docs\ARK\PvP-Hardcore-OfficialServer92"

#How many files do we retrieve?
$filecount = (60 * 24)
#Parse all into $files
$files = (Dir -file $serverFolder | Sort CreationTime -Descending | Select Name -First $filecount).name | ForEach-Object { (ConvertFrom-Json ( gc ($serverfolder + "\" + $_))) }
#Dumps a list of players and server daytimes
#$files | ForEach-Object {return (($_.players.name) + "`n" + ($_.rules.daytime_s))} | where { $_ -ne "" }

#Pull out player names into playerlist
$playerlist = ($files | ForEach-Object {return (($_.players.name) + "`n" )} )

#Get the unique ones that are more than 1 letter long (1 letter players are in there, like `n)
$somanyplayers = $playerlist | where {$_.length -gt 3} | select -Unique

#Script takes about 12 seconds to run so had it dump to file instead.
$header = "Name"
$header > "$serverFolder\player\.$filecount.txt"
$somanyplayers >> "$serverFolder\player\.$filecount.txt"

}



function Output-ArkdataPlayerTime 
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
$serverFolder = "$ArkdataDataDir\$servername"
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

#Get-ArkdataFileDate
$firstdayc = get-date -year $firstday.split("-")[0] -month $firstday.split("-")[1] -day $firstday.split("-")[2] -hour $firstday.split("-")[3] -minute $firstday.split("-")[4] -second $firstday.split("-")[5]

$lastdayc = get-date -year $lastday.split("-")[0] -month $lastday.split("-")[1] -day $lastday.split("-")[2] -hour $lastday.split("-")[3] -minute $lastday.split("-")[4] -second $lastday.split("-")[5]

$totalsec = [timespan]::FromSeconds($totalTime)
$fromsectohours = ($totalsec).totalhours
$lasttofirstdays = ($lastdayc - $firstdayc)
[int]$lasttofirstdaysstr = $lasttofirstdays.TotalDays.ToString()
[int]$timediffpercent = $totalsec.TotalDays / $lasttofirstdays.TotalDays * 100
$fromsectohoursstr = [int]$fromsectohours

$arkplayer + " played for " + $fromsectohoursstr + " hours in " + $sessioncount + " sessions, across " + $lasttofirstdaysstr + " days - that's " + $timediffpercent + " % of the time." >> "$serverFolder/player/.arkplayer.txt"

} #end Output-ArkDataPlayerTime 




Function Out-ArkdataPlayerFiles
{
Param(
   [Parameter(Mandatory=$True,Position=1)]
   [object]$Arkdata
)
#get latest scrape, parse, data for players with names
$players = $Arkdata.players | where {$_.name -ne ""} 
$arkhost = Get-ArkdataServerName $arkdata
#Populates the player files
foreach ($player in $players) {
#Cleanse brackets that break things
$playername = $player.name -replace '[][]','-'; 

#Get the current time, add to $player
$arktime = get-date -format yyyy-MM-dd-HH-mm-ss
$player = $player | Add-Member @{CurrentTime=$arktime} -passthru
#$player = $player | Add-Member @{debug1=$true} -passthru

#write file
Export-Csv -path "$ArkdataDataDir\$arkhost\player\$playername.csv" -append -InputObject $player -force

}#end foreach
}#end Out-ArkdataPlayerFiles
 
 
function Out-ArkdataTribeDB
{
Param(
   [Parameter(Mandatory=$True,Position=1)]
   [object]$Arkdata
)
$arktime = get-date -format yyyy-MM-dd-HH-mm-ss
#get latest scrape, parse, data for players with names
$players = $Arkdata.players | where {$_.name -ne ""} 

#Who's online but not in .tribe.csv?
foreach ($player in $players) {

$playername = $player.name -replace '[][]','-'; 
$tribe = import-csv "$ArkdataDataDir\assets\.tribe.csv"

#JOIN .tribe.csv with the $Arkdata packet, adds ARK name and Tribe name to online players.
$playerdata = $tribe | where {$_."Steam name" -eq $playername } | select "Steam name" ;

if ( $playerdata."Steam name".length -le 0 ) { #write-host $player.name } } 

#Add default values
$addplayer = $player.name + ",???,#N/A"
$addplayer = $addplayer | Add-Member @{"Steam name"=$playername} -passthru
$addplayer = $addplayer | Add-Member @{"ARK name"="$player ???"} -passthru
$addplayer = $addplayer | Add-Member @{"Tribe name"="#N\A"} -passthru
$addplayer = $addplayer | Add-Member @{"First seen"=$arktime} -passthru

#Update the CSV with the missing players
Export-Csv -path "$ArkdataDataDir\assets\.tribe.csv" -append -InputObject $addplayer -force

} #end IF
} #end foreach
} #end Out-ArkdataTribeDB



function Test-ArkdataHostDirs
{
Param ([Parameter(Mandatory=$True,Position=1)][string]$arkhost) #end param
#Make directories if not there
if(!(test-path "$ArkdataDataDir\$arkhost")){
md "$ArkdataDataDir\$arkhost";  #Main dir
md "$ArkdataDataDir\$arkhost\2";  #Second data source subdir
md "$ArkdataDataDir\$arkhost\player\" #Player file subdir
}
}



function Get-ArkdataServerName
{
Param(
   [Parameter(Mandatory=$True,Position=1)]
   [object]$Arkdata,
   [Parameter(Position=2)]
   [switch]$json
)

#Parse directory name, create if not there
if ($json) {
$Arkdata = (ConvertFrom-Json $Arkdata)
}
$arkhost = ($Arkdata.info.hostname.split(" "))[0]
$arkhost
}


#Get-ArkdataFileDate 2016-03-16-00-07-02
Function Get-ArkdataFileDate
{
Param(
   [Parameter(Mandatory=$True,Position=1)]
   [string]$FileName
)
$FileName = $FileName.split(".")[0]
get-date -year $FileName.split("-")[0] -month $FileName.split("-")[1] -day $FileName.split("-")[2] -hour $FileName.split("-")[3] -minute $FileName.split("-")[4] -second $FileName.split("-")[5]
}






function Get-ArkdataDedicatedServers
{
if ((get-date).minute -eq 0 ) {
while ($arkdedicatedservers -eq $null) {
$arkdedicatedservers = ( invoke-webrequest "http://arkdedicated.com/officialservers.ini").content
$arktime = get-date -format yyyy-MM-dd-HH-mm-ss
$arkdedicatedservers > "$ArkdataDataDir\dedServers\$arktime-officialservers.ini"
if ($arkdedicatedservers -eq $null) {
sleep 60
} #end inner IF
} #end WHILE
} #end outer IF
} #end Get-ArkdataDedicatedServers


Function Out-ArkdataIndex
{
$servers = (gci "$ArkdataWebDir\*.html").basename | where { $_ -notmatch "index" }
$servertitle = "Arkdata server page"
$indexfile = "$ArkdataWebDir\index.html" 

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
} #end Out-ArkdataIndex





Function Out-ArkdataWebpage
{
Param(
   [Parameter(Mandatory=$True,Position=1)]
   [string]$servername
)

$datestartpart = (get-date) 
$serverFolder = "$ArkdataDataDir\$servername"
$ArkdataPlayers = Get-ArkdataPlayers $servername
#Shows timestamp if people are playing, otherwise sleeping.

if ($ArkdataPlayers-ne $null) { 
#Parse the FileName back into the .NET datetime object
$ts = ((Dir -file $serverFolder).name[-1])
#Get-ArkdataFileDate
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
$playerspart = $ArkdataPlayers | sort "Tribe name" | select "Steam name", "ARK name", "Tribe name", @{N='Time Played'; E={$_.TimeF}} | ConvertTo-Html -fragment 
#$middlepart2 Tribe data gathered lovingly by humans from ingame chat.
#Count of tribes by number of players online
$tribespart = ($ArkdataPlayers)."Tribe name" | Group-Object | sort "count" -descending | select "count", "name" | ConvertTo-Html -fragment | out-string | Add-HTMLTableAttribute  -AttributeName 'class' -Value 'sortable'

} #end if ($ArkdataPlayers -ne $null)
#24h player count
$playercount = $ArkdataPlayers.TimeF.Count

#Had to move these beow the End If to get the player count in the title. 
$playerslast24h = Get-ArkdataPlayersLastDay $servername | where { $_."Last Session Ended" -gt (get-date).addhours(-24)}
$playerslast24w = $playerslast24h | sort "Last Session Ended" -descending | ConvertTo-Html -Fragment
$playercount24h = $playerslast24h.Count

#Load the serverlog if you made one
$serverlogpath = "$ArkdataDataDir\assets\$servername.txt"
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
$webdir = "$ArkdataWebDir\$servername.html" 
$toppart > $webdir #Top down to webpage title
$title >> $webdir #Servername as webpage title 
$gilgabanner >> $webdir #Gilgamech Technologies banner
#$Subtitle >> $webdir #Title down to "$servername"
$serversubpage  >> $webdir #Latest report: 
$servername >> $webdir #Servername
$servernamepart >> $webdir #Post servername tags
if ($ArkdataPlayers -ne $null) { 
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
$playercount >> $webdir #Count of ArkdataPlayers
$middlepart5m >> $webdir #"$player ???" means never seen...
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

} #end Out-ArkdataWebpage
# endregion


#region Webparts
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
<nav>
    <a href="/">Home</a> |
	<a href="/ark/index.html">Arkdata!</a> | 
	<a href="/minecraft.html">Minecraft!</a> | 
    <a href="/game.html">Game Page (under development)</a> | 
	<a href="/video.html">Video (under development)</a> |
	<a href="/clock.html">Concept clock (under development)</a> |
</nav>
<div class="content">
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
<h4>"PlayerName ???" means never seen on ingame chat. <br>
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
</div>
<h4>Website errors? Bad data? Advertising questions? <a href="mailto:Arkdataproject@gilgamech.com">Email me!</a><br>
Copyright 2016 Gilgamech Technologies.</h4>
<h6></h6>
<br>
<p class="banner">
    <a href="/ark/A0Oqmx8.png"><img src="/ark/A0Oqmx8.png" title="C1ick h34r ph0r m04r inph0" /></a>
</p>
</body></html>
'@
#    <a href=https://imgur.com/gallery/A0Oqmx8><img src=https://i.imgur.com/A0Oqmx8.png title="C1ick h34r ph0r m04r inph0" /></a>
#end