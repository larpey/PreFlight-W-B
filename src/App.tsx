import { useState } from 'react';
import { AnimatePresence, motion } from 'framer-motion';
import { AppShell } from './components/layout/AppShell';
import { AuthProvider, useAuth } from './contexts/AuthContext';
import { LandingPage } from './pages/LandingPage';
import { LoginPage } from './pages/LoginPage';
import { AircraftSelectPage } from './pages/AircraftSelectPage';
import { CalculatorPage } from './pages/CalculatorPage';
import { SourcesPage } from './pages/SourcesPage';
import { ScenariosPage } from './pages/ScenariosPage';
import { aircraftDatabase } from './data/aircraft';
import type { Aircraft } from './types/aircraft';
import type { SavedScenario } from './db';

type Page = 'landing' | 'login' | 'select' | 'calculator' | 'sources' | 'scenarios';

const pageTransition = {
  initial: { opacity: 0, y: 16 },
  animate: { opacity: 1, y: 0, transition: { duration: 0.35, ease: [0.25, 0.1, 0.25, 1] as [number, number, number, number] } },
  exit: { opacity: 0, y: -12, transition: { duration: 0.2, ease: [0.25, 0.1, 0.25, 1] as [number, number, number, number] } },
};

function AppContent() {
  const { isAuthenticated, isGuest, isLoading } = useAuth();
  const [page, setPage] = useState<Page>('landing');
  const [selectedAircraft, setSelectedAircraft] = useState<Aircraft | null>(null);
  const [loadedScenario, setLoadedScenario] = useState<SavedScenario | undefined>();

  const handleEnterFromLanding = () => {
    if (isAuthenticated || isGuest) {
      setPage('select');
    } else {
      setPage('login');
    }
  };

  const handleLoginComplete = () => {
    setPage('select');
  };

  const handleSelectAircraft = (aircraft: Aircraft) => {
    setSelectedAircraft(aircraft);
    setLoadedScenario(undefined);
    setPage('calculator');
  };

  const handleLoadScenario = (scenario: SavedScenario) => {
    const aircraft = aircraftDatabase.find(a => a.id === scenario.aircraftId);
    if (aircraft) {
      setSelectedAircraft(aircraft);
      setLoadedScenario(scenario);
      setPage('calculator');
    }
  };

  if (isLoading) return null;

  return (
    <AnimatePresence mode="wait">
      {page === 'landing' && (
        <motion.div key="landing" {...pageTransition}>
          <LandingPage onEnter={handleEnterFromLanding} />
        </motion.div>
      )}

      {page === 'login' && (
        <motion.div key="login" {...pageTransition}>
          <LoginPage onComplete={handleLoginComplete} />
        </motion.div>
      )}

      {page === 'select' && (
        <motion.div key="select" {...pageTransition}>
          <AppShell>
            <AircraftSelectPage
              onSelect={handleSelectAircraft}
              onHome={() => setPage('landing')}
              onViewScenarios={() => setPage('scenarios')}
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
              initialScenario={loadedScenario}
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

      {page === 'scenarios' && (
        <motion.div key="scenarios" {...pageTransition}>
          <AppShell>
            <ScenariosPage
              onBack={() => setPage('select')}
              onLoad={handleLoadScenario}
            />
          </AppShell>
        </motion.div>
      )}
    </AnimatePresence>
  );
}

export default function App() {
  return (
    <AuthProvider>
      <AppContent />
    </AuthProvider>
  );
}
