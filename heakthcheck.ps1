$endpointUri = "https://run.mocky.io/v3/c15b619c-104e-47db-b264-4077b095fc14" #### Change it to your API Health Status end-point
$response = (Invoke-RestMethod -Uri $endpointUri) 

function sendTeamMessage($TeamChannel) {

#send success and failure alerts to its dedicated channels based on failure
if ($TeamChannel -eq "success") {
$myTeamsWebHook = "<Your MS Team success channel Webhook URL>"
} else {
$myTeamsWebHook ="<Your MS Team falure channel Webhook URL>" 
}
 
$BodyTemplate = @"
    {
        "@type": "MessageCard",
        "@context": "https://schema.org/extensions",
        "summary": "API Health Status Summary",
        "themeColor": "D778D7",
        "title": "API Health Status Summary",
         "sections": [
            {
            
                "facts": [
                    {
                        "name": "Environment",
                        "value": "ENV"
                    },
                    {
                        "name": "Database:",
                        "value": "DB"
                    },
                    {
                        "name": "Fiserv:",
                        "value": "fiserv"
                    },
                    {
                        "name": "Zoot:",
                        "value": "zoot"
                    }
                ],
                "text": "API Status notification. Status API = STATUSAPI. "
            }
        ]
    }
"@

## Below you can find and replace the body contents 

        $body = $BodyTemplate.Replace("STATUSAPI","$endpointUri").Replace("ENV","$envHealth").Replace("DB","$dbHealth").Replace("fiserv","$fiservHealth").Replace("zoot","$zootHealth")
        Invoke-RestMethod -uri $myTeamsWebHook -Method Post -body $body -ContentType 'application/json'

}

$envHealth = $response.results.Env.status
$dbHealth = $response.results.Database.status
$fiservHealth = $response.results.Fiserv.status
$zootHealth = $response.results.Zoot.status

try {
	
if (($envHealth -eq "Healthy") -and ($dbHealth -eq "Healthy") -and ($fiservHealth -eq "Healthy") -and  ($zootHealth -eq "Healthy")) {
write-host "All are okay" -ForegroundColor green 
sendTeamMessage -TeamChannel "success"
}
else {
write-host "One of the Status failed" -ForegroundColor red 
sendTeamMessage -TeamChannel "failure"
}

}catch {
write-host "`n Health Check has been failed. Alerting to MS Team.`n" ` -ForegroundColor red
sendTeamMessage -TeamChannel "failure"
}

#riyasrawther.in@gmail.com
#https://wa.me/916238122062
 
