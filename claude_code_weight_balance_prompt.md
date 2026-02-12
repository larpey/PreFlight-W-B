# Claude Code Prompt: General Aviation Weight & Balance Calculator

## Development Environment Requirements
- **Primary IDE**: Visual Studio Code with React/TypeScript extensions
- **iOS Development**: Prepare for Xcode integration and iPhone 17 Pro Max testing
- **Target Device**: iPhone 17 Pro Max with latest iOS
- **PWA-to-Native Path**: Structure code for potential Xcode conversion

## Research Instructions for Claude Code
BEFORE starting development, research and gather the following WITH FULL SOURCE ATTRIBUTION:

1. **Latest Aircraft Specifications WITH SOURCES**: 
   - Document ALL sources (POH editions, manufacturer bulletins, FAA type certificates)
   - Include publication dates and revision numbers
   - Note any conflicting data between sources
   - Provide direct links/references to official documents

2. **Regulatory Requirements WITH CITATIONS**:
   - FAR 91.103, 23.23, and related regulations with specific section references
   - AC 120-27F and other Advisory Circulars
   - TCDS (Type Certificate Data Sheets) numbers and dates
   - Include exact regulatory text for critical requirements

3. **Source Verification Protocol**:
   - Cross-reference minimum 2 official sources for each aircraft specification
   - Flag any discrepancies between sources
   - Prioritize: 1) Current POH, 2) TCDS, 3) Manufacturer specs, 4) Industry databases
   - Document confidence level for each data point

## Project Overview
Create a comprehensive iPhone-native Progressive Web App (PWA) weight and balance calculator with full source transparency, designed for VS Code development and Xcode testing on iPhone 17 Pro Max.

## Core Requirements

### 1. Aircraft Database WITH FULL SOURCE TRANSPARENCY
Each aircraft specification must include complete source attribution visible to users:

#### Source Attribution Requirements:
```typescript
interface AircraftSpecification {
  value: number;
  unit: string;
  sources: {
    primary: {
      document: string;        // "POH Rev 12, 2024"
      section: string;         // "Section 6, Page 6-2"
      publisher: string;       // "Cessna Aircraft Company"
      datePublished: string;   // "2024-03-15"
      url?: string;           // Direct link if available
    };
    secondary?: {
      document: string;
      verification: string;    // "Confirms primary source"
      dateVerified: string;
    };
    confidence: 'high' | 'medium' | 'low';
    lastVerified: string;      // "2024-12-01"
    notes?: string;           // Any discrepancies or special conditions
  };
}
```

#### Single Engine Aircraft WITH SOURCES:

**Cessna 172M (1974) - FULL SOURCE DOCUMENTATION**
```typescript
const cessna172M = {
  emptyWeight: {
    value: 1466,
    unit: 'lbs',
    sources: {
      primary: {
        document: "POH 172M/Skyhawk II, Revision 8",
        section: "Section 6 Weight & Balance, Page 6-2",
        publisher: "Cessna Aircraft Company",
        datePublished: "1974-12-01",
        tcdsNumber: "3A12"
      },
      confidence: 'high',
      lastVerified: "2024-02-08"
    }
  },
  maxGrossWeight: {
    value: 2300,
    unit: 'lbs',
    sources: {
      primary: {
        document: "FAA Type Certificate Data Sheet 3A12",
        section: "Limitations",
        publisher: "FAA Aircraft Certification Office",
        datePublished: "Latest Revision"
      },
      secondary: {
        document: "POH Section 2, Limitations",
        verification: "Confirms TCDS value"
      },
      confidence: 'high'
    }
  }
  // ... continue for all specifications
};
```

#### User-Visible Source Interface:
- **"Show Sources" button** on every specification
- **Expandable source cards** with full citation information
- **Confidence indicators** (green/yellow/red dots)
- **Last verified dates** prominently displayed
- **Direct links** to online documents when available
- **Conflict warnings** when sources disagree

#### Source Transparency UI Components:
```typescript
// Interactive source transparency system
interface SourceTransparencySystem {
  sourcePanel: {
    expandable: boolean;
    touchOptimized: boolean;
    offlineAccess: boolean;
    conflictResolution: boolean;
  };
  regulatoryCompliance: {
    farReferences: string[];
    advisoryCirculars: string[];
    tcdsVerification: boolean;
    currentStatus: 'current' | 'outdated' | 'pending';
  };
  userInterface: {
    confidenceColors: {
      high: '#34D399';    // Green
      medium: '#FBBF24';  // Yellow
      low: '#F87171';     // Red
    };
    sourceIcons: {
      poh: '📖';
      tcds: '🏛️';
      manufacturer: '🏭';
      faa: '🛡️';
    };
  };
}
```

**Source Display Components:**
- **Specification Detail Cards**: Each weight/arm value shows source button
- **Source Modal**: Full-screen source information with document previews
- **Verification Status Bar**: Top-level currency indicator for all data
- **Conflict Alert System**: Prominent warnings when sources disagree
- **Offline Source Cache**: Downloadable source summaries for offline reference

#### Single Engine Aircraft:
**Cessna 172M (1974)**
- Empty Weight: 1,466 lbs
- Maximum Gross Weight: 2,300 lbs
- Useful Load: 834 lbs
- Fuel Capacity: 43 gallons usable (258 lbs at 6 lbs/gal)
- Fuel Arm: 48 inches
- Front Seats Arm: 37 inches
- Rear Seats Arm: 73 inches
- Baggage Area 1 Arm: 95 inches
- Baggage Area 2 Arm: 123 inches
- Max Baggage: 120 lbs
- CG Range: 35-47 inches aft of datum
- Datum: Leading edge of wing

**Beechcraft Bonanza A36**
- Empty Weight: 2,450 lbs
- Maximum Gross Weight: 3,650 lbs
- Useful Load: 1,200 lbs
- Fuel Capacity: 74 gallons usable (444 lbs)
- Fuel Arm: 75 inches
- Front Seats Arm: 80.5-87 inches (adjustable)
- Rear Seats Arm: 118 inches
- Baggage Compartment: 37 cu ft, 400 lbs max
- Baggage Arm: 142 inches
- CG Range: 80-90 inches aft of datum

**Piper Cherokee Six PA-32-300**
- Empty Weight: 1,780 lbs
- Maximum Gross Weight: 3,400 lbs
- Useful Load: 1,620 lbs
- Fuel Capacity: 84 gallons usable (504 lbs)
- Fuel Arm: 95 inches
- Front Seats Arm: 85 inches
- Middle Seats Arm: 117 inches
- Rear Seats Arm: 142 inches
- Baggage Area: 200 lbs max
- Baggage Arm: 150 inches
- CG Range: 83-95 inches aft of datum

#### Twin Engine Aircraft:
**Piper Navajo Chieftain PA-31-350**
- Empty Weight: 4,221 lbs
- Maximum Gross Weight: 7,000 lbs
- Useful Load: 2,779 lbs
- Fuel Capacity: 
  - Main Tanks: 182 gallons usable (1,092 lbs)
  - Optional Nacelle Tanks: 54 gallons (324 lbs)
- Fuel Arms: 
  - Main Tanks: 95 inches
  - Nacelle Tanks: 125 inches
- Seating Configuration: Up to 10 passengers
- Pilot/Copilot Arm: 72 inches
- Passenger Rows Arms: 96, 120, 144, 168, 192 inches
- Baggage Compartments: 
  - Forward: 350 lbs, arm 65 inches
  - Aft: 350 lbs, arm 185 inches
- CG Range: 81-93 inches aft of datum

### 2. iPhone-Native User Interface Design
Create a native iOS-feeling Progressive Web App optimized for iPhone interaction:

#### iPhone-Specific Design Requirements:
1. **iOS Native Feel**
   - iOS-style navigation with swipe gestures
   - Native iOS form controls and input styles
   - iOS-standard spacing and typography (San Francisco font)
   - iOS color schemes and visual hierarchy
   - Support for iOS Dark Mode with automatic switching

2. **Touch-Optimized Interactions**
   - Minimum 44pt touch targets for all interactive elements
   - Swipe gestures for navigation between aircraft/calculations
   - Pull-to-refresh for updating aircraft database
   - Long-press context menus for advanced options
   - Haptic feedback for important interactions
   - iOS-style picker wheels for weight selection

3. **iPhone Screen Optimization**
   - Responsive design for iPhone SE to iPhone 16 Pro Max
   - Safe area handling for notch/Dynamic Island
   - Optimized layouts for both portrait and landscape
   - Collapsible sections to maximize screen real estate
   - Sticky headers and floating action buttons

#### Main Interface Components:

1. **Aircraft Selection Interface**
   - iOS-style search bar with real-time filtering
   - Sectioned list with aircraft categories (Single Engine, Twin Engine, etc.)
   - Swipe actions for favorites/recent aircraft
   - 3D Touch/Haptic Touch previews of aircraft specs
   - Custom aircraft addition capability

2. **Interactive Weight Input System**
   - **Seat Configuration View**: 
     - Visual aircraft cabin layout with touch-to-select seats
     - Drag-and-drop passenger assignment
     - Weight sliders with haptic feedback at limits
     - Quick preset buttons (standard weights: 170, 190 lbs)
   
   - **Fuel Loading Interface**:
     - Visual fuel tank representation
     - Slider controls with gallon/pound conversion
     - Quick-fill buttons (Full, Tabs, Custom amounts)
     - Fuel burn calculator with time/rate inputs
   
   - **Baggage & Cargo**:
     - Multiple compartment visual layout
     - Weight distribution visualization
     - Photo attachment for cargo documentation
     - Barcode scanning for standard cargo weights

3. **Real-time Interactive Dashboard**
   - **Live CG Indicator**: Real-time needle gauge showing current CG position
   - **Weight Progress Bars**: Visual indicators for each weight category
   - **Interactive CG Envelope**: Touch to see effects of weight changes
   - **3D Aircraft Model**: Rotate to see weight distribution
   - **Alert System**: iOS-native notifications for limit violations

4. **Advanced iPhone Features**
   - **Siri Integration**: "Hey Siri, calculate weight for Cessna 172"
   - **Share Sheet Integration**: Export to other aviation apps
   - **Apple Wallet Integration**: Save frequent configurations
   - **iCloud Sync**: Sync calculations across devices
   - **Apple Pencil Support**: Handwritten weight notes (iPad)

#### Interactive Charts and Visualizations:
1. **3D Interactive CG Envelope**
   - Pinch-to-zoom, rotate gestures
   - Real-time loading point with smooth animations
   - Multiple loading scenarios comparison
   - What-if scenario sliders

2. **Animated Weight Distribution**
   - Real-time pie charts with touch interaction
   - Expandable sections showing weight breakdown
   - Side-by-side comparison views
   - Historical loading comparisons

3. **Interactive Aircraft Diagram**
   - Touch different areas to input weights
   - Visual weight indicators on aircraft silhouette
   - CG shift animation during fuel burn
   - Augmented reality aircraft overlay (future feature)

### 3. VS Code + Xcode Development Workflow

#### VS Code Setup Requirements:
```json
// .vscode/settings.json
{
  "typescript.preferences.includePackageJsonAutoImports": "on",
  "emmet.includeLanguages": {
    "typescript": "typescriptreact",
    "javascript": "javascriptreact"
  },
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode"
}

// .vscode/extensions.json
{
  "recommendations": [
    "bradlc.vscode-tailwindcss",
    "ms-vscode.vscode-typescript-next",
    "esbenp.prettier-vscode",
    "ms-vscode.vscode-eslint",
    "formulahendry.auto-rename-tag",
    "ms-vscode.vscode-json",
    "yoavbls.pretty-ts-errors"
  ]
}
```

#### iPhone 17 Pro Max Testing Setup:
```javascript
// Development configuration for iPhone 17 Pro Max
const iPhone17ProMaxConfig = {
  screen: {
    width: 430,      // Points
    height: 932,     // Points
    scale: 3,        // 3x Retina
    safeAreaTop: 59, // Dynamic Island
    safeAreaBottom: 34,
    cornerRadius: 55 // Display corner radius
  },
  gestures: {
    homeIndicator: true,
    backGesture: 'edge',
    dynamicIsland: true
  },
  performance: {
    targetFPS: 120,   // ProMotion display
    a17ProOptimization: true,
    metalSupport: true
  }
};
```

#### Xcode Integration for Testing:
```bash
# Create iOS-ready build
npm run build:ios
# Generates optimized build for iOS Safari/PWA testing

# Xcode project setup (for future native conversion)
npx cap init "GA Weight Balance" com.yourcompany.gaweightbalance
npx cap add ios
npx cap sync ios
npx cap open ios
```

#### VS Code Live Testing Workflow:
```javascript
// vite.config.ts - Optimized for iPhone testing
export default defineConfig({
  server: {
    host: '0.0.0.0', // Allow iPhone connection
    port: 3000,
    https: true,     // Required for PWA features
  },
  build: {
    target: 'es2020',
    rollupOptions: {
      output: {
        manualChunks: {
          'ios-vendor': ['react', 'react-dom'],
          'charts': ['recharts', 'framer-motion'],
          'calculations': ['./src/utils/calculations']
        }
      }
    }
  }
});
```

#### iPhone Development Tools Integration:
```typescript
// Debug tools for iPhone 17 Pro Max testing
interface iPhoneDebugTools {
  deviceInfo: {
    model: 'iPhone17,1'; // iPhone 17 Pro Max identifier
    screen: typeof iPhone17ProMaxConfig.screen;
    capabilities: string[];
  };
  performance: {
    fpsMonitor: boolean;
    memoryUsage: boolean;
    touchLatency: boolean;
  };
  pwa: {
    installPrompt: boolean;
    offlineMode: boolean;
    serviceWorkerStatus: boolean;
  };
}
```

#### Frontend Framework & iPhone Integration:
- **React 18+ with iOS-specific hooks and components**
- **TypeScript with strict type safety**
- **Tailwind CSS with iOS-specific design tokens**
- **Framer Motion for iOS-native animations**
- **React Hook Form with iOS input validation**
- **React Spring for smooth gesture animations**

#### iPhone PWA Requirements:
- **Full-screen app experience** (no Safari chrome)
- **iOS app icon and splash screens** (all required sizes)
- **Native iOS installation prompts**
- **iOS 16+ compatibility** with latest web APIs
- **Offline-first architecture** with service workers
- **Background sync** for data updates

#### iPhone-Specific Features:
```javascript
// iOS-specific functionality
interface iPhoneFeatures {
  hapticFeedback: {
    impact: 'light' | 'medium' | 'heavy';
    notification: 'success' | 'warning' | 'error';
  };
  gestures: {
    swipeNavigation: boolean;
    pinchZoom: boolean;
    longPress: boolean;
  };
  nativeIntegration: {
    shareSheet: boolean;
    siriShortcuts: boolean;
    appleWallet: boolean;
    icloudSync: boolean;
  };
}
```

#### Performance Optimization for iPhone:
- **Lazy loading** of aircraft databases
- **Image optimization** for Retina displays
- **Touch response optimization** (<100ms response time)
- **Memory management** for older iPhone models
- **Battery optimization** with efficient rendering

#### Calculation Engine with Real-time Updates:
```javascript
// Enhanced calculation engine for real-time iPhone interaction
interface WeightBalanceCalculator {
  aircraft: AircraftConfiguration;
  realTimeUpdates: boolean;
  debounceMs: 150; // Optimized for touch input
  validation: {
    immediate: boolean;
    warnings: AlertLevel[];
    hapticFeedback: boolean;
  };
}

interface InteractiveStation {
  id: string;
  name: string;
  weight: number;
  arm: number;
  position: { x: number; y: number }; // For touch interaction
  limits: { min: number; max: number };
  touchTarget: { width: number; height: number };
}
```

### 4. Safety Features
- **Warning Systems**: 
  - Red alerts for over-limits conditions
  - Yellow cautions for near-limits
  - Clear messaging about consequences
- **Regulatory Compliance**: 
  - Include FAR 91.103 references
  - Disclaimer about pilot responsibility
  - Links to official aircraft POH requirements
- **Validation Rules**:
  - Prevent negative weights
  - Enforce maximum weights per station
  - Check fuel capacity limits
  - Validate reasonable passenger weights

### 5. Advanced iPhone Integration Features

#### Native iOS Capabilities:
- **Siri Shortcuts Integration**: 
  - "Calculate weight for my Bonanza"
  - "What's my current center of gravity?"
  - Voice input for passenger weights
- **Share Sheet Integration**: 
  - Send calculations to ForeFlight
  - Email weight & balance sheets
  - AirDrop to other devices
- **iOS Widgets** (if PWA supports):
  - Quick aircraft selection widget
  - Current weight status widget
- **Apple Wallet Integration**:
  - Save frequent configurations as passes
  - Quick access to aircraft specs

#### Camera Integration:
- **Document Scanning**: Scan aircraft weight & balance documents
- **QR Code Integration**: Quick aircraft setup from QR codes
- **Photo Documentation**: Attach photos of loading configurations

#### Advanced Calculations:
- **Real-time Fuel Burn Modeling**: 
  - GPS integration for real-time position
  - Weather integration for adjusted burn rates
  - Landing weight predictions
- **Load Optimization Engine**: 
  - AI-suggested optimal loading configurations
  - Multiple passenger/cargo scenarios
  - Weight distribution recommendations
- **Flight Planning Integration**:
  - Import from popular flight planning apps
  - Export to navigation systems
  - Fuel stop planning with weight considerations

#### Professional Features:
- **Multi-Aircraft Fleet Management**:
  - Save multiple aircraft configurations
  - Fleet-wide weight tracking
  - Maintenance weight updates
- **Regulatory Compliance Tools**:
  - Digital logbook integration
  - Weight & balance history tracking
  - Regulatory change notifications
- **Advanced Reporting**:
  - PDF generation with graphics
  - Detailed moment calculations
  - Historical trending analysis

### 6. iPhone-Native PWA Implementation

#### iOS Progressive Web App Requirements:
- **Standalone App Mode**: Full-screen experience without Safari UI
- **iOS App Icons**: All required icon sizes (120x120, 152x152, 167x167, 180x180, 1024x1024)
- **Launch Screens**: Custom splash screens for all iPhone screen sizes
- **iOS-specific Manifest**: 
```json
{
  "name": "GA Weight & Balance",
  "short_name": "W&B Calc",
  "display": "standalone",
  "orientation": "portrait-primary",
  "theme_color": "#007AFF",
  "background_color": "#000000",
  "start_url": "/",
  "icons": [...],
  "apple-touch-startup-image": [...],
  "apple-mobile-web-app-capable": "yes",
  "apple-mobile-web-app-status-bar-style": "black-translucent"
}
```

#### iPhone-Specific Optimizations:
- **Touch Response**: <100ms response time for all interactions
- **Smooth Scrolling**: 60fps performance on all iPhone models
- **Memory Management**: Efficient handling for iPhone SE/older models  
- **Battery Optimization**: Minimize CPU usage during calculations
- **Network Optimization**: Intelligent caching and background sync

#### Offline Capabilities:
- **Complete Aircraft Database**: Cached for offline use
- **Calculation History**: Stored locally with iCloud backup
- **Document Storage**: Save weight & balance sheets offline
- **Background Sync**: Update database when connection available

#### iPhone Gestures & Interactions:
```javascript
// iPhone-specific gesture handling
interface iPhoneGestures {
  swipeNavigation: {
    leftToRight: 'back' | 'previous_aircraft';
    rightToLeft: 'forward' | 'next_aircraft';
  };
  pinchZoom: {
    target: 'cg_chart' | 'aircraft_diagram';
    minScale: 0.5;
    maxScale: 3.0;
  };
  longPress: {
    duration: 500; // ms
    actions: 'context_menu' | 'quick_edit';
  };
  hapticFeedback: {
    selection: 'light';
    warning: 'medium';
    error: 'heavy';
  };
}
```

#### iOS Integration APIs:
- **Web Share API**: Native iOS sharing experience
- **Device Orientation**: Landscape/portrait optimization
- **Vibration API**: Haptic feedback for alerts
- **Web App Manifest**: Native app-like installation
- **Service Worker**: Reliable offline functionality

## Implementation Instructions

### Phase 0: Research & Discovery (REQUIRED FIRST)
1. **Aircraft Database Research**:
   - Search for latest POH specifications for all target aircraft
   - Find current weight & balance data from manufacturers
   - Research STC modifications affecting weight/CG
   - Verify fuel capacity and arm data accuracy

2. **Competitive Analysis**:
   - Analyze ForeFlight W&B features and UI patterns
   - Study Garmin Pilot weight & balance interface
   - Research existing aviation calculator apps on iOS
   - Document best practices and user experience patterns

3. **iOS Design Research**:
   - Review current iOS Human Interface Guidelines
   - Research aviation app accessibility requirements
   - Study successful PWA implementations on iOS
   - Analyze touch interaction patterns for data entry apps

### Phase 1: VS Code Setup and iPhone 17 Pro Max Foundation
1. **VS Code Environment Setup**:
   - Install required extensions for React/TypeScript development
   - Configure debugging for iPhone Safari remote debugging
   - Set up live reload server accessible from iPhone
   - Configure source control for Xcode integration

2. **iPhone 17 Pro Max Optimization**:
   - Implement 120Hz ProMotion display optimization
   - Configure Dynamic Island safe area handling
   - Set up A17 Pro chip performance profiling
   - Test camera integration for document scanning

3. **Xcode Testing Pipeline**:
   ```bash
   # VS Code to Xcode workflow
   npm run dev                    # Start dev server for iPhone testing
   npm run build:ios             # Generate iOS-optimized build
   npm run test:iphone           # Run automated iPhone tests
   npx cap sync ios && npx cap open ios  # Open in Xcode for device testing
   ```

4. **Source Transparency Implementation**:
   - Build source attribution database
   - Create expandable source UI components  
   - Implement offline source caching
   - Add regulatory compliance verification system

### Phase 2: Source-Verified Calculation Engine
1. **Research and Data Verification**:
   - Cross-reference all aircraft specifications with official sources
   - Document source conflicts and resolution methodology
   - Build confidence rating system for all data points
   - Create source update notification system

2. **iPhone 17 Pro Max Calculation Optimization**:
   - Implement real-time calculations optimized for A17 Pro chip
   - Add 120Hz display-optimized animations
   - Create touch-optimized input with haptic feedback
   - Build gesture-based navigation for source viewing

### Phase 3: Complete Aircraft Database with Full Attribution
1. **Comprehensive Source Documentation**:
   - Add all aircraft with complete source attribution
   - Implement source conflict resolution interface
   - Create regulatory compliance verification
   - Build offline source document cache

2. **iPhone Testing and Validation**:
   - Test on iPhone 17 Pro Max with all screen orientations
   - Validate touch targets and gesture recognition
   - Test Dynamic Island integration and safe areas
   - Verify PWA installation and offline functionality

### Phase 4: Advanced iPhone Features & Xcode Integration
1. **Native iOS Feature Integration**:
   - Implement Siri Shortcuts with source attribution
   - Add share sheet with source references
   - Create camera integration for POH scanning
   - Build iCloud sync for source verification history

2. **Xcode Testing Pipeline**:
   - Set up automated testing in Xcode Simulator
   - Create device testing workflow for iPhone 17 Pro Max
   - Implement performance monitoring and optimization
   - Add crash reporting and analytics

### Phase 5: Source Transparency & Professional Deployment
1. **Complete Source System**:
   - Finalize source transparency interface
   - Add regulatory compliance dashboard  
   - Implement source update notifications
   - Create professional source citation exports

2. **iPhone 17 Pro Max Production Optimization**:
   - Final performance tuning for 120Hz display
   - Optimize for A17 Pro chip efficiency
   - Test battery usage and thermal management
   - Validate all iPhone-specific features

### Phase 6: Testing & Validation
1. Test on all iPhone models and iOS versions
2. Validate calculations against official aircraft POH data
3. Conduct usability testing with actual pilots
4. Performance testing on older iPhone hardware
5. Accessibility testing for aviation requirements

## VS Code + Xcode File Structure
```
project-root/
├── .vscode/
│   ├── settings.json
│   ├── extensions.json
│   ├── launch.json          # iPhone debugging config
│   └── tasks.json           # Xcode integration tasks
├── ios/                     # Xcode project (if converting to native)
│   ├── App/
│   └── App.xcodeproj
├── src/
│   ├── components/
│   │   ├── ios/
│   │   │   ├── iOSNavigationBar.tsx
│   │   │   ├── iPhone17ProMaxOptimized.tsx
│   │   │   └── DynamicIslandHandler.tsx
│   │   ├── sources/
│   │   │   ├── SourcePanel.tsx
│   │   │   ├── SourceVerification.tsx
│   │   │   ├── RegulatoryCompliance.tsx
│   │   │   └── SourceConflictResolver.tsx
│   │   └── aircraft/
│   │       ├── AircraftSelector.tsx
│   │       └── SpecificationWithSources.tsx
│   ├── data/
│   │   ├── sources/
│   │   │   ├── sourceDatabase.ts
│   │   │   ├── regulatoryRefs.ts
│   │   │   └── verificationStatus.ts
│   │   └── aircraft/
│   │       ├── cessna172WithSources.ts
│   │       └── sourceAttributed/
├── public/
│   ├── sources/
│   │   ├── poh-excerpts/     # Cached POH sections
│   │   ├── tcds-data/        # Type certificate data
│   │   └── regulatory/       # FAR/AC references
│   └── ios/
│       ├── icons/           # All iPhone icon sizes
│       └── splash/          # iPhone 17 Pro Max splash screens
├── scripts/
│   ├── build-ios.js        # iOS-specific build
│   ├── test-iphone.js      # iPhone testing automation
│   └── xcode-sync.js       # Sync with Xcode project
└── capacitor.config.ts     # Capacitor config for Xcode
```

### iPhone 17 Pro Max Testing Requirements

#### VS Code Testing Workflow:
```bash
# Start development with iPhone testing
npm run dev:iphone          # Optimized for iPhone 17 Pro Max
npm run test:sources        # Verify all source attributions
npm run validate:accuracy   # Test calculation accuracy
npm run build:ios-debug     # Debug build for Xcode testing
```

#### Xcode Device Testing:
1. **Physical Device Testing on iPhone 17 Pro Max**:
   - Touch responsiveness and gesture recognition
   - 120Hz ProMotion display performance
   - Dynamic Island interaction testing
   - Camera integration for document scanning
   - Offline functionality validation

2. **Source Transparency Testing**:
   - Verify all specifications show proper sources
   - Test source panel expansion and interaction
   - Validate regulatory compliance displays
   - Check source conflict resolution interface
   - Test offline source document access

3. **Performance Testing**:
   - Memory usage monitoring during extended use
   - Battery impact assessment
   - Thermal performance under heavy calculation load
   - Network usage for source verification updates

## Testing Requirements

### Research Validation Testing
1. **Aircraft Data Accuracy**:
   - Cross-reference all specifications with official POH documents
   - Validate calculations against known weight & balance examples
   - Test edge cases and limit conditions
   - Verify regulatory compliance

2. **Competitive Feature Analysis**:
   - Compare features against ForeFlight and Garmin Pilot
   - Benchmark user experience patterns
   - Validate industry-standard terminology and units

### iPhone-Specific Testing
1. **Device Compatibility**:
   - Test on iPhone SE (smallest screen) through iPhone 16 Pro Max
   - Verify iOS 15+ compatibility
   - Test performance on older hardware (iPhone 11, 12)
   - Validate memory usage and battery impact

2. **Touch & Gesture Testing**:
   - Verify all touch targets meet 44pt minimum
   - Test gesture recognition accuracy (swipe, pinch, long-press)
   - Validate haptic feedback timing and intensity
   - Test keyboard and input behavior

3. **PWA Installation & Functionality**:
   - Test iOS home screen installation process
   - Verify full-screen standalone mode operation
   - Test offline functionality and data persistence
   - Validate background sync when app returns online

### Calculation Accuracy Testing
1. **Known Configuration Testing**:
   - Test with official aircraft loading examples
   - Validate against flight school training scenarios  
   - Cross-check with multiple aircraft POH documents
   - Test boundary conditions and weight limits

2. **Real-time Calculation Performance**:
   - Verify <100ms response time on all devices
   - Test calculation accuracy during rapid input changes
   - Validate precision of moment calculations
   - Test fuel burn predictions

### User Experience Testing
1. **Pilot Usability Testing**:
   - Test with actual pilots of varying experience levels
   - Validate terminology and workflow patterns
   - Test under realistic pre-flight conditions
   - Gather feedback on safety and trust factors

2. **Accessibility Testing**:
   - Test with VoiceOver and screen readers
   - Verify color contrast for aviation lighting conditions
   - Test with various font sizes and iOS accessibility settings
   - Validate aviation-specific accessibility requirements

### Performance & Reliability Testing
1. **Load & Performance Testing**:
   - Test with multiple aircraft configurations loaded
   - Verify smooth 60fps animations on all devices
   - Test memory usage with extensive calculation history
   - Validate battery usage during extended sessions

2. **Network & Offline Testing**:
   - Test offline functionality completely disconnected
   - Verify data sync when connectivity returns
   - Test partial connectivity scenarios
   - Validate service worker cache behavior

## Success Criteria

### Source Transparency & Trust Goals
- **Complete Source Attribution**: Every specification linked to official documents with dates
- **Regulatory Compliance**: All FAR/AC references current and properly cited
- **Source Conflict Resolution**: Clear handling of conflicting specifications
- **Trust Indicators**: Confidence levels and verification dates visible to users
- **Offline Source Access**: Key source information available without internet

### iPhone 17 Pro Max Specific Goals
- **120Hz Performance**: Smooth animations utilizing ProMotion display
- **Dynamic Island Integration**: Proper safe area handling and status display
- **A17 Pro Optimization**: Efficient calculation performance using chip capabilities
- **Camera Features**: Document scanning and QR code integration working perfectly
- **Native Feel**: Indistinguishable from App Store aviation applications

### User Experience Goals
- **Intuitive for Pilots**: Workflow matches pilot training and habits
- **Safety-Focused**: Clear warnings and regulatory compliance
- **Native iOS Feel**: Indistinguishable from native iPhone apps
- **Accessibility**: Meets aviation industry accessibility standards
- **Reliability**: Stable performance under real-world flight planning conditions

### Research & Validation Goals
- **Industry-Standard Data**: All aircraft specifications verified against manufacturer sources
- **Competitive Feature Parity**: Match or exceed existing aviation calculator capabilities
- **Regulatory Compliance**: Meet all applicable FAA requirements
- **Professional Acceptance**: Suitable for use by commercial pilots and flight schools

## Additional Considerations

### Research & Data Management
- **Continuous Aircraft Database Updates**: Plan for new aircraft additions and specification changes
- **Manufacturer Relationship**: Consider partnerships for official aircraft data
- **STC Tracking**: Include supplemental type certificate modifications
- **International Variants**: Research metric vs. imperial unit handling for global use

### iPhone Ecosystem Integration
- **App Store Optimization**: If transitioning from PWA to native app
- **iOS Widget Support**: Future integration with iPhone home screen widgets  
- **Apple Watch Companion**: Consider weight monitoring on Apple Watch
- **AirPlay Support**: Display calculations on external screens
- **Handoff Integration**: Continue calculations across iPhone, iPad, Mac

### Professional Aviation Integration
- **FBO Integration**: Connect with fixed-base operator systems
- **Flight School Adoption**: Bulk licensing and educational features
- **Maintenance Integration**: Link with aircraft maintenance tracking systems
- **Insurance Requirements**: Ensure compliance with aviation insurance standards

### Scalability & Business Model
- **Fleet Management**: Scale for flight training organizations
- **API Development**: Allow integration with other aviation software
- **Data Analytics**: Anonymized usage patterns for safety insights
- **Subscription Model**: Professional features and enhanced aircraft database

### Future Enhancement Roadmap
- **Weather Integration**: Factor weather conditions into weight planning
- **Performance Calculator**: Expand beyond weight & balance to takeoff/landing performance
- **Flight Planning Integration**: Connect with navigation and fuel planning systems
- **AI Optimization**: Machine learning for optimal loading suggestions
- **Regulatory Updates**: Automatic compliance with changing aviation regulations

### Security & Privacy Considerations
- **Data Privacy**: Ensure flight planning data remains private
- **Backup & Recovery**: Reliable data backup for critical flight information
- **Security Audit**: Regular security reviews for aviation-critical applications
- **GDPR Compliance**: International data privacy requirements

Remember: This app handles safety-critical information for aviation with full source transparency. Users must be able to verify every specification against official documents. Prioritize accuracy, source attribution, and clear communication of data limitations throughout development.

## VS Code Development Workflow:
1. **Start with research** - Verify all sources before writing any code
2. **Build incrementally** - Test each feature on iPhone 17 Pro Max as developed
3. **Source-first approach** - Every specification needs source attribution from day one
4. **Xcode integration** - Prepare for potential native app conversion
5. **Safety mindset** - Include appropriate disclaimers and regulatory compliance

## iPhone 17 Pro Max Testing Protocol:
- **Daily device testing** during development
- **Source verification** on actual device interface
- **Performance monitoring** with A17 Pro chip optimization
- **Camera integration** testing with real POH documents
- **Offline functionality** validation in airplane mode

The goal is a production-ready aviation tool that pilots can trust for actual flight planning, with complete transparency about data sources and regulatory compliance.
