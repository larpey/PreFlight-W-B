import { useState } from 'react';
import type { SavedScenario } from '../../db';

interface ScenarioCardProps {
  scenario: SavedScenario;
  onLoad: () => void;
  onDelete: () => void;
}

export function ScenarioCard({ scenario, onLoad, onDelete }: ScenarioCardProps) {
  const [showDelete, setShowDelete] = useState(false);

  const totalWeight = scenario.stationLoads.reduce((sum, s) => sum + s.weight, 0)
    + scenario.fuelLoads.reduce((sum, f) => sum + f.gallons * 6, 0);

  const date = new Date(scenario.updatedAt);
  const dateStr = date.toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' });

  return (
    <div className="relative overflow-hidden">
      <div
        className="flex items-center px-4 py-3.5 active:bg-ios-gray-6 dark:active:bg-white/5 transition-colors cursor-pointer"
        onClick={onLoad}
        onContextMenu={e => {
          e.preventDefault();
          setShowDelete(v => !v);
        }}
      >
        <div className="flex-1 min-w-0">
          <p className="text-[16px] font-medium text-ios-text dark:text-white truncate">
            {scenario.name}
          </p>
          <p className="text-[13px] text-ios-gray-1 mt-0.5">
            {dateStr} &middot; ~{totalWeight.toLocaleString()} lbs payload
          </p>
        </div>

        <div className="flex items-center gap-2 ml-3">
          {scenario.dirty && (
            <span className="w-2 h-2 rounded-full bg-ios-orange" title="Pending sync" />
          )}
          <svg width="7" height="12" viewBox="0 0 7 12" fill="none" className="text-ios-gray-3">
            <path d="M1 1L6 6L1 11" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
          </svg>
        </div>
      </div>

      {showDelete && (
        <div className="absolute inset-y-0 right-0 flex items-center">
          <button
            onClick={e => {
              e.stopPropagation();
              onDelete();
            }}
            className="h-full px-6 bg-ios-red text-white text-[15px] font-medium"
          >
            Delete
          </button>
        </div>
      )}
    </div>
  );
}
