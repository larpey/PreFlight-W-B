import { motion, AnimatePresence } from 'framer-motion';
import { NavBar } from '../components/layout/NavBar';
import { ScenarioCard } from '../components/scenarios/ScenarioCard';
import { useScenarios } from '../hooks/useScenarios';
import { useSync } from '../hooks/useSync';
import { useAuth } from '../contexts/AuthContext';
import type { SavedScenario } from '../db';

interface ScenariosPageProps {
  onBack: () => void;
  onLoad: (scenario: SavedScenario) => void;
}

export function ScenariosPage({ onBack, onLoad }: ScenariosPageProps) {
  const { scenarios, loading, remove } = useScenarios();
  const { status: syncStatus, sync } = useSync();
  const { isAuthenticated } = useAuth();

  // Group by aircraft
  const grouped = scenarios.reduce<Record<string, SavedScenario[]>>((acc, s) => {
    (acc[s.aircraftId] ??= []).push(s);
    return acc;
  }, {});

  return (
    <div className="min-h-dvh bg-ios-bg dark:bg-black">
      <NavBar
        title="Saved Scenarios"
        onBack={onBack}
        rightContent={
          isAuthenticated ? (
            <button
              onClick={sync}
              disabled={syncStatus === 'syncing'}
              className="text-[15px] text-ios-blue disabled:opacity-50"
            >
              {syncStatus === 'syncing' ? 'Syncing...' : 'Sync'}
            </button>
          ) : undefined
        }
      />

      <div className="px-4 pt-2 pb-8">
        {loading ? (
          <div className="text-center py-12 text-ios-gray-1">Loading...</div>
        ) : scenarios.length === 0 ? (
          <div className="text-center py-16">
            <p className="text-[48px] mb-4">📋</p>
            <p className="text-[17px] font-semibold text-ios-text dark:text-white mb-2">
              No Saved Scenarios
            </p>
            <p className="text-[14px] text-ios-gray-1 max-w-[280px] mx-auto">
              Set up a loading scenario in the calculator, then tap Save to store it here.
            </p>
          </div>
        ) : (
          Object.entries(grouped).map(([aircraftId, items]) => (
            <div key={aircraftId} className="mb-6">
              <h2 className="text-[13px] font-semibold text-ios-gray-1 uppercase tracking-wider mb-2 px-1">
                {aircraftId}
              </h2>
              <div className="bg-ios-card dark:bg-white/5 rounded-2xl overflow-hidden divide-y divide-ios-separator dark:divide-white/10">
                <AnimatePresence>
                  {items.map(scenario => (
                    <motion.div
                      key={scenario.id}
                      layout
                      exit={{ opacity: 0, height: 0 }}
                      transition={{ duration: 0.2 }}
                    >
                      <ScenarioCard
                        scenario={scenario}
                        onLoad={() => onLoad(scenario)}
                        onDelete={() => remove(scenario.id)}
                      />
                    </motion.div>
                  ))}
                </AnimatePresence>
              </div>
            </div>
          ))
        )}

        {syncStatus === 'error' && (
          <p className="text-center text-ios-red text-[13px] mt-4">
            Sync failed. Your data is saved locally and will sync when connection is restored.
          </p>
        )}
      </div>
    </div>
  );
}
