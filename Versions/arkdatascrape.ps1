#Arkdata params
[CmdletBinding()]
Param(

   [Parameter(Mandatory=$True,Position=1)]
#   [string]$servername,
   [ipaddress]$serverip,
   
   [Parameter(Mandatory=$True,Position=2)]
#   [string]$arkplayer
   [int]$serverport
)
 
 #Import Arkdata module
#ipmo ".\arkdata.ps1"
ipmo "C:\Dropbox\Public\Scripts\Powershell\ARK\arkdata.ps1"

#Set date time and server vars
$serveripport = $serverip.IPAddressToString + ":" + $serverport
$serveraddy =  ("http://arkservers.net/api/query/" + $serveripport  )


#Became Get-ArkDataPayload
#Pull in the Arkdata payload
while ($arkdatapayload -eq $null) {
$arkdatapayload = (& C:\Dropbox\Programs\util\curl-7.47.1\curl.exe $serveraddy -H "Cookie:__cfduidd1aedc5f2f5b5e85d206deff1506866c71456079535" -H "DNT: 1" -H "Accept-Encoding: sdch" -H "Accept-Language: en-US,en;q=0.8" -H "User-Agent: Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.87 Safari/537.36" -H "Accept: */*" -H "Referer: $serveraddy"  -H "X-Requested-With: XMLHttpRequest" -H "Connection: keep-alive")


if ($arkdatapayload -eq $null) {

sleep 5
} #end IF
} #end WHILE

<# #Pull in the Ark2data payload
while ($ark2datapayload -eq $null) {

$ark2datapayload = (& C:\Dropbox\Programs\util\curl-7.47.1\curl.exe "https://api.ark.bar/server/$serveripport" )

if ($ark2datapayload -eq $null) {
sleep 5
} #end IF
} #end WHILE #>

<# 
#Became Get-ARKDataDedicatedServers
if ((get-date).minute -eq 0 ) {
#Pull in Arkdata as main data unit, from file
while ($arkdedicatedservers -eq $null) {
#$arkdedicatedservers = (& C:\Dropbox\Programs\util\curl-7.47.1\curl.exe "http://arkdedicated.com/officialservers.ini")
$arkdedicatedservers = ( invoke-webrequest "http://arkdedicated.com/officialservers.ini").content
if ($arkdedicatedservers -eq $null) {
sleep 5
} #end inner IF
} #end WHILE
} #end outer IF
 #>

#Became Get-ArkDataServerName
#Convert arkdatapayload to usable format
$arkdata = (ConvertFrom-Json $arkdatapayload)
#Parse directory name, create if not there
$arkhost = ($arkdata.info.hostname.split(" "))[0]
#$arkhost = Get-ArkDataServerName $arkdata

Test-ARKDataHostDirs $arkhost
<# #became Test-ARKDataHostDirs
#Make directories if not there
if(!(test-path "$ARKDataDataDir\$arkhost")){
md "$ARKDataDataDir\$arkhost";  #Main dir
md "$ARKDataDataDir\$arkhost\2";  #Second data source subdir
md "$ARKDataDataDir\$arkhost\player\" #Player file subdir
}
 #>
#Need to make this look for the servername and make a directory when found (FLAG)
#Merge Player back in to \ARK\Players\ cuz these are Steam names we're tracking. (FLAG)
#Write the files (This was just Arkdata written to file, but can't parse... For now, storing raw Json) - I can do this now, should fix at some point. (FLAG)


#Became Out-ArkDataDataFiles
#No it didn't, became part of Get-ArkDataPayload
$arktime = get-date -format yyyy-MM-dd-HH-mm-ss
$arkdatapayload > "$ARKDataDataDir\$arkhost\$arktime.txt"
#$ark2datapayload > "$ARKDataDataDir\$arkhost\2\$arktime.txt"
#if ($arkdedicatedservers -ne $null){
#$arkdedicatedservers > "$ARKDataDataDir\dedServers\$arktime-officialservers.ini"
#}


#get latest scrape, parse, data for players with names
$players = $arkdata.players | where {$_.name -ne ""} 
#if ($players -ne $null){
#Out-ARKDataPlayerFiles $players.tostring()
#Out-ARKDataTribeDB $players.tostring()
#}

#Became Out-ARKDataPlayerFiles
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

}  
 
#Became Out-ARKDataTribeDB
#get latest scrape, parse, data for players with names
#$players = $arkdata.players | where {$_.name -ne ""} 
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

#Returns the ARK server name to arkdatatask.ps1
$arkhost

# 385's call
# $arkdatapayload = (& C:\Dropbox\Programs\util\curl-7.47.1\curl.exe "http://arkservers.net/api/query/72.251.237.155:27015" -H "Pragma: no-cache" -H "DNT: 1" -H "Accept-Encoding: sdch" -H "Accept-Language: en-US,en;q=0.8" -H "User-Agent: Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.116 Safari/537.36" -H "Accept: */*" -H "Cache-Control: no-cache" -H "X-Requested-With: XMLHttpRequest" -H "Cookie: __cfduid=dc9ba606ab8f081d8433e72fb804f660a1436702201" -H "Referer: http://arkservers.net/server/72.251.237.155:27015" -H "Connection: keep-alive" )