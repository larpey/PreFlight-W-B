import { useState } from 'react';
import type { Aircraft } from '../types/aircraft';
import { aircraftDatabase } from '../data/aircraft';
import { NavBar } from '../components/layout/NavBar';
import { AircraftList } from '../components/aircraft/AircraftList';
import { Disclaimer } from '../components/common/Disclaimer';
import { useScenarios } from '../hooks/useScenarios';

interface AircraftSelectPageProps {
  onSelect: (aircraft: Aircraft) => void;
  onHome?: () => void;
  onViewScenarios?: () => void;
}

export function AircraftSelectPage({ onSelect, onHome, onViewScenarios }: AircraftSelectPageProps) {
  const [search, setSearch] = useState('');
  const { scenarios } = useScenarios();
  const savedCount = scenarios.length;

  const homeButton = onHome ? (
    <button
      onClick={onHome}
      className="text-ios-blue text-[15px] min-w-[44px] min-h-[44px] flex items-center justify-center active:opacity-60"
      aria-label="Home"
    >
      ⌂
    </button>
  ) : undefined;

  return (
    <div className="flex flex-col min-h-screen">
      <NavBar title="PreFlight W&B" rightAction={homeButton} />

      {/* Search bar */}
      <div className="px-4 py-3">
        <div className="relative">
          <span className="absolute left-3 top-1/2 -translate-y-1/2 text-ios-gray-2 text-[15px]">
            ⌕
          </span>
          <input
            type="search"
            value={search}
            onChange={e => setSearch(e.target.value)}
            placeholder="Search aircraft..."
            className="w-full h-[36px] pl-9 pr-4 rounded-xl bg-ios-gray-5 dark:bg-[#1C1C1E] text-[16px] text-ios-text dark:text-white placeholder-ios-gray-2 outline-none"
          />
        </div>
      </div>

      {/* Saved scenarios button */}
      {onViewScenarios && savedCount > 0 && (
        <div className="px-4 pb-2">
          <button
            onClick={onViewScenarios}
            className="w-full flex items-center justify-between px-4 py-3 bg-ios-card dark:bg-white/5 rounded-xl active:bg-ios-gray-5 dark:active:bg-white/10 transition-colors"
          >
            <div className="flex items-center gap-3">
              <span className="text-[20px]">📋</span>
              <span className="text-[16px] text-ios-text dark:text-white">Saved Scenarios</span>
            </div>
            <div className="flex items-center gap-2">
              <span className="text-[14px] text-ios-gray-1">{savedCount}</span>
              <svg width="7" height="12" viewBox="0 0 7 12" fill="none" className="text-ios-gray-3">
                <path d="M1 1L6 6L1 11" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
              </svg>
            </div>
          </button>
        </div>
      )}

      {/* Aircraft list */}
      <div className="flex-1 pb-4">
        <AircraftList
          aircraft={aircraftDatabase}
          searchQuery={search}
          onSelect={onSelect}
        />
      </div>

      {/* Disclaimer */}
      <Disclaimer />
    </div>
  );
}
