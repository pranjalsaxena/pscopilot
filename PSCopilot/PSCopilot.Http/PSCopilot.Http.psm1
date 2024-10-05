#Requires -Version 3.0

Import-Module $PSScriptRoot\..\PSCopilot.Setup

function Invoke-AzureOpenAIAPI{
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$query, #todo - change its name to api path

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$requestMethod,

        [Parameter(Mandatory=$false)]
        $requestBody = $null
    )

    $aoaiconfigs = Get-AzureOpenAIAPIConfig
    $uri = $aoaiconfigs["Endpoint"] + "/openai/" + $query + "?api-version=" + $aoaiconfigs["APIVersion"]

    try{
        $response = Invoke-RestMethod `
        -Uri $uri `
        -Method $requestMethod `
        -Headers @{ "content-type" = "application/json"; "api-key" = $aoaiconfigs["APIKey"] } `
        -Body $requestBody

         # Return success status and response
         return @{
            Success = $true
            Response = $response
        }
    }
    catch{
        return @{
            Success = $false
            ErrorMessage = $_.Exception.Message
        }
    }
}

Export-ModuleMember -Function Invoke-AzureOpenAIAPI