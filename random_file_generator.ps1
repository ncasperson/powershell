$bytes = 10MB
$filename = "test.bin"
$foldername = "$($env:TEMP)"

Function Format-FileSize() {
    Param ([int]$size)
    If     ($size -gt 1TB) {[string]::Format("{0:0.00} TB", $size / 1TB)}
    ElseIf ($size -gt 1GB) {[string]::Format("{0:0.00} GB", $size / 1GB)}
    ElseIf ($size -gt 1MB) {[string]::Format("{0:0.00} MB", $size / 1MB)}
    ElseIf ($size -gt 1KB) {[string]::Format("{0:0.00} kB", $size / 1KB)}
    ElseIf ($size -gt 0)   {[string]::Format("{0:0.00} B", $size)}
    Else                   {""}
}

[System.Security.Cryptography.RNGCryptoServiceProvider] $rng = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
$rndbytes = New-Object byte[] $bytes
$rng.GetBytes($rndbytes)
[System.IO.File]::WriteAllBytes( "$foldername\$filename", $rndbytes )

Write-Output "File created: $(Format-FileSize($bytes)) at $foldername\$filename"