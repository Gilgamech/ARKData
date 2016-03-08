#init vars
#Set arkdata path
$arkdatapath = "C:\Dropbox\Docs\ARK\"

#always runs
while ($true) {

#run these tasks
#arkdata scraper, downloads and parses data packet, outputs to files.
& "$arkdatapath\bin\arkdatascrape.ps1"

#arkdata webpage generator. Calls arkdata output data combiner.
& "$arkdatapath\bin\arkdatawebpage.ps1"

#arkdata player reports, these take a long time.
& "$arkdatapath\bin\arkdatareporttask.ps1"
#& "$arkdatapath\bin\arkdataplayerslast1day.ps1"
#& "$arkdatapath\bin\arkdataplayerslast1hr.ps1"
#& "$arkdatapath\bin\arkdataplayerslast5m.ps1"


#pause 60
$sleeptime = 60-(get-date).second
Sleep ($sleeptime)
}
