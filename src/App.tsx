import { useState } from 'react';
import { AppShell } from './components/layout/AppShell';
import { AircraftSelectPage } from './pages/AircraftSelectPage';
import { CalculatorPage } from './pages/CalculatorPage';
import { SourcesPage } from './pages/SourcesPage';
import type { Aircraft } from './types/aircraft';

type Page = 'select' | 'calculator' | 'sources';

export default function App() {
  const [page, setPage] = useState<Page>('select');
  const [selectedAircraft, setSelectedAircraft] = useState<Aircraft | null>(null);

  const handleSelectAircraft = (aircraft: Aircraft) => {
    setSelectedAircraft(aircraft);
    setPage('calculator');
  };

  return (
    <AppShell>
      {page === 'select' && (
        <AircraftSelectPage onSelect={handleSelectAircraft} />
      )}
      {page === 'calculator' && selectedAircraft && (
        <CalculatorPage
          aircraft={selectedAircraft}
          onBack={() => setPage('select')}
          onViewSources={() => setPage('sources')}
        />
      )}
      {page === 'sources' && selectedAircraft && (
        <SourcesPage
          aircraft={selectedAircraft}
          onBack={() => setPage('calculator')}
        />
      )}
    </AppShell>
  );
}
