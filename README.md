# SalesKido Mobile (Flutter)

CRM mobile app for SalesKido, wired to the existing backend at `https://api.beta.saleskido.com` (same APIs as `C:\SALESKIDO\FE\api`).

## Requirements

- Flutter SDK (installed at `C:\SALESKIDO\flutter` if you used the project setup)
- Android Studio / Xcode for device builds

## Run

```powershell
$env:PATH = "C:\SALESKIDO\flutter\bin;$env:PATH"
cd C:\SALESKIDO\FE\mobile
flutter pub get
flutter run
```

For a local API:

1. Edit `lib/core/constants/api_constants.dart` → `baseUrl`
2. Or run with: `--dart-define=API_BASE=http://10.0.2.2:3002` (after wiring that define)

## Features

- Onboarding
- Auth: Sign in / Sign up / Forgot & reset password
- Dashboard stats + latest leads + chart
- Lead list / add / detail
- Quotation list / detail
- WhatsApp chat list + chat UI
- Reports, notifications, profile, about, side drawer

## Login note

Mobile login sends `isMobile: true` (skips web reCAPTCHA).
