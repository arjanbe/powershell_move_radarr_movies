$APIkey = "b7a899eb920043efa501ca508d9a00be"
$RadarrURL = "http://192.168.1.50:7878"
$MovieRootFolder = "N:\grpdata\Video\__Nieuw"

$Counter = 0

# Fetch all movies from Radarr
$Movies = Invoke-RestMethod -Uri "$RadarrURL/api/v3/movie?apikey=$APIkey" 

ForEach ($Movie in $Movies)
{
    Write-Progress -Activity "Processing all movies" -Status "Checking on $($Movie.title)" -PercentComplete ($Counter / $Movies.Count * 100)
    $Counter += 1
    # ForEach movie check if it has a movie file
    If ($Movie.hasFile)
    {
        # If there is a movie file, is it already in the correct folder. genres[0] is the first genre in the list.
        If ($Movie.path -like "$MovieRootFolder\_$($Movie.genres[0])*")
        {
            # movie is alreay in the right folder. nothing todo
            Write-Host "Processing: $($Movie.Title) with movieid $($Movie.id) is in _$($Movie.genres[0])" -ForegroundColor Green
        }
        Else
        {
            # movie needs to be moved to the new location using the API
            Write-Host "Processing: $($Movie.Title) with movieid $($Movie.id) and moving it to _$($Movie.genres[0])" -ForegroundColor Yellow
            $Data = @{
                movieIds = @($Movie.id)
                moveFiles = $True
                rootFolderPath = "$MovieRootFolder\_$($Movie.genres[0])"
            }
            $json = $data | ConvertTo-Json;
            $Result = Invoke-RestMethod -Method PUT -Uri "$RadarrURL/api/v3/movie/editor?apikey=$APIkey" -ContentType "application/json" -Body $json
        }
    }
    Else
    {
        # Movie is not ready to be moved.
        Write-Host "Processing: $($Movie.Title) with movieid $($Movie.id) is not complete" -ForegroundColor Gray
    }
}