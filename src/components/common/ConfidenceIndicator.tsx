interface ConfidenceIndicatorProps {
  confidence: 'high' | 'medium' | 'low';
  showLabel?: boolean;
}

const colors = {
  high: 'bg-confidence-high',
  medium: 'bg-confidence-medium',
  low: 'bg-confidence-low',
} as const;

const labels = {
  high: 'High',
  medium: 'Medium',
  low: 'Low',
} as const;

export function ConfidenceIndicator({ confidence, showLabel = false }: ConfidenceIndicatorProps) {
  return (
    <span className="inline-flex items-center gap-1">
      <span className={`w-2 h-2 rounded-full ${colors[confidence]}`} />
      {showLabel && (
        <span className="text-xs text-ios-gray-1">{labels[confidence]}</span>
      )}
    </span>
  );
}
