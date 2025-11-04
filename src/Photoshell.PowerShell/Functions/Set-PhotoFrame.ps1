$sourcePath = "C:\pics\export\GRS-Gala-2023\"
$DestinationPath = "C:\pics\export\GRS-Gala-2023\"
$bordercolor = "black"
$bordersize = "50x50"


$photos = Get-ChildItem -Path $sourcePath 
$photos | foreach {
    $Splitname = ($_.Name).split('.')
    $a = $splitname[0]
    $b = $splitname[1]
    $NewimageName = "$a-BF.$b"
    magick $_.FullName -bordercolor $bordercolor -border $bordersize $DestinationPath$NewimageName
}