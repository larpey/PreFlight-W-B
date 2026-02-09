import type { FuelTank } from '../../types/aircraft';
import { SourceBadge } from '../sources/SourceBadge';

interface FuelInputProps {
  tank: FuelTank;
  gallons: number;
  onChange: (gallons: number) => void;
}

export function FuelInput({ tank, gallons, onChange }: FuelInputProps) {
  const weight = gallons * tank.fuelWeightPerGallon;
  const maxGal = tank.maxGallons.value;
  const pct = maxGal > 0 ? Math.min((gallons / maxGal) * 100, 100) : 0;
  const isOver = gallons > maxGal;

  return (
    <div className="bg-white dark:bg-[#1C1C1E] rounded-xl px-4 py-3">
      <div className="flex items-center justify-between mb-2">
        <div>
          <span className="text-[15px] font-medium text-ios-text dark:text-white">
            {tank.name}
          </span>
          <span className="text-[12px] text-ios-gray-1 ml-2">
            Arm: {tank.arm.value}"
          </span>
        </div>
        <SourceBadge source={tank.arm.source} />
      </div>

      {/* Slider */}
      <input
        type="range"
        min={0}
        max={maxGal}
        step={1}
        value={Math.min(gallons, maxGal)}
        onChange={e => onChange(Number(e.target.value))}
        className="w-full h-2 rounded-full appearance-none cursor-pointer accent-ios-blue bg-ios-gray-5 dark:bg-[#2C2C2E]"
      />

      {/* Values row */}
      <div className="flex items-center justify-between mt-2">
        <div className="flex items-center gap-2">
          <input
            type="number"
            inputMode="decimal"
            value={gallons || ''}
            onChange={e => onChange(Math.max(0, Number(e.target.value)))}
            placeholder="0"
            className={`w-20 h-9 px-2 rounded-lg text-[15px] bg-ios-gray-6 dark:bg-[#2C2C2E] text-ios-text dark:text-white placeholder-ios-gray-3 outline-none border-2 transition-colors ${
              isOver ? 'border-ios-red' : 'border-transparent focus:border-ios-blue'
            }`}
          />
          <span className="text-[13px] text-ios-gray-1">gal</span>
          <span className="text-[13px] text-ios-text-secondary dark:text-ios-gray-2 font-medium">
            = {weight.toFixed(0)} lbs
          </span>
        </div>
        <span className={`text-[12px] ${isOver ? 'text-ios-red font-medium' : 'text-ios-gray-1'}`}>
          max {maxGal} gal
        </span>
      </div>

      {/* Fill indicator */}
      <div className="mt-2 h-1.5 rounded-full bg-ios-gray-5 dark:bg-[#2C2C2E] overflow-hidden">
        <div
          className={`h-full rounded-full transition-all ${
            isOver ? 'bg-ios-red' : pct > 90 ? 'bg-ios-orange' : 'bg-ios-blue'
          }`}
          style={{ width: `${Math.min(pct, 100)}%` }}
        />
      </div>

      {/* Quick buttons */}
      <div className="flex gap-2 mt-2">
        <button
          onClick={() => onChange(maxGal)}
          className={`px-3 py-1 rounded-full text-[12px] min-h-[32px] transition-colors ${
            gallons === maxGal
              ? 'bg-ios-blue text-white'
              : 'bg-ios-gray-5 dark:bg-[#2C2C2E] text-ios-text-secondary dark:text-ios-gray-2 active:bg-ios-gray-4'
          }`}
        >
          Full
        </button>
        <button
          onClick={() => onChange(Math.round(maxGal / 2))}
          className={`px-3 py-1 rounded-full text-[12px] min-h-[32px] transition-colors ${
            gallons === Math.round(maxGal / 2)
              ? 'bg-ios-blue text-white'
              : 'bg-ios-gray-5 dark:bg-[#2C2C2E] text-ios-text-secondary dark:text-ios-gray-2 active:bg-ios-gray-4'
          }`}
        >
          Half
        </button>
        {gallons > 0 && (
          <button
            onClick={() => onChange(0)}
            className="px-3 py-1 rounded-full text-[12px] min-h-[32px] bg-ios-gray-5 dark:bg-[#2C2C2E] text-ios-gray-1 active:bg-ios-gray-4"
          >
            Empty
          </button>
        )}
      </div>
    </div>
  );
}
