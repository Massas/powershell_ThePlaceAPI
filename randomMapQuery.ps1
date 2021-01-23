
$apikey="***********"

function getSign{
    $signseed = Get-Random
    $num = $signseed % 2

    if($num -eq 1){
        $ret ='-'
    }else {
        $ret = ''
    }
    return $ret
}

function getLatitude {
    $latitudeint = Get-Random -Maximum 90 -Minimum 0
    $sign = getSign
    $latradix = Get-Random -Maximum 999999 -Minimum 0
    $latitude = $sign + [string]$latitudeint + '.' + [string]$latradix

    return $latitude
}

function getLongitude {
    $longitudeint = Get-Random -Maximum 180 -Minimum 0
    $sign = getSign
    $latradix = Get-Random -Maximum 999999 -Minimum 0
    $longitude = $sign + [string]$longitudeint + '.' + [string]$latradix
    
    return $longitude
}

# main
$latitude = getLatitude
$longitude = getLongitude

$apicall="https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$latitude,$longitude&radius=1000&type=political&key=$apikey"
$response = Invoke-WebRequest $apicall -UseBasicParsing

Write-Host ""
Write-Host "latitude = ${latitude}"
Write-Host "longitude = ${longitude}"

Write-Host "CONTENT : $response"
