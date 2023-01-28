#
# Powershell script for adding/removing/showing entries to the hosts file.

# arguments are:
#   add <filename> - adds entries from the file to the hosts file
#   remove <filename> - removes entries from the file from the hosts file
#   show - shows the contents of the hosts file
#
# <filename> format is:
# <ip> <hostname>
# 
# example:
# 127.0.0.1 youtube.com
# 127.0.0.1 twitter.com

function add-hosts([string]$filename, [array]$hostFileEntries) {
    foreach($item in $hostFileEntries){
        $ip = $item["ip"]
        $hostname = $item["hostname"]
        $ip + "`t" + $hostname | Out-File -encoding ASCII -append $filename
    }
}

function remove-hosts([string]$filename, [array]$hostFileEntries) {
    $c = Get-Content $filename
    $newLines = @()

    foreach ($line in $c) 
    {
        [bool]$isIpAndHostnameInFile = 0
        foreach($item in $hostFileEntries)
        {
            $ip = $item["ip"]
            $hostname = $item["hostname"]

            $bits = [regex]::Split($line, "\s+|\t+")
            if ($bits[0] -eq $ip -and $bits[1] -eq $hostname) {
                $isIpAndHostnameInFile = 1
                break
            }
        }
        if ($isIpAndHostnameInFile -eq 0)
        {
            $newLines += $line
        }
    }
    
    # Write file
    Clear-Content $filename
    foreach ($line in $newLines) {
        $line | Out-File -encoding ASCII -append $filename
    }
}

function print-hosts([string]$filename) {
    $c = Get-Content $filename
    
    foreach ($line in $c) {
        Write-Host $line
    }
}

function get-hosts([string]$filename) {
    $c = Get-Content $filename
    $hostFileEntries = @()
    foreach ($line in $c) {
        $bits = [regex]::Split($line, "\s+|\t+")
        $hostFileEntries += @{
            "ip" = $bits[0];
            "hostname" = $bits[1]
        }
    }
    return $hostFileEntries
}

try {
    $hostFile = "C:\Windows\System32\drivers\etc\hosts"
    $logFile = "C:\temp\updateHostFile.log"

    # Log arguments and date
    "$args $(Get-Date -Format "MM/dd/yyyy HH:mm K") "| Out-File $logFile -Append

    # Requires -RunAsAdministrator
    If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
    {
        $arguments = "& '" + $myinvocation.mycommand.definition + "'"
        Start-Process powershell -Verb runAs -ArgumentList $arguments
        throw "Script must be run as administrator."
    }

    if ($args[0] -eq "show") {
        print-hosts $hostFile

    } elseif ($args[0] -eq "add" -or $args[0] -eq "remove") {
        # Flush DNS cache
        ipconfig /flushdns

        $hostFileEntries = get-hosts $args[1]   

        if ($args[0] -eq "add") {
            remove-hosts $hostFile $hostFileEntries
            add-hosts $hostFile $hostFileEntries

        } elseif ($args[0] -eq "remove") {
            remove-hosts $hostFile $hostFileEntries
        }

        print-hosts $hostFile

    } else {
            throw "Invalid operation '" + $args[0] + "' - must be one of 'add <filename>', 'remove <filename>', 'show'."
    }
} catch  {
    $error[0] | Out-File $logFile -Append
    Write-Host $error[0]
}