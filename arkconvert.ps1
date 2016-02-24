#$arktime = get-date -format yyyy-MM-dd-HH-mm-ss

#$arkdata = (ConvertFrom-Json (& C:\Dropbox\Programs\util\curl-7.47.1\curl.exe "http://arkservers.net/api/query/72.251.237.140:27019" -H "Cookie: __cfduidd1aedc5f2f5b5e85d206deff1506866c71456079535" -H "DNT: 1" -H "Accept-Encoding: sdch" -H "Accept-Language: en-US,en;q=0.8" -H "User-Agent: Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.109 Safari/537.36" -H "Accept: */*" -H "Referer: http://arkservers.net/server/72.251.237.140:27019" -H "X-Requested-With: XMLHttpRequest" -H "Connection: keep-alive"))

#$arkhost = ($arkdata.info.hostname -replace "\s", "")
#if(!(test-path $arkhost)){md $arkhost; md $arkhost\player\}
#$arkdata | FL > "C:\Dropbox\Docs\ARK\$arkhost\$arktime.txt"

#foreach ($player in ($arkdata.players | where {$_.name -ne ""})) { $playername = $player.name; "Current time: " + $arktime >> "C:\Dropbox\Docs\ARK\$arkhost\player\$playername.txt"; $player | FL -property Name,Frags,Time,TimeF >> "C:\Dropbox\Docs\ARK\$arkhost\player\$playername.txt"}
 
