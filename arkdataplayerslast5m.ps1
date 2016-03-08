
$ARKFolder = "C:\Dropbox\Docs\ARK"
$serverFolder = "C:\Dropbox\Docs\ARK\PvP-Hardcore-OfficialServer92"

#How many files do we retrieve?
$filecount = (5)
#Parse all into $files
$files = (Dir -file $serverFolder | Sort CreationTime -Descending | Select Name -First $filecount).name | ForEach-Object { (ConvertFrom-Json ( gc ($serverfolder + "\" + $_))) }
#Dumps a list of players and server daytimes
#$files | ForEach-Object {return (($_.players.name) + "`n" + ($_.rules.daytime_s))} | where { $_ -ne "" }
 #Pull out player names into playerlist
$playerlist = ($files | ForEach-Object {return (($_.players.name) + "`n" )} )
#Get the unique ones that are more than 1 letter long (1 letter players are in there, like `n)
$somanyplayers = $playerlist | where {$_.length -gt 1} | select -Unique

#Script takes about 12 seconds to run so had it dump to file instead.

$header = "Name"
$header > "$serverFolder\player\.$filecount.txt"
$somanyplayers >> "$serverFolder\player\.$filecount.txt"

#$player24 = gc "$serverFolder\player\.24h.txt"
#$player24.length
#This gets the player count