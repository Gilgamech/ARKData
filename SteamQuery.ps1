# .\SteamQuery.ps1 Build: 1 2016-04-17T15:15:48      










$SteamQuery = "$((Get-Location).path)\SteamQuery.ps1"#Where this module is ran from.
(cat $SteamQuery | Select-String "function") | select -skip 1

function Get-TestingCommands {
write-host "
Get-SteamServers 104.156.227.231 -Player
Get-SteamServers 104.156.227.231 27040
Get-SteamServers 10.0.0.5 -Rules
Get-SteamServerInfo 10.0.0.5 
"
}

function Get-ArkdataSteamDedicatedServers {
#Param (
#[Parameter(Mandatory=$True,Position=1)]
#[string]$Filename
#) #end param
#$filecontents = gc $Filename 
#$arkdedicatedservers = ( invoke-webrequest "http://arkdedicated.com/officialservers.ini").content
$filecontents = ( invoke-webrequest "http://arkdedicated.com/officialservers.ini").content

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

function Get-SteamServerInfo {
Param(
   [Parameter(Mandatory=$True,Position=1)]
   [ipaddress]$serveraddr,
   [Parameter(Position=2)]
   [int]$serverport
)
#Prepare our request message
$bytes =  "ÿÿÿÿTSource Engine Query" | Flip-TextToBytes -a 
$bytes += "00"
#Set our UDP timeout in ms.

$UDPtimeout = 1000

#If you don't specify a port, it uses default 27015
if (!($serverport)) {$serverport = 27015}

#Build endpoint
    $endpoint = New-Object System.Net.IPEndPoint ($serveraddr,$serverport)
#I found this online, I don't really know what it does lol
    $udpclient= New-Object System.Net.Sockets.UdpClient
#Timeout in ms
#	$udpclient.client.receiveTimeout = 3000
	$udpclient.client.receiveTimeout = $UDPtimeout
#Not sure what we're doing with BytesSent here - it's just 9.
    $bytesSent=$udpclient.Send($bytes,$bytes.length,$endpoint)

#Listen for the challenge response
$content=try {	
$udpclient.Receive([ref]$endpoint)  
} catch {
Write-Host -fore red "Connection timed out. Double-check the server's listening port."
} #finally {}

#If the challenge isn't empty, print as Bytes then print as ASCII
if ($content) {
#	$content
	$contxt = Flip-BytesToText $content 
	-join $contxt
	
	$conlen = $content.length
#Data container
#$oput = "" | Select "Header","Protocol","Servername","Map","Folder","Game","ID","Players","MaxPlayers","Bots","ServerType","Environment","Visibility","VAC"	
$oput = "" | Select "Raw","Header","Protocol","Servername","ARKVersion","Map","Folder","Game","ID","Players","MaxPlayers","Bots","ServerType","Environment","Visibility","VAC","Version","EDF"	

	#Manually populating cuz bleh.
	#Data	Type	Comment
	$oput.raw = $content
	#Header	byte	Always equal to 'I' (0x49)
	$oput.header = $content[4]
	#Protocol	byte	Protocol version used by the server.
	$oput.protocol = $content[5]
	#Name	string	Name of the server.
	$oput.servername = $content.length
	#$oput.servername = $contxt.Split(" ,:") [0].substring(6,($g.Split(" ,:")[0].length - 6))
	$snlen = $oput.servername.Length
	#Version of ARK
	#$oput.ARKVersion = $conjoinSplit[2].substring(1,6)
	$oput.ARKVersion = $content.length
	#Map	string	Map the server has currently loaded.
	#$oput.map = $contxt.Split(" ,:")[2].substring(9,($g.Split(" ,:")[0].length - 26))
	#$oput.map = $conjoinSplit[2].substring(9,9)
	$oput.map = $content.length
	#Folder	string	Name of the folder containing the game files.
	$oput.folder = $content.length
	#$oput.folder = $conjoinSplit[2].substring(19,20)
	#Game	string	Full name of the game.
	$oput.game = $content.length
	#$oput.game = $conjoinSplit[2].substring(40,3) + " " + $conjoinSplit[4] + " " + $conjoinSplit[5].substring(0,7)
	#ID	short	Steam Application ID of game.
	$oput.id = $content[($snlen + 70)..($snlen + 72)] 
	#Players	byte	Number of players on the server.
	$oput.players = $content[($snlen + 73)]
	#Max. Players	byte	Maximum number of players the server reports it can hold.
	$oput.maxplayers = $content[($snlen + 74)]
	#Bots	byte	Number of bots on the server.
	$oput.bots = $content[($snlen + 75)]
	#Server type	byte	Indicates the type of server: 'd' for a dedicated server, 'l' for a non-dedicated server, 'p' for a SourceTV relay (proxy)
	$oput.servertype = $content.length
	#$oput.servertype = Flip-BytesToText $content[($snlen + 76)] -a
	#Environment	byte	Indicates the operating system of the server: 'l' for Linux, 'w' for Windows, 'm' or 'o' for Mac (the code changed after L4D1)
	$oput.environment = $content.length
	#$oput.environment = Flip-BytesToText $content[($snlen + 77)] -a
	#Visibility	byte	Indicates whether the server requires a password: 0 for public, 1 for private
	$oput.visibility = if ($content[($snlen + 78)] ) {"Private"} else {"Public"}
	#VAC	byte	Specifies whether the server uses VAC: 0 for unsecured, 1 for secured
	$oput.vac = if ($content[($snlen + 79)] ) {"Unsecured"} else {"Secured"}
	#Version	string	Version of the game installed on the server. (is always 1.0.0.0)
	$oput.Version = Flip-BytesToText $content[($snlen + 80)..($snlen + 87)] -a
	#Extra options:
	$oput.EDF = $content.length #(Flip-BytesToText $content[-131..-10] -a).split(",")
	#	$content[-10..-1]
	$oput
	
} #if context

#Close the UDP client
$udpclient.Close()
} #end Get-SteamServerInfo

function Get-SteamServerRules2 {
Param(
   [Parameter(Mandatory=$True,Position=1)]
   [ipaddress]$serveraddr,
   [Parameter(Position=2)]
   [int]$serverport
)
#Prepare our request message
$bytes =  'ÿÿÿÿVÿÿÿ' | Flip-TextToBytes -a 
#Set our UDP timeout in ms.
$UDPtimeout = 1000

#If you don't specify a port, it uses default 27015
if (!($serverport)) {$serverport = 27015}

#Build endpoint
    $endpoint = New-Object System.Net.IPEndPoint ($serveraddr,$serverport)
#I found this online, I don't really know what it does lol
    $udpclient= New-Object System.Net.Sockets.UdpClient
#Timeout in ms
#	$udpclient.client.receiveTimeout = 3000
	$udpclient.client.receiveTimeout = $UDPtimeout
#Not sure what we're doing with BytesSent here.
    $bytesSent=$udpclient.Send($bytes,$bytes.length,$endpoint)

#Listen for the challenge response
$content=try {	
$udpclient.Receive([ref]$endpoint)  
} catch {
Write-Host -fore red "Connection timed out. Double-check the server's listening port."
} #finally {}

#If the challenge isn't empty, print as Bytes then print as ASCII
if ($content) {
#	$content
	$contxt = Flip-BytesToText $content -a
	-join $contxt
	
#Data container
$oput = "" | Select "Header","Protocol","Name","Map","Folder","Game","ID","Players","MaxPlayers","Bots","ServerType","Environment","Visibility","VAC"	

	#Data	Type	Comment
	#Header	byte	Always equal to 'I' (0x49)
	$oput.header = $content.length
	#Protocol	byte	Protocol version used by the server.
	$oput.protocol = $content.length
	#Name	string	Name of the server.
	$oput.name = $content.length
	#Map	string	Map the server has currently loaded.
	$oput.map = $content.length
	#Folder	string	Name of the folder containing the game files.
	$oput.folder = $content.length
	#Game	string	Full name of the game.
	$oput.game = $content.length
	#ID	short	Steam Application ID of game.
	$oput.id = $content.length
	#Players	byte	Number of players on the server.
	$oput.players = $content.length
	#Max. Players	byte	Maximum number of players the server reports it can hold.
	$oput.maxplayers = $content.length
	#Bots	byte	Number of bots on the server.
	$oput.bots = $content.length
	#Server type	byte	Indicates the type of server: 'd' for a dedicated server, 'l' for a non-dedicated server, 'p' for a SourceTV relay (proxy)
	$oput.servertype = $content.length
	#Environment	byte	Indicates the operating system of the server: 'l' for Linux, 'w' for Windows, 'm' or 'o' for Mac (the code changed after L4D1)
	$oput.environment = $content.length
	#Visibility	byte	Indicates whether the server requires a password: 0 for public, 1 for private
	$oput.visibility = $content.length
	#VAC	byte	Specifies whether the server uses VAC: 0 for unsecured, 1 for secured
	$oput.vac = $content.length
	
	$oput
	
	
} #if context

#Close the UDP client
$udpclient.Close()
}

function Get-SteamServerPlayers2 {
Param(
   [Parameter(Mandatory=$True,Position=1)]
   [ipaddress]$serveraddr,
   [Parameter(Position=2)]
   [int]$serverport = 27015
)
#Set our UDP timeout in ms.
$UDPtimeout = 1000

#Build message
$bytes =  'ÿÿÿÿUÿÿÿÿ' | Flip-TextToBytes -a 


#Build endpoint
    $endpoint = New-Object System.Net.IPEndPoint ($serveraddr,$serverport)
#I found this online, I don't really know what it does lol
    $udpclient= New-Object System.Net.Sockets.UdpClient
#Timeout in ms
	$udpclient.client.receiveTimeout = $UDPtimeout
#Not sure what we're doing with BytesSent here.
    $bytesSent=$udpclient.Send($bytes,$bytes.length,$endpoint)

#Listen for the challenge response
$content=try {	
$udpclient.Receive([ref]$endpoint)  
} catch {
Write-Host -fore red "Connection timed out. Double-check the server's listening port."
} #finally {}

#If the challenge isn't empty, print as Bytes then print as ASCII
if ($content) {
	$contxt = Flip-BytesToText $content -a
	
#Modify challenge to be response	
	$content[4] = "U" | Flip-TextToBytes -a
	$conrsp = Flip-BytesToText $content -a
	
#Send the challenge response back as a handshake
    $payloadbytes = $udpclient.Send($content,$content.length,$endpoint)

	#Listen for the challenge response
$payload=try {	
$udpclient.Receive([ref]$endpoint)  
} catch {
Write-Host -fore red "Connection timed out. Double-check the server's listening port."
} #finally {}

#If the payload isn't empty, print as Bytes then print as ASCII
if ($payload) {
	$paytxt = Flip-BytesToText $payload -a
	$paytxt
	
	#Data container
$oput = "" | Select "Header","Protocol","Name","Map","Folder","Game","ID","Players","MaxPlayers","Bots","ServerType","Environment","Visibility","VAC"	

	#Data	Type	Comment
	#Header	byte	Always equal to 'I' (0x49)
	$oput.header = $paytxt.length
	#Protocol	byte	Protocol version used by the server.
	$oput.protocol = $paytxt.length
	#Name	string	Name of the server.
	$oput.name = $paytxt.length
	#Map	string	Map the server has currently loaded.
	$oput.map = $paytxt.length
	#Folder	string	Name of the folder containing the game files.
	$oput.folder = $paytxt.length
	#Game	string	Full name of the game.
	$oput.game = $paytxt.length
	#ID	short	Steam Application ID of game.
	$oput.id = $paytxt.length
	#Players	byte	Number of players on the server.
	$oput.players = $paytxt.length
	#Max. Players	byte	Maximum number of players the server reports it can hold.
	$oput.maxplayers = $paytxt.length
	#Bots	byte	Number of bots on the server.
	$oput.bots = $paytxt.length
	#Server type	byte	Indicates the type of server: 'd' for a dedicated server, 'l' for a non-dedicated server, 'p' for a SourceTV relay (proxy)
	$oput.servertype = $paytxt.length
	#Environment	byte	Indicates the operating system of the server: 'l' for Linux, 'w' for Windows, 'm' or 'o' for Mac (the code changed after L4D1)
	$oput.environment = $paytxt.length
	#Visibility	byte	Indicates whether the server requires a password: 0 for public, 1 for private
	$oput.visibility = $paytxt.length
	#VAC	byte	Specifies whether the server uses VAC: 0 for unsecured, 1 for secured
	$oput.vac = $paytxt.length
	
	$oput
	
	
} else {
Write-Host -fore red "No payload received."
} #if payload

} #if context

#Close the UDP client
$udpclient.Close()
} #end Get-SteamServerPlayers2

function Get-SteamServerPlayers {
Param(
   [Parameter(Mandatory=$True,Position=1)]
   [ipaddress]$serveraddr,
   [Parameter(Position=2)]
   [int]$serverport = 27015
)
	#Set our UDP timeout in ms.
	$UDPtimeout = 1000
	#Build message
	$bytes =  'ÿÿÿÿUÿÿÿÿ' | Flip-TextToBytes -a 

	[array]$obj = @{}

	#Build endpoint
    $endpoint = New-Object System.Net.IPEndPoint ($serveraddr,$serverport)
	#I found this online, I don't really know what it does lol
    $udpclient= New-Object System.Net.Sockets.UdpClient
	#Timeout in ms
	$udpclient.client.receiveTimeout = $UDPtimeout
	#Not sure what we're doing with BytesSent here.
    $bytesSent=$udpclient.Send($bytes,$bytes.length,$endpoint)

	#Listen for the challenge response
	$content=try {	
		$udpclient.Receive([ref]$endpoint)  
	} catch {
		Write-Host -fore red "Connection timed out. Double-check the server's listening port."
	} #finally {}

	#If the challenge isn't empty, print as Bytes then print as ASCII
	if ($content) {
		$contxt = Flip-BytesToText $content -a
		
		#Modify challenge to be response	
		$content[4] = "U" | Flip-TextToBytes -a
		$conrsp = Flip-BytesToText $content -a
		
		#Send the challenge response back as a handshake
		$payloadbytes = $udpclient.Send($content,$content.length,$endpoint)
		
		#Listen for the challenge response
	$payload=try {	
	$udpclient.Receive([ref]$endpoint)  
	} catch {
	Write-Host -fore red "Connection timed out. Double-check the server's listening port."
	} #finally {}

	#If the payload isn't empty, print as Bytes then print as ASCII
	if ($payload) {
		
		$payload = for ($i = 0 ; $i -le $payload.Length ; $i++) {
		$n = $payload[$i]
		$n1 = $payload[($i + 1)]
		$n2 = $payload[($i + 2)]
		$n3 = $payload[($i + 3)]
		$n4 = $payload[($i + 4)]
		$n5 = $payload[($i + 5)]
		$n6 = $payload[($i + 6)]
		$p1 = $payload[($i - 1)]


		if (  ( $n -eq 0  ) -and ( $n1 -eq 0 ) -and ( $n2 -eq 0  ) -and ( $n3 -eq 0 )  -and ( $n4 -eq 0  ) -and ( $n5 -eq 0 ) ) {  
			#Next 6 are 0, meaning the Player is null cuz they aren't connected yet.
			0
			1 #20  
			1
			1
			1
			0

		} else {
			$n   

		} #end if n
	} #end payload

	$playercount = ($payload[(5)])

	#<# 
	#Add payload as raw data, mostly for debugging.
	[string]$property = "Raw"
	#[string]$property = (Flip-BytesToText $_,0)
	[object]$value = $payload
	#[object]$value = 0

	#Add a line to the array, create columns for Name, Value, Type
	$obj = "" | select ID, Player, Score, Time, TimeF; 
	#Math out the index of the new line
	$arrayspot = ( $obj.length -1 )
	#Populate Name
	$obj[ $arrayspot ].Player = $property 
	$obj[ $arrayspot ].Time = $value 

	<# 

	[string]$property = ("Players")
	[object]$value = $playercount

	$obj += "" | select ID, Player, Score, Time, TimeF; 
	#Math out the index of the new line
	$arrayspot = ( $obj.length -1 )
	#Populate Name
	$obj[ $arrayspot ].Player = $property 
	$obj[ $arrayspot ].Time = $value  
	#>

	#Haicut the first 6...
		$payload = $payload[6..($payload.Length)]
	#	$paytxt = Flip-BytesToText $payload -a
		$paytxt = -join ($payload | foreach { Flip-BytesToText $_,0 })
		#If there are players...
		if ($payload.length -gt 6) {
		#Grab the null bits and split on them.
		$m = Flip-BytesToText 0 -a
		#$paym = $paytxt.split($m) | select -unique 
		$paym = $paytxt.split($m) |  where { $_.length -ge 3}
		#Get the count of splits...
		$conlen = $paym.length
		
	<# 
	[string]$property = ("Split chunks")
	[object]$value = $conlen

	$obj += "" | select ID, Player, Score, Time, TimeF; 
	#Math out the index of the new line
	$arrayspot = ( $obj.length -1 )
	#Populate Name
	$obj[ $arrayspot ].Player = $property 
	$obj[ $arrayspot ].Time = $value 
		 #>
		
		#And...don't write the 3rd one? Dunno what that's all about. I think one server had a "blank one" problem. 
	#	$paym = $paym[0..($conlen)]
	#	$paym = $paym[0..1] + $paym[3..($conlen)]

	# if there are 5 zeroes in a row, there's a player connected. But 6 means no player. 
	# if this byte is 0, and the next 4 after, replace them with 10s.

		# Foreach line in the count of splits, - you'll iterate over each split
		$s = for ($i = 1; $i -le ($conlen - 1); $i++) { 
	#	$s = for ($i = 1; $i -le ($playercount*2); $i++) { 

		#if the line number is odd, write as property and the next line as value.
	#	if ($i % 2) { 
		if (!($i % 2)) { 
		#Odd line is the property, even is the value
	#	$paym[ $i ] + ": " + $paym[ ($i + 1) ] 
		
	<# 
	$playername = foreach ($byte in $payload[134..153]) { Flip-BytesToText $byte,0 }
	$Time = $payload[129..132]
	#$Time = $payload[129] + $payload[130] + $payload[131] + $payload[132]

	#Add a line to the array, create columns for Name, Value, Type
	$obj += "" | select ID,Name,Score,Time ; 
	#Math out the index of the new line
	$arrayspot = ( $obj.length -1 )
	#Populate Name
	$obj[ $arrayspot ].ID = $payload[ ($offset + 3) ]
	$obj[ $arrayspot ].Name = $payload[ ($offset + 4)..$playerlen ]  | Flip-BytesToText
	$obj[ $arrayspot ].Score = $payload[ ($offset + $playerlen + 1) ]
	$obj[ $arrayspot ].Time = $payload[ ($offset + $playerlen+2)..$payload[ ($offset + $playerlen+6) ] ]

	#3 byte header of 0s (0..2) . . . . . . . . . . . . . . . . . . . . . . . . . . . . This makes five zeroes,
	#1 byte ID of 0 (3). . . . . . .  . . . . . . . . . . . . . . . . . . . . . . . . . . .  if a player is connected,
	#1-19 byte Steam name (4-22) #3..(16 + 3) or just a 0. . . .  or six zeroes,
	#1 byte Score of 0 (5-24). . . . . . . . . . . . . . . . . . . . . . . . . . . . . if one is connected.
	#4 byte time connected, float ((6..25)..(10..29)) . . . . . . . . . . 
	#Total is 10-29 bytes per player. . . . . . . . . . . . . . . . . . . . . . . 

	while ($true) {$payload = (Get-SteamServerPlayers 72.251.237.107)[0].value ; write-host $((((($payload[132]*255) + $payload[131]*255) + $payload[130])/3) + ($payload[129]/255)) ; sleep 1 } 

	$n = foreach ($byte in $payload) { if ($byte -eq 0) {$byte = 10} ; Flip-BytesToText $byte ,0}
	-join $n

	#>



	#Write the odd item to "Player" and the even to "Time". 
	if ($paym[$i] -eq (Flip-BytesToText 1,1,1,1 -a)) {
		[string]$playerproperty = [int]0 #""
	} else {
		[string]$playerproperty = ($paym[ $i ])
	}; #end if paym

	#[string]$timevalue = ($paym[($i + 1)]) | Flip-TextToBytes -a
	$bytes = ($paym[($i + 1)]) | Flip-TextToBytes -a
	$timevalue = [bitconverter]::ToInt16($bytes,2)

	$timef = (get-date) - (get-date).AddSeconds(-$timevalue)

	#Add a line to the array, create columns for Name, Value, Type
	$obj += "" | select ID, Player, Score, Time, TimeF; 
	#Math out the index of the new line
	$arrayspot = ( $obj.length -1 )
	#Populate Name
	$obj[ $arrayspot ].ID = 0 #ID is always 0 in ARK. Will fix later.
	$obj[ $arrayspot ].Player = $playerproperty 
	#$obj[ $arrayspot ].Time = $property 
	$obj[ $arrayspot ].Score = 0 #Score is always 0 in ARK. Will fix later.
	$obj[ $arrayspot ].Time = $timevalue 
	#$obj[ $arrayspot ].Player = $value 
	$obj[ $arrayspot ].TimeF = $timef 
		
	} #end if paym
			
			} #end for 
			} else {
		[string]$property = ("No players found.")
		[string]$value = ($True)

		#Add a line to the array, create columns for Name, Value, Type
		$obj += "" | select ID, Player, Score, Time, TimeF; 
		#Math out the index of the new line
		$arrayspot = ( $obj.length -1 )
		#Populate Name
		$obj[ $arrayspot ].Player = $property 
		$obj[ $arrayspot ].Time = $value 
			}
			
			$obj | sort player -descending
			

		} else {
		Write-Host -fore red "No payload received."
		} #end if payload
		
	} #end if context

	#Close the UDP client
	$udpclient.Close()
} #end Get-SteamServerPlayers

function Get-SteamServers {
Param(
   [Parameter(Mandatory=$True,Position=1)]
   [ipaddress]$serveraddr,
   [Parameter(Position=2)]
   [int]$serverport,
   [switch]$Info,
   [switch]$Player,
   [switch]$Rules
)
#Set our UDP timeout in ms.
$UDPtimeout = 1000

#Build message - Info, Player, Rules
if ($Info){
#$bytes = "FF FF FF FF 54 53 6F 75 72 63 65 20 45 6E 67 69 6E 65 20 51 75 65 72 79 00"
$bytes =  "ÿÿÿÿTSource Engine Query" | Flip-TextToBytes -a 
$bytes += "00"
}

if ($Player){
#$bytes = "FF FF FF FF 55 FF FF FF FF"
$bytes =  'ÿÿÿÿUÿÿÿÿ' | Flip-TextToBytes -a 
}

if ($Rules){
#$bytes = "FF FF FF FF 55 FF FF FF FF"
$bytes =  'ÿÿÿÿVÿÿÿÿ' | Flip-TextToBytes -a 
}

#If you don't specify a port, it uses default 27015
if (!($serverport)) {$serverport = 27015}


#Build endpoint
    $endpoint = New-Object System.Net.IPEndPoint ($serveraddr,$serverport)
#I found this online, I don't really know what it does lol
    $udpclient= New-Object System.Net.Sockets.UdpClient
#Timeout in ms
	$udpclient.client.receiveTimeout = $UDPtimeout
#Convert the request
#	$bytes =  $Message | Flip-TextToBytes -a 
#Not sure what we're doing with BytesSent here.
    $bytesSent=$udpclient.Send($bytes,$bytes.length,$endpoint)

#$atime = get-date
#Write-Host -fore green "Querying server at: $($endpoint.address.ToString()):$($endpoint.Port.ToString())"
#	$bytes
#    $bytes | Flip-BytesToText -a

#Listen for the challenge response
$content=try {	
$udpclient.Receive([ref]$endpoint)  
} catch {
Write-Host -fore red "Connection timed out. Double-check the server's listening port."
} #finally {}

#If the challenge isn't empty, print as Bytes then print as ASCII
if ($content) {
#$btime = get-date
#Write-Host -fore green "Challenge response received, took $([int]($btime-$atime).totalmilliseconds) ms."
#	$content
	$contxt = Flip-BytesToText $content -a
#	-join $contxt
	
#Modify challenge to be response	
	$content[4] = "U" | Flip-TextToBytes -a
#Write-Host -fore green "Challenge response created:"
#	$content
	$conrsp = Flip-BytesToText $content -a
#	-join $conrsp

	
#Send the challenge response back as a handshake
#Write-Host -fore green "Sending challenge response, awaiting payload."
    $payloadbytes = $udpclient.Send($content,$content.length,$endpoint)

	#Listen for the challenge response
$payload=try {	
$udpclient.Receive([ref]$endpoint)  
} catch {
Write-Host -fore red "Connection timed out. Double-check the server's listening port."
} #finally {}


#If the payload isn't empty, print as Bytes then print as ASCII
if ($payload) {
#$ctime = get-date
#	$payload
#Write-Host -fore green "Payload received, took $([int]($ctime-$btime).totalmilliseconds) ms. Total time $([int]($ctime-$atime).totalmilliseconds) ms."
	$paytxt = Flip-BytesToText $payload -a
#Write-Host -fore green "Payload converted. Payload length: $($paytxt.Length)"
	$paytxt
} else {
Write-Host -fore red "No payload received."
} #if payload

} #if context

#Close the UDP client
$udpclient.Close()
} #end Get-SteamServers

function Get-SteamServerRules {
Param(
   [Parameter(Mandatory=$True,Position=1)]
   [ipaddress]$serveraddr,
   [Parameter(Position=2)]
   [int]$serverport
)
#Build message
$bytes =  'ÿÿÿÿVÿÿÿÿ' | Flip-TextToBytes -a 
#Set our UDP timeout in ms.
$UDPtimeout = 1000

#If you don't specify a port, it uses default 27015
if (!($serverport)) {$serverport = 27015}


#Build endpoint
    $endpoint = New-Object System.Net.IPEndPoint ($serveraddr,$serverport)
#I found this online, I don't really know what it does lol
    $udpclient= New-Object System.Net.Sockets.UdpClient
#Timeout in ms
	$udpclient.client.receiveTimeout = $UDPtimeout
#Not sure what we're doing with BytesSent here.
    $bytesSent=$udpclient.Send($bytes,$bytes.length,$endpoint)

#Listen for the challenge response
$content=try {	
$udpclient.Receive([ref]$endpoint)  
} catch {
Write-Host -fore red "Connection timed out. Double-check the server's listening port."
} #finally {}

#If the challenge isn't empty, print as Bytes then print as ASCII
if ($content) {
	$contxt = Flip-BytesToText $content -a
	
#Modify challenge to be response	
	$content[4] = "V" | Flip-TextToBytes -a
	$conrsp = Flip-BytesToText $content -a
	
#Send the challenge response back as a handshake
    $payloadbytes = $udpclient.Send($content,$content.length,$endpoint)

	#Listen for the challenge response
$payload=try {	
$udpclient.Receive([ref]$endpoint)  
} catch {
Write-Host -fore red "Connection timed out. Double-check the server's listening port."
} #finally {}

#If the payload isn't empty, print as Bytes then print as ASCII
if ($payload) {
	$paytxt = Flip-BytesToText $payload -a
	$paytxt
	
		#Data container
$oput = "" | Select "Header","Protocol","Name","Map","Folder","Game","ID","Players","MaxPlayers","Bots","ServerType","Environment","Visibility","VAC"	

	#Data	Type	Comment
	#Header	byte	Always equal to 'I' (0x49)
	$oput.header = $paytxt.length
	#Protocol	byte	Protocol version used by the server.
	$oput.protocol = $paytxt.length
	#Name	string	Name of the server.
	$oput.name = $paytxt.length
	#Map	string	Map the server has currently loaded.
	$oput.map = $paytxt.length
	#Folder	string	Name of the folder containing the game files.
	$oput.folder = $paytxt.length
	#Game	string	Full name of the game.
	$oput.game = $paytxt.length
	#ID	short	Steam Application ID of game.
	$oput.id = $paytxt.length
	#Players	byte	Number of players on the server.
	$oput.players = $paytxt.length
	#Max. Players	byte	Maximum number of players the server reports it can hold.
	$oput.maxplayers = $paytxt.length
	#Bots	byte	Number of bots on the server.
	$oput.bots = $paytxt.length
	#Server type	byte	Indicates the type of server: 'd' for a dedicated server, 'l' for a non-dedicated server, 'p' for a SourceTV relay (proxy)
	$oput.servertype = $paytxt.length
	#Environment	byte	Indicates the operating system of the server: 'l' for Linux, 'w' for Windows, 'm' or 'o' for Mac (the code changed after L4D1)
	$oput.environment = $paytxt.length
	#Visibility	byte	Indicates whether the server requires a password: 0 for public, 1 for private
	$oput.visibility = $paytxt.length
	#VAC	byte	Specifies whether the server uses VAC: 0 for unsecured, 1 for secured
	$oput.vac = $paytxt.length
	
	$oput
	
	
	
} else {
Write-Host -fore red "No payload received."
} #if payload

} #if context

#Close the UDP client
$udpclient.Close()
} #end Get-SteamServerRules

function Get-SteamServerRules2 {
Param(
   [Parameter(Mandatory=$True,Position=1)]
   [ipaddress]$serveraddr,
   [Parameter(Position=2)]
   [int]$serverport
)
#Prepare our request message

$bytes =  'ÿÿÿÿVÿÿÿÿ' | Flip-TextToBytes -a 
#Set our UDP timeout in ms.
$UDPtimeout = 1000

#If you don't specify a port, it uses default 27015
if (!($serverport)) {$serverport = 27015}

	#Output vehicle
	[array]$obj = @{}

	#Build endpoint
    $endpoint = New-Object System.Net.IPEndPoint ($serveraddr,$serverport)
	#I found this online, I don't really know what it does lol
    $udpclient= New-Object System.Net.Sockets.UdpClient
	#Timeout in ms
	$udpclient.client.receiveTimeout = $UDPtimeout
	#Not sure what we're doing with BytesSent here.
    $bytesSent=$udpclient.Send($bytes,$bytes.length,$endpoint)

	#Listen for the challenge response
	$content=try {	
		$udpclient.Receive([ref]$endpoint)  
	} catch {
		Write-Host -fore red "Connection timed out. Double-check the server's listening port."
	} #finally {}

#If the challenge isn't empty, print as Bytes then print as ASCII
if ($content) {
	$contxt = Flip-BytesToText $content -a
	
	#Modify challenge to be response	
	$content[4] = "V" | Flip-TextToBytes -a
	$conrsp = Flip-BytesToText $content -a
	
	#Send the challenge response back as a handshake
    $payloadbytes = $udpclient.Send($content,$content.length,$endpoint)

	#Listen for the challenge response
$payload=try {	
$udpclient.Receive([ref]$endpoint)  
} catch {
Write-Host -fore red "Connection timed out. Double-check the server's listening port."
} #finally {}

#If the payload isn't empty, print as Bytes then print as ASCII
if ($payload) {

#Add payload as raw data, mostly for debugging.
[string]$property = ("Raw")
[object]$value = ($payload)

#Add a line to the array, create columns for Name, Value, Type
$obj += "" | select Property, value #, Type ; 
#Math out the index of the new line
$arrayspot = ( $obj.length -1 )
#Populate Name
$obj[ $arrayspot ].property = $property 
$obj[ $arrayspot ].value = $value 

	$paytxt = Flip-BytesToText $payload -a
	#$paytxt
	
	
	$m = $paytxt.Substring(6,1)
	$conm = $paytxt.split($m)
#	$conm
	$conlen = $conm.length
	$s = for ($i = 1; $i -le $conlen; $i++) { 

	#if odd
	if ($i % 2) { 
	#Odd line is the property, even is the value
#	$conm[ $i ] + ": " + $conm[ ($i + 1) ] 

[string]$property = ($conm[ $i ])
[object]$value = ($conm[($i + 1)])

#Add a line to the array, create columns for Name, Value, Type
$obj += "" | select Property, value #, Type ; 
#Math out the index of the new line
$arrayspot = ( $obj.length -1 )
#Populate Name
$obj[ $arrayspot ].property = $property 
$obj[ $arrayspot ].value = $value 


	} #end if 
	
	} #end for 
#	$s
$obj
	
} else {
Write-Host -fore red "No payload received."
} #if payload

} #if context

#Close the UDP client
$udpclient.Close()
} #end Get-SteamServerRules2



