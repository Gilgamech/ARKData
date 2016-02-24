#Set date time
$arktime = get-date -format yyyy-MM-dd-HH-mm-ss

#Pull in Arkdata as main data unit
$arkdata = (ConvertFrom-Json (& C:\Dropbox\Programs\util\curl-7.47.1\curl.exe "http://arkservers.net/api/query/72.251.237.140:27019" -H "Cookie: __cfduidd1aedc5f2f5b5e85d206deff1506866c71456079535" -H "DNT: 1" -H "Accept-Encoding: sdch" -H "Accept-Language: en-US,en;q=0.8" -H "User-Agent: Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.109 Safari/537.36" -H "Accept: */*" -H "Referer: http://arkservers.net/server/72.251.237.140:27019" -H "X-Requested-With: XMLHttpRequest" -H "Connection: keep-alive"))

#Parse directory name, create if not there
$arkhost = ($arkdata.info.hostname -replace "\s", "")
if(!(test-path "C:\Dropbox\Docs\ARK\$arkhost")){md "C:\Dropbox\Docs\ARK\$arkhost"; md "C:\Dropbox\Docs\ARK\$arkhost\player\"}
#Merge Player back in to \ARK\Players\ cuz these are Steam names we're tracking.
#How to match up server-player & tribe?

#Write the file (This was just Arkdata written to file, but can't parse... For now, storing raw Json)
(& C:\Dropbox\Programs\util\curl-7.47.1\curl.exe "http://arkservers.net/api/query/72.251.237.140:27019" -H "Cookie: __cfduidd1aedc5f2f5b5e85d206deff1506866c71456079535" -H "DNT: 1" -H "Accept-Encoding: sdch" -H "Accept-Language: en-US,en;q=0.8" -H "User-Agent: Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.109 Safari/537.36" -H "Accept: */*" -H "Referer: http://arkservers.net/server/72.251.237.140:27019" -H "X-Requested-With: XMLHttpRequest" -H "Connection: keep-alive") > "C:\Dropbox\Docs\ARK\$arkhost\$arktime.txt"

#old command
#$arkdata > "C:\Dropbox\Docs\ARK\$arkhost\$arktime.txt"

#Populates the player files
foreach ($player in ($arkdata.players | where {$_.name -ne ""})) { $playername = $player.name; "Current time: " + $arktime >> "C:\Dropbox\Docs\ARK\$arkhost\player\$playername.txt"; $player | FL -property Name,Frags,Time,TimeF >> "C:\Dropbox\Docs\ARK\$arkhost\player\$playername.txt"}
 
