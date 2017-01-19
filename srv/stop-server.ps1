<#
    .DESCRIPTION
    Stops the httd server, removing the container and associated volumes.
#>

docker rm --force --volumes build-static