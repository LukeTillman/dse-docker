<#
    .DESCRIPTION
    Downloads the DSE version specified in the DSE_VERSION file.
#>

$scriptPath = Split-Path -parent $PSCommandPath
$downloadPath = Resolve-Path "$scriptPath\.."

# Use contents of DSE_VERSION file as variables
Get-Content "$scriptPath\DSE_VERSION" |% {
    if ($_) {
        $varParts = $_.Split('=')
        New-Variable -Name $varParts[0] -Value $varParts[1]
    }
}

$DSE_FILE = "dse-$DSE_VERSION-bin.tar.gz"

# Prompt for username and password
$credentials = Get-Credential -Message "Enter credentials for downloads.datastax.com"

# Download the files
Invoke-WebRequest -Uri "http://downloads.datastax.com/enterprise/$DSE_FILE" -OutFile "$downloadPath\$DSE_FILE" -Credential $credentials
Invoke-WebRequest -Uri "http://downloads.datastax.com/enterprise/$DSE_FILE.md5" -OutFile "$downloadPath\$DSE_FILE.md5" -Credential $credentials

# Checksum verification
$verified = $true
Get-Content "$downloadPath\$DSE_FILE.md5" |% {
    if ($_ -match '^([\w\d]+)\s+(.+)') {
        $filePath = Resolve-Path (Join-Path $downloadPath $Matches[2])
        $hash = Get-FileHash $filePath -Algorithm MD5
        if ($hash.Hash -ne $Matches[1]) {
            Write-Error "MD5 Hash does not match for file $filePath"
            $verified = $false
        } else {
            Write-Host "MD5 Hash matches for file $filePath"
        }
    }
}

if (!$verified) {
    throw "At least one file failed MD5 validation"
}