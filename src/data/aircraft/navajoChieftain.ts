import type { Aircraft } from '../../types/aircraft';

const wbReportSource = {
  document: 'Weight & Balance Report — Colemill Enterprises Inc, Nashville TN',
  section: 'Corrected Empty Weight',
  publisher: 'Albert T MacMillan, A&P/IA (AP 506843185 IA)',
  datePublished: '2008-05-01',
};

const loadingFormSource = {
  document: 'PA-31-350 Navajo Chieftain Weight & Balance Loading Form (N800LP)',
  section: 'Station Arms & Performance Limits',
  publisher: 'Aircraft Owner / Operator',
  datePublished: '2025-01-01',
};

const blrSource = {
  document: 'Super Chieftain I Modification CG Envelope — Boundary Layer Research, Inc.',
  section: 'Section 6 - Weight and Balance, CHIEFTAINT-1020 PA-31-350',
  publisher: 'Boundary Layer Research, Inc.',
  datePublished: '2008-01-01',
};

export const navajoChieftain: Aircraft = {
  id: 'navajo-chieftain-pa31',
  name: 'Piper PA-31-350 Chieftain (Super Chieftain I — N800LP)',
  model: 'PA-31-350',
  manufacturer: 'Piper Aircraft Corporation',
  year: '1983',
  category: 'multi-engine',

  emptyWeight: {
    value: 5082,
    unit: 'lbs',
    source: {
      primary: wbReportSource,
      secondary: {
        document: 'W&B Report Scale Data',
        verification: 'Weighed 26 Mar 2008 at Cornelia Fort Airpark. Total as weighed: 6,206.00 lbs. Less main fuel (-672), aux fuel (-480), plus unusable fuel (+28.20) = 5,082.20 lbs corrected empty weight.',
        dateVerified: '2008-05-01',
      },
      confidence: 'high',
      lastVerified: '2026-02-10',
      notes: 'Aircraft-specific empty weight from official weighing. Seven seats, one toilet, four dividers, two side tables. BLR VGs, stall fences, winglets, 4-blade props installed. Includes 10 gal unusable fuel.',
    },
  },

  emptyWeightArm: {
    value: 122.5,
    unit: 'inches',
    source: {
      primary: { ...loadingFormSource, section: 'Empty Weight Entry' },
      secondary: {
        document: 'W&B Report — Colemill Enterprises',
        verification: 'W&B report shows CG of 125.26" — loading form uses 122.5". Using owner-provided loading form value.',
        dateVerified: '2026-02-10',
      },
      confidence: 'high',
      lastVerified: '2026-02-10',
      notes: 'Per owner\'s loading form. W&B report (Colemill, May 2008) shows 125.26" — discrepancy noted.',
    },
  },

  maxGrossWeight: {
    value: 7368,
    unit: 'lbs',
    source: {
      primary: { ...loadingFormSource, section: 'Performance — Maximum take-off weight' },
      secondary: {
        document: 'Super Chieftain I STC — Boundary Layer Research, Inc.',
        verification: 'BLR Super Chieftain I STC increases max takeoff weight from standard 7,000 to 7,368 lbs',
      },
      confidence: 'high',
      lastVerified: '2026-02-10',
      notes: 'Max TAKEOFF weight per Super Chieftain I STC. Standard PA-31-350 is 7,000 lbs.',
    },
  },

  maxRampWeight: {
    value: 7448,
    unit: 'lbs',
    source: {
      primary: { ...loadingFormSource, section: 'Performance — Maximum ramp weight' },
      confidence: 'high',
      lastVerified: '2026-02-10',
      notes: 'Max ramp weight per Super Chieftain I STC. 80 lb allowance for taxi fuel burn.',
    },
  },

  maxLandingWeight: {
    value: 7000,
    unit: 'lbs',
    source: {
      primary: { ...loadingFormSource, section: 'Performance — Maximum landing weight' },
      secondary: {
        document: 'FAA TCDS A20SO',
        verification: 'Standard PA-31-350 max landing weight of 7,000 lbs confirmed',
      },
      confidence: 'high',
      lastVerified: '2026-02-10',
    },
  },

  usefulLoad: {
    value: 2286,
    unit: 'lbs',
    source: {
      primary: { ...loadingFormSource, section: 'Derived from max takeoff minus empty weight' },
      confidence: 'high',
      lastVerified: '2026-02-10',
      notes: 'Max takeoff (7,368) minus empty weight (5,082) = 2,286 lbs. W&B report shows 2,163 lbs based on earlier 7,245 gross weight.',
    },
  },

  datum: '137 inches ahead of wing main spar centerline',

  cgRange: {
    forward: {
      value: 120,
      unit: 'inches',
      source: {
        primary: { ...blrSource, section: 'Forward CG Limit' },
        confidence: 'high',
        lastVerified: '2026-02-10',
        notes: 'Weight-dependent forward limit: 120" at ≤5,200 lbs, increasing to ~129" at max ramp (7,448 lbs). See CG envelope for precise limits.',
      },
    },
    aft: {
      value: 135,
      unit: 'inches',
      source: {
        primary: { ...blrSource, section: 'Aft CG Limit' },
        confidence: 'high',
        lastVerified: '2026-02-10',
      },
    },
  },

  cgEnvelope: {
    points: [
      { weight: 4000, cg: 120 },
      { weight: 5200, cg: 120 },
      { weight: 5600, cg: 121 },
      { weight: 6200, cg: 122 },
      { weight: 6800, cg: 124 },
      { weight: 7000, cg: 126 },
      { weight: 7200, cg: 127 },
      { weight: 7448, cg: 129 },
      { weight: 7448, cg: 135 },
      { weight: 4000, cg: 135 },
    ],
    source: {
      primary: blrSource,
      secondary: {
        document: 'Owner-provided CG Envelope Chart (photographed)',
        verification: 'Envelope points traced from Super Chieftain I chart. Forward limit read from labeled points: 120, 121, 122, 124, 126, 127. Aft limit ~135".',
        dateVerified: '2026-02-10',
      },
      confidence: 'medium',
      lastVerified: '2026-02-10',
      notes: 'Traced from Super Chieftain I CG envelope chart (Boundary Layer Research). Points are approximate readings from the chart photograph. Pilot should verify against original chart for critical operations.',
    },
  },

  stations: [
    {
      id: 'pilot',
      name: 'Pilot',
      arm: {
        value: 95.0,
        unit: 'inches',
        source: {
          primary: { ...loadingFormSource, section: 'Pilot Station' },
          confidence: 'high',
          lastVerified: '2026-02-10',
        },
      },
      maxWeight: 300,
    },
    {
      id: 'copilot',
      name: 'Copilot',
      arm: {
        value: 95.0,
        unit: 'inches',
        source: {
          primary: { ...loadingFormSource, section: 'Copilot Station' },
          confidence: 'high',
          lastVerified: '2026-02-10',
        },
      },
      maxWeight: 300,
    },
    {
      id: 'fwd-baggage',
      name: 'A — Forward Baggage',
      arm: {
        value: 19.0,
        unit: 'inches',
        source: {
          primary: { ...loadingFormSource, section: 'Station A' },
          confidence: 'high',
          lastVerified: '2026-02-10',
        },
      },
      maxWeight: 200,
    },
    {
      id: 'aft-cockpit',
      name: 'B — Aft Cockpit Storage',
      arm: {
        value: 131.5,
        unit: 'inches',
        source: {
          primary: { ...loadingFormSource, section: 'Station B' },
          confidence: 'high',
          lastVerified: '2026-02-10',
        },
      },
      maxWeight: 100,
    },
    {
      id: 'front-pax',
      name: 'C1 — Front Passengers',
      arm: {
        value: 104.0,
        unit: 'inches',
        source: {
          primary: { ...loadingFormSource, section: 'Station C1' },
          confidence: 'high',
          lastVerified: '2026-02-10',
        },
      },
      maxWeight: 400,
    },
    {
      id: 'rear-pax',
      name: 'C2 — Rear Passengers',
      arm: {
        value: 174.0,
        unit: 'inches',
        source: {
          primary: { ...loadingFormSource, section: 'Station C2' },
          confidence: 'high',
          lastVerified: '2026-02-10',
        },
      },
      maxWeight: 400,
    },
    {
      id: 'back-pax',
      name: 'D — Back Passengers',
      arm: {
        value: 218.0,
        unit: 'inches',
        source: {
          primary: { ...loadingFormSource, section: 'Station D' },
          confidence: 'high',
          lastVerified: '2026-02-10',
        },
      },
      maxWeight: 400,
    },
    {
      id: 'rear-baggage',
      name: 'E — Rear Baggage',
      arm: {
        value: 255.0,
        unit: 'inches',
        source: {
          primary: { ...loadingFormSource, section: 'Station E' },
          confidence: 'high',
          lastVerified: '2026-02-10',
        },
      },
      maxWeight: 200,
    },
    {
      id: 'r-nacelle',
      name: 'F1 — Right Nacelle Baggage',
      arm: {
        value: 192.0,
        unit: 'inches',
        source: {
          primary: { ...loadingFormSource, section: 'Station F1' },
          confidence: 'high',
          lastVerified: '2026-02-10',
        },
      },
      maxWeight: 150,
    },
    {
      id: 'l-nacelle',
      name: 'F2 — Left Nacelle Baggage',
      arm: {
        value: 192.0,
        unit: 'inches',
        source: {
          primary: { ...loadingFormSource, section: 'Station F2' },
          confidence: 'high',
          lastVerified: '2026-02-10',
        },
      },
      maxWeight: 150,
    },
  ],

  fuelTanks: [
    {
      id: 'main-fuel',
      name: 'Main Fuel (Inboard L+R)',
      arm: {
        value: 126.8,
        unit: 'inches',
        source: {
          primary: { ...loadingFormSource, section: 'Main fuel (usable)' },
          confidence: 'high',
          lastVerified: '2026-02-10',
        },
      },
      maxGallons: {
        value: 106,
        unit: 'gallons',
        source: {
          primary: { ...loadingFormSource, section: 'Main fuel capacity' },
          confidence: 'high',
          lastVerified: '2026-02-10',
          notes: '106 gal usable. Total capacity 112 gal (56 per side). 6 gal unusable included in empty weight. [(56 gal x 2 x 6 lbs) - (6 x 6 lbs)]',
        },
      },
      fuelWeightPerGallon: 6.0,
    },
    {
      id: 'aux-fuel',
      name: 'Aux Fuel (Outboard L+R)',
      arm: {
        value: 148.0,
        unit: 'inches',
        source: {
          primary: { ...loadingFormSource, section: 'Aux fuel (usable)' },
          confidence: 'high',
          lastVerified: '2026-02-10',
        },
      },
      maxGallons: {
        value: 76,
        unit: 'gallons',
        source: {
          primary: { ...loadingFormSource, section: 'Aux fuel capacity' },
          confidence: 'high',
          lastVerified: '2026-02-10',
          notes: '76 gal usable. Total capacity 80 gal (40 per side). 4 gal unusable included in empty weight. [(40 gal x 2 x 6 lbs) - (4 x 6 lbs)]',
        },
      },
      fuelWeightPerGallon: 6.0,
    },
  ],

  regulatory: {
    tcdsNumber: 'A20SO',
    farBasis: 'FAR Part 23',
  },
};
