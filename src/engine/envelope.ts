import type { EnvelopePoint } from '../types/aircraft';

/**
 * Ray-casting algorithm to test if a point (weight, cg) is inside the CG envelope polygon.
 * Uses the standard even-odd rule point-in-polygon test.
 *
 * The envelope points define a closed polygon where:
 *   x = CG position (inches aft of datum)
 *   y = weight (lbs)
 */
export function isPointInEnvelope(
  weight: number,
  cg: number,
  envelope: EnvelopePoint[]
): boolean {
  let inside = false;
  const n = envelope.length;

  for (let i = 0, j = n - 1; i < n; j = i++) {
    const xi = envelope[i]!.cg, yi = envelope[i]!.weight;
    const xj = envelope[j]!.cg, yj = envelope[j]!.weight;

    if (
      ((yi > weight) !== (yj > weight)) &&
      (cg < ((xj - xi) * (weight - yi)) / (yj - yi) + xi)
    ) {
      inside = !inside;
    }
  }

  return inside;
}

/**
 * Given a weight, find the forward (min CG) and aft (max CG) limits
 * by intersecting a horizontal line at that weight with the envelope polygon edges.
 * Returns null if the weight is outside the envelope's weight range.
 */
export function getEnvelopeLimitsAtWeight(
  weight: number,
  envelope: EnvelopePoint[]
): { fwdLimit: number; aftLimit: number } | null {
  const intersections: number[] = [];
  const n = envelope.length;

  for (let i = 0; i < n; i++) {
    const j = (i + 1) % n;
    const p1 = envelope[i]!;
    const p2 = envelope[j]!;

    const minW = Math.min(p1.weight, p2.weight);
    const maxW = Math.max(p1.weight, p2.weight);

    if (weight >= minW && weight <= maxW) {
      if (p1.weight === p2.weight) {
        intersections.push(p1.cg, p2.cg);
      } else {
        const t = (weight - p1.weight) / (p2.weight - p1.weight);
        intersections.push(p1.cg + t * (p2.cg - p1.cg));
      }
    }
  }

  if (intersections.length === 0) return null;

  return {
    fwdLimit: Math.min(...intersections),
    aftLimit: Math.max(...intersections),
  };
}
