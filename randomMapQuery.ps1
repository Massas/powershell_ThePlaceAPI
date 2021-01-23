
$apikey="********"

$latitudeint=Get-Random -Maximum 90 -Minimum 0
$longitudeint=Get-Random -Maximum 180 -Minimum 0

$signseed_lat=Get-Random
$signseed_lon=Get-Random

$signnum_lat=$signseed_lat % 2
$signnum_lon=$signseed_lon % 2

if($signnum_lat -eq 1){
    $minussign_lat ='-'
}else {
    $minussign_lat = ''
}

if($signnum_lon -eq 1){
    $minussign_lon ='-'
}else {
    $minussign_lon = ''
}

$latradix = Get-Random -Maximum 999999 -Minimum 0
$lonradix = Get-Random -Maximum 999999 -Minimum 0

$latitude = $minussign_lat + [string]$latitudeint + '.' + [string]$latradix
$longitude = $minussign_lon + [string]$longitudeint + '.' + [string]$lonradix

$apicall="https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$latitude,$longitude&radius=1000&type=political&key=$apikey"
$response = Invoke-WebRequest $apicall -UseBasicParsing

Write-Host ""
Write-Host "latitude = ${latitude}"
Write-Host "longitude = ${longitude}"

Write-Host "CONTENT : $response"
