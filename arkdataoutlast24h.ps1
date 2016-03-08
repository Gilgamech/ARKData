#Concatenates .tribe.csv and latest ARKdata file to show tribes and playtimes of active players.

$serverFolder = "C:\Dropbox\Docs\ARK\PvP-Hardcore-OfficialServer92"
$tribe = import-csv "$serverfolder\player\.tribe.csv"
$file = ".1440.txt"
#get latest scrape, parse, data for players with names
$players = import-csv ($serverfolder + "\player\$file")

$currentplayers = (convertfrom-json (gc ($serverfolder + "\" + (Dir $serverFolder | Sort CreationTime -Descending | Select Name -First 1).name))).players.name | where {$_ -ne ""}
#$playerinfo = $players2

#foreach ($player in $players2) { 
$players | foreach-object { $player = $_ ; 
#write-host $player ;

foreach ($current in $currentplayers) { if ($current -eq $player.name ) {return} }

[array]$playerdata = $tribe | where {$_."Steam name" -eq $player.name } | select "Steam name",  "ARK name", "Tribe name"; 
#write-host $playerdata ;
if ($playerdata -ne $null) {

#$playerdata =  $playerdata | Add-Member @{TimeF=($players | where {$_.name -eq $player} | select TimeF).TimeF} -PassThru

#$playerinfo =  convertto-json ($playerdata )
#$playerinfo =  $playerinfo  | Add-Member @{$player.TimeF=($players | where {$_.name -eq $player} | select TimeF).TimeF} -PassThru

return $playerdata #| FT ;

} else { 
#Have to add in some kind of values here.
 
$playerdata =  $playerdata | Add-Member @{"Steam name"=$player} -PassThru
$playerdata =  $playerdata | Add-Member @{"ARK name"="???"} -PassThru
$playerdata =  $playerdata | Add-Member @{"Tribe name"="#N\A"} -PassThru
#$playerdata =  $playerdata | Add-Member @{TimeF=($players | where {$_.name -eq $player} | select TimeF).TimeF} -PassThru

#send back player data
return $playerdata #| FT ;

#return $playerinfo  | FT ;
#write-host $playerdata | FT ;
#write-host (convertto-json $playerdata) ;
#write-host $playerdata."Steam name" | FT ;
#write-host $playerinfo | FT ;
}
};


