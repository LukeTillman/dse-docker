<#
    .DESCRIPTION
    Runs a docker build for the DSE version specified in the DSE_VERSION file.
#>

$scriptPath = Split-Path -parent $PSCommandPath

# Use contents of DSE_VERSION file as variables
Get-Content "$scriptPath\DSE_VERSION" |% {
    if ($_) {
        $varParts = $_.Split('=')
        New-Variable -Name $varParts[0] -Value $varParts[1]
    }
}

docker build --build-arg DSE_VERSION=$DSE_VERSION -t luketillman/datastax-enterprise:$DSE_VERSION .