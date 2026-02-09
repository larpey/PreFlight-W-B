/** Source attribution for any aircraft specification value */
export interface SourceAttribution {
  primary: {
    document: string;
    section: string;
    publisher: string;
    datePublished: string;
    tcdsNumber?: string;
    url?: string;
  };
  secondary?: {
    document: string;
    section?: string;
    publisher?: string;
    verification: string;
    dateVerified?: string;
  };
  confidence: 'high' | 'medium' | 'low';
  lastVerified: string;
  notes?: string;
}

/** A numeric value with unit and source attribution */
export interface SourcedValue {
  value: number;
  unit: 'lbs' | 'inches' | 'gallons' | 'lbs/gal' | 'lb-in';
  source: SourceAttribution;
}

/** A loading station (seat row, baggage area) */
export interface Station {
  id: string;
  name: string;
  arm: SourcedValue;
  maxWeight?: number;
  defaultWeight?: number;
}

/** Fuel tank configuration */
export interface FuelTank {
  id: string;
  name: string;
  arm: SourcedValue;
  maxGallons: SourcedValue;
  fuelWeightPerGallon: number;
  isOptional?: boolean;
}

/** A point defining the CG envelope boundary */
export interface EnvelopePoint {
  weight: number;
  cg: number;
}

/** CG envelope definition */
export interface CGEnvelope {
  points: EnvelopePoint[];
  source: SourceAttribution;
}

export type AircraftCategory = 'single-engine' | 'multi-engine';

/** Complete aircraft definition */
export interface Aircraft {
  id: string;
  name: string;
  model: string;
  manufacturer: string;
  year?: string;
  category: AircraftCategory;

  emptyWeight: SourcedValue;
  emptyWeightArm: SourcedValue;
  maxGrossWeight: SourcedValue;
  usefulLoad: SourcedValue;

  datum: string;
  cgRange: {
    forward: SourcedValue;
    aft: SourcedValue;
  };
  cgEnvelope: CGEnvelope;

  stations: Station[];
  fuelTanks: FuelTank[];

  regulatory: {
    tcdsNumber: string;
    farBasis: string;
  };
}
