<#
    .SYNOPSIS
        Function to copy and rename photos
        Version:1.0
        Author: Charbel HANNA
    .DESCRIPTION
        The objective of this function is to copy photos from source to destination while performing a rename operation.
        The photos are copied to by Date taken 'yyyy-M-dd' folders that are created under the root folder destination.
        The photos are renamed based on the following naming convention. 
        [Datetaken]_[CameraModel]_[OriginalImageName]extension
    .PARAMETER
        1.Source root folder
        2.Destination root folder
    .EXAMPLE
    #>
param (
    [Parameter( Mandatory = $true,
        HelpMessage = "Enter the source root folder path")]
    [String]$Source,
    [Parameter( Mandatory = $true,
        HelpMessage = "Enter the desired destination root folder path ','" )]
    [String]$Destination,
    [Parameter(Mandatory = $False,
        HelpMessage = "specify , seperated extensions to filter")]
    [array]$Filter = "*.JPG,*.CR2,*.CR3"
      
)
    
[array]$TotalFolders
[array]$Totalcopies
[array]$records
[array]$alllogs
$properties = @{}
    
function Import-photos {
    param (
        [string]$Inputpath,
        [string]$BaseDestination
            
    )
    [array]$totalFilesToCopy = @()
    [int]$Totalcopies = 0  
    $LogFileName = "IP_$((Get-Date).ToString("ddMMyyyy_HHmmss")).log"
        
    
    if (!(test-path $Source)) {
            
        write-host "input path is not found" -ForegroundColor Red
        exit 1     
    }
   
    $photos = $Filter.Split(',') | Where-Object { $_ } | ForEach-Object { Get-ChildItem $InputPath -File -Filter $_ }
    write-host $photos.count "photos has been found" -ForegroundColor Cyan 
    Write-Progress -Activity "Processing Photos" -Status "Starting" -PercentComplete 0 
    $Photos | 
    ForEach-Object {
        $index++
        #Extracting image metadata
        Write-Progress -Activity "Processing Image $($index) of $($photos.count)" -Status "Processing Image $($_.FullName)" -PercentComplete "$(($index/$photos.count)*100)"
        $metadata = exiftool -j $_.FullName | ConvertFrom-Json
        $DateTaken = ($metadata.DateTimeOriginal).split(' ')[0].Replace(':', '-')
        $BaseYear = $DateTaken.Split('-')[0]
        $CameraModel = $metadata.Model 
        #$CameraName = $metadata.Make
        $ImageName = $metadata.FileName
        $FullDestination = join-path $BaseDestination $BaseYear $DateTaken '\'
        $FutureFileFullName = ('{0:}{1:}_{2:}_{3:}' -f $FullDestination, $DateTaken, $CameraModel, $ImageName) 
        If (Test-Path -Path "$FullDestination") {
            Write-Host "Folder $FullDestination Exist at $BaseDestination Skipping Folder Creation" -ForegroundColor Green
        }
        Else {
            Write-Host "Folder $FullDestination Does not Exist at $BaseDestination" -ForegroundColor Yellow
            Write-Host "Creating Destination Folder" $FullDestination -ForegroundColor Cyan
            $createFolder = New-Item -Path $FullDestination -ItemType Directory 3>&1 
            $TotalFolders += $CreateFolder
        }
        If (!(test-path "$FutureFileFullName")) {
            Write-Host "File:"$FutureFileFullName " was not found" -ForegroundColor Yellow   
            $copy = Copy-Item -path $_.FullName -Destination $FutureFileFullName -verbose 3>&1  -passthru
            $Totalcopies++
            $Totalfilestocopy += $copy
                
        }
        Else {
            $Log = Write-Output "File:"$FutureFileFullName " was found at $FullDestination | skippping copy" -Verbose 2>&1
            $Status = "Skipped"
            $alllogs += $log
        }
        
        $collection = @{
            'ImageName'         = $ImageName
            'CopyStatus'        = $Status
            'DestinationFolder' = $BaseDestination
            'FileName'          = $FutureFileFullName
        } 
        foreach ($keys in $collection.keys) {
            $properties[$keys] = $collection[$keys]
        }
        $Items = [PSCustomObject]$properties
        $records += $Items
    }
    Write-Progress -Activity "Processing Photos" -Status "Completed" -PercentComplete 100  
    write-host $Totalcopies "photo(s) were copied"
    $TotalFolders | Out-File .\$LogFileName 
    #$Totalfilestocopy | out-file .\$LogFileName
    $alllogs | Out-File .\$LogFileName
    $records | Out-File .\$logFileName
    write-host "copy logs are stored in" (Get-ChildItem -path .\$LogFileName).FullName 
}
# main script
try {
        
    Import-photos -InputPath $Source -BaseDestination $Destination
} 
catch {
    Write-Host "An error occurred:" -ForegroundColor Red
    Write-Host $_ -ForegroundColor Red
}
finally {
}

    