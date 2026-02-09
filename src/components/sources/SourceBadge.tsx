import { useState } from 'react';
import type { SourceAttribution } from '../../types/aircraft';
import { ConfidenceIndicator } from '../common/ConfidenceIndicator';
import { SourcePanel } from './SourcePanel';

interface SourceBadgeProps {
  source: SourceAttribution;
  label?: string;
}

export function SourceBadge({ source, label }: SourceBadgeProps) {
  const [showPanel, setShowPanel] = useState(false);

  return (
    <>
      <button
        onClick={() => setShowPanel(!showPanel)}
        className="inline-flex items-center gap-1 px-1.5 py-0.5 rounded-md bg-ios-gray-5 dark:bg-[#2C2C2E] active:opacity-60 min-h-[28px]"
      >
        <ConfidenceIndicator confidence={source.confidence} />
        <span className="text-[11px] text-ios-gray-1">
          {label ?? 'Source'}
        </span>
      </button>
      {showPanel && (
        <SourcePanel source={source} onClose={() => setShowPanel(false)} />
      )}
    </>
  );
}
