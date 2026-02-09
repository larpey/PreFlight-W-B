import { useState } from 'react';
import { AnimatePresence, motion } from 'framer-motion';
import { AppShell } from './components/layout/AppShell';
import { LandingPage } from './pages/LandingPage';
import { AircraftSelectPage } from './pages/AircraftSelectPage';
import { CalculatorPage } from './pages/CalculatorPage';
import { SourcesPage } from './pages/SourcesPage';
import type { Aircraft } from './types/aircraft';

type Page = 'landing' | 'select' | 'calculator' | 'sources';

const pageTransition = {
  initial: { opacity: 0, y: 16 },
  animate: { opacity: 1, y: 0, transition: { duration: 0.35, ease: [0.25, 0.1, 0.25, 1] as [number, number, number, number] } },
  exit: { opacity: 0, y: -12, transition: { duration: 0.2, ease: [0.25, 0.1, 0.25, 1] as [number, number, number, number] } },
};

export default function App() {
  const [page, setPage] = useState<Page>('landing');
  const [selectedAircraft, setSelectedAircraft] = useState<Aircraft | null>(null);

  const handleSelectAircraft = (aircraft: Aircraft) => {
    setSelectedAircraft(aircraft);
    setPage('calculator');
  };

  return (
    <AnimatePresence mode="wait">
      {page === 'landing' && (
        <motion.div key="landing" {...pageTransition}>
          <LandingPage onEnter={() => setPage('select')} />
        </motion.div>
      )}

      {page === 'select' && (
        <motion.div key="select" {...pageTransition}>
          <AppShell>
            <AircraftSelectPage
              onSelect={handleSelectAircraft}
              onHome={() => setPage('landing')}
            />
          </AppShell>
        </motion.div>
      )}

      {page === 'calculator' && selectedAircraft && (
        <motion.div key="calculator" {...pageTransition}>
          <AppShell>
            <CalculatorPage
              aircraft={selectedAircraft}
              onBack={() => setPage('select')}
              onViewSources={() => setPage('sources')}
            />
          </AppShell>
        </motion.div>
      )}

      {page === 'sources' && selectedAircraft && (
        <motion.div key="sources" {...pageTransition}>
          <AppShell>
            <SourcesPage
              aircraft={selectedAircraft}
              onBack={() => setPage('calculator')}
            />
          </AppShell>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
