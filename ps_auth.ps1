# Don't touch this file if you don't know what you're doing.

# Não mexa nesse arquivo se você não sabe o que está fazendo.


# Set utf8 encoding
$OutputEncoding = [Console]::OutputEncoding = [Text.UTF8Encoding]::UTF8

$windowsLanguage = [System.Globalization.CultureInfo]::CurrentCulture.Name

# Define colors for messages
$foregroundColor = "Yellow" # Default color
$errorForegroundColor = "Red"
$successForegroundColor = "Green"

# Define the URL for the request
$url = "https://kessel-api.parsecgaming.com/v1/auth"

$prefix = "[!] "


# Define messages based on Windows language
if ($windowsLanguage -eq "pt-BR" -or $windowsLanguage -eq "pt-PT") {
    $warningMessage = $prefix + "Essa script apenas usa suas credenciais para autenticar no Parsec Soda. Suas credenciais nao serao salvas. \n Voce pode verificar o codigo fonte usando qualquer editor de texto. \n Sempre baixe o script em: https://github.com/luizhtss/ps-soda-auth" ;
    $promptEmail = "Insira o seu email:"
    $promptPassword = "Insira a sua senha:"
    $promptTFA = "Insira o seu TFA:"
    $successMessage = $prefix + "Autenticado com sucesso! Agora voce pode usar o Parsec Soda."
    $loginFailed = $prefix + "Falha ao autenticar"
} else {
    $warningMessage = $prefix + "This script just use your credentials to authenticate in Parsec Soda. Your credentials will not be saved. \n You can check the source code using any text editor. \n Always download the script at: https://github.com/luizhtss/ps-soda-auth";
    $promptEmail = "Enter your email:"
    $promptPassword = "Enter your password:"
    $promptTFA = "Enter your TFA:"
    $successMessage = $prefix + "Authenticated successfully! Now you can use Parsec Soda."
    $loginFailed = $prefix + "Failed to authenticate"
}

Write-Host $warningMessage -ForegroundColor "Cyan"

Start-Sleep -s 2

Write-Host -NoNewline ($promptEmail + " ") -ForegroundColor $foregroundColor
$email = Read-Host

Write-Host -NoNewline ($promptPassword + " ") -ForegroundColor $foregroundColor
$password = Read-Host -AsSecureString

Write-Host -NoNewline ($promptTFA + " ") -ForegroundColor $foregroundColor
$tfa = Read-Host -AsSecureString

# Convert SecureString to String
$passwordString = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
$tfaString = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($tfa))

# Define the JSON to be sent in the request body
$jsonBody = @{
    "email" = $email
    "password" = $passwordString
    "tfa" = $tfaString
} | ConvertTo-Json

# Define the headers for the request
$headers = @{
    "Content-Type" = "application/json"
    "Host" = "kessel-api.parsecgaming.com"
    "Content-Length" = $jsonBody.Length
}

try {
    # Make the POST request
    $response = Invoke-RestMethod -Uri $url -Method Post -Body $jsonBody -Headers $headers

    # Path to the JSON file
    $jsonFilePath = [System.IO.Path]::Combine($env:APPDATA, "SmashSodaZombie", "session.json")

    # Save the response to a JSON file
    [System.IO.File]::WriteAllText($jsonFilePath, ($response | ConvertTo-Json -Depth 100 -Compress))

    # Show status message
    Write-Host $successMessage -ForegroundColor $successForegroundColor
} catch {
        Write-Host $loginFailed -ForegroundColor $errorForegroundColor

}