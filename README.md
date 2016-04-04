# ARKdata
This is my code for scraping ARK servers by the arkserver.net API. It is the HMTL version of a manual scraping project I originally built by copying player data from the arkservers.net webpage and pasting into Excel.


Contains 18 functions:

Start-ArkdataTask - Runs Run-ArkdataTask as a job for each server (currently 2 that I play on), then runs Get-ArkdataTask.
Get-ArkdataTask - Gets the current Job list, and outputs the data, so you can watch your job output for errors. Or not it's your life.
Run-ArkdataTask - Runs the whole process for a given server IP and port.
Get-ArkdataPayload - Pulls Arkdata from Arkservers.net as JSON packet, outputs as Powershell object. Need to rewrite to query servers directly with UDP.
Import-ArkdataINI - Imports the latest Official Dedicated Servers list as Servername and IP. Each IP is supposed to have ARK 4 servers, but some have fewer.
Add-HTMLTableAttribute - Got from here: https://www.reddit.com/r/PowerShell/comments/2nni5r/the_power_of_converttohtml_and_css_part_2/
Get-ArkdataPlayers - Takes output from Get-ArkdataPayload and output s a list of players who are online.
Get-ArkdataPlayersLastDay - Reads the past 24h of files and outputs players who have been online.
Out-ArkdataPlayersFile - Outputs a list of playernames who have been online, used by Out-ArkdataWebpage.
Output-ArkdataPlayerTime - Takes a playername and a server, outputs how many hours they've played. Work in progress.
Out-ArkdataPlayerFiles - Updates the player.csv files.
Out-ArkdataTribeDB - Updates the .tribe.csv DB source.
Test-ArkdataHostDirs - Tests for Arkdata directories, creates if not there.
Get-ArkdataServerName - Takes output from Get-ArkdataPayload, outputs servername.
Get-ArkdataFileDate - Takes Arkdata filename, outputs Powershell DateTime object.
Get-ArkdataDedicatedServers - Downloads a list of master servers from Arkservers.net.
Out-ArkdataIndex - Outputs the Arkdata main page, which auto-updates when Arkdata finds new servers.
Out-ArkdataWebpage - Outputs the Arkdata page for a given server. Depends on the Webparts at the bottom.


ARK name and Tribe name are collected by watching ingame chat and manually updating the DB. This works surprisingly well, and gives us crazy amounts of data. "Do things that don't scale", right? Inspired by some guy who got on the front page of HN:
https://defaultnamehere.tumblr.com/post/139351766005/graphing-when-your-facebook-friends-are-awake
