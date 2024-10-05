Import-Module $PSScriptRoot\..\PSCopilot.Setup
Import-Module $PSScriptRoot\..\PSCopilot.Http

$script:activeThreadId = ""

function New-ThreadId {
    $result = Invoke-AzureOpenAIAPI -query "threads" -requestMethod "POST" -requestBody ""
    if ($result.Success -eq $true){
        return $result.Response.id
    }
    else{
        Write-Error "Failed to create a new thread"
        throw $result.ErrorMessage
    }
}

function Get-ActiveThreadId {
    if($script:activeThreadId -eq "" -or $script:activeThreadId -eq $null){
        $script:activeThreadId = New-ThreadId
    }

    return $script:activeThreadId
}

function Reset-ActiveThreadId {
    $script:activeThreadId = New-ThreadId
}

Export-ModuleMember -Function Get-ActiveThreadId, Reset-ActiveThreadId