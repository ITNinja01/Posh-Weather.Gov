function Get-WeatherForecastShortByZip {
    <#
.SYNOPSIS
This script will show the weather forecast for now, next week of time and next 8 hours based off your public IP.
.DESCRIPTION
This script uses the public IP information from Ipinfo.io to feed the longitude and latitude to the Weather.Gov API which than receives the forecast.
.FUNCTIONALITY
API Calls, JSON, Terminal Output
.COMPONENT
Weather.Gov API, PowerShell
.INPUTS
Zippopotam.us JSON response, Weather.Gov API
.OUTPUTS
Weather.Gov JSON response
.EXAMPLE
Get-WeatherForecastShortByZip
.NOTES
Developer: ITNinja01
Date: 04-05-2026
Version: 1.0.0
#>

    #Set TLS 1.2 for the API calls
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $ZipCode = Read-Host -Prompt "Please enter your ZIP Code, if you are in the United States?"

    $CountryFullName = Read-Host -Prompt "Please enter your country (e.g., US, CA, GB), or press Enter to auto-detect"

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
    
    # Check if the ZIP Code is valid by checking the status code of the response. If it's 200, the ZIP Code is valid. If not, it will show an error message and exit the function.   
    $WebResponse = Invoke-WebRequest -Uri $URI -Method Get -ErrorAction SilentlyContinue

    if ($WebResponse.StatusCode -eq 200) {
        Write-Host "ZIP Code found. Fetching weather data..."
    }
    else {
        Write-Host "ZIP Code not found. Please check the ZIP Code and try again." -ForegroundColor Red
        $LASTEXITCODE = 1
        return
    }

    #Extracts city, country, latitude and longitude from the response
    $response = Invoke-RestMethod  -Uri $URI
    $latitude = $response.places.latitude
    $longitude = $response.places.longitude
    $City = $response.places.'place name'

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