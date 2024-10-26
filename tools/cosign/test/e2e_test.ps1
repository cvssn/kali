function New-TmpDir {
    $parent = [System.IO.Path]::GetTempPath()
    $name = [System.IO.Path]::GetRandomFileName()

    New-Item -ItemType Directory -Path (Join-Path $parent $name)
}

make cosign
$TmpDir = New-TmpDir
Copy-Item -Path .\cosign -Destination (Join-Path $TmpDir cosign.exe)

Push-Location $TmpDir

.\cosign.exe version

# gera uma senha alfa-numérica aleatória para a chave privada
$pass = Get-Random

Write-Output $pass | .\cosign.exe generate-key-pair
$signing_key = "cosign.key"
$verification_key = "cosign.pub"

$test_img = "ghcr.io/distroless/static"
Write-Output $pass | .\cosign.exe sign --key $signing_key --output-signature interactive.sig --output-payload interactive.payload --tlog-upload=false $test_img
.\cosign.exe verify --key $verification_key --signature interactive.sig --payload interactive.payload --insecure-ignore-tlog=true $test_img

Pop-Location

Write-Output "sucesso"