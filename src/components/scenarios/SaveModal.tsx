import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

interface SaveModalProps {
  isOpen: boolean;
  onSave: (name: string) => void;
  onCancel: () => void;
  defaultName?: string;
}

export function SaveModal({ isOpen, onSave, onCancel, defaultName = '' }: SaveModalProps) {
  const [name, setName] = useState(defaultName);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (name.trim()) {
      onSave(name.trim());
      setName('');
    }
  };

  return (
    <AnimatePresence>
      {isOpen && (
        <>
          {/* Backdrop */}
          <motion.div
            className="fixed inset-0 bg-black/50 z-50"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={onCancel}
          />

          {/* Modal */}
          <motion.div
            className="fixed inset-0 z-50 flex items-center justify-center px-6"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
          >
            <motion.div
              className="bg-ios-card dark:bg-[#1c1c1e] rounded-2xl w-full max-w-[320px] overflow-hidden"
              initial={{ scale: 0.9, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0.9, opacity: 0 }}
              transition={{ duration: 0.2 }}
              onClick={e => e.stopPropagation()}
            >
              <div className="p-5 text-center">
                <h3 className="text-[17px] font-semibold text-ios-text dark:text-white mb-1">
                  Save Scenario
                </h3>
                <p className="text-[13px] text-ios-gray-1 mb-4">
                  Give this loading configuration a name.
                </p>

                <form onSubmit={handleSubmit}>
                  <input
                    type="text"
                    value={name}
                    onChange={e => setName(e.target.value)}
                    placeholder="e.g. Weekend trip, Training flight"
                    autoFocus
                    className="w-full px-3.5 py-2.5 bg-ios-gray-6 dark:bg-white/10 rounded-xl text-[16px] text-ios-text dark:text-white placeholder:text-ios-gray-2 outline-none focus:ring-2 focus:ring-ios-blue/30"
                  />
                </form>
              </div>

              <div className="flex border-t border-ios-separator dark:border-white/10">
                <button
                  onClick={onCancel}
                  className="flex-1 py-3.5 text-[17px] text-ios-blue border-r border-ios-separator dark:border-white/10"
                >
                  Cancel
                </button>
                <button
                  onClick={() => name.trim() && onSave(name.trim())}
                  disabled={!name.trim()}
                  className="flex-1 py-3.5 text-[17px] text-ios-blue font-semibold disabled:opacity-40"
                >
                  Save
                </button>
              </div>
            </motion.div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
}
