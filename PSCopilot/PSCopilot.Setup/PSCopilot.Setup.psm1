$script:AzureOpenAIAPIEndpoint = "https://prsaxeopenaieu2.openai.azure.com"
$script:AzureOpenAIAPIKey = ""
$script:PowershellCopilotAssistantId = "asst_iAr5zMLDwfPDjr2yEtgtlwVe"
$script:AzureOpenAIAPIVersion = "2024-02-15-preview"
function Get-AzureOpenAIAPIConfig{
    return @{
        Endpoint = $script:AzureOpenAIAPIEndpoint
        APIKey = $script:AzureOpenAIAPIKey
        AssistantId = $script:PowershellCopilotAssistantId
        APIVersion = $script:AzureOpenAIAPIVersion
    }
}

function Set-AzureOpenAIAPIConfig{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$Endpoint,

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$APIKey,
        
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$AssistantId,

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$APIVersion
    )

    if($Endpoint -ne ""){
        $script:AzureOpenAIAPIEndpoint = $Endpoint
    }
    if($APIKey -ne ""){
        $script:AzureOpenAIAPIKey = $APIKey
    }
    if ($AssistantId -ne ""){
        $script:PowershellCopilotAssistantId = $AssistantId
    }
    if ($APIVersion -ne ""){
        $script:AzureOpenAIAPIVersion = $APIVersion
    }
}