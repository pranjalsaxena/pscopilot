Import-Module $PSScriptRoot\..\PSCopilot.Http

function Find-MessageCreationStep{
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $steps
    )

    $steps | Where-Object { $_.step_details.type -eq "message_creation" }
}

function Get-MessageCreationId{
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $steps
    )

    (Find-MessageCreationStep -steps $steps).step_details.message_creation.message_id
}

function Add-MessageToThread{
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$threadId,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$message
    )

    $result = Invoke-AzureOpenAIAPI `
    -query "threads/$threadId/messages" `
    -requestMethod "POST" `
    -requestBody "{`"role`":`"user`",`"content`":`"$message`", `"file_ids`": []}"

    if ($result.Success -eq $true){
        return $result.Response.id
    }
    else{
        Write-Error "Failed to add message to thread"
        throw $result.ErrorMessage
    }
}

function Get-MessageCreationMessage{
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $threadId,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $messageId
    )

    $result = Invoke-AzureOpenAIAPI `
    -query "threads/$threadId/messages/$messageId" `
    -requestMethod "GET" `

    if ($result.Success -eq $true){
        return $result.Response.content[0].text.value
    }
    else{
        Write-Error "Failed to get message content"
        throw $result.ErrorMessage
    }
}

Export-ModuleMember -Function Add-MessageToThread, Get-MessageCreationId, Get-MessageCreationMessage