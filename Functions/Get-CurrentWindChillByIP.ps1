function Get-CurrentWindChillByIP {
    <#
.SYNOPSIS
This script will show the current weather information based off your public IP.
.DESCRIPTION
This script uses the public IP information from Ipinfo.io to feed the longitude and latitude to the Weather.Gov API which than receives the current weather information.
.FUNCTIONALITY
API Calls, JSON, Terminal Output
.COMPONENT
Ipinfo.io, Weather.Gov API, PowerShell
.INPUTS
Ipinfo.io JSON response
.OUTPUTS
Weather.Gov JSON response
.EXAMPLE
Get-CurrentWeatherByIP
.NOTES
Developer: ITNinja01
Date: 07-03-2026
Version: 1.0.0
#>

    #Making a request to a public IP information service 
    $response = Invoke-RestMethod -Uri "http://ipinfo.io/json"

    #Extracts city, country, latitude and longitude from the response
    $location = $response.loc -split ","
    $latitude = $location[0]
    $longitude = $location[1]
    $City = $response.city
    $Country = $response.country

    #Creating variables to access weather

    $APIWeatherURL = "https://api.weather.gov/points/$latitude,$longitude"
    $CurrentWeather = Invoke-RestMethod $APIWeatherURL

    # Get nearest observation station
    $stationUrl = $CurrentWeather.properties.observationStations

    $stations = Invoke-RestMethod -Uri $stationUrl
    $station = $stations.features[0].properties.stationIdentifier

    # Get latest observation
    $Observation = Invoke-RestMethod -Uri "https://api.weather.gov/stations/$station/observations/latest"

    $WindChill = $Observation.properties.WindChill.value

    #Math equation for finding Fahrenheit from Celsius degrees and converting wind speed from km/h to mph
    $ConvertedDegree = [math]::Round(($WindChill * 9) / 5 + 32, 2)

    
    $stationName = $Observation.properties.stationname
    $timestamp = $Observation.properties.timestamp


    #Carriage return to make it easier to read in the terminal
    $crlf = [Environment]::NewLine

    Write-Host "$crlf
$City, $Country Current Weather
Current Temperature: $ConvertedDegree °F
Observation Time: $timestamp
Weather Station: $stationName
$crlf

"
}