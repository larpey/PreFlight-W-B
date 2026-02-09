import type { Station } from '../../types/aircraft';
import { SourceBadge } from '../sources/SourceBadge';

interface StationInputProps {
  station: Station;
  weight: number;
  onChange: (weight: number) => void;
}

const presetWeights = [170, 190, 200];

export function StationInput({ station, weight, onChange }: StationInputProps) {
  const isOver = station.maxWeight !== undefined && weight > station.maxWeight;
  const isSeating = station.name.toLowerCase().includes('seat') ||
    station.name.toLowerCase().includes('pilot') ||
    station.name.toLowerCase().includes('row');

  return (
    <div className="bg-white dark:bg-[#1C1C1E] rounded-xl px-4 py-3">
      <div className="flex items-center justify-between mb-2">
        <div>
          <span className="text-[15px] font-medium text-ios-text dark:text-white">
            {station.name}
          </span>
          <span className="text-[12px] text-ios-gray-1 ml-2">
            Arm: {station.arm.value}"
          </span>
        </div>
        <SourceBadge source={station.arm.source} />
      </div>

      <div className="flex items-center gap-3">
        <div className="relative flex-1">
          <input
            type="number"
            inputMode="decimal"
            value={weight || ''}
            onChange={e => onChange(Math.max(0, Number(e.target.value)))}
            placeholder="0"
            className={`w-full h-11 px-3 rounded-lg text-[17px] bg-ios-gray-6 dark:bg-[#2C2C2E] text-ios-text dark:text-white placeholder-ios-gray-3 outline-none border-2 transition-colors ${
              isOver
                ? 'border-ios-red'
                : 'border-transparent focus:border-ios-blue'
            }`}
          />
          <span className="absolute right-3 top-1/2 -translate-y-1/2 text-[13px] text-ios-gray-1">
            lbs
          </span>
        </div>

        {station.maxWeight !== undefined && (
          <span
            className={`text-[12px] whitespace-nowrap ${
              isOver ? 'text-ios-red font-medium' : 'text-ios-gray-1'
            }`}
          >
            max {station.maxWeight}
          </span>
        )}
      </div>

      {/* Quick-set buttons for seating stations */}
      {isSeating && (
        <div className="flex gap-2 mt-2">
          {presetWeights.map(pw => (
            <button
              key={pw}
              onClick={() => onChange(pw)}
              className={`px-3 py-1 rounded-full text-[12px] min-h-[32px] transition-colors ${
                weight === pw
                  ? 'bg-ios-blue text-white'
                  : 'bg-ios-gray-5 dark:bg-[#2C2C2E] text-ios-text-secondary dark:text-ios-gray-2 active:bg-ios-gray-4'
              }`}
            >
              {pw} lbs
            </button>
          ))}
          {weight > 0 && (
            <button
              onClick={() => onChange(0)}
              className="px-3 py-1 rounded-full text-[12px] min-h-[32px] bg-ios-gray-5 dark:bg-[#2C2C2E] text-ios-gray-1 active:bg-ios-gray-4"
            >
              Clear
            </button>
          )}
        </div>
      )}
    </div>
  );
}
