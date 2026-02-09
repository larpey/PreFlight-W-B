import type { SourceAttribution } from '../../types/aircraft';
import { ConfidenceIndicator } from '../common/ConfidenceIndicator';

interface SourcePanelProps {
  source: SourceAttribution;
  onClose: () => void;
}

export function SourcePanel({ source, onClose }: SourcePanelProps) {
  return (
    <div className="mt-2 rounded-xl bg-white dark:bg-[#1C1C1E] border border-ios-separator dark:border-[#38383A] overflow-hidden">
      <div className="flex items-center justify-between px-4 py-2 bg-ios-gray-6 dark:bg-[#2C2C2E] border-b border-ios-separator dark:border-[#38383A]">
        <span className="text-xs font-semibold text-ios-text-secondary dark:text-ios-gray-2 uppercase tracking-wide">
          Source Attribution
        </span>
        <button
          onClick={onClose}
          className="text-ios-blue text-sm min-w-[44px] min-h-[44px] flex items-center justify-end active:opacity-60"
        >
          Done
        </button>
      </div>

      <div className="px-4 py-3 space-y-3">
        {/* Primary Source */}
        <div>
          <div className="text-[11px] font-medium text-ios-gray-1 uppercase tracking-wide mb-1">
            Primary Source
          </div>
          <div className="text-sm font-medium text-ios-text dark:text-white">
            {source.primary.document}
          </div>
          <div className="text-xs text-ios-text-secondary dark:text-ios-gray-2 mt-0.5">
            {source.primary.section}
          </div>
          <div className="text-xs text-ios-gray-1 mt-0.5">
            {source.primary.publisher} · {source.primary.datePublished}
          </div>
          {source.primary.tcdsNumber && (
            <div className="text-xs text-ios-gray-1 mt-0.5">
              TCDS: {source.primary.tcdsNumber}
            </div>
          )}
          {source.primary.url && (
            <a
              href={source.primary.url}
              target="_blank"
              rel="noopener noreferrer"
              className="text-xs text-ios-blue mt-1 inline-block"
            >
              View Document →
            </a>
          )}
        </div>

        {/* Secondary Source */}
        {source.secondary && (
          <div className="pt-2 border-t border-ios-separator dark:border-[#38383A]">
            <div className="text-[11px] font-medium text-ios-gray-1 uppercase tracking-wide mb-1">
              Secondary Source
            </div>
            <div className="text-sm text-ios-text dark:text-white">
              {source.secondary.document}
            </div>
            <div className="text-xs text-ios-text-secondary dark:text-ios-gray-2 mt-0.5">
              {source.secondary.verification}
            </div>
          </div>
        )}

        {/* Confidence & Verification */}
        <div className="pt-2 border-t border-ios-separator dark:border-[#38383A] flex items-center justify-between">
          <div className="flex items-center gap-2">
            <span className="text-[11px] text-ios-gray-1">Confidence:</span>
            <ConfidenceIndicator confidence={source.confidence} showLabel />
          </div>
          <div className="text-[11px] text-ios-gray-1">
            Verified: {source.lastVerified}
          </div>
        </div>

        {/* Notes */}
        {source.notes && (
          <div className="pt-2 border-t border-ios-separator dark:border-[#38383A]">
            <div className="text-[11px] font-medium text-ios-gray-1 uppercase tracking-wide mb-1">
              Notes
            </div>
            <div className="text-xs text-ios-text-secondary dark:text-ios-gray-2 leading-relaxed">
              {source.notes}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
