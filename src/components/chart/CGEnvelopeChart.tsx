import type { Aircraft } from '../../types/aircraft';
import type { CalculationResult } from '../../types/calculation';

interface CGEnvelopeChartProps {
  aircraft: Aircraft;
  result: CalculationResult;
}

export function CGEnvelopeChart({ aircraft, result }: CGEnvelopeChartProps) {
  const envelope = aircraft.cgEnvelope.points;

  // Compute data bounds with padding
  const allCG = envelope.map(p => p.cg);
  const allWeight = envelope.map(p => p.weight);
  const minCG = Math.min(...allCG) - 2;
  const maxCG = Math.max(...allCG) + 2;
  const minWeight = Math.min(...allWeight) - 100;
  const maxWeight = Math.max(...allWeight) + 200;

  // SVG dimensions
  const svgWidth = 360;
  const svgHeight = 260;
  const padding = { top: 20, right: 20, bottom: 40, left: 55 };
  const plotW = svgWidth - padding.left - padding.right;
  const plotH = svgHeight - padding.top - padding.bottom;

  // Coordinate mapping
  const toCGx = (cg: number) =>
    padding.left + ((cg - minCG) / (maxCG - minCG)) * plotW;
  const toWeightY = (w: number) =>
    padding.top + plotH - ((w - minWeight) / (maxWeight - minWeight)) * plotH;

  // Envelope polygon path
  const envelopePath = envelope
    .map((p, i) => `${i === 0 ? 'M' : 'L'}${toCGx(p.cg)},${toWeightY(p.weight)}`)
    .join(' ') + ' Z';

  // Current point
  const cx = toCGx(result.cg);
  const cy = toWeightY(result.totalWeight);
  const isInside = result.isWithinCGEnvelope;

  // Grid lines
  const cgStep = Math.ceil((maxCG - minCG) / 5);
  const weightStep = Math.ceil((maxWeight - minWeight) / 5 / 100) * 100;
  const cgTicks: number[] = [];
  const weightTicks: number[] = [];

  for (let cg = Math.ceil(minCG); cg <= maxCG; cg += cgStep) cgTicks.push(cg);
  for (let w = Math.ceil(minWeight / 100) * 100; w <= maxWeight; w += weightStep) weightTicks.push(w);

  return (
    <div className="bg-white dark:bg-[#1C1C1E] rounded-xl px-4 py-4">
      <div className="flex items-center justify-between mb-3">
        <span className="text-[15px] font-semibold text-ios-text dark:text-white">
          CG Envelope
        </span>
        <span className={`text-[12px] font-medium ${isInside ? 'text-ios-green' : 'text-ios-red'}`}>
          {isInside ? 'Within Envelope' : 'Outside Envelope'}
        </span>
      </div>

      <svg
        viewBox={`0 0 ${svgWidth} ${svgHeight}`}
        className="w-full"
        style={{ touchAction: 'none' }}
      >
        {/* Grid lines */}
        {cgTicks.map(cg => (
          <line
            key={`cg-${cg}`}
            x1={toCGx(cg)}
            y1={padding.top}
            x2={toCGx(cg)}
            y2={padding.top + plotH}
            stroke="currentColor"
            className="text-ios-gray-5 dark:text-[#2C2C2E]"
            strokeWidth={1}
          />
        ))}
        {weightTicks.map(w => (
          <line
            key={`w-${w}`}
            x1={padding.left}
            y1={toWeightY(w)}
            x2={padding.left + plotW}
            y2={toWeightY(w)}
            stroke="currentColor"
            className="text-ios-gray-5 dark:text-[#2C2C2E]"
            strokeWidth={1}
          />
        ))}

        {/* Envelope fill */}
        <path
          d={envelopePath}
          fill={isInside ? 'rgba(52, 199, 89, 0.15)' : 'rgba(52, 199, 89, 0.08)'}
          stroke="rgba(52, 199, 89, 0.6)"
          strokeWidth={2}
        />

        {/* Max gross weight reference line */}
        <line
          x1={padding.left}
          y1={toWeightY(aircraft.maxGrossWeight.value)}
          x2={padding.left + plotW}
          y2={toWeightY(aircraft.maxGrossWeight.value)}
          stroke="rgba(255, 59, 48, 0.4)"
          strokeWidth={1}
          strokeDasharray="4 3"
        />

        {/* Current loading point */}
        <circle
          cx={cx}
          cy={cy}
          r={7}
          fill={isInside ? '#34C759' : '#FF3B30'}
          stroke="white"
          strokeWidth={2}
        />
        <circle
          cx={cx}
          cy={cy}
          r={12}
          fill="none"
          stroke={isInside ? 'rgba(52, 199, 89, 0.3)' : 'rgba(255, 59, 48, 0.3)'}
          strokeWidth={2}
        />

        {/* X-axis labels (CG) */}
        {cgTicks.map(cg => (
          <text
            key={`label-cg-${cg}`}
            x={toCGx(cg)}
            y={svgHeight - 8}
            textAnchor="middle"
            className="fill-ios-gray-1 text-[10px]"
          >
            {cg}
          </text>
        ))}
        <text
          x={padding.left + plotW / 2}
          y={svgHeight}
          textAnchor="middle"
          className="fill-ios-gray-1 text-[10px]"
        >
          CG (inches aft of datum)
        </text>

        {/* Y-axis labels (Weight) */}
        {weightTicks.map(w => (
          <text
            key={`label-w-${w}`}
            x={padding.left - 8}
            y={toWeightY(w) + 4}
            textAnchor="end"
            className="fill-ios-gray-1 text-[10px]"
          >
            {w.toLocaleString()}
          </text>
        ))}
        <text
          x={12}
          y={padding.top + plotH / 2}
          textAnchor="middle"
          transform={`rotate(-90, 12, ${padding.top + plotH / 2})`}
          className="fill-ios-gray-1 text-[10px]"
        >
          Weight (lbs)
        </text>

        {/* Current point label */}
        <text
          x={cx + 14}
          y={cy - 4}
          className="fill-ios-text dark:fill-white text-[10px] font-medium"
        >
          {result.totalWeight.toFixed(0)} lbs
        </text>
        <text
          x={cx + 14}
          y={cy + 8}
          className="fill-ios-gray-1 text-[9px]"
        >
          CG {result.cg.toFixed(1)}"
        </text>
      </svg>

      <div className="text-[11px] text-ios-gray-1 mt-2 text-center">
        Datum: {aircraft.datum}
      </div>
    </div>
  );
}
