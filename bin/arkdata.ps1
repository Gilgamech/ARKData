#ARKData version 2.0
#
#Init settings
$ARKDataBinDir = (Get-Location).path #Where ARKData.ps1 is ran from. Currently also hardcoded on line 294.
$ARKDataDataDir = "C:\www\ARKData\data" #Where ARKData stores its data files.
$ARKDataWebDir = "C:\www\ARKData" #Where ARKData writes its website files.
$ARKDataImagesDir = "C:\www\Images" #Where ARKData writes its website files.
#
#
# cd C:\www\ARKData\bin
# ipmo .\arkdata.ps1
# Start-ARKDataTask
# 

#region always runs
#Test if paths are valid:
if (!(Test-Path $ARKDataDataDir)) { 
	write-host $ARKDataDataDir "is not a valid directory, please check `$ARKDataDataDir in your init settings at the top of ARKData.ps1.`nDid not load ARKData module." -f "Red"
	break
} elseif (!(Test-Path $ARKDataWebDir)) { 
	write-host $ARKDataWebDir "is not a valid directory, please check `$ARKDataWebDir in your init settings at the top of ARKData.ps1.`nDid not load ARKData module." -f "Red"
	break
} elseif (!(Test-Path ($ARKDataImagesDir + "\ARK"))) { 
	write-host $ARKDataWebDir "\ARK is not a valid directory, please check `$ARKDataWebDir in your init settings at the top of ARKData.ps1.`nDid not load ARKData module." -f "Red"
	break
}else {
	(cat "$ARKDataBinDir\ARKData.ps1" | Select-String "Function") | select -skip 1
	write-host "Directories validated." -f "Yellow"
	write-host "Type " -f "Yellow" -nonewline; write-host "Start-ARKDataTask" -f  "Green" -nonewline; write-host " to start ARKData." -f "Yellow"
}
#endregion

#region Functions 
Function Start-ARKDataTask {
	#Noob Friendly!Wiped 1/6 PVPVE 10xT 3xG 5xExp-72ndLegion - (v253
	start-job { ipmo "C:\www\ARKData\bin\ARKData.ps1" ; Run-ARKDataTask -serverip "104.156.227.231" -serverport 27040 }

	#GILARK
	#start-job { ipmo "C:\Public\Scripts\Powershell\ARKData\ARKData.ps1" ; Run-ARKDataTask -serverip "24.16.204.32" -serverport 27015 }
	
	Get-ARKDataTask
}; #end Start-ARKDataTask


Function Get-ARKDataTask {
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
		}; #end if 
		sleep 10
		}; #end foreach
	}; #end while
}; #end Get-ARKDataTask

Function Run-ARKDataTask {
	Param(
		[Parameter(Mandatory=$True)][ipaddress]$Serverip,
		[Parameter(Mandatory=$True)][int]$Serverport
	); #end Param #end params

	$ARKDataBinDir
	while ($true) {
		$ARKDataBinDir = "C:\www\ARKData\bin"

		#run these tasks
		#ARKData scraper, downloads and parses data packet, outputs to files.
		$ARKData = Get-ARKDataPayload $Serverip $Serverport 
		[string]$ServerName = Get-ARKDataServerName $ARKData 
		[string]$MapName = $ARKData.info.map
		[string]$ServerFolder = "$ARKDataDataDir\$ServerName"
		
		Test-ARKDataHostDirs $ServerName
		Out-ARKDataPlayerFiles $ARKData
		Out-ARKDataTribeDB $ARKData

		#Create the .1440.txt file.
		Out-ARKDataPlayersFile $ServerName
		#Start-Process -filepath powershell.exe -argumentlist 'Out-ARKDataPlayersFile $ServerName'

		#ARKData webpage generator. Calls ARKData output data combiner.
		Out-ARKDataWebpage $ServerName $MapName

		#ARKData player reports, these take a long time.
		Get-ARKDataPlayersLastDay $ServerName

		#Push the ArkMap CSV to JSON.
		Convert-ARKDataFilesToJSON
		
		#Main page
		#Do this stuff once an hour: 
		if ((get-date).minute -eq 0 ) {
			Out-ARKDataIndex
			Get-ARKDataDedicatedServers
			Invoke-RandomARKDataMapBG $MapName
		}; #end if 
		#pause 60
		$sleeptime = 60-(get-date).second
		Sleep ($sleeptime)
	}; #end while

}; #end Run-ARKDataTask

Function Convert-ARKDataFilesToJSON {
	gc "$ARKDataWebDir\ARKMap.csv" | ConvertFrom-Csv | ConvertTo-Json > "$ARKDataWebDir\ARKMap.json"
	gc "$ARKDataWebDir\tribe.csv" | ConvertFrom-Csv | ConvertTo-Json -compress > "$ARKDataWebDir\tribe.json"
	Copy-Item ($Serverfolder + "\" + (Dir $ServerFolder | Sort CreationTime -Descending | Select Name -First 1).name)  "$ARKDataWebDir\ARKDataPayload.json"
	
}; #end Run-ARKDataTask
Function Invoke-ArchiveARKDataHTMLFiles {
	$FilesToArchive = (ls "$ARKDataWebDir\*.html" -File  | where { $_ -notmatch "index" } | where {$_.LastWriteTime -lt (Get-Date).AddDays(-1) } ).name
	if ($FilesToArchive) {
		Move-Item $FilesToArchive "$ARKDataWebDir\Archive\"
	}; #end if FilesToArchive
}; #end Invoke-ArchiveARKDataHTMLFiles 

Function Get-ARKDataPayload {
	Param(
		[Parameter(Mandatory=$True,Position=1)]
		[ipaddress]$Serverip,
		[Parameter(Mandatory=$True,Position=2)]
		[int]$Serverport
	); #end Param
	#Set date time and server vars
	$Serveripport = $Serverip.IPAddressToString + ":" + $Serverport
	$Serveraddy =  ("http://ARKservers.net/api/query/" + $Serveripport  )
	#Pull in the ARKData payload
	while ($ARKDatapayload -eq $null) {
		$ARKDatapayload = (& C:\Programs\curl-7.47.1\curl.exe $Serveraddy -H "Cookie:__cfduid=d011ccc7d114ba24205cb7eda808578de1484437836" -H "DNT: 1" -H "Accept-Encoding: sdch" -H "Accept-Language: en-US,en;q=0.8" -H "User-Agent: Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36" -H "Accept: */*" -H "Referer: $Serveraddy"  -H "X-Requested-With: XMLHttpRequest" -H "Connection: keep-alive")
		if ($ARKDatapayload -eq $null) {
			sleep 5
		}; #end if ARKDataPayload
	}; #end while ARKDataPayload

	#Convert ARKDatapayload to usable format
	$ARKData = (ConvertFrom-Json $ARKDatapayload)
	$ServerName = Get-ARKDataServerName $ARKData
	#$ServerName = Get-ARKDataServerName $ARKData 
	Test-ARKDataHostDirs $ServerName
	$ARKtime = get-date -format yyyy-MM-dd-HH-mm-ss
	$ARKDatapayload > "$ARKDataDataDir\$ServerName\$ARKtime.txt"
	$ARKData
}; #end Get-ARKDataPayload

#Parses the OfficialServer.ini files into objects - each OfficialServer has 4 OfficialServers running on it - ports 27015-27019
Function Import-ARKDataINI {
	Param (
		[Parameter(Mandatory=$True)][string]$Filename
	); #end Param #end param
	$Filecontents = gc $Filename 

	#init objection object array
	[array]$objection = @{}; #end

	$Fileline = $Filecontents.Split([System.Environment]::NewLine) | where { $_.length -gt 4} | select -Unique
	#parse each line and populate internal ServerName and IP
	foreach ($Line in  $Fileline) {
		$Linesplit = ($Line.split(" /") | where { $_.length -gt 4} | select -Unique)
		
		[string]$ServerName = ($Linesplit[1])
		[ipaddress]$Serverip = ($Linesplit[0])
		
		#Add a line to the array, create columns for Name, Value, Type
		$objection += "" | select ServerName, ServerIP 
		#Math out the index of the new line
		$arrayspot = ( $objection.length -1 )
		#Populate Name
		$objection[ $arrayspot ].ServerName = $ServerName 
		$objection[ $arrayspot ].ServerIP = $Serverip 
		
	}; #end foreach
	$objection
}; #end Import-ARKDataINI 


#I got this online somewhere. I don't even use it. This is to add some attribute to my dynamic tables.
#Got from https://www.reddit.com/r/PowerShell/comments/2nni5r/the_power_of_converttohtml_and_css_part_2/
Function Add-HTMLTableAttribute {
	Param (
		[Parameter(Mandatory=$true,ValueFromPipeline=$true)][string]$HTML,
		[Parameter(Mandatory=$true)][string]$AttributeName,
		[Parameter(Mandatory=$true)][string]$Value
	); #end Param

	$xml=[xml]$HTML
	$attr=$xml.CreateAttribute($AttributeName)
	$attr.Value=$Value
	$xml.table.Attributes.Append($attr) | Out-Null
	Return ($xml.OuterXML | out-string)
}; #end Add-HTMLTableAttribute


Function Get-ARKDataPlayers {
#Concatenates .tribe.csv and latest ARKData file to show tribes and playtimes of active players. 
	Param(
		[Parameter(Mandatory=$True)][string]$ServerName
	); #end Param
		
	$ServerFolder = "$ARKDataDataDir\$ServerName"
	$Tribe = import-csv "$ARKDataWebDir\tribe.csv"
	#get latest scrape, parse, data for players with names
	$players = (convertfrom-json (gc ($Serverfolder + "\" + (Dir $ServerFolder | Sort CreationTime -Descending | Select Name -First 1).name))).players
	$players2 = ($players | where {$_.name -ne ""}).name
	$playerinfo = $players2
	foreach ($player in $players2) { 	
		[array]$playerdata = $Tribe | where {$_."SteamName" -eq $player } | select "SteamName",  "ARKName", "TribeName"; 
		#write-host $playerdata ;
		if ($playerdata -ne $null) {
			
			$playerdata =  $playerdata | Add-Member @{TimeF=($players | where {$_.name -eq $player} | select TimeF).TimeF} -PassThru
			
			#send back player data
			$playerdata			
		} else {
			#Have to add in some kind of values here
			$playerdata =  $playerdata | Add-Member @{"SteamName"=$player} -PassThru
			$playerdata =  $playerdata | Add-Member @{"ARKName"="$($player.name)???"} -PassThru
			$playerdata =  $playerdata | Add-Member @{"TribeName"="N/A"} -PassThru
			$playerdata =  $playerdata | Add-Member @{TimeF=($players | where {$_.name -eq $player} | select TimeF).TimeF} -PassThru
			
			#send back player data
			$playerdata
			
		}; #end if playerdata
	}; #end foreach

}; #end Get-ARKDataPlayers

Function Get-ARKDataPlayersLastDay {
	Param(
		[Parameter(Mandatory=$True)][string]$ServerName
	); #end Param
	#Concatenates .tribe.csv and latest ARKData file to show tribes and playtimes of active players.
	$ServerFolder = "$ARKDataDataDir\$ServerName"
	$Tribe = import-csv "$ARKDataWebDir\tribe.csv"
	$File = ".1440.txt"
	#get latest scrape, parse, data for players with names
	$players = import-csv ($Serverfolder + "\player\$File") 

	$currentplayers = (convertfrom-json (gc ($Serverfolder + "\" + (Dir $ServerFolder | Sort CreationTime -Descending | Select Name -First 1).name))).players.name | where {
		$_ -ne ""
	}; #end where _

	foreach ($player in $players) { 	
		foreach ($current in $currentplayers) { 
			#If they're in both lists, don't write.
			if ($current -eq $player.name ) {
				Continue 
			}; #end if current 
		}; #end foreach current

		[array]$playerdata = $Tribe | where {$_."SteamName" -eq $player.name } | select "SteamName",  "ARKName", "TribeName"; 

		#write-host $playerdata ;
		if ($playerdata -ne $null) {
			$playername = $player.name | Convert-SymbolsToUnderscore
			$playertime = get-date -format yyyy-MM-dd-HH-mm-ss
			if (Test-Path "$ServerFolder\player\$playername.csv") {
				$playertime = Import-Csv "$ServerFolder\player\$playername.csv" | select Name, Time, TimeF, CurrentTime
				if ($playertime.CurrentTime.count -gt 1) {
					$playerlasttime  = $playertime.CurrentTime[-1] 
					$playerlastsession = $playertime.TimeF[-1]
				}else{
					$playerlasttime  = $playertime.CurrentTime 
					$playerlastsession = $playertime.TimeF
				}; #end if playertime 
			} else{
				$playerlasttime = get-date -format yyyy-MM-dd-HH-mm-ss
				$playerlastsession = "00:00"
			}; #end if Test-Path 

			$playerlasttime = get-date -year $playerlasttime.split("-")[0] -month $playerlasttime.split("-")[1] -day $playerlasttime.split("-")[2] -hour $playerlasttime.split("-")[3] -minute $playerlasttime.split("-")[4] -second $playerlasttime.split("-")[5]
			$playerdata =  $playerdata | Add-Member @{"Last Session Ended"=$playerlasttime} -PassThru
			$playerdata =  $playerdata | Add-Member @{"Session Duration"=$playerlastsession} -PassThru
			$playerdata
		} else { 
			#Have to add in some kind of values here.
			$playername = $player.name | Convert-SymbolsToUnderscore
			$playerlasttime  = Import-Csv "$ServerFolder\player\$playername.csv"
			$playerdata =  $playerdata | Add-Member @{"SteamName"=$playername} -PassThru
			$playerdata =  $playerdata | Add-Member @{"ARKName"="$($playername)???"} -PassThru
			$playerdata =  $playerdata | Add-Member @{"TribeName"="N/A"} -PassThru
			$playerdata =  $playerdata | Add-Member @{"Last Session Ended"=$playerlasttime} -PassThru

			#send back player data
			$playerdata
		}; #end if playerdata
	}; #end $players foreach-object 

}; #end Get-ARKDataPlayersLastDay


#(gc "$ServerFolder\player\.24h.txt").length
#This gets the player count
Function Out-ARKDataPlayersFile {
	Param(
		[Parameter(Mandatory=$True)][string]$ServerName
	); #end Param
	$ServerFolder = "$ARKDataDataDir\$ServerName"
	#How many files do we retrieve?
	$Filecount = (60 * 24)
	#Parse all into $Files
	$Files = (Dir -file $ServerFolder | Sort CreationTime -Descending | Select Name -First $Filecount).name | ForEach-Object { (ConvertFrom-Json ( gc ($Serverfolder + "\" + $_))) }
	#Dumps a list of players and server daytimes
	#Pull out player names into playerlist
	$playerlist = ($Files | ForEach-Object {return (($_.players.name) + "`n" )} )
	#Get the unique ones that are more than 1 letter long (1 letter players are in there, like `n)
	$somanyplayers = $playerlist | where {$_.length -gt 3} | select -Unique
	#Script takes about 12 seconds to run so had it dump to file instead.
	$header = "Name"
	$header > "$ServerFolder\player\.$Filecount.txt"
	$somanyplayers >> "$ServerFolder\player\.$Filecount.txt"
}; #end Out-ARKDataPlayersFile



#Doesn't work. 
Function Output-ARKDataPlayerTime {
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$True)][string]$ServerName,
		[Parameter(Mandatory=$True)][string]$ARKplayer
	); #end Param
	#Inits
	$sessioncount = 0 ; 
	$prevTime = 9999; 
	$totalTime = 0 ; 
	$firstday = "00-00-00-00-00-00";
	$lastday = "00-00-00-00-00-00";
	#Folders
	$ServerName = $ServerName | Convert-SymbolsToUnderscoreServerName
	$ServerFolder = "$ARKDataDataDir\$ServerName"
	$players = import-csv "$ServerFolder\player\$ARKplayer.csv"
	#Get the first time in the thing
	if  ( $players.length -gt 1)  {
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
		}; #end if prevTime
		[int]$prevTime = [int]$pltime	
	}; #end foreach pltime

	#Get-ARKDataFileDate
	$firstdayc = get-date -year $firstday.split("-")[0] -month $firstday.split("-")[1] -day $firstday.split("-")[2] -hour $firstday.split("-")[3] -minute $firstday.split("-")[4] -second $firstday.split("-")[5]
	$lastdayc = get-date -year $lastday.split("-")[0] -month $lastday.split("-")[1] -day $lastday.split("-")[2] -hour $lastday.split("-")[3] -minute $lastday.split("-")[4] -second $lastday.split("-")[5]

	$totalsec = [timespan]::FromSeconds($totalTime)
	$fromsectohours = ($totalsec).totalhours
	$lasttofirstdays = ($lastdayc - $firstdayc)
	[int]$lasttofirstdaysstr = $lasttofirstdays.TotalDays.ToString()
	[int]$timediffpercent = $totalsec.TotalDays / $lasttofirstdays.TotalDays * 100
	$fromsectohoursstr = [int]$fromsectohours

	$ARKplayer + " played for " + $fromsectohoursstr + " hours in " + $sessioncount + " sessions, across " + $lasttofirstdaysstr + " days - that's " + $timediffpercent + " % of the time." >> "$ServerFolder/player/.ARKplayer.txt"

}; #end Output-ARKDataPlayerTime 

Function Out-ARKDataPlayerFiles {
	Param(
		[Parameter(Mandatory=$True)][object]$ARKData
	); #end Param
	#get latest scrape, parse, data for players with names
	$players = $ARKData.players | where {$_.name -ne ""} 
	$ServerName = Get-ARKDataServerName $ARKData
	#Populates the player files
	foreach ($player in $players) {
		#Cleanse brackets that break things
		$playername = $player.name | Convert-SymbolsToUnderscore

		#Get the current time, add to $player
		$ARKtime = get-date -format yyyy-MM-dd-HH-mm-ss
		$player = $player | Add-Member @{CurrentTime=$ARKtime} -passthru
	
		#write file
		Export-Csv -path "$ARKDataDataDir\$ServerName\player\$playername.csv" -append -InputObject $player -force
	
	}; #end foreach
}; #end Out-ARKDataPlayerFiles
 
Function Invoke-RandomARKDataMapBG {
	Param(
		[Parameter(Mandatory=$True)][string]$MapName
	); #end Param
	$RandomMapName = Get-ChildItem ($ARKDataImagesDir +"\ARK\"+ $MapName) -File | Get-Random | Select-Object -ExpandProperty Name
	Copy-Item ($ARKDataImagesDir +"\ARK\"+ $MapName + "\" + $RandomMapName) ($ARKDataImagesDir +"\ARKMap.jpg") -Force
	
	$RandomAdName = Get-ChildItem ($ARKDataImagesDir +"\ads\") -File | Get-Random | Select-Object -ExpandProperty Name
	Copy-Item ($ARKDataImagesDir +"\ads\" + $RandomAdName) ($ARKDataImagesDir +"\BannerImage.jpg") -Force
	# Need to replace the .jpg with file's actual file type.
	
}; #end Out-ARKDataPlayerFiles
 
Function Out-ARKDataTribeDB {
	Param(
		[Parameter(Mandatory=$True)]
		[object]$ARKData
	); #end Param
	$ARKtime = get-date -format yyyy-MM-dd-HH-mm-ss
	#get latest scrape, parse, data for players with names
	$players = $ARKData.players | where {$_.name -ne ""} 

	#Who's online but not in .tribe.csv?
	foreach ($player in $players) {

		$playername = $player.name | Convert-SymbolsToUnderscore 
		$Tribe = import-csv "$ARKDataWebDir\tribe.csv"

		#JOIN .tribe.csv with the $ARKData packet, adds ARK name and Tribe name to online players.
		$playerdata = $Tribe | where {$_."SteamName" -eq $playername } | select "SteamName" ;

		if ($playerdata."SteamName".length -le 0 ) { #write-host $player.name } } 

			#Add default values
			$addplayer = "$playername, $playername ???,N/A"
			$addplayer = $addplayer | Add-Member @{"SteamName"=$playername} -passthru
			$addplayer = $addplayer | Add-Member @{"ARKName"="$playername ???"} -passthru
			$addplayer = $addplayer | Add-Member @{"TribeName"="N/A"} -passthru
			$addplayer = $addplayer | Add-Member @{"FirstSeen"=$ARKtime} -passthru

			#Update the CSV with the missing players
			Export-Csv -path "$ARKDataWebDir\tribe.csv" -append -InputObject $addplayer -force

		}; #end if playerdata
	}; #end foreach player
}; #end Out-ARKDataTribeDB

Function Test-ARKDataHostDirs {
	Param (
		[Parameter(Mandatory=$True)][string]$ServerName
	); #end Param
	#Make directories if not there
	if(!(Test-Path "$ARKDataDataDir\$ServerName")){
		md "$ARKDataDataDir\$ServerName";  #Main dir
		md "$ARKDataDataDir\$ServerName\2";  #Second data source subdir
		md "$ARKDataDataDir\$ServerName\player\" #Player file subdir
	}; #end Test-Path
}; #end Test-ARKDataHostDirs

Function Get-ARKDataServerName  {
	Param (
		[Parameter(Mandatory=$True)][object]$ARKData,
		[switch]$JSON
	); #end Param

	#Parse directory name, create if not ther
	if ($JSON)  {
		$ARKData = (ConvertFrom-Json $ARKData)
	}; #end if JSON
	
	#$ServerName = ($ARKData.info.hostname.split(" "))[0]
	$ServerName = $ARKData.info.hostname | Convert-SymbolsToUnderscoreServerName
	$ServerName
}; #end Get-ARKDataServerName

	#Get-ARKDataFileDate 2016-03-16-00-07-02
Function Get-ARKDataFileDate {
	Param (
		[Parameter(Mandatory=$True)][string]$FileName
	); #end Param
	
	$FileName = $FileName.split(".")[0]
	Get-Date -year $FileName.split("-")[0] -month $FileName.split("-")[1] -day $FileName.split("-")[2] -hour $FileName.split("-")[3] -minute $FileName.split("-")[4] -second $FileName.split("-")[5]
}; #end Get-ARKDatatFileDate

Filter Convert-SymbolsToUnderscore {
	if ($_) {
		#$_ = $_ -replace(" ","_")
		$_ = $_ -replace("``","_")
		#$_ = $_ -replace("[~]","_")
		#$_ = $_ -replace("[!]","_")
		#$_ = $_ -replace("[@]","_")
		#$_ = $_ -replace("[#]","_")
		#$_ = $_ -replace("[$]","_")
		#$_ = $_ -replace("[%]","_")
		#$_ = $_ -replace("[\^]","_")
		#$_ = $_ -replace("[&]","_")
		#$_ = $_ -replace("[*]","_")
		#$_ = $_ -replace("[(]","_")
		#$_ = $_ -replace("[)]","_")
		$_ = $_ -replace("[[]","_")
		$_ = $_ -replace("[]']","_")
		#$_ = $_ -replace("[-]","_")
		#$_ = $_ -replace("[=]","_")
		#$_ = $_ -replace("[+]","_")
		$_ = $_ -replace("[{]","_")
		$_ = $_ -replace("[}]","_")
		$_ = $_ -replace("\\","_")
		#$_ = $_ -replace("[|]","_")
		#$_ = $_ -replace("[:]","_")
		$_ = $_ -replace("[;]","_")
		#$_ = $_ -replace('["]',"_")
		#$_ = $_ -replace("[']","_")
		$_ = $_ -replace("[<]","_")
		$_ = $_ -replace("[,]","_")
		$_ = $_ -replace("[>]","_")
		$_ = $_ -replace("[.]","_")
		#$_ = $_ -replace("[?]","_")
		$_ = $_ -replace("[/]","_")
		#$_ = $_ -replace("[™]","_")
	}; #end if _
	return $_
}; #end Convert-SymbolsToUnderscore


Filter Convert-SymbolsToUnderscoreServerName {
	if ($_) {
		$_ = $_ -replace(" ","_")
		$_ = $_ -replace("``","_")
		$_ = $_ -replace("[~]","_")
		$_ = $_ -replace("[!]","_")
		$_ = $_ -replace("[@]","_")
		$_ = $_ -replace("[#]","_")
		$_ = $_ -replace("[$]","_")
		$_ = $_ -replace("[%]","_")
		$_ = $_ -replace("[\^]","_")
		$_ = $_ -replace("[&]","_")
		$_ = $_ -replace("[*]","_")
		$_ = $_ -replace("[(]","_")
		$_ = $_ -replace("[)]","_")
		$_ = $_ -replace("[[]","_")
		$_ = $_ -replace("[]']","_")
		$_ = $_ -replace("[-]","_")
		$_ = $_ -replace("[=]","_")
		$_ = $_ -replace("[+]","_")
		$_ = $_ -replace("[{]","_")
		$_ = $_ -replace("[}]","_")
		$_ = $_ -replace("\\","_")
		$_ = $_ -replace("[|]","_")
		$_ = $_ -replace("[:]","_")
		$_ = $_ -replace("[;]","_")
		$_ = $_ -replace('["]',"_")
		$_ = $_ -replace("[']","_")
		$_ = $_ -replace("[<]","_")
		$_ = $_ -replace("[,]","_")
		$_ = $_ -replace("[>]","_")
		$_ = $_ -replace("[.]","_")
		$_ = $_ -replace("[?]","_")
		$_ = $_ -replace("[/]","_")
		#$_ = $_ -replace("™","_")
	}; #end if _
	return $_
}; #end Convert-SymbolsToUnderscore


Function Get-ARKDataDedicatedServers {
	if ((get-date).minute -eq 0 ) {
		while ($ARKDataDedicatedServers -eq $null) {
			$ARKDataDedicatedServers = ( invoke-webrequest "http://ARKdedicated.com/officialservers.ini").content
			$ARKtime = get-date -format yyyy-MM-dd-HH-mm-ss
			$ARKDataDedicatedServers > "$ARKDataDataDir\dedServers\$ARKtime-officialservers.ini"
			if ($ARKDataDedicatedServers -eq $null) {
				sleep 60
			}; #end inner if ARKDataDedicatedServers
		}; #end while ARKDataDedicatedServers
	}; #end if get-date
}; #end Get-ARKDataDedicatedServers

Function Out-ARKDataIndex {
	$Servers = (gci "$ARKDataWebDir\*.html").basename | where { $_ -notmatch "index" }
	$Servertitle = "ARKData server page"
	$indexfile = "$ARKDataWebDir\index.html" 

	$toppart > $indexfile #Header
	$Servertitle >> $indexfile #Title
	$gilgabanner >> $indexfile #Gilgamech Technologies banner
	$subbannersubpage >> $indexfile #Sub-banner.
	$indexsubpage >> $indexfile #Servers being tracked:
	
	foreach ($Server in $Servers) {
		$Serverone >> $indexfile #HTML before ServerName to set up link
		$Server >> $indexfile
		$Servertwo >> $indexfile #HTML to close link and set up text display
		$Server >> $indexfile
		$Serverthree>> $indexfile #HTML after ServerName to close text display
	}; #end foreach
	
	$endpart >> $indexfile #Page still under development
	$tailpart >> $indexfile #Footer and banner ads
}; #end Out-ARKDataIndex

Function Out-ARKDataWebpage {
	Param(
		[Parameter(Mandatory=$True)][string]$ServerName,
		[Parameter(Mandatory=$True)][string]$MapName
	)

	$ServerName = $ServerName | Convert-SymbolsToUnderscoreServerName
	$datestartpart = (get-date) 
	$ServerFolder = "$ARKDataDataDir\$ServerName"
	$ARKDataPlayers = Get-ARKDataPlayers $ServerName
	#Shows timestamp if people are playing, otherwise sleeping.

	if ($ARKDataPlayers-ne $null) { 
		#Parse the FileName back into the .NET datetime object
		$ts = ((Dir -file $ServerFolder).name[-1])
		#Get-ARKDataFileDate
		$latestpayload = get-date -year $ts.split("-")[0] -month $ts.split("-")[1] -day $ts.split("-")[2] -hour $ts.split("-")[3] -minute $ts.split("-")[4] -second $ts.split("-")[5].split(".")[0]
		#Current server time
		$Servertime = (convertfrom-json (gc ($Serverfolder + "\" + (Dir $ServerFolder | Sort CreationTime -Descending | Select Name -First 1).name))).rules.daytime_s
		#Parse hour and minute
		$hour = $Servertime.split(":")[0].tostring()
		$minute = $Servertime.split(":")[1].tostring()
		#Gametime is 28 minutes to an RL minute, so our time is at least 28 minutes late. 
		$compensatetime = (28 + 28 )
		#Take servertime and recombine with compensatetime to try to be accurate.
		$Servertimeoutput = (get-date -hour $hour -minute $minute).AddMinutes($compensatetime)
		#Time to midday calculations
		$midday = get-date -hour 12 -minute 00 -day ($Servertimeoutput.day + 1 )
		$timetomidday = new-timespan -start $Servertimeoutput -end $midday
		$ttmd = ($timetomidday.hours * 60 + $timetomidday.Minutes)/28
		#Time to night calculations
		$night = get-date -hour 21 -minute 50 -day ($Servertimeoutput.day +  1)
		$timetonight = new-timespan -start $Servertimeoutput -end $night
		$ttmn = ($timetonight.hours * 60 + $timetonight.Minutes)/28
		#Time to morning calculations
		$morning = get-date -hour 5 -minute 15 -day ($Servertimeoutput.day + 1)
		$timetomorning = new-timespan -start $Servertimeoutput -end $morning
		$ingametimetomorning = ( $timetomorning.hours.tostring() + ":" + $timetomorning.minutes)
		$ttmm = ($timetomorning.hours * 60 + $timetomorning.Minutes)/28
		#$middlepartttm  minutes until tomorrow morning.
		#$playerspart = Table of Steam name, ARK name, Tribe name, TimeF goes here
		$playerspart = $ARKDataPlayers | sort "TribeName" | select "SteamName", "ARKName", "TribeName", @{N='Time Played'; E={$_.TimeF}} | ConvertTo-Html -fragment 
		#$middlepart2 Tribe data gathered lovingly by humans from ingame chat.
		#Count of tribes by number of players online
		$Tribespart = ($ARKDataPlayers)."TribeName" | Group-Object | sort "count" -descending | select "count", "name" | ConvertTo-Html -fragment | out-string | Add-HTMLTableAttribute  -AttributeName 'class' -Value 'sortable'

	}; #end if ARKDataPlayers
	#24h player count
	$playercount = $ARKDataPlayers.TimeF.Count

	#Had to move these beow the End If to get the player count in the title. 
	$playerslast24h = Get-ARKDataPlayersLastDay $ServerName | where { $_."Last Session Ended" -gt (get-date).addhours(-24)}
	$playerslast24w = $playerslast24h | sort "Last Session Ended" -descending | ConvertTo-Html -Fragment
	$playercount24h = $playerslast24h.Count

	#Load the serverlog if you made one
	$Serverlogpath = "$ARKDataDataDir\assets\$ServerName.txt"
	$Serverlog = "string"
	
	if (Test-Path $Serverlogpath) { 
		$Serverlog = import-csv $Serverlogpath  | select "Server Log (Manually updated)" | ConvertTo-Html -Fragment
	} else {
		$Serverlog = ""
	}; #end if Test-Path
	#Create page title (Player count and ServerName)
	if ($playercount) {
		$title = $playercount.tostring() + " playing on " + $ServerName 
	} else {
		$title = "0 playing on " + $ServerName 
	}; #end if playercount

	#Webpage Stamping
	$webdir = "$ARKDataWebDir\$ServerName.html" 
	$toppart > $webdir #Top down to webpage title
	$title >> $webdir #ServerName as webpage title 
	$gilgabanner >> $webdir #Gilgamech Technologies banner
	<#
	$subbannersubpage >> $webdir
	$Subtitle >> $webdir #Title down to "$ServerName"
	$Serversubpage  >> $webdir #Latest report: 
	$ServerName >> $webdir #ServerName
	$MapNamePart >> $webdir #Map Name:
	$MapName >> $webdir #MapName
	$ServerNamepart >> $webdir #Post ServerName tags
	#>
	if ($ARKDataPlayers -ne $null) { 
		<#
		$dateendpart = (get-date) # ----------------------------------------------> End timestamp
		($dateendpart  | select datetime | ConvertTo-Html -fragment)[3] >> $webdir #Report Datestamp
		$middlepartone >> $webdir #Newest data payload
		($latestpayload  | select datetime | ConvertTo-Html -fragment)[3] >> $webdir #Payload datestamp
		$middlepartreporttime >> $webdir #Current ingame time is approx
		$Servertimeoutput.ToString("HH:mm")  >> $webdir #Server ingame time
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
		$Tribespart >> $webdir #Count of tribes online
		$middlepartplayercount >> $webdir #Player count:
		#>
		$playercount >> $webdir #Count of ARKDataPlayers
		$middlepart5m >> $webdir #""$($player.name) ???" means never seen...
		<#
		#>
		$playerslast24w >> $webdir #Players seen last 24h by session ended date
		$middlepart24h >> $webdir #Players seen:
		$playercount24h >> $webdir #Count of Players seen last 24h
		$playerserver >> $webdir #Players seen closing tag
	} else {
		#Sleeping output is very cacheable.
		"<h2>Nobody's playing right now,<br> so ARKData is sleeping.</h2>" >> $webdir
	}; #end ???

	if ($Serverlog -ne "") {
		$Serverlog >> $webdir #Manual serverlog text file
	}; #end if Serverlog
	$tailpart >> $webdir #Footer - Website errors...down to ad.
	
	
}; #end Out-ARKDataWebpage
# endregion

#region Webparts
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
<link rel="stylesheet" type="text/css" charset="utf-8" href="/gilgamech.css">
<link rel="stylesheet" type="text/css" charset="utf-8" href="/ARKData/ARKData.css">
<link rel="stylesheet" type="text/css" charset="utf-8" href="/ARKData/ARKDatam.css" media="handheld" />
<script  type="text/css" charset="utf-8" src="/ARKData/sorttable.js"></script>
</head>
<body>
<div class = "top">
<a href="/">Gilgamech Technologies</a>
</div>
<nav>
	<a href="/">Home</a> |
	<a href="/ARKData/index.html">ARKData!</a> | 
	<a href="/robot-fruit-hunt/Index.html">Fruitbot!</a> 
</nav>
'@
$subbannersubpage = @'
<h4></h4>
<h4>Servers currently being tracked:</h4>
<div class="content">
<H1>Welcome to ARKData</h1>
<h4>Gil's player and tribe tracker</H4>
'@

$indexsubpage = @'
<h4></h4>
<h4>Servers currently being tracked:</h4>
'@

$Serversubpage = @'
<h4>Page auto-refreshes every minute.</h4>
<h4>Report also generates every minute. Latest report: </h4>
<H2>
'@

$MapNamePart = @'
</H2>
<h5>Map Name:</h5>
<H2>
'@

$ServerNamepart = @'
</H2>
<h5>Latest report date:</h5>
<table>
'@

$middlepartone = @'
</table>

<h5>Newest data payload:</h5>
<table>
'@

$Serverone = @'
<H2><a href="/ARKData/
'@ #"

$Servertwo = @'
.html">
'@ #"

$Serverthree = @'
</a></H2>
'@

$endpart = @'
<h5></h5>
<table>
'@
#<h2>Page still under development.</h2>

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
</div>
<div class="Map">
<h4>Map page</h4>
<script src="ARKMap.js" Content-Type="text/javascript" charset="UTF-8"></script>
</div>
<div class="content">
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
<h4>Website errors? Bad data? Advertising questions? <a href="mailto:ARKDataproject@gilgamech.com">Email me!</a><br>
Copyright 2016 Gilgamech Technologies.</h4>
<h6></h6>
<br>
<p class="banner">
	<a href="/ARK/Images/A0Oqmx8.png"><img src="/ARK/Images/A0Oqmx8.png" title="C1ick h34r ph0r m04r inph0" /></a>
</p>
</body></html>
'@
#	<a href=https://imgur.com/gallery/A0Oqmx8><img src=https://i.imgur.com/A0Oqmx8.png title="C1ick h34r ph0r m04r inph0" /></a>
#end