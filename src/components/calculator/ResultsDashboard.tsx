import type { CalculationResult } from '../../types/calculation';
import type { Aircraft } from '../../types/aircraft';

interface ResultsDashboardProps {
  result: CalculationResult;
  aircraft: Aircraft;
}

export function ResultsDashboard({ result, aircraft }: ResultsDashboardProps) {
  const maxGross = aircraft.maxGrossWeight.value;
  const weightPct = Math.min((result.totalWeight / maxGross) * 100, 110);
  const allGood = result.isWithinWeightLimit && result.isWithinCGEnvelope && result.isWithinAllStationLimits;

  const fwdLimit = aircraft.cgRange.forward.value;
  const aftLimit = aircraft.cgRange.aft.value;
  const cgRange = aftLimit - fwdLimit;
  const cgPct = cgRange > 0 ? ((result.cg - fwdLimit) / cgRange) * 100 : 50;

  return (
    <div className="bg-white dark:bg-[#1C1C1E] rounded-xl px-4 py-4">
      {/* Status indicator */}
      <div className="flex items-center justify-between mb-4">
        <span className="text-[15px] font-semibold text-ios-text dark:text-white">
          Calculation Results
        </span>
        <span
          className={`px-3 py-1 rounded-full text-[13px] font-semibold ${
            allGood
              ? 'bg-ios-green/15 text-ios-green'
              : 'bg-ios-red/15 text-ios-red'
          }`}
        >
          {allGood ? 'Within Limits' : 'Out of Limits'}
        </span>
      </div>

      {/* Weight */}
      <div className="mb-4">
        <div className="flex items-baseline justify-between mb-1">
          <span className="text-[13px] text-ios-gray-1">Total Weight</span>
          <span className={`text-[20px] font-bold tabular-nums ${
            result.isWithinWeightLimit ? 'text-ios-text dark:text-white' : 'text-ios-red'
          }`}>
            {result.totalWeight.toLocaleString(undefined, { maximumFractionDigits: 1 })}
            <span className="text-[13px] font-normal text-ios-gray-1 ml-1">
              / {maxGross.toLocaleString()} lbs
            </span>
          </span>
        </div>
        <div className="h-2.5 rounded-full bg-ios-gray-5 dark:bg-[#2C2C2E] overflow-hidden">
          <div
            className={`h-full rounded-full transition-all duration-300 ${
              weightPct > 100
                ? 'bg-ios-red'
                : weightPct > 95
                ? 'bg-ios-orange'
                : 'bg-ios-green'
            }`}
            style={{ width: `${Math.min(weightPct, 100)}%` }}
          />
        </div>
        <div className="flex justify-between mt-1 text-[11px] text-ios-gray-1">
          <span>
            {result.isWithinWeightLimit
              ? `${result.weightMargin.toFixed(0)} lbs remaining`
              : `${(-result.weightMargin).toFixed(0)} lbs OVER`}
          </span>
          <span>{weightPct.toFixed(0)}%</span>
        </div>
        {(aircraft.maxRampWeight || aircraft.maxLandingWeight) && (
          <div className="flex gap-3 mt-1.5 text-[11px] text-ios-gray-2">
            {aircraft.maxRampWeight && (
              <span>
                Ramp: {aircraft.maxRampWeight.value.toLocaleString()} lbs
              </span>
            )}
            {aircraft.maxLandingWeight && (
              <span className={result.totalWeight > aircraft.maxLandingWeight.value ? 'text-ios-orange' : ''}>
                Landing: {aircraft.maxLandingWeight.value.toLocaleString()} lbs
              </span>
            )}
          </div>
        )}
      </div>

      {/* CG Position */}
      <div className="mb-3">
        <div className="flex items-baseline justify-between mb-1">
          <span className="text-[13px] text-ios-gray-1">Center of Gravity</span>
          <span className={`text-[20px] font-bold tabular-nums ${
            result.isWithinCGEnvelope ? 'text-ios-text dark:text-white' : 'text-ios-red'
          }`}>
            {result.cg.toFixed(2)}
            <span className="text-[13px] font-normal text-ios-gray-1 ml-1">inches</span>
          </span>
        </div>
        <div className="relative h-2.5 rounded-full bg-ios-gray-5 dark:bg-[#2C2C2E] overflow-hidden">
          <div
            className={`absolute top-0 h-full rounded-full transition-all duration-300 w-3 ${
              result.isWithinCGEnvelope ? 'bg-ios-green' : 'bg-ios-red'
            }`}
            style={{ left: `${Math.max(0, Math.min(cgPct, 100))}%`, transform: 'translateX(-50%)' }}
          />
        </div>
        <div className="flex justify-between mt-1 text-[11px] text-ios-gray-1">
          <span>Fwd {fwdLimit}"</span>
          <span>Aft {aftLimit}"</span>
        </div>
      </div>

      {/* Moment */}
      <div className="pt-3 border-t border-ios-separator dark:border-[#38383A]">
        <div className="flex justify-between text-[13px]">
          <span className="text-ios-gray-1">Total Moment</span>
          <span className="text-ios-text dark:text-white tabular-nums">
            {result.totalMoment.toLocaleString(undefined, { maximumFractionDigits: 1 })} lb-in
          </span>
        </div>
      </div>
    </div>
  );
}
