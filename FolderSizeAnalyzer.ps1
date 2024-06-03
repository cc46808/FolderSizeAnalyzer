<#
.SYNOPSIS
    FolderSizeAnalyzer - A PowerShell script to analyze folder sizes recursively.

.DESCRIPTION
    This script calculates the sizes of folders within a specified directory, with options to limit the depth of recursion,
    specify the number of top largest folders to display, and output the results to a log file. It includes hidden folders (those starting with a dot).

.AUTHOR
    Craig Carroll

.CONTACT
    https://craigcarroll.design

.LICENSE
    MIT License

.VERSION
    1.0

.SCRIPT NAME
    FolderSizeAnalyzer

.PARAMETER Path
    Specifies the path to calculate folder sizes. Default is the current directory.

.PARAMETER First
    Specifies the number of top largest folders to display. Default is 10.

.PARAMETER OutputPath
    Specifies the path for the output log file. Default is 'FolderSizes_YYYYMMDD_HHMMSS.log'.

.PARAMETER MaxDepth
    Specifies the maximum depth for recursive directory search. Default is 2. Use '0' or 'max' for no limit.

.PARAMETER IncludeSystemFolders
    Specifies whether to include system folders in the search. Default is false.

.PARAMETER Help
    Displays the help message.

.EXAMPLE
    .\FolderSizeAnalyzer.ps1 -p C:\Some\Other\Path -f 15 -o C:\output\folderSizes.log -d 3 --include-system-folders

.NOTES
    This script uses recursive directory search to calculate folder sizes and can handle large directory structures.
#>

# FolderSizeAnalyzer.ps1
param (
    [Alias("p")]
    [string]$Path = (Get-Location),  # The path to calculate folder sizes. Default is the current directory.

    [Alias("f")]
    [int]$First = 10,  # The number of top largest folders to display. Default is 10.

    [Alias("o")]
    [string]$OutputPath = "FolderSizes_$((Get-Date).ToString('yyyyMMdd_HHmmss')).log",  # The path for the output log file. Default is 'FolderSizes_YYYYMMDD_HHMMSS.log'.

    [Alias("d")]
    [string]$MaxDepth = "2",  # The maximum depth for recursive directory search. Default is 2. Use '0' or 'max' for no limit.

    [switch]$IncludeSystemFolders = $false,  # Include system folders in the search. Default is false.
    
    [switch]$Help  # Display the help message.
)

# Function to display the help message
function Show-Help {
    Write-Host "Usage: .\FolderSizeAnalyzer.ps1 [-p <Path>] [-f <Number>] [-o <OutputPath>] [-d <MaxDepth>] [--include-system-folders] [-help] [--help]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -p, --path                    Specifies the path to calculate folder sizes. Default is the current directory."
    Write-Host "  -f, --first                   Specifies the number of top largest folders to display. Default is 10."
    Write-Host "  -o, --output                  Specifies the path for the output log file. Default is 'FolderSizes_YYYYMMDD_HHMMSS.log'."
    Write-Host "  -d, --depth                   Specifies the maximum depth for recursive directory search. Default is 2. Use '0' or 'max' for no limit."
    Write-Host "      --include-system-folders  Specifies whether to include system folders in the search. Default is false."
    Write-Host "  -h, --help                    Displays this help message."
    Write-Host ""
    Write-Host "Example:"
    Write-Host "  .\FolderSizeAnalyzer.ps1 -p C:\Some\Other\Path -f 15 -o C:\output\folderSizes.log -d 3 --include-system-folders"
    Write-Host ""
}

# Function to recursively get directories up to the specified depth
function Get-Directories {
    param (
        [string]$Path,
        [int]$Depth,
        [switch]$IncludeSystemFolders
    )

    $result = @()  # Initialize an empty array to store the directories

    if ($Depth -le 0) {
        return $result  # Return an empty array if the depth is less than or equal to 0
    }

    try {
        Write-Host -NoNewline "$Path" -ForegroundColor Cyan
        $directories = Get-ChildItem -Path $Path -Directory -Force  # Get all directories, including hidden ones, in the specified path
        # Write-Host "Directories found in ${Path}: $($directories.Count)" -ForegroundColor Green
    } catch {
        Write-Host "Warning: Access to the path '$Path' is denied." -ForegroundColor Yellow
        return $result  # Return the accumulated directories up to this point if access is denied
    }

    if (-not $IncludeSystemFolders) {
        $directories = $directories | Where-Object { -not ($_.Attributes -band [System.IO.FileAttributes]::System) }
        # Write-Host -NoNewline "`rDirectories after filtering system folders: $($directories.Count)" -ForegroundColor Green
    }

    $result += $directories  # Add the directories to the result array

    foreach ($directory in $directories) {
        Write-Host "`e[2K`r$($directory.FullName)" -NoNewline -ForegroundColor Cyan
        $result += Get-Directories -Path $directory.FullName -Depth ($Depth - 1) -IncludeSystemFolders:$IncludeSystemFolders  # Recursively get subdirectories
    }

    # Clear the line after the loop is completed
    Write-Host "`e[2K" -NoNewline

    return $result  # Return the accumulated directories
}

# Function to check if running as administrator
function Test-Administrator {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Handle --help explicitly
if ($args.Contains("--help") -or $args.Contains("-h")) {
    Show-Help
    exit
}

# Display help if the Help switch is provided
if ($Help) {
    Show-Help
    exit
}

# Check if the script is running as an administrator
if (-not (Test-Administrator)) {
    Write-Host "This script must be run as an administrator." -ForegroundColor Red
    exit
}

try {
    # Check if the specified path exists
    if (-Not (Test-Path -Path $Path)) {
        throw "The specified path does not exist."
    }

    # Convert MaxDepth to an integer and handle 'max' option
    if ($MaxDepth -eq "0" -or $MaxDepth -eq "max") {
        $MaxDepth = [int]::MaxValue
    } else {
        $MaxDepth = [int]$MaxDepth
    }

    # Initialize an array to store directory size info
    $dirSizes = @()

    # Get all directories in the specified path with the specified max depth
    Write-Host "Fetching directories..."
    $directories = Get-Directories -Path $Path -Depth $MaxDepth -IncludeSystemFolders:$IncludeSystemFolders

    $totalDirs = $directories.Count
    Write-Host -NoNewline "`e[2K`rTotal directories found: $totalDirs" -ForegroundColor Green

    $currentDir = 0

    # Start a stopwatch to measure elapsed time
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    # Calculate the size of each directory
    foreach ($dir in $directories) {
        $currentDir++
        try {
            $dirSize = (Get-ChildItem -Path $dir.FullName -Recurse -ErrorAction SilentlyContinue -Force | Measure-Object -Property Length -Sum).Sum
        } catch {
            Write-Host "Warning: Access to the path '$($dir.FullName)' is denied." -ForegroundColor Yellow
            continue
        }
        $dirSizes += [PSCustomObject]@{
            Name = $dir.FullName
            SizeMB = [math]::round($dirSize / 1MB, 2)
        }
        $elapsed = $stopwatch.Elapsed
        $remaining = $elapsed.TotalSeconds / $currentDir * ($totalDirs - $currentDir)
        Write-Progress -Activity "Working" -Status "$currentDir of $totalDirs" -PercentComplete (($currentDir / $totalDirs) * 100) -SecondsRemaining $remaining
    }

    $stopwatch.Stop()

    Write-Host ""  # Move to a new line

    # Sort the directories by size and select the top N
    $topDirs = $dirSizes | Sort-Object -Property SizeMB -Descending | Select-Object -First $First

    # Output the results in a table format
    $topDirs | Format-Table -Property Name, SizeMB -AutoSize

    # Log the results to the specified file
    $topDirs | Out-File -FilePath $OutputPath -Encoding UTF8

    Write-Host "Results saved to $OutputPath"
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
    Write-Host ""
    Show-Help
}
