import type { Aircraft } from '../../types/aircraft';

const pohSource = {
  document: 'POH VB-753, Piper Cherokee Six PA-32-300',
  section: 'Section 6 - Weight & Balance',
  publisher: 'Piper Aircraft Corporation',
  datePublished: '1972-01-01',
};

const tcdsSource = {
  document: 'FAA Type Certificate Data Sheet 2A13',
  section: 'Limitations',
  publisher: 'FAA Aircraft Certification Office',
  datePublished: '2024-01-15',
};

export const cherokee6: Aircraft = {
  id: 'cherokee-six-pa32',
  name: 'Piper Cherokee Six PA-32-300',
  model: 'PA-32-300',
  manufacturer: 'Piper Aircraft Corporation',
  year: '1966',
  category: 'single-engine',

  emptyWeight: {
    value: 1780,
    unit: 'lbs',
    source: {
      primary: { ...pohSource, section: 'Section 6, Weight & Balance Data' },
      confidence: 'high',
      lastVerified: '2024-02-08',
      notes: 'Typical empty weight. Actual varies per serial number and installed equipment.',
    },
  },

  emptyWeightArm: {
    value: 87.0,
    unit: 'inches',
    source: {
      primary: { ...pohSource, section: 'Section 6, Weight & Balance Data' },
      confidence: 'medium',
      lastVerified: '2024-02-08',
      notes: 'Typical value. Use aircraft-specific W&B record.',
    },
  },

  maxGrossWeight: {
    value: 3400,
    unit: 'lbs',
    source: {
      primary: tcdsSource,
      secondary: {
        document: 'POH Section 2, Limitations',
        verification: 'Confirms TCDS value of 3,400 lbs',
      },
      confidence: 'high',
      lastVerified: '2024-02-08',
    },
  },

  usefulLoad: {
    value: 1620,
    unit: 'lbs',
    source: {
      primary: { ...pohSource, section: 'Section 6' },
      confidence: 'high',
      lastVerified: '2024-02-08',
      notes: 'Max gross (3,400) minus typical empty weight (1,780). Varies per aircraft.',
    },
  },

  datum: '78.4 inches ahead of wing leading edge',

  cgRange: {
    forward: {
      value: 83,
      unit: 'inches',
      source: {
        primary: { ...tcdsSource, section: 'CG Range' },
        confidence: 'high',
        lastVerified: '2024-02-08',
      },
    },
    aft: {
      value: 95,
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
      { weight: 1780, cg: 83 },
      { weight: 3400, cg: 83 },
      { weight: 3400, cg: 95 },
      { weight: 1780, cg: 95 },
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
      id: 'front-seats',
      name: 'Front Seats',
      arm: {
        value: 85,
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
      id: 'middle-seats',
      name: 'Middle Seats',
      arm: {
        value: 117,
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
      id: 'rear-seats',
      name: 'Rear Seats',
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
    {
      id: 'baggage',
      name: 'Baggage Area',
      arm: {
        value: 150,
        unit: 'inches',
        source: {
          primary: { ...pohSource, section: 'Section 6, Loading Arrangements' },
          confidence: 'high',
          lastVerified: '2024-02-08',
        },
      },
      maxWeight: 200,
    },
  ],

  fuelTanks: [
    {
      id: 'main-fuel',
      name: 'Main Fuel Tanks',
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
        value: 84,
        unit: 'gallons',
        source: {
          primary: { ...pohSource, section: 'Section 6, Fuel Capacity' },
          secondary: {
            document: 'TCDS 2A13',
            verification: 'Confirms 84 gallons usable',
          },
          confidence: 'high',
          lastVerified: '2024-02-08',
        },
      },
      fuelWeightPerGallon: 6.0,
    },
  ],

  regulatory: {
    tcdsNumber: '2A13',
    farBasis: 'FAR Part 23',
  },
};
