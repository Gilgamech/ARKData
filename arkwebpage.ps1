$arkpath = "C:\Dropbox\Docs\ARK\"
$serverFolder = "$arkpath\PvP-Hardcore-OfficialServer92-(v236.0)"

get-date | select datetime | ConvertTo-Html > "$serverFolder\player\test.html"

"$arkpath\bin\arkoutput.ps1" | sort "Tribe name" | select "ARK name", "Tribe name", "TimeF" | ConvertTo-Html >> "$serverFolder\player\test.html"

("$arkpath\bin\arkoutput.ps1")."Tribe name" | Group-Object | select "count", "name" | ConvertTo-Html >> "$serverFolder\player\test.html"

