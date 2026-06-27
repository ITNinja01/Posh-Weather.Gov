function Get-CurrentWeatherByIP {
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
Date: 06-27-2026
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
    $obs = Invoke-RestMethod -Uri "https://api.weather.gov/stations/$station/observations/latest"

    $CurrentTemperature = $obs.properties.temperature.value

    #Math equation for finding Fahrenheit from Celsius degrees
    $ConvertedDegree = [math]::Round(($CurrentTemperature * 9) / 5 + 32, 2)

    $stationName = $obs.properties.stationname
    $timestamp = $obs.properties.timestamp
    $windDirection = $obs.properties.windDirection.value
    $windSpeed = $obs.properties.windSpeed.value

    #Carriage return to make it easier to read in the terminal
    $crlf = [Environment]::NewLine

    Write-Host "$crlf
$City, $Country Current Weather
Current Temperature: $ConvertedDegree °F
Wind Speed: $windSpeed m/s
WindDirection: $windDirection °
Observation Time: $timestamp
Weather Station: $stationName
$crlf
"
}