# App Store Assets Specification — PreFlight W&B

## App Icon

### Source
- SVG source: `public/icons/icon.svg`
- Design: Blue rounded square (#007AFF) with white balance scale icon and airplane silhouette
- No transparency, no alpha channel (Apple requirement)

### Required Sizes (iOS)
Generate from SVG at these exact pixel dimensions:

| Size | Scale | Usage |
|------|-------|-------|
| 20x20 | 1x | iPad Notifications |
| 40x40 | 2x | iPad Notifications, iPhone/iPad Spotlight |
| 60x60 | 3x | iPad Notifications |
| 29x29 | 1x | iPad Settings |
| 58x58 | 2x | iPhone/iPad Settings |
| 87x87 | 3x | iPhone Settings |
| 40x40 | 1x | iPad Spotlight |
| 80x80 | 2x | iPhone/iPad Spotlight |
| 120x120 | 3x | iPhone Spotlight, iPhone App |
| 76x76 | 1x | iPad App |
| 152x152 | 2x | iPad App |
| 167x167 | 2x | iPad Pro App |
| 180x180 | 3x | iPhone App |
| **1024x1024** | 1x | **App Store listing** (most important) |

### Output Location
`ios/PreFlightWB/PreFlightWB/Resources/Assets.xcassets/AppIcon.appiconset/`

Each PNG must be named consistently (e.g., `icon-20.png`, `icon-40.png`, etc.) and referenced in the `Contents.json` manifest.

### Also Generate for PWA (currently missing)
| File | Size | Location |
|------|------|----------|
| `icon-192.png` | 192x192 | `public/icons/` |
| `icon-512.png` | 512x512 | `public/icons/` |
| `apple-touch-icon.png` | 180x180 | `public/icons/` |

---

## App Store Screenshots

Apple requires screenshots for at least the 6.7" display. Providing both 6.7" and 6.1" covers all required sizes.

### Required Screenshot Sizes

| Device Class | Resolution | Required? |
|---|---|---|
| **6.7" iPhone** (iPhone 15 Pro Max) | 1290 x 2796 px | **Yes** |
| **6.1" iPhone** (iPhone 15 Pro) | 1179 x 2556 px | Recommended |
| 5.5" iPhone (iPhone 8 Plus) | 1242 x 2208 px | Optional (legacy) |
| 12.9" iPad Pro | 2048 x 2732 px | If supporting iPad |

### Screenshot Count
- Minimum: 3 screenshots per device size
- Maximum: 10 screenshots per device size
- Recommended: 5-6 screenshots

### Recommended Screenshots (in order)

1. **Landing Page** — App logo, tagline "Weight & Balance with Source Transparency", safety disclaimer visible
   - Caption: "Weight & balance calculations you can verify"

2. **Aircraft Selection** — Grid of 4 aircraft cards with names and images
   - Caption: "4 GA aircraft with full POH references"

3. **Calculator — Loaded** — Cessna 172M with realistic loads (pilot 170lb, passenger 150lb, 40gal fuel), showing total weight and CG
   - Caption: "Real-time weight, CG, and moment calculations"

4. **CG Envelope Chart** — Same loaded configuration showing the dot inside the green envelope
   - Caption: "Interactive CG envelope shows you're within limits"

5. **Source Attribution** — Sources page showing POH references with confidence badges
   - Caption: "Every number traced to its source document"

6. **Scenarios List** — 2-3 saved scenarios with names and dates
   - Caption: "Save and sync your loading scenarios"

### Screenshot Guidelines
- Use a clean iOS simulator (no debug indicators)
- Status bar should show realistic time, full battery, full signal
- Use iPhone 15 Pro Max simulator for 6.7" captures
- Dark mode screenshots are optional but nice to have as alternates
- Do NOT include device frames in the uploaded screenshots (App Store adds them)
- Screenshots must be PNG or JPEG, sRGB color space

### Screenshot Capture Process
```bash
# In Xcode Simulator:
# 1. Run the app on iPhone 15 Pro Max simulator
# 2. Navigate to each screen
# 3. Cmd+S to save screenshot (saves to Desktop)
# Or use xcrun:
xcrun simctl io booted screenshot landing.png
xcrun simctl io booted screenshot aircraft-select.png
xcrun simctl io booted screenshot calculator.png
xcrun simctl io booted screenshot cg-chart.png
xcrun simctl io booted screenshot sources.png
xcrun simctl io booted screenshot scenarios.png
```

---

## App Preview Video (Optional)

A 15-30 second preview video can significantly boost downloads.

| Device | Resolution | FPS | Format |
|--------|-----------|-----|--------|
| 6.7" iPhone | 1290 x 2796 | 30 | H.264, .mp4 |

### Suggested Storyboard (15 seconds)
1. (0-3s) Landing page → tap "Continue as Guest"
2. (3-6s) Aircraft grid → tap Cessna 172M
3. (6-10s) Adjust pilot weight slider → see numbers update live
4. (10-13s) Scroll to CG chart → dot moves inside envelope
5. (13-15s) Tap "Save" → scenario saved with name

---

## Splash Screen / Launch Screen

### Storyboard (Recommended by Apple)
- Background color: #007AFF
- Centered app icon (white, ~120px)
- No text (Apple discourages text on launch screens)
- Configure in `ios/PreFlightWB/PreFlightWB/Base.lproj/LaunchScreen.storyboard`

---

## Color Reference

| Name | Hex | Usage |
|------|-----|-------|
| iOS Blue (Primary) | #007AFF | App icon bg, status bar, buttons, splash |
| iOS Background | #F2F2F7 | App background |
| iOS Card | #FFFFFF | Card surfaces |
| iOS Green | #34C759 | In-envelope indicator, high confidence |
| iOS Red | #FF3B30 | Out-of-envelope indicator, low confidence |
| iOS Orange | #FF9500 | Warnings, safety disclaimer |
| iOS Yellow | #FFCC00 | Medium confidence |

---

## File Checklist

Before App Store submission, verify all assets exist:

- [ ] App icon 1024x1024 PNG (no alpha, no rounded corners — Apple applies mask)
- [ ] All icon sizes in AppIcon.appiconset with Contents.json
- [ ] At least 3 screenshots at 1290x2796 (6.7" iPhone)
- [ ] Launch screen storyboard or splash screen images
- [ ] Privacy policy hosted at live URL
- [ ] Support URL live and accessible
