Import-Module $PSScriptRoot\..\PSCopilot.Http

function Get-RunSteps{
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$threadId,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$runId
    )

    $result = Invoke-AzureOpenAIAPI `
    -query "threads/$threadId/runs/$runId/steps" `
    -requestMethod "GET"

    if($result.Success -eq $false){
        Write-Error "Failed to get run steps"
        throw $result.ErrorMessage
    }

    $result.Response.data
}