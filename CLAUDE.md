# PreFlight W&B — Development Guide

## Tech Stack
- **Frontend:** React 19 + TypeScript 5.9 (strict) + Vite 7 + Tailwind CSS 4 + Framer Motion 12
- **Backend:** Express + PostgreSQL on VPS (15.204.227.100), PM2 process manager
- **PWA:** vite-plugin-pwa (workbox), offline-first with IndexedDB via `idb`
- **Auth:** Google OAuth + 6-digit email verification code (via Resend) + guest mode
- **Sync:** IndexedDB local-first, background sync to server, last-write-wins conflict resolution

## Build & Deploy

### Frontend
```bash
npm run build          # TypeScript check + Vite build → dist/
npm run dev            # Dev server on localhost:5173
npm test               # Vitest
```

### Server
```bash
cd server
npm run build          # TypeScript → dist/
npm run dev            # Dev server on localhost:3001
```

### Deployment
```bash
# Server: copy built files + restart PM2
scp -r server/dist/* ubuntu@15.204.227.100:/home/ubuntu/preflight-api/dist/
ssh ubuntu@15.204.227.100 "cd /home/ubuntu/preflight-api && pm2 restart preflight-api"

# Frontend: copy built files to nginx root
scp -r dist/* ubuntu@15.204.227.100:/home/ubuntu/preflight-wb/
```

### VPS Access
- SSH: `ssh ubuntu@15.204.227.100` (NOT root)
- API: `https://api.preflight.valderis.com` → nginx → localhost:3001
- Frontend: `https://preflight.valderis.com` → nginx → /home/ubuntu/preflight-wb
- PM2 logs: `ssh ubuntu@15.204.227.100 "pm2 logs preflight-api --lines 50"`

### iOS App
```bash
# On Mac — requires Xcode 16+, XcodeGen
cd ios/PreFlightWB
xcodegen generate                     # Regenerate .xcodeproj from project.yml
xcodebuild build -project PreFlightWB.xcodeproj -scheme PreFlightWB -destination 'generic/platform=iOS'
xcodebuild test -project PreFlightWB.xcodeproj -scheme PreFlightWBTests -destination 'platform=iOS Simulator,name=iPhone 16'
```

### iOS Development Workflow
1. Edit Swift files on Windows (VS Code + Claude Code)
2. Push to GitHub (CI builds automatically via `.github/workflows/ios-ci.yml`)
3. Pull on MacBook, open in Xcode, build & test on device

## Architecture

### Frontend Structure
- `src/types/` — Aircraft and Calculation interfaces
- `src/data/aircraft/` — 4 aircraft files with source attribution
- `src/engine/` — calculator.ts + envelope.ts (pure functions)
- `src/hooks/` — useCalculation, useOnlineStatus, useAuth, useScenarios, useSync
- `src/components/` — layout, aircraft, calculator, chart, sources, scenarios, common
- `src/pages/` — LandingPage, LoginPage, AircraftSelectPage, CalculatorPage, ScenariosPage, SourcesPage
- `src/db/` — IndexedDB init + local scenario CRUD
- `src/services/` — api.ts (fetch wrapper with JWT + retry), sync.ts (background sync)
- `src/contexts/` — AuthContext.tsx

### iOS Structure
- `ios/PreFlightWB/project.yml` — XcodeGen project definition (source of truth for .xcodeproj)
- `ios/PreFlightWB/PreFlightWB/App/` — SwiftUI app entry point
- `ios/PreFlightWB/PreFlightWB/Data/` — Aircraft definitions (Cessna172M, BonanzaA36, Cherokee6, NavajoChieftain)
- `ios/PreFlightWB/PreFlightWB/Engine/` — Calculator.swift + Envelope.swift (ported from TS)
- `ios/PreFlightWB/PreFlightWB/Models/` — Aircraft, Calculation, Scenario types
- `ios/PreFlightWB/PreFlightWB/Services/` — APIClient, AuthManager, KeychainHelper, SyncService
- `ios/PreFlightWB/PreFlightWB/Views/` — All SwiftUI views
- `ios/PreFlightWB/PreFlightWBTests/` — Swift Testing unit tests

### Server Structure
- `server/src/index.ts` — Express entry
- `server/src/db.ts` — PostgreSQL pool
- `server/src/auth/` — google.ts, magicLink.ts (6-digit code), jwt.ts, middleware.ts
- `server/src/routes/` — auth.ts, scenarios.ts
- `server/migrations/` — SQL schema

### Auth Flow
- Google OAuth: GSI script → ID token → `/auth/google` → JWT
- Email: enter email → `/auth/magic-link` sends 6-digit code → user enters code → `/auth/verify` → JWT
- Guest: no auth, no save/sync, full offline functionality
- JWT stored in IndexedDB, 90-day expiry, no refresh tokens

### Key Patterns
- Offline-first: all writes go to IndexedDB, sync in background when online
- Calculation engine is pure functions — no side effects, easily unit tested
- CG envelope check uses ray-casting point-in-polygon algorithm
- useState-based routing (no react-router)
- iOS design tokens as Tailwind @theme custom properties

## Gotchas
- Cessna 172M empty weight (1466 lbs) is below envelope minimum (1500 lbs) — correct behavior
- Tailwind v4 uses `@import "tailwindcss"` + `@theme {}` syntax, not `@tailwind` directives
- Tailwind v4 uses `@tailwindcss/vite` plugin, not `postcss.config.js`
- PWA: `skipWaiting: true` + `clientsClaim: true` needed for immediate SW updates
- iOS PWA + Safari have separate IndexedDB — that's why we use 6-digit code (not clickable link)
- Resend emails must come from verified domain (`noreply@valderis.com`, not subdomain)
- Server env: `FROM_EMAIL=noreply@valderis.com` (valderis.com is verified in Resend)
- Frontend API client retries POST requests 3x on 5xx/429/network errors
- Server email sending retries 3x with exponential backoff
- iOS app targets iOS 17+ / Swift 6.0 / Xcode 16+
- iOS project uses XcodeGen — edit `project.yml`, not `.xcodeproj` directly
- iOS CI builds for Simulator only (no code signing needed); device builds done locally on MacBook
- SPM dependency: GoogleSignIn-iOS v8.0.0+ (resolved automatically)
