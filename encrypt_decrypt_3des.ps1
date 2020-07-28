###############################################################
# Decrypt or Encrypt Script - 3DES
#
# Created by Nathaniel Casperson nathaniel.casperson@gmail.com
###############################################################

Function Protect-String-3DES($String, $Passphrase, $InitVector) {
    $Key = [Text.Encoding]::UTF8.GetBytes($Passphrase)
    $IV  = [Text.Encoding]::UTF8.GetBytes($InitVector)
            
    $cryptoProvider = New-Object System.Security.Cryptography.TripleDESCryptoServiceProvider
    $memoryStream = New-Object IO.MemoryStream    
    $cryptoStream = New-Object Security.Cryptography.CryptoStream $memoryStream,$cryptoProvider.CreateEncryptor($Key,$IV),"Write"
    $streamWriter = New-Object IO.StreamWriter $cryptostream
    $streamWriter.Write($String)
    
    $streamWriter.Close()
    $cryptoStream.Close()
    $memoryStream.Close()
    $cryptoProvider.Clear()
    
    [byte[]]$result = $memoryStream.ToArray()
    if($arrayOutput) {
        return $result
    } else {
        Write-Output "This is our encrypted string: "
        return [Convert]::ToBase64String($result)
    }    
} # end of function

Function Unprotect-String-3DES($Encrypted, $Passphrase, $InitVector) {
    if($Encrypted -is [string]){
        $Encrypted = [Convert]::FromBase64String($Encrypted)
    }

    $cryptoProvider = New-Object System.Security.Cryptography.TripleDESCryptoServiceProvider
    $Key = [Text.Encoding]::UTF8.GetBytes($Passphrase)
    $IV = [Text.Encoding]::UTF8.GetBytes($InitVector)
    
    $memoryStream = New-Object IO.MemoryStream @(,$Encrypted)
    $cryptoStream = New-Object Security.Cryptography.CryptoStream $memoryStream,$cryptoProvider.CreateDecryptor($Key, $IV),"Read"
    $streamReader = New-Object IO.StreamReader $cryptoStream
    Write-Output "This is the decrypted string "
    return $streamReader.ReadToEnd()
    $streamReader.Close()
    $cryptoStream.Close()
    $memoryStream.Close()
    $cryptoProvider.Clear()   
} # end of function

Protect-String-3DES "What you talkin' about Willis?" "My_Shibboleth_2010_12_31" "01234567"
Unprotect-String-3DES "+fznzeBc8L737N2vzFr9V94/W5Y/aibkZbQqXwNQ+N8=" "My_Shibboleth_2010_12_31" "01234567"