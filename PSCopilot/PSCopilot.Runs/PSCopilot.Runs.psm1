Import-Module $PSScriptRoot\..\PSCopilot.Http
Import-Module $PSScriptRoot\..\PSCopilot.Functions

function New-Run{
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$threadId,

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$assistantId = (Get-AzureOpenAIAPIConfig["AssistantId"])
    )

    
    $result = Invoke-AzureOpenAIAPI `
    -query "threads/$threadId/runs" `
    -requestMethod "POST" `
    -requestBody "{`"assistant_id`":`"$assistantId`",`"tools`": null }"

    $result.Response.id
}

function Track-Run{
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$threadId,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$runId
    )

    $result = $null
    $cancel = $false
    do{
        Write-Host "Thinking..."
        Start-Sleep -Seconds 1
        
        $result = Invoke-AzureOpenAIAPI `
        -query "threads/$threadId/runs/$runId" `
        -requestMethod "GET"

        if($result.Success -eq $false){
            Write-Error "Failed to track the run"
            throw $result.ErrorMessage
        }

        Write-Debug "Run Status: $($result.Response.status)"
        # Check for function calls from ai model
        if($result.Response.status -eq "requires_action"){
            if($result.Response.required_action.type -ne "submit_tool_outputs"){
                Write-Host "Unexpected action required by assistant: $($result.Response.required_action.type)"
                # Cancel the run and break
                $cancel = $true
            }

            $toolOutputs = @()
            foreach ($tool_call in $result.Response.required_action.submit_tool_outputs.tool_calls)
            {
                Write-Debug "Tool Call: $($tool_call.id)"
                if ($tool_call.type -eq "function")
                {
                    $funcToCall = $tool_call.function.name
                    $arguments = $tool_call.function.arguments
                    $callId = $tool_call.id
                    $res = Handle_FunctionCall -funcToCall $funcToCall -arguments $arguments
                    $toolOutputs += @{
                        tool_call_id = $callId
                        output = $res
                    }
                }
            }
            Write-Debug "Submitting Tool Outputs: $($toolOutputs|ConvertTo-Json)"
            Submit-ToolOutputs -threadId $threadId -runId $runId -toolOutputs $toolOutputs
        }
        if($cancel -eq $true){
            # Run Cancellation
        }

    }while ($result.Response.status -notin @("cancelled", "failed", "completed", "expired"))

    if($result.Response.status -in @("completed")){
        return @{
            Success = $true
            Status = $result.Response.status
            Response = $result.Response
        }
    }
    else{
        return @{
            Success = $false
            Status = $result.Response.status
        }
    }
}

function Submit-ToolOutputs{
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$threadId,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$runId,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $toolOutputs
    )

    $jsonString = "[" + ($toolOutputs | ForEach-Object { $_ | ConvertTo-Json }) + "]"

    $result = Invoke-AzureOpenAIAPI `
    -query "threads/$threadId/runs/$runId/submit_tool_outputs" `
    -requestMethod "POST" `
    -requestBody "{`"tool_outputs`": $jsonString}"

    if($result.Success -eq $false){
        Write-Error "Failed to submit tool outputs"
        throw $result.ErrorMessage
    }
}