<#
    .DESCRIPTION
    Starts httpd from busybox in Docker, serving up any files under the 'http' directory 
    relative to the script. Outputs a URL where the server is reachable.
#>


$scriptPath = Split-Path -parent $PSCommandPath
$wwwPath = Join-Path $scriptPath '.\http' -Resolve

# Start busybox httpd to make any files in the http folder (e.g. download credentials)
# available via HTTP
docker pull busybox:latest | Out-Null
docker run -d -p 8000:80 -v ${wwwPath}:/www --name build-static busybox:latest httpd -f -h /www | Out-Null

# Get the IP address where this will be reachable during a docker build and export it as the
# environment variable that the build script expects
$getIpCmd = 'ip route | awk ''/default/ { print $3 }'''
$httpIp = docker exec build-static bin/sh -c $getIpCmd
Write-Output "http://${httpIp}:8000"