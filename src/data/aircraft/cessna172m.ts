import type { Aircraft } from '../../types/aircraft';

const pohSource = {
  document: 'POH D1016-13, Cessna Model 172M Skyhawk',
  section: 'Section 6 - Weight & Balance',
  publisher: 'Cessna Aircraft Company',
  datePublished: '1975-01-01',
};

const tcdsSource = {
  document: 'FAA Type Certificate Data Sheet 3A12',
  section: 'Limitations',
  publisher: 'FAA Aircraft Certification Office',
  datePublished: '2024-01-15',
};

export const cessna172m: Aircraft = {
  id: 'cessna-172m',
  name: 'Cessna 172M Skyhawk',
  model: '172M',
  manufacturer: 'Cessna Aircraft Company',
  year: '1974',
  category: 'single-engine',

  emptyWeight: {
    value: 1466,
    unit: 'lbs',
    source: {
      primary: { ...pohSource, section: 'Section 6, Page 6-2' },
      confidence: 'high',
      lastVerified: '2024-02-08',
      notes: 'Typical empty weight. Actual varies per serial number — always use aircraft-specific W&B record.',
    },
  },

  emptyWeightArm: {
    value: 40.6,
    unit: 'inches',
    source: {
      primary: { ...pohSource, section: 'Section 6, Weight & Balance Data' },
      confidence: 'medium',
      lastVerified: '2024-02-08',
      notes: 'Typical value. Actual empty weight CG varies per aircraft. Use data from aircraft W&B record.',
    },
  },

  maxGrossWeight: {
    value: 2300,
    unit: 'lbs',
    source: {
      primary: tcdsSource,
      secondary: {
        document: 'POH Section 2, Limitations',
        verification: 'Confirms TCDS value of 2,300 lbs',
      },
      confidence: 'high',
      lastVerified: '2024-02-08',
    },
  },

  usefulLoad: {
    value: 834,
    unit: 'lbs',
    source: {
      primary: { ...pohSource, section: 'Section 6' },
      confidence: 'high',
      lastVerified: '2024-02-08',
      notes: 'Max gross (2,300) minus typical empty weight (1,466). Varies per aircraft.',
    },
  },

  datum: 'Firewall (leading edge of wing on some references)',

  cgRange: {
    forward: {
      value: 35,
      unit: 'inches',
      source: {
        primary: { ...tcdsSource, section: 'CG Range' },
        confidence: 'high',
        lastVerified: '2024-02-08',
      },
    },
    aft: {
      value: 47,
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
      { weight: 1500, cg: 35 },
      { weight: 1950, cg: 35 },
      { weight: 2300, cg: 37 },
      { weight: 2300, cg: 47 },
      { weight: 1500, cg: 47 },
    ],
    source: {
      primary: { ...pohSource, section: 'Section 6, Figure 6-1, CG Envelope' },
      confidence: 'high',
      lastVerified: '2024-02-08',
      notes: 'Envelope simplified to key vertices. Refer to actual POH chart for precise limits.',
    },
  },

  stations: [
    {
      id: 'front-seats',
      name: 'Front Seats',
      arm: {
        value: 37,
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
        value: 73,
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
      id: 'baggage-1',
      name: 'Baggage Area 1',
      arm: {
        value: 95,
        unit: 'inches',
        source: {
          primary: { ...pohSource, section: 'Section 6, Loading Arrangements' },
          confidence: 'high',
          lastVerified: '2024-02-08',
        },
      },
      maxWeight: 120,
    },
    {
      id: 'baggage-2',
      name: 'Baggage Area 2',
      arm: {
        value: 123,
        unit: 'inches',
        source: {
          primary: { ...pohSource, section: 'Section 6, Loading Arrangements' },
          confidence: 'high',
          lastVerified: '2024-02-08',
        },
      },
      maxWeight: 50,
    },
  ],

  fuelTanks: [
    {
      id: 'main-fuel',
      name: 'Main Tanks (Both)',
      arm: {
        value: 48,
        unit: 'inches',
        source: {
          primary: { ...pohSource, section: 'Section 6, Fuel Loading' },
          confidence: 'high',
          lastVerified: '2024-02-08',
        },
      },
      maxGallons: {
        value: 43,
        unit: 'gallons',
        source: {
          primary: { ...pohSource, section: 'Section 6, Fuel Capacity' },
          secondary: {
            document: 'TCDS 3A12',
            verification: 'Confirms 43 gallons usable',
          },
          confidence: 'high',
          lastVerified: '2024-02-08',
        },
      },
      fuelWeightPerGallon: 6.0,
    },
  ],

  regulatory: {
    tcdsNumber: '3A12',
    farBasis: 'CAR Part 3',
  },
};
