function Get-WeatherForecastShortByIP {
<#
.SYNOPSIS
This script will show the weather forecast for now, next week of time and next 8 hours based off your public IP.
.DESCRIPTION
This script uses the public IP information from Ipinfo.io to feed the longitude and latitude to the Weather.Gov API which than receives the forecast.
.FUNCTIONALITY
API Calls, JSON, Terminal Output
.COMPONENT
Ipinfo.io, Weather.Gov API, PowerShell
.INPUTS
Ipinfo.io JSON response
.OUTPUTS
Weather.Gov JSON response
.EXAMPLE
Get-WeatherForecastShortIP
.NOTES
Developer: ITNinja01
Date: 01-10-2025
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
Write-Host "$City, $Country Forecast"

#Creating variables to access weather

$APIWeatherURL = "https://api.weather.gov/points/$latitude,$longitude"
$FullWeather = Invoke-RestMethod $APIWeatherURL

Write-Host "Latest:"
(Invoke-RestMethod ($FullWeather.properties.forecast)).Properties.periods | Select-Object name, detailedForecast -First 1 -ExpandProperty detailedForecast | Out-Default

#Carriage return to make it easier to read in the terminal
    $crlf = [Environment]::NewLine
$crlf

Write-Host "The next week:"
(Invoke-RestMethod ($FullWeather.properties.forecast)).Properties.periods | Select-Object name, temperature, shortForecast, windSpeed | Out-Default

Write-Host "The next 8 hours:"
$HourlyWeather = (Invoke-RestMethod ($FullWeather.properties.forecastHourly)).Properties.periods | Select-Object startTime, endTime, temperature, probabilityOfPrecipitation
$HourlyWeather[0..7]
}