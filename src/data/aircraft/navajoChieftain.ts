import type { Aircraft } from '../../types/aircraft';

const pohSource = {
  document: 'POH VB-1204, Piper Navajo Chieftain PA-31-350',
  section: 'Section 6 - Weight & Balance',
  publisher: 'Piper Aircraft Corporation',
  datePublished: '1982-01-01',
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
  year: '1982',
  category: 'multi-engine',

  emptyWeight: {
    value: 4319,
    unit: 'lbs',
    source: {
      primary: { ...pohSource, section: 'Section 6, Weight & Balance Data' },
      secondary: {
        document: 'AOPA Aircraft Guide - Piper Chieftain PA-31-350',
        verification: 'Confirms typical empty weight of 4,319 lbs for production model',
        dateVerified: '2026-02-08',
      },
      confidence: 'high',
      lastVerified: '2026-02-08',
      notes: 'Typical empty weight per AOPA. Earlier sources cite 4,221 lbs for initial production. Actual varies significantly with installed equipment and year. Always use aircraft-specific W&B record.',
    },
  },

  emptyWeightArm: {
    value: 86.0,
    unit: 'inches',
    source: {
      primary: { ...pohSource, section: 'Section 6, Weight & Balance Data' },
      confidence: 'medium',
      lastVerified: '2024-02-08',
      notes: 'Typical value. Use aircraft-specific W&B record.',
    },
  },

  maxGrossWeight: {
    value: 7000,
    unit: 'lbs',
    source: {
      primary: tcdsSource,
      secondary: {
        document: 'POH Section 2, Limitations',
        verification: 'Confirms TCDS value of 7,000 lbs',
      },
      confidence: 'high',
      lastVerified: '2024-02-08',
    },
  },

  usefulLoad: {
    value: 2681,
    unit: 'lbs',
    source: {
      primary: { ...pohSource, section: 'Section 6' },
      secondary: {
        document: 'AOPA Aircraft Guide - Piper Chieftain PA-31-350',
        verification: 'Confirms useful load of 2,681 lbs',
        dateVerified: '2026-02-08',
      },
      confidence: 'high',
      lastVerified: '2026-02-08',
      notes: 'Max gross (7,000) minus typical empty weight (4,319). Varies per aircraft.',
    },
  },

  datum: 'Nose of aircraft',

  cgRange: {
    forward: {
      value: 81,
      unit: 'inches',
      source: {
        primary: { ...tcdsSource, section: 'CG Range' },
        confidence: 'high',
        lastVerified: '2024-02-08',
      },
    },
    aft: {
      value: 93,
      unit: 'inches',
      source: {
        primary: { ...tcdsSource, section: 'CG Range' },
        confidence: 'high',
        lastVerified: '2024-02-08',
      },
    },
  },

  cgEnvelope: {
    points: [
      { weight: 4319, cg: 81 },
      { weight: 7000, cg: 81 },
      { weight: 7000, cg: 93 },
      { weight: 4319, cg: 93 },
    ],
    source: {
      primary: { ...pohSource, section: 'Section 6, CG Envelope Chart' },
      confidence: 'high',
      lastVerified: '2024-02-08',
      notes: 'Simplified rectangular envelope. Refer to actual POH for precise limits.',
    },
  },

  stations: [
    {
      id: 'pilot-copilot',
      name: 'Pilot & Copilot',
      arm: {
        value: 72,
        unit: 'inches',
        source: {
          primary: { ...pohSource, section: 'Section 6, Loading Arrangements' },
          confidence: 'high',
          lastVerified: '2024-02-08',
        },
      },
      maxWeight: 400,
    },
    {
      id: 'row-2',
      name: 'Passenger Row 2',
      arm: {
        value: 96,
        unit: 'inches',
        source: {
          primary: { ...pohSource, section: 'Section 6, Loading Arrangements' },
          confidence: 'high',
          lastVerified: '2024-02-08',
        },
      },
      maxWeight: 400,
    },
    {
      id: 'row-3',
      name: 'Passenger Row 3',
      arm: {
        value: 120,
        unit: 'inches',
        source: {
          primary: { ...pohSource, section: 'Section 6, Loading Arrangements' },
          confidence: 'high',
          lastVerified: '2024-02-08',
        },
      },
      maxWeight: 400,
    },
    {
      id: 'row-4',
      name: 'Passenger Row 4',
      arm: {
        value: 144,
        unit: 'inches',
        source: {
          primary: { ...pohSource, section: 'Section 6, Loading Arrangements' },
          confidence: 'high',
          lastVerified: '2024-02-08',
        },
      },
      maxWeight: 400,
    },
    {
      id: 'row-5',
      name: 'Passenger Row 5',
      arm: {
        value: 168,
        unit: 'inches',
        source: {
          primary: { ...pohSource, section: 'Section 6, Loading Arrangements' },
          confidence: 'high',
          lastVerified: '2024-02-08',
        },
      },
      maxWeight: 400,
    },
    {
      id: 'fwd-baggage',
      name: 'Forward Baggage',
      arm: {
        value: 65,
        unit: 'inches',
        source: {
          primary: { ...pohSource, section: 'Section 6, Baggage Compartments' },
          confidence: 'high',
          lastVerified: '2024-02-08',
        },
      },
      maxWeight: 350,
    },
    {
      id: 'aft-baggage',
      name: 'Aft Baggage',
      arm: {
        value: 185,
        unit: 'inches',
        source: {
          primary: { ...pohSource, section: 'Section 6, Baggage Compartments' },
          confidence: 'high',
          lastVerified: '2024-02-08',
        },
      },
      maxWeight: 350,
    },
  ],

  fuelTanks: [
    {
      id: 'main-fuel',
      name: 'Main Tanks',
      arm: {
        value: 95,
        unit: 'inches',
        source: {
          primary: { ...pohSource, section: 'Section 6, Fuel Loading' },
          confidence: 'high',
          lastVerified: '2024-02-08',
        },
      },
      maxGallons: {
        value: 192,
        unit: 'gallons',
        source: {
          primary: { ...pohSource, section: 'Section 6, Fuel Capacity' },
          secondary: {
            document: 'AOPA Aircraft Guide - Piper Chieftain PA-31-350',
            verification: 'Confirms 192 gallons total fuel capacity',
            dateVerified: '2026-02-08',
          },
          confidence: 'high',
          lastVerified: '2026-02-08',
          notes: '192 gallons total across 4 wing cells (2x 40 gal outboard + 2x 56 gal inboard). Earlier sources list 182 gal usable.',
        },
      },
      fuelWeightPerGallon: 6.0,
    },
    {
      id: 'nacelle-fuel',
      name: 'Nacelle Tanks (Optional)',
      arm: {
        value: 125,
        unit: 'inches',
        source: {
          primary: { ...pohSource, section: 'Section 6, Fuel Loading' },
          confidence: 'high',
          lastVerified: '2024-02-08',
        },
      },
      maxGallons: {
        value: 54,
        unit: 'gallons',
        source: {
          primary: { ...pohSource, section: 'Section 6, Fuel Capacity' },
          confidence: 'high',
          lastVerified: '2024-02-08',
        },
      },
      fuelWeightPerGallon: 6.0,
      isOptional: true,
    },
  ],

  regulatory: {
    tcdsNumber: 'A20SO',
    farBasis: 'FAR Part 23',
  },
};
