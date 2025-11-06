<#
    .SYNOPSIS
        Function to copy and rename photos
        Version:1.1
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
    [array]$Filter = "*.JPG,*.CR2,*.CR3",
    [Parameter(Mandatory = $False,
        HelpMessage = "specify the log file path")]
    [string]$LogFilePath
)
    
[array]$TotalFolders
[array]$Totalcopies
$records = [System.Collections.ArrayList]@()
[array]$alllogs = @()
$LogFileName = "log_$((Get-Date).ToString("ddMMyyyy_HHmmss")).csv"
$copyresultsLogFileName = "CopyResults_$((Get-Date).ToString("ddMMyyyy_HHmmss")).log"
$LogFilePath = if ($LogFilePath) { $LogFilePath } else { $PSScriptRoot }
Function Write-Log {
    <#
    .DESCRIPTION 
    Write-Log is used to write information to a log file and to the console.
    
    .PARAMETER Severity
    parameter specifies the severity of the log message. Values can be: Information, Warning, or Error. 
    #>

    [CmdletBinding()]
    param(
        [parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Message,
        [string]$LogFileName,
 
        [parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Information', 'Warning', 'Error')]
        [string]$Severity = 'Information'
    )
    # Write the message out to the correct channel											  
    switch ($Severity) {
        "Information" { Write-Host $Message -ForegroundColor Green }
        "Warning" { Write-Host $Message -ForegroundColor Yellow }
        "Error" { Write-Host $Message -ForegroundColor Red }
    } 											  
    try {
        [PSCustomObject] [ordered] @{
            Time     = (Get-Date -f g)
            Message  = $Message
            Severity = $Severity
        } | Export-Csv -Path "$LogFilePath\$LogFileName" -Append -NoTypeInformation -Force
    }
    catch {
        Write-Error "An error occurred in Write-Log() method" -ErrorAction SilentlyContinue		
    }    
}    
function Import-photos {
    param (
        [string]$Inputpath,
        [string]$BaseDestination
            
    )
    [array]$totalFilesToCopy = @()
    [int]$Totalcopies = 0  
   
        
    write-log "Import-Photos started processing photos from $InputPath to $BaseDestination" -LogFileName $LogFileName -Severity Information
    if (!(test-path $Source)) {
        Write-log "input path $InputPath is not found" -LogFileName $LogFileName -Severity Error    
        exit 1     
    }
   
    $photos = $Filter.Split(',') | Where-Object { $_ } | ForEach-Object { Get-ChildItem $InputPath -File -Filter $_ }
    write-log "A total of $($photos.count) photos found for processing" -LogFileName $LogFileName -Severity Information
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
            write-log "Folder $FullDestination Exist at $BaseDestination Skipping Folder Creation" -LogFileName $LogFileName -Severity Information
        }
        Else {
            write-log "Folder $FullDestination Does not Exist at $BaseDestination" -LogFileName $LogFileName -Severity Warning
            write-log "Creating Destination Folder $FullDestination" -LogFileName $LogFileName -Severity Information
            $createFolder = New-Item -Path $FullDestination -ItemType Directory 3>&1 
            #$TotalFolders += $CreateFolder
        }
        If (!(test-path "$FutureFileFullName")) {
            write-log "File:$FutureFileFullName was not found" -LogFileName $LogFileName -Severity Information
            $copy = Copy-Item -path $_.FullName -Destination $FutureFileFullName -verbose 3>&1  -passthru
            $Totalcopies++
            $status = "Copied"
            #$log = Write-Output $copy -Verbose 2>&1
            #$Totalfilestocopy += $copy
                
        }
        Else {
            write-log  "File:$FutureFileFullName  was found at $FullDestination | skippping copy" -LogFileName $LogFileName -Severity Warning
            #$Log = Write-Output "File:$FutureFileFullName  was found at $FullDestination | skippping copy" -Verbose 2>&1
            $Status = "Skipped"
            #$alllogs += $log
        }
        
        $collection = [ordered] @{
            ImageName         = $ImageName
            CopyStatus        = $Status
            Destination       = $BaseDestination
            FileName          = $FutureFileFullName
        } 
       
        $Items = [PSCustomObject]$collection
        $records.Add($Items) | Out-Null
    }
    Write-Progress -Activity "Processing Photos" -Status "Completed" -PercentComplete 100  
    write-log "Import-Photos completed processing photos from $InputPath to $BaseDestination" -LogFileName $LogFileName -Severity Information
    write-log "$Totalcopies photo(s) were copied" -LogFileName $LogFileName -Severity Information
    $TotalFolders | Out-File .\$LogFileName 
    #$Totalfilestocopy | out-file .\$LogFileName
    $alllogs | Out-File .\$copyresultsLogFileName
    $records | Out-File .\$copyresultsLogFileName
    write-host "copy report are stored in" (Get-ChildItem -path $LogFilePath\$copyresultsLogFileName).FullName 
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

    