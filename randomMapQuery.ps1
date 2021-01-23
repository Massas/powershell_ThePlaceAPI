
$apikey="*****************"

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

function isLand($latitude, $longitude){
    Write-Host "[isLand]: start"
    [float]$lati = $latitude[0]
    [float]$longi = $latitude[1]
    Write-Host "latitude = $lati"
    Write-Host "longitude = $longi"

    $continentArr = @(
                    @(-43.500000,-11.500000,113.500000,153.000000,"Austraria"),
                    @(-47.000000,-36.000000,166.800000,178.400000,"Newzealand"),
                    @(-35.000000,36.600000,13.000000,50.800000,"Africa continent"),
                    @(35.000000,70.800000,42.400000,47.500000,"Europe continent"),
                    @(13.000000,47.000000,27.500000,66.000000,"Middle East"),
                    @(5.000000,75.000000,66.000000,144.000000,"Russia,China,and others"),
                    @(56.000000,71.000000,-167.000000,-62.000000,"Arasca"),
                    @(23.000000,59.000000,-136.000000,-55.000000,"USA"),
                    @(8.000000,23.000000,-105.000000,-66.000000,"Central America & carib"),
                    @(-55.000000,12.000000,-79.200000,-35.000000,"South America")
                );

    for($i = 0; $i -lt $continentArr.Count; $i++){
        if(($lati -gt $continentArr[$i][0]) -and ($lati -lt $continentArr[$i][1]) -and (($longi -gt $continentArr[$i][2]) -and ($longi -lt $continentArr[$i][3]))){
            $continent = $continentArr[$i][4]
            Write-Host "i: $i $continent"
            return $true
        }
    }
    Write-Host "[isLand]: end"
    return $false
}

function getLatiLong{
    $latilongArr = @()
    $latitude = getLatitude
    $longitude = getLongitude
    
    # check function: isLand? Or recursive call
    [bool]$land = isLand($latitude, $longitude) 
    if($land -eq $False){
        Write-Host "recursive call"
        Start-Sleep 3
        getLatiLong
    }
    $latilongArr += $latitude
    $latilongArr += $longitude

    return $latilongArr
}

# main
$arr = getLatiLong

[float]$latitude = $arr[0]
[float]$longitude = $arr[1]

Write-Host ""
Write-Host "latitude = ${latitude}"
Write-Host "longitude = ${longitude}"

$apicall="https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$latitude,$longitude&radius=50000&type=political&key=$apikey"
$response = Invoke-WebRequest $apicall -UseBasicParsing


Write-Host "CONTENT : $response"
