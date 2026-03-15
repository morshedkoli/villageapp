param(
  [Parameter(Mandatory = $true)]
  [string]$ProjectId,
  [string]$Platforms = "android,ios,web"
)

$ErrorActionPreference = "Stop"

if (-not $env:GOOGLE_APPLICATION_CREDENTIALS) {
  Write-Error "Set GOOGLE_APPLICATION_CREDENTIALS to your service account json path before running."
}

if (-not (Get-Command firebase -ErrorAction SilentlyContinue)) {
  Write-Host "Installing Firebase CLI..."
  npm install -g firebase-tools
}

if (-not (Get-Command flutterfire -ErrorAction SilentlyContinue)) {
  Write-Host "Installing FlutterFire CLI..."
  dart pub global activate flutterfire_cli
}

Write-Host "Verifying Firebase access..."
firebase projects:list | Out-Null

Write-Host "Configuring FlutterFire for project: $ProjectId"
flutterfire configure --project $ProjectId --platforms $Platforms --yes

Write-Host "Deploying Firestore and Storage rules..."
firebase deploy --only firestore:rules,storage --project $ProjectId

Write-Host "Done. Firebase setup completed for $ProjectId"
