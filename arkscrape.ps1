#Set date time
$arktime = get-date -format yyyy-MM-dd-HH-mm-ss
$arkpath = "C:\Dropbox\Docs\ARK\"

#Pull in the Arkdata payload
$arkpayload = (& C:\Dropbox\Programs\util\curl-7.47.1\curl.exe "http://arkservers.net/api/query/72.251.237.140:27019" -H "Cookie: __cfduidd1aedc5f2f5b5e85d206deff1506866c71456079535" -H "DNT: 1" -H "Accept-Encoding: sdch" -H "Accept-Language: en-US,en;q=0.8" -H "User-Agent: Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.109 Safari/537.36" -H "Accept: */*" -H "Referer: http://arkservers.net/server/72.251.237.140:27019" -H "X-Requested-With: XMLHttpRequest" -H "Connection: keep-alive")


#Pull in Arkdata as main data unit, from file
#$arkdata = (convertfrom-json (gc (Dir | Sort CreationTime -Descending | Select Name -First 1)


#Convert Arkpayload to usable format
$arkdata = (ConvertFrom-Json $arkpayload)

#Parse directory name, create if not there
$arkhost = ($arkdata.info.hostname -replace "\s", "")
if(!(test-path "$arkpath\$arkhost")){md "$arkpath\$arkhost"; md "$arkpath\$arkhost\player\"}
#Need to make this look for the servername and make a directory when found
#Merge Player back in to \ARK\Players\ cuz these are Steam names we're tracking.
#How to match up server-player & tribe?

$tribe = import-csv "$arkpath\$arkhost\player\.tribe.csv"

#Write the file (This was just Arkdata written to file, but can't parse... For now, storing raw Json)
$arkpayload > "$arkpath\$arkhost\$arktime.txt"
#get latest scrape, parse, data for players with names
$players = $arkdata.players | where {$_.name -ne ""} 

#Populates the player files
foreach ($player in ($arkdata.players | where {$_.name -ne ""})) { 
$playername = $player.name; "Current time: " + $arktime >> "$arkpath\$arkhost\player\$playername.txt"; $player | FL -property Name,Frags,Time,TimeF >> "$arkpath\$arkhost\player\$playername.txt"}
 
#.name)).players | where {$_.name -ne ""} | select Name,TimeF

#foreach ($player in $players) {
#$playerdata = $tribe | where {$_."Steam name" -ne $player } | select "Steam name", "Tribe name";
#if ( $playerdata."Steam name".length -le 0 ) { #write-host $addplayer }} 



#Who's online but not in .tribe.csv?
foreach ($player in $players) {
$playerdata = $tribe | where {$_."Steam name" -eq $player.name } | select "Steam name" ;
if ( $playerdata."Steam name".length -le 0 ) { #write-host $player.name } } 
#Add member
$addplayer = $player.name + ",???,#N/A"
$addplayer = $addplayer | Add-Member @{"Steam name"=$player.name} -passthru
$addplayer = $addplayer | Add-Member @{"ARK name"="???"} -passthru
$addplayer = $addplayer | Add-Member @{"Tribe name"="#N\A"} -passthru
#write-host $addplayer }}
#write-host $player }}
#Update the CSV with the missing players
Export-Csv -path "$arkpath\$arkhost\player\.tribet.csv" -append -InputObject $addplayer

} 
}


# 385's call
# $arkpayload = (& C:\Dropbox\Programs\util\curl-7.47.1\curl.exe "http://arkservers.net/api/query/72.251.237.155:27015" -H "Pragma: no-cache" -H "DNT: 1" -H "Accept-Encoding: sdch" -H "Accept-Language: en-US,en;q=0.8" -H "User-Agent: Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.116 Safari/537.36" -H "Accept: */*" -H "Cache-Control: no-cache" -H "X-Requested-With: XMLHttpRequest" -H "Cookie: __cfduid=dc9ba606ab8f081d8433e72fb804f660a1436702201" -H "Connection: keep-alive" -H "Referer: http://arkservers.net/server/72.251.237.155:27015" )
