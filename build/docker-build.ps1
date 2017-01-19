<#
    .DESCRIPTION
    Runs a docker build for the DSE version specified in the DSE_VERSION file. Expects the
    DSE_CREDENTIALS_URL environment variable to be set.
#>

$scriptPath = Split-Path -parent $PSCommandPath

# Make sure DSE_CREDENTIALS_URL is present
if (!$Env:DSE_CREDENTIALS_URL) {
    throw 'The DSE_CREDENTIALS_URL environment variable must be set before building'
}

# Use contents of DSE_VERSION file as variables
Get-Content "$scriptPath\DSE_VERSION" |% {
    if ($_) {
        $varParts = $_.Split('=')
        New-Variable -Name $varParts[0] -Value $varParts[1]
    }
}


# Build the image
docker build --build-arg DSE_VERSION=$DSE_VERSION --build-arg DSE_CREDENTIALS_URL=$Env:DSE_CREDENTIALS_URL -t luketillman/datastax-enterprise:$DSE_VERSION .
