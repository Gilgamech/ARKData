function Get-TestingCommands
{
write-host "
Get-SteamServers 10.0.0.5 -Rules
Get-SteamServers 72.251.237.140  -Player
Get-SteamServerInfo 10.0.0.5 
Get-SteamServerInfo 72.251.237.140 
"
}



function Get-ArkdataSteamDedicatedServers
{
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




function Get-SteamServerInfo
{
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
$oput = "" | Select "Header","Protocol","Servername","Map","Folder","Game","ID","Players","MaxPlayers","Bots","ServerType","Environment","Visibility","VAC"	

	#Data	Type	Comment
	#Header	byte	Always equal to 'I' (0x49)
	$oput.header = $content.length
	#Protocol	byte	Protocol version used by the server.
	$oput.protocol = $content.length
	#Name	string	Name of the server.
	$oput.servername = $contxt.Split(" ,:")[0].substring(6,($g.Split(" ,:")[0].length - 6))
	#Map	string	Map the server has currently loaded.
	$oput.map = $contxt.Split(" ,:")[2].substring(9,($g.Split(" ,:")[0].length - 26))
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





function Get-SteamServerRules
{
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



function Get-SteamServerPlayers
{
Param(
   [Parameter(Mandatory=$True,Position=1)]
   [ipaddress]$serveraddr,
   [Parameter(Position=2)]
   [int]$serverport
)
#Set our UDP timeout in ms.
$UDPtimeout = 1000

#Build message
$bytes =  'ÿÿÿÿUÿÿÿÿ' | Flip-TextToBytes -a 

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
} #end Get-SteamServerPlayers




function Get-SteamServers
{
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








function Get-SteamServerRules
{
Param(
   [Parameter(Mandatory=$True,Position=1)]
   [ipaddress]$serveraddr,
   [Parameter(Position=2)]
   [int]$serverport
)
#Set our UDP timeout in ms.
$UDPtimeout = 1000

#Build message
$bytes =  'ÿÿÿÿVÿÿÿÿ' | Flip-TextToBytes -a 

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



