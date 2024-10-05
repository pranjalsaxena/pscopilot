Import-Module $PSScriptRoot\PSCopilot.Setup
Import-Module $PSScriptRoot\PSCopilot.Threads
Import-Module $PSScriptRoot\PSCopilot.Runs
Import-Module $PSScriptRoot\PSCopilot.Messages
Import-Module $PSScriptRoot\PSCopilot.Steps
Import-Module $PSScriptRoot\PSCopilot.Functions

function check_api_key_setup{
    if ("" -eq (Get-AzureOpenAIAPIConfig)["ApiKey"]){
        Write-Host "Need to set API Key before using PowerShell CoPilot."
        Write-Host "Please get the API Key from Key Vault prsaxe-kv.vault.azure.net and secretname `"PowerShellCopilotKey`""
        Write-Host "Please set the API Key using: Set-AzureOpenAIAPIConfig -APIKey <APIKey>"
        return $false
    }

    return $true
}

function Chat-PSCopilot {
    [CmdletBinding()]
    [alias("cop")]
    param(
        [Parameter(Mandatory=$false)]
        [string]$message = "Hello"
    )

    if(!(check_api_key_setup)){
        return
    }

    # Get AssistantId
    $assistantId = (Get-AzureOpenAIAPIConfig)["AssistantId"]

    # Get the active thread id
    $threadId = Get-ActiveThreadId
    Write-Debug "ThreadId: $threadId"

    # Add Message to the thread
    $userMessageId = Add-MessageToThread -threadId $threadId -message $message

    # Run Thread
    $runId = New-Run -threadId $threadId -assistantId $assistantId
    Write-Debug "RunId: $runId"

    # Check for Thread Status
    $result = Track-Run -threadId $threadId -runId $runId
    if ($result.Success -eq $false){
        Write-Host "Something Went Wrong! Please try again."
        return
    }

    # Get Run Steps
    $steps = Get-RunSteps -threadId $threadId -runId $runId

    # Get Message Creation Id
    $messageId = Get-MessageCreationId -steps $steps
    Write-Debug "MessageId: $messageId"

    if($null -ne $messageId){
        # Get Message
        $message = Get-MessageCreationMessage -threadId $threadId -messageId $messageId

        # Print the message
        Write-Host $message
    }
}

function Reset-PSCopilotThread{
    [CmdletBinding()]
    [alias("reset-chat")]
    [alias("rc")]
    param()

    if(!(check_api_key_setup)){
        return
    }

    # Reset the active thread id
    Reset-ActiveThreadId

    Write-Host "New Chat started with CoPilot."
}

function CopilotErrorHelper{
    [CmdletBinding()]
    [alias("ceh")]
    param()
    Chat-PSCopilot -message "Please explain the last error and provide a solution"
}