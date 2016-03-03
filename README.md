# ARKdata
This is my code for scraping ARK servers by the arkserver.net API. It is the HMTL version of a manual scraping project I originally built by copying player data from the arkservers.net webpage and pasting into Excel.


It consists of 4 modules: 

1. Arkdatascrape.ps1 - Pulls JSON from API with curl, writes JSON to file, parses, updates DB, and writes to player files. Player files are nice to look at but mostly useless (for now).

2. Arkdataoutput.ps1 - Combines data from the most recent JSON file with the DB (currently .tribe.csv) and returns players who are online by Steam name, ARK name, Tribe name, and TimeF (Time online, formatted into HH:mm:ss) - (This was funky to write, and it works weird.)

3. ARkdatawebpage.ps1 - HTML boilerplate, this calls Arkdataoutput.ps1 and stamps an HTML page with a timestamp, list of players (the columns from Arkdataoutput.ps1) and a simple count of tribes by players online. Uses an external CSS file for proper formatting, this increases the amount of the page that I know how to cache.

4. Arkdatatask.ps1 - The scheduling engine. Currently, this calls Arkdatascrape.ps1 and then Arkdatawebpage.ps1, then sleeps for 60 seconds. It's watched over by a 5-minute Windows Scheduled Task, which is included as ArkdataTask.xml. 


ARK name and Tribe name are collected by watching ingame chat and manually updating the DB. This works surprisingly well, and gives us crazy amounts of data. "Do things that don't scale", right?


I'm just starting to tap into the aforementioned data. More to come.


Inspired by some guy who got on the front page of HN:
https://defaultnamehere.tumblr.com/post/139351766005/graphing-when-your-facebook-friends-are-awake


I'm serious, making this is more fun than picking up rocks in ARK. 
