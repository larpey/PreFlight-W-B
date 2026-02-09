import { motion } from 'framer-motion';
import type { Aircraft } from '../../types/aircraft';

interface AircraftCardProps {
  aircraft: Aircraft;
  onSelect: (aircraft: Aircraft) => void;
}

export function AircraftCard({ aircraft, onSelect }: AircraftCardProps) {
  return (
    <motion.button
      whileTap={{ scale: 0.98 }}
      onClick={() => onSelect(aircraft)}
      className="w-full text-left bg-white dark:bg-[#1C1C1E] rounded-xl px-4 py-3 active:bg-ios-gray-5 dark:active:bg-[#2C2C2E] transition-colors"
    >
      <div className="flex items-center justify-between">
        <div className="flex-1 min-w-0">
          <div className="text-[17px] font-medium text-ios-text dark:text-white truncate">
            {aircraft.name}
          </div>
          <div className="text-[13px] text-ios-gray-1 mt-0.5">
            {aircraft.manufacturer}{aircraft.year ? ` · ${aircraft.year}` : ''}
          </div>
        </div>
        <span className="text-ios-gray-3 dark:text-ios-gray-1 ml-2 text-lg">›</span>
      </div>
      <div className="flex gap-4 mt-2 text-[12px] text-ios-text-secondary dark:text-ios-gray-2">
        <span>Empty: {aircraft.emptyWeight.value.toLocaleString()} lbs</span>
        <span>Max: {aircraft.maxGrossWeight.value.toLocaleString()} lbs</span>
        <span>Useful: {aircraft.usefulLoad.value.toLocaleString()} lbs</span>
      </div>
    </motion.button>
  );
}
