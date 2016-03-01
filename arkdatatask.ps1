#init vars
#Set arkdata path
$arkdatapath = "C:\Dropbox\Docs\ARK\"

#always runs
while ($true) {

#run these tasks
#arkdata scraper, downloads and parses data packet, outputs to files.
#& "$arkdatapath\bin\arkscrape.ps1"
& "$arkdatapath\bin\arkdatascrape.ps1"

#arkdata webpage generator. Calls arkdata output data combiner.
& "$arkdatapath\bin\arkdatawebpage.ps1"
#& "$arkdatapath\bin\arkdatawebpage.ps1"

#pause 60
Sleep (60-(get-date).second)
}
