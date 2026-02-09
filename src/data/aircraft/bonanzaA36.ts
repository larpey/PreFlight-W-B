import type { Aircraft } from '../../types/aircraft';

const pohSource = {
  document: 'POH P/N 36-590001-9B, Beechcraft Bonanza A36',
  section: 'Section 6 - Weight & Balance',
  publisher: 'Beech Aircraft Corporation',
  datePublished: '1984-01-01',
};

const tcdsSource = {
  document: 'FAA Type Certificate Data Sheet 3A15',
  section: 'Limitations',
  publisher: 'FAA Aircraft Certification Office',
  datePublished: '2024-01-15',
};

export const bonanzaA36: Aircraft = {
  id: 'bonanza-a36',
  name: 'Beechcraft Bonanza A36',
  model: 'A36',
  manufacturer: 'Beech Aircraft Corporation',
  year: '1970',
  category: 'single-engine',

  emptyWeight: {
    value: 2450,
    unit: 'lbs',
    source: {
      primary: { ...pohSource, section: 'Section 6, Weight & Balance Data' },
      confidence: 'high',
      lastVerified: '2024-02-08',
      notes: 'Typical empty weight. Actual varies per serial number and installed equipment.',
    },
  },

  emptyWeightArm: {
    value: 82.0,
    unit: 'inches',
    source: {
      primary: { ...pohSource, section: 'Section 6, Weight & Balance Data' },
      confidence: 'medium',
      lastVerified: '2024-02-08',
      notes: 'Typical value. Use aircraft-specific W&B record for actual CG.',
    },
  },

  maxGrossWeight: {
    value: 3650,
    unit: 'lbs',
    source: {
      primary: tcdsSource,
      secondary: {
        document: 'POH Section 2, Limitations',
        verification: 'Confirms TCDS value of 3,650 lbs',
      },
      confidence: 'high',
      lastVerified: '2024-02-08',
    },
  },

  usefulLoad: {
    value: 1200,
    unit: 'lbs',
    source: {
      primary: { ...pohSource, section: 'Section 6' },
      confidence: 'high',
      lastVerified: '2024-02-08',
      notes: 'Max gross (3,650) minus typical empty weight (2,450). Varies per aircraft.',
    },
  },

  datum: 'Leading edge of wing',

  cgRange: {
    forward: {
      value: 80,
      unit: 'inches',
      source: {
        primary: { ...tcdsSource, section: 'CG Range' },
        confidence: 'high',
        lastVerified: '2024-02-08',
      },
    },
    aft: {
      value: 90,
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
      { weight: 2450, cg: 80 },
      { weight: 3650, cg: 80 },
      { weight: 3650, cg: 90 },
      { weight: 2450, cg: 90 },
    ],
    source: {
      primary: { ...pohSource, section: 'Section 6, CG Envelope Chart' },
      confidence: 'high',
      lastVerified: '2024-02-08',
      notes: 'Simplified rectangular envelope. Actual POH envelope may have additional vertices at lower weights.',
    },
  },

  stations: [
    {
      id: 'front-seats',
      name: 'Front Seats',
      arm: {
        value: 85,
        unit: 'inches',
        source: {
          primary: { ...pohSource, section: 'Section 6, Loading Arrangements' },
          confidence: 'high',
          lastVerified: '2024-02-08',
          notes: 'Adjustable range 80.5-87 inches. Using 85 in midpoint for calculation.',
        },
      },
      maxWeight: 400,
    },
    {
      id: 'rear-seats',
      name: 'Rear Seats',
      arm: {
        value: 118,
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
      id: 'baggage',
      name: 'Baggage Compartment',
      arm: {
        value: 142,
        unit: 'inches',
        source: {
          primary: { ...pohSource, section: 'Section 6, Loading Arrangements' },
          confidence: 'high',
          lastVerified: '2024-02-08',
        },
      },
      maxWeight: 400,
    },
  ],

  fuelTanks: [
    {
      id: 'main-fuel',
      name: 'Main Fuel Tanks',
      arm: {
        value: 75,
        unit: 'inches',
        source: {
          primary: { ...pohSource, section: 'Section 6, Fuel Loading' },
          confidence: 'high',
          lastVerified: '2024-02-08',
        },
      },
      maxGallons: {
        value: 74,
        unit: 'gallons',
        source: {
          primary: { ...pohSource, section: 'Section 6, Fuel Capacity' },
          secondary: {
            document: 'TCDS 3A15',
            verification: 'Confirms 74 gallons usable',
          },
          confidence: 'high',
          lastVerified: '2024-02-08',
        },
      },
      fuelWeightPerGallon: 6.0,
    },
  ],

  regulatory: {
    tcdsNumber: '3A15',
    farBasis: 'CAR Part 3',
  },
};
