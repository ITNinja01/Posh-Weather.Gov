function Get-CurrentWeatherByZip {
    <#
.SYNOPSIS
This script will show the current weather information based off your zip code.
.DESCRIPTION
This script uses the ZIP Code information to fetch the longitude and latitude from the Zippopotam.us API, which is then used to query the Weather.Gov API for the current weather information.
.FUNCTIONALITY
API Calls, JSON, Terminal Output
.COMPONENT
Zippopotam.us, Weather.Gov API, PowerShell
.INPUTS
Zippopotam.us JSON response
.OUTPUTS
Weather.Gov JSON response
.EXAMPLE
Get-CurrentWeatherByZip
.NOTES
Developer: ITNinja01
Date: 07-05-2026
Version: 1.0.0
#>
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

    #Creating variables to access weather

    $APIWeatherURL = "https://api.weather.gov/points/$latitude,$longitude"
    $CurrentWeather = Invoke-RestMethod $APIWeatherURL

    # Get nearest observation station
    $stationUrl = $CurrentWeather.properties.observationStations

    $stations = Invoke-RestMethod -Uri $stationUrl
    $station = $stations.features[0].properties.stationIdentifier

    # Get latest observation
    $Observationervation   = Invoke-RestMethod -Uri "https://api.weather.gov/stations/$station/observations/latest"

    $CurrentTemperature = $Observation.properties.temperature.value
    $windSpeed = $Observation.properties.windSpeed.value

    #Math equation for finding Fahrenheit from Celsius degrees and converting wind speed from km/h to mph
    $ConvertedDegree = [math]::Round(($CurrentTemperature * 9) / 5 + 32, 2)
    $ConvertedWindSpeed = [math]::Round(($windSpeed * 0.621371), 2)
    
    $stationName = $Observation.properties.stationname
    $timestamp = $Observation.properties.timestamp
    $windDirection = $Observation.properties.windDirection.value
    $Description = $Observation.properties.textDescription   
    $WindCompass = '                     0° / 360°
                         N
                         |
                         |
             315° NW     |     NE 45°
                    \    |    /
                     \   |   /
                      \  |  /
270° W -----------------+----------------- E 90°
                      /  |  \
                     /   |   \
                    /    |    \
             225° SW     |     SE 135°
                         |
                         |
                         S
                       180°'

    #Carriage return to make it easier to read in the terminal
    $crlf = [Environment]::NewLine

    Write-Host "$crlf
$City, $Country Current Weather
Description: $Description
Current Temperature: $ConvertedDegree °F
Wind Speed: $ConvertedWindSpeed mph
WindDirection: $windDirection °
Observation Time: $timestamp
Weather Station: $stationName
$crlf
$WindCompass
"
}