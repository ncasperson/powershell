###############################################################
# Decrypt or Encrypt Script - AES
#
# Nathaniel Casperson nathaniel.casperson@gmail.com
###############################################################

Function Protect-String-AES ($String, $Passphrase, $InitVector){
    $Key = [Text.Encoding]::UTF8.GetBytes($Passphrase)
    $IV  = [Text.Encoding]::UTF8.GetBytes($InitVector)

    $cryptoProvider       = New-Object System.Security.Cryptography.AesCryptoServiceProvider
    $cryptoProvider.Key   = $Key
    $cryptoProvider.IV    = $IV

    $UnencryptedBytes     = [System.Text.Encoding]::UTF8.GetBytes($String)
    $Encryptor            = $cryptoProvider.CreateEncryptor()
    $EncryptedBytes       = $Encryptor.TransformFinalBlock($UnencryptedBytes, 0, $UnencryptedBytes.Length)

    [byte[]] $FullData    = $cryptoProvider.IV + $EncryptedBytes
    $CipherText           = [System.Convert]::ToBase64String($FullData)
    $cryptoProvider.Dispose()

    Write-Output $CipherText
} # end of function

Function Unprotect-String-AES ($CipherText, $Passphrase, $InitVector) {
    $Key = [Text.Encoding]::UTF8.GetBytes($Passphrase)
    $IV  =  [Text.Encoding]::UTF8.GetBytes($InitVector)

    $cryptoProvider       = New-Object System.Security.Cryptography.AesCryptoServiceProvider
    $cryptoProvider.Key   = $Key
    $cryptoProvider.IV    = $IV

    $EncryptedBytes       = [System.Convert]::FromBase64String($CipherText)
    $Decryptor            = $cryptoProvider.CreateDecryptor();
    $UnencryptedBytes     = $Decryptor.TransformFinalBlock($EncryptedBytes, 16, $EncryptedBytes.Length - 16)

    $plainText            = [System.Text.Encoding]::UTF8.GetString($UnencryptedBytes)
    $cryptoProvider.Dispose()
    
    Write-Output $plainText
} # end of function

Protect-String-AES "What you talkin' about Willis?" "My_Shibboleth_2010_12_31" "0123456789012345"
Unprotect-String-AES "MDEyMzQ1Njc4OTAxMjM0NVn/KCAG5LYmzMn5420+RZmQVOmGvmXfdhH557kS1que" "My_Shibboleth_2010_12_31" "0123456789012345"
