import { useState } from 'react';
import { disclaimer } from '../../data/regulatory';

export function Disclaimer() {
  const [expanded, setExpanded] = useState(false);

  return (
    <div className="mx-4 mb-6 rounded-xl bg-ios-orange/10 dark:bg-ios-orange/20 border border-ios-orange/30 overflow-hidden">
      <button
        onClick={() => setExpanded(!expanded)}
        className="w-full flex items-center justify-between px-4 py-3 min-h-[44px] active:opacity-60"
      >
        <span className="flex items-center gap-2 text-sm font-medium text-ios-orange">
          <span>⚠</span>
          <span>Important Safety Disclaimer</span>
        </span>
        <span className="text-ios-gray-1 text-xs">
          {expanded ? 'Hide' : 'Show'}
        </span>
      </button>
      {expanded && (
        <div className="px-4 pb-4 text-xs text-ios-text-secondary dark:text-ios-gray-2 leading-relaxed whitespace-pre-line">
          {disclaimer}
        </div>
      )}
    </div>
  );
}
