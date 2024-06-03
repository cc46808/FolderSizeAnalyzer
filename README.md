
# FolderSizeAnalyzer

## Overview

`FolderSizeAnalyzer` is a PowerShell script designed to recursively analyze the sizes of folders within a specified directory. The script provides options to limit the depth of recursion, specify the number of top largest folders to display, and output the results to a log file. It can include hidden folders (those starting with a dot) and optionally include system folders.

## Features

- Recursively calculate folder sizes.
- Limit the depth of recursion.
- Display the top largest folders.
- Output results to a log file.
- Include hidden folders.
- Optionally include system folders.

## Requirements

- Windows PowerShell (run as Administrator for full functionality)

## Usage

```powershell
.\FolderSizeAnalyzer.ps1 [-p <Path>] [-f <Number>] [-o <OutputPath>] [-d <MaxDepth>] [--include-system-folders] [-help] [--help]
```

## Parameters

- `-p`, `--path`
  - Specifies the path to calculate folder sizes. Default is the current directory.

- `-f`, `--first`
  - Specifies the number of top largest folders to display. Default is 10.

- `-o`, `--output`
  - Specifies the path for the output log file. Default is `FolderSizes_YYYYMMDD_HHMMSS.log`.

- `-d`, `--depth`
  - Specifies the maximum depth for recursive directory search. Default is 2. Use `0` or `max` for no limit.

- `--include-system-folders`
  - Specifies whether to include system folders in the search. Default is false.

- `-h`, `--help`
  - Displays this help message.

## Examples

### Example 1: Basic Usage

```powershell
.\FolderSizeAnalyzer.ps1
```

This command calculates the folder sizes in the current directory with a default depth of 2, displaying the top 10 largest folders, and saves the results to a log file.

### Example 2: Specify Path and Output File

```powershell
.\FolderSizeAnalyzer.ps1 -p C:\Some\Other\Path -f 15 -o C:\output\FolderSizes.log
```

This command calculates the folder sizes in the specified path `C:\Some\Other\Path`, displays the top 15 largest folders, and saves the results to the specified output file `C:\output\FolderSizes.log`.

### Example 3: Include System Folders

```powershell
.\FolderSizeAnalyzer.ps1 -p C:\Some\Other\Path -d max --include-system-folders
```

This command calculates the folder sizes in the specified path `C:\Some\Other\Path` with no limit on recursion depth, including system folders, and saves the results to the default output file.

## Notes

- Run the script as an administrator for full functionality, especially when including system folders.
- Ensure the path provided is valid and accessible.
- The script handles access-denied errors gracefully, skipping over directories it cannot access.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

## Contact

For questions or feedback, please contact me.

---

© 2024. All rights reserved.
