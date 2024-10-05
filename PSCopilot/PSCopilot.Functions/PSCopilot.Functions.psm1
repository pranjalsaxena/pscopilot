function run_powershell{
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$command
    )

    Write-Host "May I run the following powershell command:`n$command"
    Write-Host "Enter 'y' to confirm or 'n' to cancel:"
    $userChoice = Read-Host
    if($userChoice -ne "y"){
        return "The user denied the request to run the command."
    }
    else{
        try{
            $cmdRes = (Invoke-Expression $command|Out-String)
            if ((($cmdRes -split '\n').length -gt 2) -or (($cmdRes -split ' ').length -gt 5)){
            Write-Host $cmdRes
                return "The user accepted the request to run the command. The command has been executed successfully. The output of the command has already been printed on user's console. Hence not providing the output here."
            }
            else {
                return "The user accepted the request to run the command. But the output is not printed on user's console. Here is the output:`n$cmdRes"
            }
        }
        catch{
            Write-Error "Error: $_"
            return "The command has failed to execute, with error: $_"
        }
    }
}

function get_last_error{
    Write-Debug "Inside Get Last Error Function"
    Write-Debug "Error: $($global:Error[0].Exception.Message)"
    $global:Error[0].Exception.Message
}

function Handle_FunctionCall{
    param(
        [string]$funcToCall,
        [string]$arguments
    )

    if ($funcToCall -eq "run_powershell"){
        $argsJson = $arguments| ConvertFrom-Json
        if($null -eq $argsJson.command)
        {
            return 1
        }

        $functionReturn = (run_powershell -command $argsJson.command)
        return $functionReturn
    }
    elseif ($funcToCall -eq "get_last_error") {
        return (get_last_error)
    }
    else{
        throw "Unknown function: $funcToCall"
        # Ideally, we should cancel the run here
    }
}

Export-ModuleMember -Function Handle_FunctionCall, run_powershell