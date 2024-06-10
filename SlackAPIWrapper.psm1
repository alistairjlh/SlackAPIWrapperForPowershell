class SlackAPIWrapper {

    hidden [string]$token   
    
    $Limiters = @{} 

    SlackAPIWrapper($token) {
        
        $this.token = $token

        $this.Limiters.Add("chat.postMessage", [SlackAPILimiter]::new([SlackRateLimits]::MessagePosting) )
        
    }

    static [System.Collections.Specialized.NameObjectCollectionBase]NewQuery() {
        return  [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
    }

    [System.Object] SendCommand  (
        [string]$command,
        [System.Collections.Specialized.NameObjectCollectionBase]$query 
    ) {

        $this.limiter($command)
    
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Content-Type", "application/x-www-form-urlencoded")
        $headers.Add("Authorization", "Bearer $($this.token)")
    
        $multipartContent = [System.Net.Http.MultipartFormDataContent]::new()
        $body = $multipartContent

        $uriRequest = [System.UriBuilder]"https://slack.com/api/$command"
        $uriRequest.Query = $query.ToString()

        $response = Invoke-RestMethod $uriRequest.Uri.OriginalString -Method 'GET' -Headers $headers -Body $body

        return $response  
    
    }

    hidden limiter([string]$commandText) {  

        $limiter = $this.Limiters[$commandText]

        if ($limiter -eq $null) {

            $limiter = [SlackAPILimiter]::new([SlackRateLimits]::Tier3)
            $this.Limiters.Add($commandText, $limiter )

        }
   
        do {

            if ($limiter.transmissionTimer.Elapsed.TotalSeconds -ge $limiter.SecondsPerInterval  ) {

                $limiter.transmissionCount = 0
                $limiter.transmissionTimer.Restart()

            }
   
        }while ($limiter.transmissionCount -gt $limiter.maxTransmissionsPer)

        $limiter.transmissionCount++

    }

}

class SlackAPILimiter {

    SlackAPILimiter ([SlackRateLimits]$slackRateLimit) {

        $this.TierName = $slackRateLimit

        switch ($this.Interval) {
            "Minute" { $this.SecondsPerInterval = 60 }
            "Second" { $this.SecondsPerInterval = 1 } 
        }

        switch ($slackRateLimit) {
            Tier1 {
                $this.MaxTransmissionsPer = 1
                $this.Interval = "Minute"     
            }
            Tier2 {
                $this.MaxTransmissionsPer = 20
                $this.Interval = "Minute"     
            }
            Tier3 {
                $this.MaxTransmissionsPer = 50
                $this.Interval = "Minute"     
            }
            Tier4 {
                $this.MaxTransmissionsPer = 100
                $this.Interval = "Minute"     
            }
            MessagePosting {
                $this.MaxTransmissionsPer = 1
                $this.Interval = "Second"  
            }  
            Default {
                $this.MaxTransmissionsPer = 50
                $this.Interval = "Minute"                
            }
        }
        
    }

    [SlackRateLimits]$TierName
    [int]$MaxTransmissionsPer = 50
    [string]$Interval = "Minute"
    [int]$TransmissionCount = 0;
    [int]$SecondsPerInterval = 60
    [System.Diagnostics.Stopwatch]$TransmissionTimer = [System.Diagnostics.Stopwatch]::StartNew()
    
}

enum SlackRateLimits{

    Tier1 
    Tier2 
    Tier3 
    Tier4 
    MessagePosting

}