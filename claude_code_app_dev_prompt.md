# PreFlight W&B — Native SwiftUI iOS App Development Prompt

> Use this prompt with Claude Code to build a native iOS app in SwiftUI that ports the existing React PWA. The app lives in `ios/` alongside the existing web codebase. The backend API is unchanged.

---

## Context

PreFlight W&B is a General Aviation Weight & Balance Calculator. The existing React PWA is the reference implementation — this prompt ports it to native SwiftUI.

**What exists (DO NOT modify):**
- `server/` — Express + PostgreSQL backend API at https://api.preflight.valderis.com
- `src/` — React 19 PWA (frozen reference implementation)
- `docs/appstore/` — Privacy policy, App Store metadata, asset specs

**What we're building:**
- `ios/PreFlightWB/` — Native SwiftUI app (Xcode project)
- Targets iOS 17.0+ (SwiftUI 5, SwiftData, async/await)
- Same backend API, same user accounts, same sync protocol

**Backend API endpoints (already deployed, do not change):**
```
POST /auth/google        { idToken }                    → { token, user }
POST /auth/magic-link    { email }                      → { sent: true }
POST /auth/verify        { email, code }                → { token, user }
GET  /auth/me            Authorization: Bearer {jwt}    → { id, email, name, avatarUrl }
POST /scenarios/sync     { lastSyncAt, changes[] }      → { serverChanges[], syncedAt }
GET  /scenarios          Authorization: Bearer {jwt}    → Scenario[]
POST /scenarios          { id, aircraftId, name, ... }  → Scenario (201)
PUT  /scenarios/:id      { name, stationLoads, ... }    → Scenario
DELETE /scenarios/:id                                    → { deleted: true }
```

**Reference files for porting (read these, don't modify):**
| React file | What to port | Swift equivalent |
|---|---|---|
| `src/engine/calculator.ts` | W&B calculation (pure functions) | `Calculator.swift` |
| `src/engine/envelope.ts` | CG envelope ray-casting | `Envelope.swift` |
| `src/types/aircraft.ts` | Aircraft, Station, FuelTank, SourceAttribution | Swift structs |
| `src/types/calculation.ts` | CalculationResult, LoadingScenario, warnings | Swift structs |
| `src/data/aircraft/*.ts` | 4 aircraft data files with source attribution | Swift static data |
| `src/data/regulatory.ts` | Safety disclaimer, FAR references | Swift constants |
| `src/db/scenarios.ts` | IndexedDB CRUD + dirty tracking | SwiftData models |
| `src/services/api.ts` | API client with retry logic | URLSession wrapper |
| `src/services/sync.ts` | Sync orchestration | SyncService actor |
| `src/contexts/AuthContext.tsx` | Auth state (JWT + user) | AuthManager @Observable |
| `src/pages/LoginPage.tsx` | Google OAuth + 6-digit email code | LoginView |
| `src/pages/CalculatorPage.tsx` | Main calculator UI | CalculatorView |
| `src/components/chart/CGEnvelopeChart.tsx` | Custom SVG CG chart | Swift Charts or Canvas |

---

## Instructions

You are building a native SwiftUI iOS app that replicates the PreFlight W&B React PWA. The React `src/` directory is your specification — read it to understand behavior, then write idiomatic Swift. Execute these phases using parallel agents.

### Phase 1: Xcode Project + Data Models (Agent 1)

1. Create the Xcode project structure at `ios/PreFlightWB/`:
   ```
   ios/PreFlightWB/
   ├── PreFlightWB.xcodeproj
   ├── PreFlightWB/
   │   ├── App/
   │   │   ├── PreFlightWBApp.swift          # @main entry point
   │   │   └── ContentView.swift             # Root NavigationStack
   │   ├── Models/
   │   │   ├── Aircraft.swift                # Aircraft, Station, FuelTank, SourceAttribution
   │   │   ├── Calculation.swift             # CalculationResult, LoadingScenario, warnings
   │   │   └── Scenario.swift                # SwiftData @Model for saved scenarios
   │   ├── Data/
   │   │   ├── AircraftDatabase.swift         # Static aircraft array + lookup
   │   │   ├── Cessna172M.swift
   │   │   ├── BonanzaA36.swift
   │   │   ├── Cherokee6.swift
   │   │   ├── NavajoChieftain.swift
   │   │   └── Regulatory.swift              # Disclaimer + FAR references
   │   ├── Engine/
   │   │   ├── Calculator.swift              # calculateWeightAndBalance()
   │   │   └── Envelope.swift                # isPointInEnvelope(), getEnvelopeLimits()
   │   ├── Services/
   │   │   ├── APIClient.swift               # URLSession + retry + auth header
   │   │   ├── AuthManager.swift             # @Observable, Keychain token storage
   │   │   └── SyncService.swift             # Push dirty, pull server changes
   │   ├── Views/
   │   │   ├── Landing/
   │   │   │   └── LandingView.swift
   │   │   ├── Auth/
   │   │   │   └── LoginView.swift           # Google + email code
   │   │   ├── Aircraft/
   │   │   │   ├── AircraftSelectView.swift
   │   │   │   └── AircraftCard.swift
   │   │   ├── Calculator/
   │   │   │   ├── CalculatorView.swift       # Main calculator screen
   │   │   │   ├── StationInputRow.swift
   │   │   │   ├── FuelInputRow.swift
   │   │   │   ├── ResultsDashboard.swift
   │   │   │   └── SafetyAlerts.swift
   │   │   ├── Chart/
   │   │   │   └── CGEnvelopeChart.swift      # Swift Charts or Canvas
   │   │   ├── Scenarios/
   │   │   │   ├── ScenariosView.swift
   │   │   │   └── SaveScenarioSheet.swift
   │   │   └── Sources/
   │   │       └── SourcesView.swift
   │   └── Resources/
   │       └── Assets.xcassets/
   │           ├── AppIcon.appiconset/
   │           ├── AccentColor.colorset/      # #007AFF
   │           └── Colors/                    # iOS design tokens
   └── PreFlightWBTests/
       ├── CalculatorTests.swift
       └── EnvelopeTests.swift
   ```

2. Set Xcode project settings:
   - Bundle ID: `com.valderis.preflightwb`
   - Deployment target: iOS 17.0
   - Swift language version: 6.0
   - Portrait only
   - `ITSAppUsesNonExemptEncryption`: false

3. Define all data models by reading `src/types/aircraft.ts` and `src/types/calculation.ts`:

   ```swift
   // MARK: - Source Attribution
   struct SourceAttribution: Codable, Sendable {
       let document: String
       let section: String
       let publisher: String
       let datePublished: String
       var tcdsNumber: String?
       var url: String?
       let confidence: Confidence
       let lastVerified: String
       var notes: String?

       enum Confidence: String, Codable, Sendable {
           case high, medium, low
       }
   }

   struct SourcedValue: Codable, Sendable {
       let value: Double
       let unit: String
       let source: SourceAttribution
   }

   // MARK: - Aircraft
   struct Aircraft: Identifiable, Sendable {
       let id: String
       let name: String
       let model: String
       let manufacturer: String
       var year: String?
       let category: AircraftCategory

       let emptyWeight: SourcedValue
       let emptyWeightArm: SourcedValue
       let maxGrossWeight: SourcedValue
       var maxRampWeight: SourcedValue?
       var maxLandingWeight: SourcedValue?
       let usefulLoad: SourcedValue

       let datum: String
       let cgRange: CGRange
       let cgEnvelope: CGEnvelope

       let stations: [Station]
       let fuelTanks: [FuelTank]

       let regulatory: RegulatoryInfo
   }

   enum AircraftCategory: String, Codable, Sendable {
       case singleEngine = "single-engine"
       case multiEngine = "multi-engine"
   }

   struct Station: Identifiable, Codable, Sendable {
       let id: String
       let name: String
       let arm: SourcedValue
       var maxWeight: Double?
       var defaultWeight: Double?
   }

   struct FuelTank: Identifiable, Codable, Sendable {
       let id: String
       let name: String
       let arm: SourcedValue
       let maxGallons: SourcedValue
       let fuelWeightPerGallon: Double  // 6.0 for 100LL
       var isOptional: Bool?
   }

   struct EnvelopePoint: Codable, Sendable {
       let weight: Double
       let cg: Double
   }

   struct CGEnvelope: Codable, Sendable {
       let points: [EnvelopePoint]
       let source: SourceAttribution
   }

   // MARK: - Calculation
   struct StationLoad: Codable, Sendable {
       let stationId: String
       var weight: Double
   }

   struct FuelLoad: Codable, Sendable {
       let tankId: String
       var gallons: Double
   }

   struct CalculationResult: Sendable {
       let totalWeight: Double
       let totalMoment: Double
       let cg: Double
       let isWithinWeightLimit: Bool
       let isWithinCGEnvelope: Bool
       let isWithinAllStationLimits: Bool
       let weightMargin: Double
       let cgForwardMargin: Double
       let cgAftMargin: Double
       let stationDetails: [StationDetail]
       let fuelDetails: [FuelDetail]
       let warnings: [CalculationWarning]
   }

   struct CalculationWarning: Identifiable, Sendable {
       let id = UUID()
       let level: WarningLevel
       let code: String
       let message: String
       var detail: String?
       var regulatoryRef: String?

       enum WarningLevel: String, Sendable {
           case caution, warning, danger
       }
   }
   ```

4. Create the SwiftData model for saved scenarios:
   ```swift
   import SwiftData

   @Model
   final class SavedScenario {
       @Attribute(.unique) var id: String
       var aircraftId: String
       var name: String
       var stationLoads: [StationLoad]  // Codable, stored as JSON
       var fuelLoads: [FuelLoad]        // Codable, stored as JSON
       var notes: String?
       var createdAt: Date
       var updatedAt: Date
       var deletedAt: Date?             // Soft-delete
       var dirty: Bool                  // Unsynced local changes

       init(id: String = UUID().uuidString, ...) { ... }
   }
   ```

### Phase 2: Calculation Engine (Agent 2 — run in parallel with Phase 1)

Port `src/engine/calculator.ts` and `src/engine/envelope.ts` to pure Swift. These are stateless functions with zero dependencies — direct 1:1 port.

1. **Read** `src/engine/calculator.ts` and port `calculateWeightAndBalance()`:
   ```swift
   enum Calculator {
       static func calculate(aircraft: Aircraft, stationLoads: [StationLoad], fuelLoads: [FuelLoad]) -> CalculationResult
   }
   ```

   Key logic:
   - Start with `totalWeight = aircraft.emptyWeight.value`, `totalMoment = emptyWeight * emptyWeightArm`
   - Add each station: `weight * station.arm.value`
   - Add each fuel tank: `gallons * fuelWeightPerGallon * tank.arm.value`
   - CG = totalMoment / totalWeight (guard totalWeight > 0)
   - Check weight limits against maxGrossWeight, maxRampWeight, maxLandingWeight
   - Check CG envelope via `Envelope.isPointInEnvelope()`
   - Generate warnings with same codes as TypeScript version

2. **Read** `src/engine/envelope.ts` and port the ray-casting algorithm:
   ```swift
   enum Envelope {
       /// Ray-casting (even-odd) point-in-polygon test
       static func isPointInEnvelope(weight: Double, cg: Double, envelope: CGEnvelope) -> Bool

       /// Find forward/aft CG limits at a given weight
       static func getLimitsAtWeight(_ weight: Double, envelope: CGEnvelope) -> (forward: Double, aft: Double)?
   }
   ```

   The ray-casting algorithm:
   - Cast horizontal ray from (cg, weight) rightward
   - Count edge crossings of the envelope polygon
   - Odd crossings = inside

3. **Write XCTest unit tests** in `PreFlightWBTests/CalculatorTests.swift`:
   - Port the existing 24+ test cases from `tests/engine/calculator.test.ts`
   - Same test data, same expected outputs
   - Include edge cases: empty aircraft below envelope, zero weight guard, negative inputs

### Phase 3: Aircraft Data (Agent 3 — run in parallel with Phases 1 & 2)

Port all 4 aircraft data files. Read each TypeScript file and create equivalent Swift structs.

1. **Read** `src/data/aircraft/cessna172m.ts` → create `Cessna172M.swift`
2. **Read** `src/data/aircraft/bonanzaA36.ts` → create `BonanzaA36.swift`
3. **Read** `src/data/aircraft/cherokee6.ts` → create `Cherokee6.swift`
4. **Read** `src/data/aircraft/navajoChieftain.ts` → create `NavajoChieftain.swift`

Every single numeric value must include its `SourceAttribution` — this is critical for regulatory compliance. Do not simplify or omit source metadata.

5. Create `AircraftDatabase.swift`:
   ```swift
   enum AircraftDatabase {
       static let all: [Aircraft] = [cessna172m, bonanzaA36, cherokee6, navajoChieftain]

       static func aircraft(for id: String) -> Aircraft? {
           all.first { $0.id == id }
       }
   }
   ```

6. **Read** `src/data/regulatory.ts` → create `Regulatory.swift`:
   ```swift
   enum Regulatory {
       static let disclaimer: String = """
       IMPORTANT: This calculator is a supplemental planning tool only...
       Per FAR 91.103, the pilot in command is solely responsible...
       """

       static let references: [String: RegulatoryReference] = [
           "FAR 91.103": ...,
           "FAR 23.23": ...,
           "AC 120-27F": ...,
       ]
   }
   ```

### Phase 4: Networking + Auth (Agent 4 — after Phase 1 creates the project)

1. **Read** `src/services/api.ts` and port to `APIClient.swift`:
   ```swift
   actor APIClient {
       static let shared = APIClient()
       private let baseURL = URL(string: "https://api.preflight.valderis.com")!

       func fetch<T: Decodable>(_ path: String, method: String = "GET", body: Encodable? = nil) async throws -> T

       // Retry logic: POST retries 3x with exponential backoff (1s, 2s, 3s)
       // GET retries 1x
       // Retry on 5xx, 429; not on 4xx
       // Auto-attaches Authorization: Bearer {token} from Keychain
   }
   ```

   Use `URLSession.shared` with `JSONEncoder`/`JSONDecoder`. Decoder should use `.convertFromSnakeCase` for server responses.

2. **Create** `AuthManager.swift`:
   ```swift
   @Observable
   final class AuthManager {
       var user: AuthUser?
       var isAuthenticated: Bool { user != nil }
       var isGuest: Bool = false
       var isLoading: Bool = true

       func loginWithGoogle(idToken: String) async throws
       func sendEmailCode(email: String) async throws
       func verifyEmailCode(email: String, code: String) async throws
       func continueAsGuest()
       func logout()
       func restoreSession() async  // Called on app launch
   }

   struct AuthUser: Codable, Sendable {
       let id: String
       let email: String
       var name: String?
       var avatarUrl: String?
   }
   ```

   Token storage: Use **Keychain** (via `Security` framework), not UserDefaults. The JWT has 90-day expiry.

3. **Google Sign-In**: Use the official `GoogleSignIn-iOS` SPM package:
   ```
   https://github.com/google/GoogleSignIn-iOS
   ```
   - Add to Xcode via Swift Package Manager
   - Configure with Google Client ID: read from a `Config.plist` or `Secrets.swift` (gitignored)
   - On success, get `idToken` → POST `/auth/google` → store JWT

4. **Email code flow**: No SDK needed — just two API calls:
   - `POST /auth/magic-link` with `{ email }` (lowercased)
   - `POST /auth/verify` with `{ email, code }`
   - Code input: `TextField` with `.keyboardType(.numberPad)`, `.textContentType(.oneTimeCode)`, max 6 chars

### Phase 5: Persistence + Sync (Agent 5 — after Phase 1)

1. **SwiftData container setup** in `PreFlightWBApp.swift`:
   ```swift
   @main
   struct PreFlightWBApp: App {
       var body: some Scene {
           WindowGroup {
               ContentView()
           }
           .modelContainer(for: SavedScenario.self)
       }
   }
   ```

2. **Port CRUD operations** from `src/db/scenarios.ts`:
   ```swift
   // These work with @Environment(\.modelContext)
   // List non-deleted, sorted newest first
   #Predicate<SavedScenario> { $0.deletedAt == nil }
   SortDescriptor(\SavedScenario.updatedAt, order: .reverse)

   // Filter by aircraft
   #Predicate<SavedScenario> { $0.aircraftId == aircraftId && $0.deletedAt == nil }

   // Soft-delete
   func deleteScenario(_ scenario: SavedScenario) {
       scenario.deletedAt = Date()
       scenario.updatedAt = Date()
       scenario.dirty = true
   }

   // Get dirty for sync
   #Predicate<SavedScenario> { $0.dirty == true }
   ```

3. **Read** `src/services/sync.ts` and port to `SyncService.swift`:
   ```swift
   actor SyncService {
       func sync(context: ModelContext) async throws -> Int  // returns count of synced items
   }
   ```

   Sync protocol (same as React version):
   1. Fetch dirty scenarios from SwiftData
   2. POST to `/scenarios/sync` with `{ lastSyncAt, changes[] }`
   3. Mark pushed scenarios as `dirty = false`
   4. Apply `serverChanges` with conflict resolution:
      - No local version → insert server version
      - Local not dirty → overwrite with server
      - Server newer than local → overwrite
      - Local newer → keep local
   5. Update `lastSyncAt` (store in UserDefaults or a separate SwiftData model)

4. **Auto-sync triggers:**
   - On app launch (if authenticated)
   - On return from background (`scenePhase == .active`)
   - After saving or deleting a scenario

### Phase 6: UI Views (Agent 6 — after Phases 1-3)

Build all views using SwiftUI. Match the behavior of the React pages, but use native iOS patterns.

**Design tokens** (from `src/index.css`):
```swift
extension Color {
    static let iosBlue = Color(hex: "007AFF")
    static let iosGreen = Color(hex: "34C759")
    static let iosRed = Color(hex: "FF3B30")
    static let iosOrange = Color(hex: "FF9500")
    static let iosYellow = Color(hex: "FFCC00")
    static let iosBg = Color(hex: "F2F2F7")
    static let iosCard = Color.white
    static let iosSeparator = Color(hex: "C6C6C8")
}
```

1. **ContentView.swift** — Root with NavigationStack:
   ```swift
   struct ContentView: View {
       @State private var authManager = AuthManager()

       var body: some View {
           Group {
               if authManager.isLoading {
                   SplashView()
               } else if authManager.isAuthenticated || authManager.isGuest {
                   MainNavigationView()
               } else {
                   LandingView()
               }
           }
           .environment(authManager)
       }
   }
   ```

2. **LandingView** — App intro with logo, tagline, disclaimer, "Get Started" button
   - Read `src/pages/LandingPage.tsx` for layout
   - Include the FAR 91.103 safety disclaimer (expandable, orange banner)
   - Show version badge (v1.0.0)

3. **LoginView** — Two auth methods:
   - "Continue with Google" button (Google Sign-In SDK)
   - Email input → 6-digit code input (animated transition)
   - "Continue as Guest" option
   - Code input: large centered font, 6 boxes or single field with `.oneTimeCode`

4. **AircraftSelectView** — Grid of aircraft cards:
   - LazyVGrid with 2 columns
   - Each card: aircraft name, manufacturer, category badge
   - NavigationLink to CalculatorView

5. **CalculatorView** — Main screen:
   - ScrollView with sections: Station Loads, Fuel Loads, Results
   - Each station: name label + Slider or Stepper (range 0...maxWeight)
   - Each fuel tank: name + Slider (range 0...maxGallons)
   - Live recalculation on every change (Combine or @State)
   - Results dashboard: total weight, CG, moment, margins
   - Warning banners (color-coded: red/orange/yellow)
   - Toolbar buttons: Save, Sources, Chart

6. **CGEnvelopeChart** — Use Swift Charts (Charts framework) or Canvas:
   - X-axis: CG (inches), Y-axis: Weight (lbs)
   - Draw envelope polygon (filled green/red based on in/out)
   - Draw current position as a dot
   - Axis labels and grid lines
   - Read `src/components/chart/CGEnvelopeChart.tsx` for the SVG approach — port to `Path` drawing

7. **ScenariosView** — List of saved scenarios:
   - SwiftUI List with swipe-to-delete
   - Tap to load into calculator
   - "Save" sheet: name input, optional notes
   - Pull-to-refresh triggers sync

8. **SourcesView** — Source attribution for selected aircraft:
   - Grouped by data point (empty weight, arm, max gross, etc.)
   - Each shows: value, source document, section, confidence badge (green/yellow/red)
   - Read `src/components/sources/` for layout

### Phase 7: App Icon + Assets (Agent 7 — run in parallel with everything)

The SVG source is at `public/icons/icon.svg`.

1. Generate all required Xcode icon sizes (see `docs/appstore/assets-spec.md`):
   - 1024x1024 for App Store
   - All standard iOS sizes for the asset catalog
   - Use a script with `rsvg-convert`, `sips`, or `sharp` (Node.js)

2. Set up `Assets.xcassets`:
   - `AccentColor`: #007AFF
   - Custom color sets for all iOS design tokens
   - App icon set with all sizes

3. Configure launch screen in `LaunchScreen.storyboard`:
   - Background: #007AFF
   - Centered white app icon
   - No text

---

## Parallel Execution Strategy

```
Time →
─────────────────────────────────────────────────────────────
Agent 1: [Phase 1: Xcode + Models    ]
Agent 2: [Phase 2: Calc Engine       ]
Agent 3: [Phase 3: Aircraft Data     ]
Agent 7: [Phase 7: Icons + Assets    ]
                                       ↓
Agent 4:          [Phase 4: Network + Auth    ]
Agent 5:          [Phase 5: Persistence + Sync]
Agent 6:          [Phase 6: UI Views                        ]
                                                             ↓
Sequential:                            [Build + Test + Fix   ]
─────────────────────────────────────────────────────────────
```

- **Agents 1 + 2 + 3 + 7** run in parallel (no dependencies between them)
- **Agents 4 + 5 + 6** start after Agent 1 (they need the Xcode project and model types)
- Agent 6 also needs Agents 2 + 3 (engine + data) before the calculator view works
- Final build + test runs after all agents complete

---

## Important Notes

- **Read the React source as your spec** — every `src/` file documents the expected behavior. Port behavior, not code style.
- Do NOT modify `server/` or `src/`. The backend is deployed and stable. The React PWA remains as a reference.
- Do NOT simplify source attribution. Every `SourcedValue` must carry its full `SourceAttribution`. This is a regulatory requirement.
- Do NOT remove or weaken the safety disclaimer (14 CFR 91.103).
- Use **SwiftData** (not Core Data) for persistence — it's the modern Apple-blessed approach.
- Use **Keychain** for JWT storage (not UserDefaults).
- Use **async/await** throughout — no completion handlers.
- Use **@Observable** (Observation framework) not ObservableObject/Published.
- Use `Codable` with `JSONEncoder`/`JSONDecoder` for all API serialization.
- The API returns snake_case JSON — configure decoder with `.convertFromSnakeCase`.
- Google Client ID: `478969641599-ri9rjfoqk7jqtv5751kkg7u06i17n3na.apps.googleusercontent.com`

---

## Verification Checklist

- [ ] Xcode project builds with zero warnings
- [ ] App launches in iOS 17 Simulator
- [ ] LandingView renders with disclaimer and version badge
- [ ] Google Sign-In flow works (idToken → server → JWT)
- [ ] Email code flow works (send code → enter 6 digits → JWT)
- [ ] Guest mode works (no auth, full calculator)
- [ ] Aircraft selection shows all 4 aircraft
- [ ] Calculator updates in real-time as loads change
- [ ] CG envelope chart renders correctly with position dot
- [ ] Weight/CG warnings appear with correct severity colors
- [ ] Scenarios save to SwiftData with dirty flag
- [ ] Scenarios list shows saved configurations
- [ ] Swipe-to-delete soft-deletes (sets deletedAt)
- [ ] Sync pushes dirty scenarios to server
- [ ] Sync pulls server changes and resolves conflicts
- [ ] Offline mode: calculator works without network
- [ ] Sources view shows all attribution with confidence badges
- [ ] Cessna 172M empty weight (1466 lbs) correctly shows outside envelope
- [ ] Unit tests pass for Calculator and Envelope
- [ ] App icon appears correctly on home screen
