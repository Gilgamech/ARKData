#$arktime = get-date -format yyyy-MM-dd-HH-mm-ss

#$arkdata = (ConvertFrom-Json (& C:\Dropbox\Programs\util\curl-7.47.1\curl.exe "http://arkservers.net/api/query/72.251.237.140:27019" -H "Cookie: __cfduidd1aedc5f2f5b5e85d206deff1506866c71456079535" -H "DNT: 1" -H "Accept-Encoding: sdch" -H "Accept-Language: en-US,en;q=0.8" -H "User-Agent: Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.109 Safari/537.36" -H "Accept: */*" -H "Referer: http://arkservers.net/server/72.251.237.140:27019" -H "X-Requested-With: XMLHttpRequest" -H "Connection: keep-alive"))

#$arkhost = ($arkdata.info.hostname -replace "\s", "")
#if(!(test-path $arkhost)){md $arkhost; md $arkhost\player\}
#$arkdata | FL > "C:\Dropbox\Docs\ARK\$arkhost\$arktime.txt"

#foreach ($player in ($arkdata.players | where {$_.name -ne ""})) { $playername = $player.name; "Current time: " + $arktime >> "C:\Dropbox\Docs\ARK\$arkhost\player\$playername.txt"; $player | FL -property Name,Frags,Time,TimeF >> "C:\Dropbox\Docs\ARK\$arkhost\player\$playername.txt"}
 
 
 
#Concatenates .tribe.csv and latest ARKdata file to show tribes and playtimes of active players.

$serverFolder = "C:\Dropbox\Docs\ARK\PvP-Hardcore-OfficialServer92-(v236.0)"
$tribe = import-csv "$serverfolder\player\.tribet.csv"
#get latest scrape, parse, data for players with names
$players = (convertfrom-json (gc ($serverfolder + "\" + (Dir $serverFolder | Sort CreationTime -Descending | Select Name -First 1).name))).players
$players2 = ($players | where {$_.name -ne ""}).name
#$players2 = ($players | where {$_.name -eq "RandomMadPanda"}).name
$playerinfo = $players2

#foreach ($player in $players2) { 
$players2 | foreach-object {
$player = $_
#write-host $player ;

[array]$playerdata = $tribe | where {$_."Steam name" -eq $player } | select "Steam name",  "ARK name", "Tribe name"; 
#write-host $playerdata ;
if ($playerdata -ne $null) {

$playerdata =  $playerdata | Add-Member @{TimeF=($players | where {$_.name -eq $player} | select TimeF).TimeF} -PassThru

#$playerinfo =  convertto-json ($playerdata )
#$playerinfo =  $playerinfo  | Add-Member @{$player.TimeF=($players | where {$_.name -eq $player} | select TimeF).TimeF} -PassThru

return $playerdata #| FT ;

} else { 
#Have to make the missing objects here. Then we can return instead of write-host.
#write-host "$Player not in database TimeF =" ($players | where {$_.name -eq $player} | select TimeF).TimeF }

$playerdata =  $playerdata | Add-Member @{"Steam name"=$player} -PassThru
$playerdata =  $playerdata | Add-Member @{"ARK name"="???"} -PassThru
$playerdata =  $playerdata | Add-Member @{"Tribe name"="#N\A"} -PassThru
$playerdata =  $playerdata | Add-Member @{TimeF=($players | where {$_.name -eq $player} | select TimeF).TimeF} -PassThru

#send back player data
return $playerdata #| FT ;

#return $playerinfo  | FT ;
#write-host $playerdata | FT ;
#write-host (convertto-json $playerdata) ;
#write-host $playerdata."Steam name" | FT ;
#write-host $playerinfo | FT ;
}
};


