
$apikey="**********************"

# result continent name this time
$result_continent_name = $null
# array that result continent name(five times)
$result_continent_arr = @()
$tmp_continent_arr = @()

# default Place Type
$placetype = "political" 

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
#    Write-Host "latitude = $lati"
#    Write-Host "longitude = $longi"

    $continentArr = @(
                    @(-43.500000,-11.500000,113.500000,153.000000,"Austraria"),
                    @(-47.000000,-36.000000,166.800000,178.400000,"Newzealand"),
                    @(-35.000000,36.600000,13.000000,50.800000,"Africa continent"),
                    @(33.000000,70.800000,-13.000000,61.000000,"Europe continent"),
                    @(13.000000,47.000000,27.500000,66.000000,"Middle East"),
                    @(5.000000,75.000000,66.000000,144.000000,"Russia,China,and others"),
                    @(56.000000,71.000000,-167.000000,-62.000000,"Arasca"),
                    @(23.000000,59.000000,-136.000000,-55.000000,"USA"),
                    @(8.000000,23.000000,-105.000000,-66.000000,"Central America & carib"),
                    @(-55.000000,12.000000,-79.200000,-35.000000,"South America")
                );

    for($i = 0; $i -lt $continentArr.Count; $i++){
        if(($lati -gt $continentArr[$i][0]) -and ($lati -lt $continentArr[$i][1]) -and (($longi -gt $continentArr[$i][2]) -and ($longi -lt $continentArr[$i][3]))){

            # save in a global scope variable
            $Global:result_continent_name = $continentArr[$i][4]

            Write-Host "$Global:result_continent_name"

#            Write-Host "i: $i $continent"
            Write-Host "[isLand]: end(true)"
            return $true
        }
    }
    Write-Host "[isLand]: end(false)"
    return $false
}

function isCorrespond($str){
#    Write-Host "[isCorrespond]: start"
#    Write-Host "str:$str"
    $continentName = $str

#    Write-Host "result_continent_arr: $result_continent_arr"

    if($result_continent_arr -contains $continentName){
#        Write-Host "[isCorrespond]: end(false)"
        return $false
    }
#    Write-Host "[isCorrespond]: end(true)"
    return $true
}

function getLatiLong{
    $latilongArr = @()
    $latitude = getLatitude
    $longitude = getLongitude
    
    # check function: isLand? Or recursive call
    [bool]$land = isLand($latitude, $longitude) 
    if($land -eq $False){
#        Write-Host "recursive call"
#        Start-Sleep 1
        getLatiLong
    }

    # check the continent name whether correspond with past five times' result
#    Write-Host "result_continent_name: $result_continent_name"
    [bool]$correspond = isCorrespond($Global:result_continent_name)
    if($correspond -eq $False){
#        Write-Host "recursive call"
#        Start-Sleep 1
        getLatiLong
    }

    $latilongArr += $latitude
    $latilongArr += $longitude

    return $latilongArr
}

function getLatiLongMain{
    $arr = getLatiLong

    [float]$latitude = $arr[0]
    [float]$longitude = $arr[1]
    
#    Write-Host ""
#   Write-Host "latitude = ${latitude}"
#    Write-Host "longitude = ${longitude}"
    
    
    $apicall="https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$latitude,$longitude&radius=50000&type=$placetype&key=$apikey"
    $response = Invoke-WebRequest $apicall -UseBasicParsing
    
    if($response -match "ZERO_RESULTS"){
#        Write-Host "recursive call(ZERO_RESULTS)"
#        Start-Sleep 1
        $response = $null
        getLatiLongMain
    }

    if ($Global:result_continent_arr.Count -eq 5) {
        $Global:tmp_continent_arr = $Global:result_continent_arr[1..($Global:result_continent_arr.Count - 1)]
        $Global:result_continent_arr = $null
        $Global:result_continent_arr = $Global:tmp_continent_arr
    }
    $Global:result_continent_arr += $result_continent_name
#    Write-Host "result_continent_arr:$result_continent_arr"
    $Global:result_continent_name = $null

    return $response
}

function find_geometry($str){
    $Index = $str.IndexOf('geometry')
#    Write-Host "Index: $Index"
    $tmp1 = $str.Substring($Index,$str.Length - $Index - 1)

    return $tmp1
}

function find_location($str) {
    $Index = $str.IndexOf('location')
    $Index_end = $str.IndexOf('}')
#    Write-Host "Index: $Index Index_end: $Index_end"
    $tmp1 = $str.Substring($Index, $Index_end - $Index - 1)

    Write-Host $tmp1
    $Global:result_str_arr += $tmp1

    $tmp2 = $str.Substring($Index_end ,$str.Length - $Index_end - 1)

    return $tmp2
}

function find_name($str) {
    $Index = $str.IndexOf('name')
    $tmpstr = $str.Substring($Index, $str.Length - $Index - 1)
    $Index_end = $tmpstr.IndexOf(',')
#    Write-Host "Index: $Index Index_end: $Index_end"
    $tmp1 = $str.Substring($Index, $Index_end)

    Write-Host $tmp1
    $Global:result_str_arr += ($tmp1 + "`n")

    return
}

# parse and write to file
function parse_write($str){

    while($str.IndexOf('geometry') -ne -1){
#        Write-host "found geometry"
        $tmp1 = find_geometry($str)

        $strtmp = $tmp1
        $tmp1 = find_location($strtmp)

        find_name($tmp1)

#        Write-Host "tmp1" $tmp1
        $str = $tmp1.Substring(1,$tmp1.Length - 1)
    }

}

function Select-PlaceType{

    $placetype_arr = @("political",
                        "locality",
                        "administrative_area_level_1",
                        "administrative_area_level_2",
                        "administrative_area_level_3",
                        "administrative_area_level_4",
                        "church",
                        "university",
                        "hindu_temple",
                        "stadium",
                        "mosque",
                        "lodging",
                        "premise",
                        "point_of_interest",
                        "sublocality",
                        "natural_feature")

    $Font = New-Object System.Drawing.Font("Meiryo UI",12)
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Select"
    $form.Size = New-Object System.Drawing.Size(600,450)
    $form.StartPosition = "Manual"
    $form.font = $Font

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10,10)
    $label.Size = New-Object System.Drawing.Size(500,40)
    $label.Text = "place type settings"
    $form.Controls.Add($label)

    $OKButton = New-Object System.Windows.Forms.Button
    $OKButton.Location = New-Object System.Drawing.Point(40,100)
    $OKButton.Size = New-Object System.Drawing.Size(75,30)
    $OKButton.Text = "OK"
    $OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $OKButton
    $form.Controls.Add($OKButton)

    $CancelButton = New-Object System.Windows.Forms.Button
    $CancelButton.Location = New-Object System.Drawing.Point(130,100)
    $CancelButton.Size = New-Object System.Drawing.Size(75,30)
    $CancelButton.Text = "Cancel"
    $CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $CancelButton
    $form.Controls.Add($CancelButton)

    $Combo = New-Object System.Windows.Forms.Combobox
    $Combo.Location = New-Object System.Drawing.Point(50,50)
    $Combo.size = New-Object System.Drawing.Size(500,60)
    $Combo.DropDownStyle = "DropDown"
    $Combo.FlatStyle = "standard"
    $Combo.font = $Font

    # Add an array item to the combo box
    ForEach ($select in $placetype_arr){
        [void] $Combo.Items.Add("$select")
    }

    $form.Controls.Add($Combo)
    $form.Topmost = $True
    $result = $form.ShowDialog()

    if ($result -eq "OK")
    {
        $ret = $combo.Text
    }else{
        return
    }

    Write-Host "[selected]: $ret"

    return $ret
}

# global variables
$Global:result_str_arr = @()
$Global:result_str_arr += "======================`n"

#main
# Loading an assembly
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$Global:result_str_arr -replace '"', '' | Add-Content "./result.log" -Encoding Default

while ($true) {
    Write-Host ""
    Write-Host "[[MAIN FUNCTION]]"
    Write-Host "mode is below."
    Write-Host "search places : ENTER"
    Write-Host "place type setting : s"
    Write-Host "quit : q"
    Write-Host ""

    $select = Read-Host "<<MODE SELECT>>"
    if(($select -eq 's') -or ($select -eq 'S')){
        # place type setting
        # sample : set amusement_park
        $placetype = Select-PlaceType
        continue
    }elseif(($select -eq 'q') -or ($select -eq 'Q')){
        Write-Host "terminate this program"
        Start-Sleep 1
        return
    }else{
        # global variables
        $Global:result_str_arr = $null
        $Global:result_str_arr += "======================`n"

        $response = getLatiLongMain

        # parse and write to file
        parse_write([string]$response)

        $Global:result_str_arr -replace '"', '' | Add-Content "./result.log" -Encoding Default

        continue
    }
}

