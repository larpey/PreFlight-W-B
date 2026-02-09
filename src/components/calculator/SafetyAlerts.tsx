import { AnimatePresence, motion } from 'framer-motion';
import type { CalculationWarning } from '../../types/calculation';

interface SafetyAlertsProps {
  warnings: CalculationWarning[];
}

const levelStyles = {
  danger: 'bg-ios-red/10 border-ios-red/30 dark:bg-ios-red/20',
  warning: 'bg-ios-orange/10 border-ios-orange/30 dark:bg-ios-orange/20',
  caution: 'bg-ios-yellow/10 border-ios-yellow/30 dark:bg-ios-yellow/20',
} as const;

const levelIcons = {
  danger: '🔴',
  warning: '🟠',
  caution: '🟡',
} as const;

const levelTextColor = {
  danger: 'text-ios-red',
  warning: 'text-ios-orange',
  caution: 'text-[#996600] dark:text-ios-yellow',
} as const;

export function SafetyAlerts({ warnings }: SafetyAlertsProps) {
  if (warnings.length === 0) return null;

  // Sort: danger first, then warning, then caution
  const sorted = [...warnings].sort((a, b) => {
    const order = { danger: 0, warning: 1, caution: 2 };
    return order[a.level] - order[b.level];
  });

  return (
    <AnimatePresence>
      <div className="space-y-2">
        {sorted.map((warning, i) => (
          <motion.div
            key={warning.code + i}
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -10 }}
            className={`rounded-xl border px-4 py-3 ${levelStyles[warning.level]}`}
          >
            <div className="flex items-start gap-2">
              <span className="text-sm mt-0.5">{levelIcons[warning.level]}</span>
              <div className="flex-1">
                <div className={`text-[14px] font-semibold ${levelTextColor[warning.level]}`}>
                  {warning.message}
                </div>
                {warning.detail && (
                  <div className="text-[12px] text-ios-text-secondary dark:text-ios-gray-2 mt-0.5">
                    {warning.detail}
                  </div>
                )}
                {warning.regulatoryRef && (
                  <div className="text-[11px] text-ios-gray-1 mt-1">
                    Ref: {warning.regulatoryRef}
                  </div>
                )}
              </div>
            </div>
          </motion.div>
        ))}
      </div>
    </AnimatePresence>
  );
}
