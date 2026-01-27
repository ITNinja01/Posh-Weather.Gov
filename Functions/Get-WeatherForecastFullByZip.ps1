function Get-WeatherForecastFullByZip {
    <#
.SYNOPSIS
This script will show the weather forecast for now, next week of time and next 24 hours based off your ZIP Code.
.DESCRIPTION
This script uses the ZIP Code information from Zippopotam.us to feed the longitude and latitude to the Weather.Gov API which than receives the forecast.
.FUNCTIONALITY
API Calls, JSON, Terminal Output
.COMPONENT
Weather.Gov API, PowerShell
.INPUTS
Zippopotam.us
.OUTPUTS
Weather.Gov JSON response
.EXAMPLE
Get-WeatherForecastFullByIP
.NOTES
Developer: ITNinja01  
Date: 01-24-2026
Version: 1.0.0
#>

    #Set TLS 1.2 for the API calls
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls13

    $ZipCode = Read-Host -Prompt "Please enter your ZIP Code, if you are in the United States?"

    $response = Invoke-RestMethod  -Uri "api.zippopotam.us/us/$ZipCode"

    $CountryHashTable = @{
        'Andorra'                      = { $Country = 'AD' }
        'Argentina'                    = { $Country = 'AR' }
        'American Samoa'               = { $Country = 'AS' }
        'Austria'                      = { $Country = 'AT' }
        'Australia'                    = { $Country = 'AU' }
        'Bangladesh'                   = { $Country = 'BD' }
        'Belgium'                      = { $Country = 'BE' }
        'Bulgaria'                     = { $Country = 'BG' }
        'Brazil'                       = { $Country = 'BR' }
        'Canada'                       = { $Country = 'CA' }
        'Switzerland'                  = { $Country = 'CH' }
        'Czech Republic'               = { $Country = 'CZ' }
        'Germany'                      = { $Country = 'DE' }
        'Denmark'                      = { $Country = 'DK' }
        'Dominican Republic'           = { $Country = 'DO' }
        'Spain'                        = { $Country = 'ES' }
        'Finland'                      = { $Country = 'FI' }
        'Faroe Islands'                = { $Country = 'FO' }
        'France'                       = { $Country = 'FR' }
        'Great Britain'                = { $Country = 'GB' }
        'French Guyana'                = { $Country = 'GF' }
        'Guernsey'                     = { $Country = 'GG' }
        'Greenland'                    = { $Country = 'GL' }
        'Guadeloupe'                   = { $Country = 'gp' }
        'Guatemala'                    = { $Country = 'GT' }
        'Guam'                         = { $Country = 'GU' }
        'Guyana'                       = { $Country = 'GY' }
        'Croatia'                      = { $Country = 'HR' }
        'Hungary'                      = { $Country = 'HU' }
        'Isle of Man'                  = { $Country = 'IM' }
        'India'                        = { $Country = 'IN' }
        'Iceland'                      = { $Country = 'IS' }
        'Italy'                        = { $Country = 'IT' }
        'Jersey'                       = { $Country = 'JE' }
        'Japan'                        = { $Country = 'JP' }
        'Liechtenstein'                = { $Country = 'LI' }
        'Sri Lanka'                    = { $Country = 'LK' }
        'Lithuania'                    = { $Country = 'LT' }
        'Luxembourg'                   = { $Country = 'LU' }
        'Monaco'                       = { $Country = 'MC' }
        'Moldavia'                     = { $Country = 'MD' }
        'Marshall Islands'             = { $Country = 'MH' }
        'Macedonia'                    = { $Country = 'MK' }
        'Northern Mariana Islands'     = { $Country = 'MP' }
        'Martinique'                   = { $Country = 'MQ' }
        'Mexico'                       = { $Country = 'MX' }
        'Malaysia'                     = { $Country = 'MY' }
        'Holland'                      = { $Country = 'NL' }
        'Norway'                       = { $Country = 'NO' }
        'New Zealand'                  = { $Country = 'NZ' }
        'Phillippines'                 = { $Country = 'PH' }
        'Pakistan'                     = { $Country = 'PK' }
        'Poland'                       = { $Country = 'PL' } 
        'Saint Pierre and Miquelon'    = { $Country = 'PM' }
        'Puerto Rico'                  = { $Country = 'PR' }
        'Portugal'                     = { $Country = 'PT' }
        'French Reunion'               = { $Country = 'RE' }
        'Russia'                       = { $Country = 'RU' }
        'Sweden'                       = { $Country = 'SE' }
        'Slovenia'                     = { $Country = 'SI' }
        'Svalbard & Jan Mayen Islands' = { $Country = 'SJ' }
        'Slovak Republic'              = { $Country = 'SK' }
        'San Marino'                   = { $Country = 'SM' }
        'Thailand'                     = { $Country = 'TH' }
        'Turkey'                       = { $Country = 'TR' }
        'Vatican'                      = { $Country = 'VA' }
        'Virgin Islands'               = { $Country = 'VI' }
        'Mayotte'                      = { $Country = 'YT' }
        'South Africa'                 = { $Country = 'ZA' }
        'United States'                = { $Country = 'US' }
        'USA'                          = { $Country = 'US' }
        'US'                           = { $Country = 'US' }
    }  


    #Extracts city, country, latitude and longitude from the response
    $latitude = $response.places.latitude
    $longitude = $response.places.longitude
    $City = $response.places.'place name'

    Write-Host "$City, $Country Forecast"

    #Creating variables to access weather

    $APIWeatherURL = "https://api.weather.gov/points/$latitude,$longitude"
    $FullWeather = Invoke-RestMethod $APIWeatherURL

    Write-Host "Latest:"
    (Invoke-RestMethod ($FullWeather.properties.forecast)).Properties.periods | Select-Object Name, detailedForecast, temperature, probabilityOfPrecipitation, windSpeed, windDirection |  Out-Default

    #Carriage return to make it easier to read in the terminal
    $crlf = [Environment]::NewLine
    $crlf

    Write-Host "The next week:"
    (Invoke-RestMethod ($FullWeather.properties.forecast)).Properties.periods | Select-Object name, temperature, shortForecast, windSpeed | Out-Default

    Write-Host "The next 24 hours:"
    $HourlyWeather = (Invoke-RestMethod ($FullWeather.properties.forecastHourly)).Properties.periods | Select-Object startTime, endTime, temperature, probabilityOfPrecipitation, dewpoint, windSpeed, windDirection, relativeHumidity 
    $HourlyWeather[0..23]
}