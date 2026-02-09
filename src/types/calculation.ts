/** Weight entered at a single station */
export interface StationLoad {
  stationId: string;
  weight: number;
}

/** Fuel loaded in a tank */
export interface FuelLoad {
  tankId: string;
  gallons: number;
}

/** Complete loading scenario */
export interface LoadingScenario {
  aircraftId: string;
  stationLoads: StationLoad[];
  fuelLoads: FuelLoad[];
}

/** Result of a weight & balance calculation */
export interface CalculationResult {
  totalWeight: number;
  totalMoment: number;
  cg: number;

  isWithinWeightLimit: boolean;
  isWithinCGEnvelope: boolean;
  isWithinAllStationLimits: boolean;

  weightMargin: number;
  cgForwardMargin: number;
  cgAftMargin: number;

  stationDetails: {
    stationId: string;
    name: string;
    weight: number;
    arm: number;
    moment: number;
  }[];

  fuelDetails: {
    tankId: string;
    name: string;
    gallons: number;
    weight: number;
    arm: number;
    moment: number;
  }[];

  warnings: CalculationWarning[];
}

export interface CalculationWarning {
  level: 'caution' | 'warning' | 'danger';
  code: string;
  message: string;
  detail?: string;
  regulatoryRef?: string;
}
