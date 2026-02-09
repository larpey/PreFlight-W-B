import type { Aircraft } from '../types/aircraft';
import { useCalculation } from '../hooks/useCalculation';
import { NavBar } from '../components/layout/NavBar';
import { StationInput } from '../components/calculator/StationInput';
import { FuelInput } from '../components/calculator/FuelInput';
import { ResultsDashboard } from '../components/calculator/ResultsDashboard';
import { SafetyAlerts } from '../components/calculator/SafetyAlerts';
import { CGEnvelopeChart } from '../components/chart/CGEnvelopeChart';
import { Disclaimer } from '../components/common/Disclaimer';

interface CalculatorPageProps {
  aircraft: Aircraft;
  onBack: () => void;
  onViewSources: () => void;
}

export function CalculatorPage({ aircraft, onBack, onViewSources }: CalculatorPageProps) {
  const { stationLoads, fuelLoads, result, updateStation, updateFuel, resetAll } =
    useCalculation(aircraft);

  const dangerWarnings = result.warnings.filter(w => w.level === 'danger');

  return (
    <div className="flex flex-col min-h-screen">
      <NavBar
        title={aircraft.name}
        onBack={onBack}
        rightAction={
          <button
            onClick={onViewSources}
            className="text-ios-blue text-[15px] min-w-[44px] min-h-[44px] flex items-center justify-end active:opacity-60"
          >
            Sources
          </button>
        }
      />

      <div className="flex-1 px-4 py-4 space-y-4">
        {/* Danger warnings pinned at top */}
        {dangerWarnings.length > 0 && (
          <SafetyAlerts warnings={dangerWarnings} />
        )}

        {/* Results dashboard */}
        <ResultsDashboard result={result} aircraft={aircraft} />

        {/* CG Envelope */}
        <CGEnvelopeChart aircraft={aircraft} result={result} />

        {/* Station inputs */}
        <section>
          <div className="flex items-center justify-between mb-2 px-1">
            <h2 className="text-[13px] font-medium text-ios-gray-1 uppercase tracking-wide">
              Loading
            </h2>
            <button
              onClick={resetAll}
              className="text-[13px] text-ios-blue active:opacity-60 min-h-[32px] flex items-center"
            >
              Reset All
            </button>
          </div>
          <div className="space-y-2">
            {aircraft.stations.map(station => {
              const load = stationLoads.find(s => s.stationId === station.id);
              return (
                <StationInput
                  key={station.id}
                  station={station}
                  weight={load?.weight ?? 0}
                  onChange={w => updateStation(station.id, w)}
                />
              );
            })}
          </div>
        </section>

        {/* Fuel inputs */}
        <section>
          <h2 className="text-[13px] font-medium text-ios-gray-1 uppercase tracking-wide mb-2 px-1">
            Fuel
          </h2>
          <div className="space-y-2">
            {aircraft.fuelTanks.map(tank => {
              const load = fuelLoads.find(f => f.tankId === tank.id);
              return (
                <FuelInput
                  key={tank.id}
                  tank={tank}
                  gallons={load?.gallons ?? 0}
                  onChange={g => updateFuel(tank.id, g)}
                />
              );
            })}
          </div>
        </section>

        {/* All warnings (including cautions) */}
        {result.warnings.length > 0 && (
          <section>
            <h2 className="text-[13px] font-medium text-ios-gray-1 uppercase tracking-wide mb-2 px-1">
              Alerts
            </h2>
            <SafetyAlerts warnings={result.warnings} />
          </section>
        )}

        {/* Disclaimer */}
        <Disclaimer />

        {/* Loading breakdown */}
        <section className="pb-8">
          <h2 className="text-[13px] font-medium text-ios-gray-1 uppercase tracking-wide mb-2 px-1">
            Loading Breakdown
          </h2>
          <div className="bg-white dark:bg-[#1C1C1E] rounded-xl overflow-hidden">
            <table className="w-full text-[13px]">
              <thead>
                <tr className="border-b border-ios-separator dark:border-[#38383A]">
                  <th className="text-left px-4 py-2 text-ios-gray-1 font-medium">Item</th>
                  <th className="text-right px-4 py-2 text-ios-gray-1 font-medium">Weight</th>
                  <th className="text-right px-4 py-2 text-ios-gray-1 font-medium">Arm</th>
                  <th className="text-right px-4 py-2 text-ios-gray-1 font-medium">Moment</th>
                </tr>
              </thead>
              <tbody>
                {/* Empty weight */}
                <tr className="border-b border-ios-separator/50 dark:border-[#38383A]/50">
                  <td className="px-4 py-2 text-ios-text dark:text-white">Empty Weight</td>
                  <td className="px-4 py-2 text-right tabular-nums text-ios-text dark:text-white">
                    {aircraft.emptyWeight.value.toLocaleString()}
                  </td>
                  <td className="px-4 py-2 text-right tabular-nums text-ios-text dark:text-white">
                    {aircraft.emptyWeightArm.value.toFixed(1)}
                  </td>
                  <td className="px-4 py-2 text-right tabular-nums text-ios-text dark:text-white">
                    {(aircraft.emptyWeight.value * aircraft.emptyWeightArm.value).toLocaleString(undefined, { maximumFractionDigits: 0 })}
                  </td>
                </tr>
                {/* Station details */}
                {result.stationDetails
                  .filter(s => s.weight > 0)
                  .map(s => (
                    <tr key={s.stationId} className="border-b border-ios-separator/50 dark:border-[#38383A]/50">
                      <td className="px-4 py-2 text-ios-text dark:text-white">{s.name}</td>
                      <td className="px-4 py-2 text-right tabular-nums text-ios-text dark:text-white">
                        {s.weight.toLocaleString()}
                      </td>
                      <td className="px-4 py-2 text-right tabular-nums text-ios-text dark:text-white">
                        {s.arm.toFixed(1)}
                      </td>
                      <td className="px-4 py-2 text-right tabular-nums text-ios-text dark:text-white">
                        {s.moment.toLocaleString(undefined, { maximumFractionDigits: 0 })}
                      </td>
                    </tr>
                  ))}
                {/* Fuel details */}
                {result.fuelDetails
                  .filter(f => f.weight > 0)
                  .map(f => (
                    <tr key={f.tankId} className="border-b border-ios-separator/50 dark:border-[#38383A]/50">
                      <td className="px-4 py-2 text-ios-text dark:text-white">
                        {f.name} ({f.gallons} gal)
                      </td>
                      <td className="px-4 py-2 text-right tabular-nums text-ios-text dark:text-white">
                        {f.weight.toLocaleString()}
                      </td>
                      <td className="px-4 py-2 text-right tabular-nums text-ios-text dark:text-white">
                        {f.arm.toFixed(1)}
                      </td>
                      <td className="px-4 py-2 text-right tabular-nums text-ios-text dark:text-white">
                        {f.moment.toLocaleString(undefined, { maximumFractionDigits: 0 })}
                      </td>
                    </tr>
                  ))}
                {/* Totals */}
                <tr className="font-semibold">
                  <td className="px-4 py-2 text-ios-text dark:text-white">Total</td>
                  <td className={`px-4 py-2 text-right tabular-nums ${
                    result.isWithinWeightLimit ? 'text-ios-text dark:text-white' : 'text-ios-red'
                  }`}>
                    {result.totalWeight.toLocaleString(undefined, { maximumFractionDigits: 1 })}
                  </td>
                  <td className={`px-4 py-2 text-right tabular-nums ${
                    result.isWithinCGEnvelope ? 'text-ios-text dark:text-white' : 'text-ios-red'
                  }`}>
                    {result.cg.toFixed(2)}
                  </td>
                  <td className="px-4 py-2 text-right tabular-nums text-ios-text dark:text-white">
                    {result.totalMoment.toLocaleString(undefined, { maximumFractionDigits: 0 })}
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </section>
      </div>
    </div>
  );
}
