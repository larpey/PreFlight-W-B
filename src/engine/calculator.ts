import type { Aircraft } from '../types/aircraft';
import type {
  LoadingScenario,
  CalculationResult,
  CalculationWarning,
} from '../types/calculation';
import { isPointInEnvelope, getEnvelopeLimitsAtWeight } from './envelope';

export function calculateWeightAndBalance(
  aircraft: Aircraft,
  scenario: LoadingScenario
): CalculationResult {
  const warnings: CalculationWarning[] = [];

  // Start with empty weight
  let totalWeight = aircraft.emptyWeight.value;
  let totalMoment = aircraft.emptyWeight.value * aircraft.emptyWeightArm.value;

  // Process station loads
  const stationDetails = scenario.stationLoads.map(load => {
    const station = aircraft.stations.find(s => s.id === load.stationId);
    if (!station) throw new Error(`Unknown station: ${load.stationId}`);

    const arm = station.arm.value;
    const moment = load.weight * arm;

    if (load.weight < 0) {
      warnings.push({
        level: 'danger',
        code: 'NEGATIVE_WEIGHT',
        message: `${station.name} has negative weight`,
        detail: 'Weight values must be zero or positive',
      });
    }

    if (station.maxWeight !== undefined && load.weight > station.maxWeight) {
      warnings.push({
        level: 'danger',
        code: 'STATION_OVERWEIGHT',
        message: `${station.name} exceeds maximum weight`,
        detail: `${load.weight} lbs exceeds limit of ${station.maxWeight} lbs`,
      });
    }

    totalWeight += load.weight;
    totalMoment += moment;

    return {
      stationId: load.stationId,
      name: station.name,
      weight: load.weight,
      arm,
      moment,
    };
  });

  // Process fuel loads
  const fuelDetails = scenario.fuelLoads.map(load => {
    const tank = aircraft.fuelTanks.find(t => t.id === load.tankId);
    if (!tank) throw new Error(`Unknown fuel tank: ${load.tankId}`);

    if (load.gallons < 0) {
      warnings.push({
        level: 'danger',
        code: 'NEGATIVE_FUEL',
        message: `${tank.name} has negative fuel`,
        detail: 'Fuel values must be zero or positive',
      });
    }

    if (load.gallons > tank.maxGallons.value) {
      warnings.push({
        level: 'danger',
        code: 'FUEL_OVERCAPACITY',
        message: `${tank.name} exceeds fuel capacity`,
        detail: `${load.gallons} gal exceeds maximum of ${tank.maxGallons.value} gal`,
      });
    }

    const weight = load.gallons * tank.fuelWeightPerGallon;
    const arm = tank.arm.value;
    const moment = weight * arm;

    totalWeight += weight;
    totalMoment += moment;

    return {
      tankId: load.tankId,
      name: tank.name,
      gallons: load.gallons,
      weight,
      arm,
      moment,
    };
  });

  // Compute CG
  const cg = totalWeight > 0 ? totalMoment / totalWeight : 0;

  // Check weight limits
  const maxGross = aircraft.maxGrossWeight.value;
  const isWithinWeightLimit = totalWeight <= maxGross;
  const weightMargin = maxGross - totalWeight;

  // Check CG limits
  const fwdLimit = aircraft.cgRange.forward.value;
  const aftLimit = aircraft.cgRange.aft.value;
  const cgForwardMargin = cg - fwdLimit;
  const cgAftMargin = aftLimit - cg;

  const isWithinCGEnvelope = isPointInEnvelope(
    totalWeight,
    cg,
    aircraft.cgEnvelope.points
  );

  const isWithinAllStationLimits = !warnings.some(
    w => w.code === 'STATION_OVERWEIGHT'
  );

  // Generate weight warnings
  if (!isWithinWeightLimit) {
    warnings.push({
      level: 'danger',
      code: 'OVER_MAX_GROSS',
      message: 'Aircraft exceeds maximum takeoff weight',
      detail: `${totalWeight.toFixed(1)} lbs exceeds limit of ${maxGross.toLocaleString()} lbs by ${(totalWeight - maxGross).toFixed(1)} lbs`,
      regulatoryRef: 'FAR 91.103',
    });
  } else if (weightMargin < maxGross * 0.05) {
    warnings.push({
      level: 'caution',
      code: 'NEAR_MAX_GROSS',
      message: 'Approaching maximum takeoff weight',
      detail: `${weightMargin.toFixed(1)} lbs remaining (${((weightMargin / maxGross) * 100).toFixed(1)}% margin)`,
    });
  }

  // Check max ramp weight if defined
  if (aircraft.maxRampWeight) {
    const maxRamp = aircraft.maxRampWeight.value;
    if (totalWeight > maxRamp) {
      warnings.push({
        level: 'danger',
        code: 'OVER_MAX_RAMP',
        message: 'Aircraft exceeds maximum ramp weight',
        detail: `${totalWeight.toFixed(1)} lbs exceeds ramp limit of ${maxRamp.toLocaleString()} lbs by ${(totalWeight - maxRamp).toFixed(1)} lbs`,
      });
    }
  }

  // Check max landing weight if defined (informational for pre-flight planning)
  if (aircraft.maxLandingWeight) {
    const maxLanding = aircraft.maxLandingWeight.value;
    if (totalWeight > maxLanding) {
      warnings.push({
        level: 'warning',
        code: 'OVER_MAX_LANDING',
        message: 'Current weight exceeds max landing weight',
        detail: `${totalWeight.toFixed(1)} lbs exceeds landing limit of ${maxLanding.toLocaleString()} lbs — plan fuel burn before landing`,
      });
    }
  }

  // Generate CG warnings
  const envelopeLimits = getEnvelopeLimitsAtWeight(totalWeight, aircraft.cgEnvelope.points);
  if (!isWithinCGEnvelope) {
    const limitDetail = envelopeLimits
      ? `forward limit: ${envelopeLimits.fwdLimit.toFixed(1)}\" / aft limit: ${envelopeLimits.aftLimit.toFixed(1)}\" at ${totalWeight.toFixed(0)} lbs`
      : `approved range: ${fwdLimit}–${aftLimit} in`;
    warnings.push({
      level: 'danger',
      code: 'CG_OUT_OF_ENVELOPE',
      message: 'Center of gravity outside approved envelope',
      detail: `CG at ${cg.toFixed(2)} in — ${limitDetail}`,
      regulatoryRef: 'FAR 91.103',
    });
  } else if (envelopeLimits && (cg - envelopeLimits.fwdLimit < 1 || envelopeLimits.aftLimit - cg < 1)) {
    warnings.push({
      level: 'caution',
      code: 'CG_NEAR_LIMIT',
      message: 'CG is near envelope boundary',
      detail: `CG at ${cg.toFixed(2)} in — forward limit: ${envelopeLimits.fwdLimit.toFixed(1)}\" / aft limit: ${envelopeLimits.aftLimit.toFixed(1)}\" at this weight`,
    });
  }

  return {
    totalWeight,
    totalMoment,
    cg,
    isWithinWeightLimit,
    isWithinCGEnvelope,
    isWithinAllStationLimits,
    weightMargin,
    cgForwardMargin,
    cgAftMargin,
    stationDetails,
    fuelDetails,
    warnings,
  };
}
