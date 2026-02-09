import type { Aircraft } from '../../types/aircraft';
import { AircraftCard } from './AircraftCard';

interface AircraftListProps {
  aircraft: Aircraft[];
  searchQuery: string;
  onSelect: (aircraft: Aircraft) => void;
}

export function AircraftList({ aircraft, searchQuery, onSelect }: AircraftListProps) {
  const query = searchQuery.toLowerCase();
  const filtered = aircraft.filter(
    a =>
      a.name.toLowerCase().includes(query) ||
      a.model.toLowerCase().includes(query) ||
      a.manufacturer.toLowerCase().includes(query)
  );

  const singleEngine = filtered.filter(a => a.category === 'single-engine');
  const multiEngine = filtered.filter(a => a.category === 'multi-engine');

  if (filtered.length === 0) {
    return (
      <div className="px-4 py-12 text-center text-ios-gray-1">
        No aircraft match your search.
      </div>
    );
  }

  return (
    <div className="px-4 space-y-6">
      {singleEngine.length > 0 && (
        <section>
          <h2 className="text-[13px] font-medium text-ios-gray-1 uppercase tracking-wide px-1 mb-2">
            Single Engine
          </h2>
          <div className="space-y-px rounded-xl overflow-hidden">
            {singleEngine.map(a => (
              <AircraftCard key={a.id} aircraft={a} onSelect={onSelect} />
            ))}
          </div>
        </section>
      )}

      {multiEngine.length > 0 && (
        <section>
          <h2 className="text-[13px] font-medium text-ios-gray-1 uppercase tracking-wide px-1 mb-2">
            Multi Engine
          </h2>
          <div className="space-y-px rounded-xl overflow-hidden">
            {multiEngine.map(a => (
              <AircraftCard key={a.id} aircraft={a} onSelect={onSelect} />
            ))}
          </div>
        </section>
      )}
    </div>
  );
}
