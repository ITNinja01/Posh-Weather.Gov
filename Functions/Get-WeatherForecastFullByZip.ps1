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
Date: 02-16-2026
Version: 1.0.0
#>

    #Set TLS 1.2 for the API calls
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $ZipCode = Read-Host -Prompt "Please enter your ZIP Code?"

    $CountryFullName = Read-Host -Prompt "Please enter your country (e.g., US, CA, GB). Default is US if left blank."

    $CountryHashTable = @{
        'Andorra'                      = 'AD'
        'Argentina'                    = 'AR'
        'American Samoa'               = 'AS'
        'Austria'                      = 'AT'
        'Australia'                    = 'AU'
        'Bangladesh'                   = 'BD'
        'Belgium'                      = 'BE'
        'Bulgaria'                     = 'BG'
        'Brazil'                       = 'BR'
        'Canada'                       = 'CA'
        'Switzerland'                  = 'CH'
        'Czech Republic'               = 'CZ'
        'Germany'                      = 'DE'
        'Denmark'                      = 'DK'
        'Dominican Republic'           = 'DO'
        'Spain'                        = 'ES'
        'Finland'                      = 'FI'
        'Faroe Islands'                = 'FO'
        'France'                       = 'FR'
        'Great Britain'                = 'GB'
        'French Guyana'                = 'GF'
        'Guernsey'                     = 'GG'
        'Greenland'                    = 'GL'
        'Guadeloupe'                   = 'GP'
        'Guatemala'                    = 'GT'
        'Guam'                         = 'GU'
        'Guyana'                       = 'GY'
        'Croatia'                      = 'HR'
        'Hungary'                      = 'HU'
        'Isle of Man'                  = 'IM'
        'India'                        = 'IN'
        'Iceland'                      = 'IS'
        'Italy'                        = 'IT'
        'Jersey'                       = 'JE'
        'Japan'                        = 'JP'
        'Liechtenstein'                = 'LI'
        'Sri Lanka'                    = 'LK'
        'Lithuania'                    = 'LT'
        'Luxembourg'                   = 'LU'
        'Monaco'                       = 'MC'
        'Moldavia'                     = 'MD'
        'Marshall Islands'             = 'MH'
        'Macedonia'                    = 'MK'
        'Northern Mariana Islands'     = 'MP'
        'Martinique'                   = 'MQ'
        'Mexico'                       = 'MX'
        'Malaysia'                     = 'MY'
        'Holland'                      = 'NL'
        'Norway'                       = 'NO'
        'New Zealand'                  = 'NZ'
        'Phillippines'                 = 'PH'
        'Pakistan'                     = 'PK'
        'Poland'                       = 'PL' 
        'Saint Pierre and Miquelon'    = 'PM'
        'Puerto Rico'                  = 'PR'
        'Portugal'                     = 'PT'
        'French Reunion'               = 'RE'
        'Russia'                       = 'RU'
        'Sweden'                       = 'SE'
        'Slovenia'                     = 'SI'
        'Svalbard & Jan Mayen Islands' = 'SJ'
        'Slovak Republic'              = 'SK'
        'San Marino'                   = 'SM'
        'Thailand'                     = 'TH'
        'Turkey'                       = 'TR'
        'Vatican'                      = 'VA'
        'Virgin Islands'               = 'VI'
        'Mayotte'                      = 'YT'
        'South Africa'                 = 'ZA'
        'United States'                = 'US'
        'USA'                          = 'US'
        'US'                           = 'US'
    }  
    if ($CountryHashTable.ContainsKey($CountryFullName)) {
        $Country = $CountryHashTable[$CountryFullName]
    }
    else {
        Write-Host "Country not recognized or not provided. Defaulting to 'US'."
        $Country = 'US'
    }

    $URI = "https://api.zippopotam.us/$Country/$ZipCode"

    # Try/Catth is not working. Look into the status code from Zippopotam.us.
    try {
        Invoke-WebRequest -Uri $URI -ErrorAction Stop | Out-Null
        Write-Host "ZIP Code not found. Please check the ZIP Code and try again."  
        $LASTEXITCODE = 1
        # Exit
    }
    catch {
        Write-Host "ZIP Code found. Fetching weather data..."
        
    }

    $response = Invoke-RestMethod -Uri $URI

    #Extracts city, country, latitude and longitude from the response
    $latitude = $response.places.latitude
    $longitude = $response.places.longitude
    $City = $response.places.'place name'

    Write-Host "$City, $Country Forecast"

    #Creating variables to access weather

    $APIWeatherURL = "https://api.weather.gov/points/$latitude,$longitude"
    $FullWeather = Invoke-RestMethod $APIWeatherURL

    Write-Host "Latest:"
    (Invoke-RestMethod ($FullWeather.properties.forecast)).Properties.periods | Select-Object Name, detailedForecast, temperature, probabilityOfPrecipitation, windSpeed, windDirection | Out-Default

    #Carriage return to make it easier to read in the terminal
    $crlf = [Environment]::NewLine
    $crlf

    Write-Host "The next week:"
    (Invoke-RestMethod ($FullWeather.properties.forecast)).Properties.periods | Select-Object name, temperature, shortForecast, windSpeed | Out-Default

    Write-Host "The next 24 hours:"
    $HourlyWeather = (Invoke-RestMethod ($FullWeather.properties.forecastHourly)).Properties.periods | Select-Object startTime, endTime, temperature, probabilityOfPrecipitation, dewpoint, windSpeed, windDirection, relativeHumidity 
    $HourlyWeather[0..23]
}