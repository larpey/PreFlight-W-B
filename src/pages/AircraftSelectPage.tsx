import { useState } from 'react';
import type { Aircraft } from '../types/aircraft';
import { aircraftDatabase } from '../data/aircraft';
import { NavBar } from '../components/layout/NavBar';
import { AircraftList } from '../components/aircraft/AircraftList';
import { Disclaimer } from '../components/common/Disclaimer';

interface AircraftSelectPageProps {
  onSelect: (aircraft: Aircraft) => void;
}

export function AircraftSelectPage({ onSelect }: AircraftSelectPageProps) {
  const [search, setSearch] = useState('');

  return (
    <div className="flex flex-col min-h-screen">
      <NavBar title="PreFlight W&B" />

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
