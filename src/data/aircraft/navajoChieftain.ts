import type { Aircraft } from '../../types/aircraft';

const pohSource = {
  document: 'POH VB-1204, Piper Navajo Chieftain PA-31-350',
  section: 'Section 6 - Weight & Balance',
  publisher: 'Piper Aircraft Corporation',
  datePublished: '1983-01-01',
};

const tcdsSource = {
  document: 'FAA Type Certificate Data Sheet A20SO',
  section: 'Limitations',
  publisher: 'FAA Aircraft Certification Office',
  datePublished: '2005-07-06',
};

export const navajoChieftain: Aircraft = {
  id: 'navajo-chieftain-pa31',
  name: 'Piper Navajo Chieftain PA-31-350',
  model: 'PA-31-350',
  manufacturer: 'Piper Aircraft Corporation',
  year: '1983',
  category: 'multi-engine',

  emptyWeight: {
    value: 4319,
    unit: 'lbs',
    source: {
      primary: { ...pohSource, section: 'Section 6, Weight & Balance Data' },
      secondary: {
        document: 'AOPA Aircraft Guide - Piper Chieftain PA-31-350',
        verification: 'Confirms typical empty weight of 4,319 lbs for production model',
        dateVerified: '2025-02-08',
      },
      confidence: 'medium',
      lastVerified: '2026-02-08',
      notes: 'Typical empty weight per AOPA. Actual varies significantly with installed equipment. ALWAYS use aircraft-specific W&B record for actual operations.',
    },
  },

  emptyWeightArm: {
    value: 132.0,
    unit: 'inches',
    source: {
      primary: { ...pohSource, section: 'Section 6, Weight & Balance Data' },
      confidence: 'medium',
      lastVerified: '2026-02-10',
      notes: 'Typical empty weight CG. MUST be replaced with aircraft-specific value from individual W&B record.',
    },
  },

  maxGrossWeight: {
    value: 7000,
    unit: 'lbs',
    source: {
      primary: tcdsSource,
      secondary: {
        document: 'POH Section 2, Limitations',
        verification: 'Confirms TCDS value of 7,000 lbs max takeoff weight',
      },
      confidence: 'high',
      lastVerified: '2026-02-10',
      notes: 'Max ramp weight is 7,045 lbs (45 lbs allowance for taxi fuel burn).',
    },
  },

  usefulLoad: {
    value: 2681,
    unit: 'lbs',
    source: {
      primary: { ...pohSource, section: 'Section 6' },
      confidence: 'medium',
      lastVerified: '2026-02-10',
      notes: 'Max gross (7,000) minus typical empty weight (4,319). Varies per aircraft — use aircraft-specific W&B record.',
    },
  },

  datum: '137 inches ahead of wing main spar centerline',

  cgRange: {
    forward: {
      value: 120,
      unit: 'inches',
      source: {
        primary: { ...tcdsSource, section: 'CG Range' },
        secondary: {
          document: 'POH Section 6, CG Envelope',
          verification: 'Forward limit 120" at ≤5,200 lbs, increasing linearly to 126" at 7,000 lbs',
        },
        confidence: 'high',
        lastVerified: '2026-02-10',
        notes: 'Weight-dependent forward limit: 120.0" aft of datum at ≤5,200 lbs, linearly increasing to 126.0" at 7,000 lbs.',
      },
    },
    aft: {
      value: 135,
      unit: 'inches',
      source: {
        primary: { ...tcdsSource, section: 'CG Range' },
        confidence: 'high',
        lastVerified: '2026-02-10',
      },
    },
  },

  cgEnvelope: {
    points: [
      { weight: 4319, cg: 120 },
      { weight: 5200, cg: 120 },
      { weight: 7000, cg: 126 },
      { weight: 7000, cg: 135 },
      { weight: 4319, cg: 135 },
    ],
    source: {
      primary: { ...pohSource, section: 'Section 6, CG Envelope Chart' },
      confidence: 'high',
      lastVerified: '2026-02-10',
      notes: 'Weight-dependent forward CG limit. Forward limit is 120" at ≤5,200 lbs, linearly increasing to 126" at 7,000 lbs. Aft limit is 135" at all weights.',
    },
  },

  stations: [
    {
      id: 'pilot-copilot',
      name: 'Pilot & Copilot',
      arm: {
        value: 95.0,
        unit: 'inches',
        source: {
          primary: { ...pohSource, section: 'Section 6, Loading Arrangements' },
          confidence: 'high',
          lastVerified: '2026-02-10',
        },
      },
      maxWeight: 400,
    },
    {
      id: 'row-2',
      name: 'Passengers Row 2 (3rd & 4th)',
      arm: {
        value: 131.0,
        unit: 'inches',
        source: {
          primary: { ...pohSource, section: 'Section 6, Loading Arrangements' },
          confidence: 'high',
          lastVerified: '2026-02-10',
        },
      },
      maxWeight: 400,
    },
    {
      id: 'row-3',
      name: 'Passengers Row 3 (5th & 6th)',
      arm: {
        value: 164.0,
        unit: 'inches',
        source: {
          primary: { ...pohSource, section: 'Section 6, Loading Arrangements' },
          confidence: 'high',
          lastVerified: '2026-02-10',
        },
      },
      maxWeight: 400,
    },
    {
      id: 'row-4',
      name: 'Passengers Row 4 (7th & 8th)',
      arm: {
        value: 190.0,
        unit: 'inches',
        source: {
          primary: { ...pohSource, section: 'Section 6, Loading Arrangements' },
          confidence: 'high',
          lastVerified: '2026-02-10',
        },
      },
      maxWeight: 400,
    },
    {
      id: 'nose-baggage',
      name: 'Nose Baggage',
      arm: {
        value: 19.0,
        unit: 'inches',
        source: {
          primary: { ...pohSource, section: 'Section 6, Baggage Compartments' },
          confidence: 'high',
          lastVerified: '2026-02-10',
        },
      },
      maxWeight: 200,
    },
    {
      id: 'nacelle-lockers',
      name: 'Nacelle Lockers (L+R)',
      arm: {
        value: 145.0,
        unit: 'inches',
        source: {
          primary: { ...pohSource, section: 'Section 6, Baggage Compartments' },
          confidence: 'high',
          lastVerified: '2026-02-10',
          notes: 'Forward section arm 145". Maximum 150 lbs per side, 300 lbs total.',
        },
      },
      maxWeight: 300,
    },
    {
      id: 'aft-baggage',
      name: 'Aft Baggage',
      arm: {
        value: 255.0,
        unit: 'inches',
        source: {
          primary: { ...pohSource, section: 'Section 6, Baggage Compartments' },
          confidence: 'high',
          lastVerified: '2026-02-10',
        },
      },
      maxWeight: 200,
    },
  ],

  fuelTanks: [
    {
      id: 'inboard-fuel',
      name: 'Inboard Tanks (L+R)',
      arm: {
        value: 126.8,
        unit: 'inches',
        source: {
          primary: { ...pohSource, section: 'Section 6, Fuel Loading' },
          confidence: 'high',
          lastVerified: '2026-02-10',
        },
      },
      maxGallons: {
        value: 112,
        unit: 'gallons',
        source: {
          primary: { ...pohSource, section: 'Section 6, Fuel Capacity' },
          confidence: 'high',
          lastVerified: '2026-02-10',
          notes: '56 gallons per side (inboard cells). All 112 gallons usable.',
        },
      },
      fuelWeightPerGallon: 6.0,
    },
    {
      id: 'outboard-fuel',
      name: 'Outboard Tanks (L+R)',
      arm: {
        value: 148.0,
        unit: 'inches',
        source: {
          primary: { ...pohSource, section: 'Section 6, Fuel Loading' },
          confidence: 'high',
          lastVerified: '2026-02-10',
        },
      },
      maxGallons: {
        value: 70,
        unit: 'gallons',
        source: {
          primary: { ...pohSource, section: 'Section 6, Fuel Capacity' },
          confidence: 'high',
          lastVerified: '2026-02-10',
          notes: '40 gallons total per side (outboard cells), 35 usable per side. 80 gal total, 70 usable. 192 gal total capacity, 182 usable across all tanks.',
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
