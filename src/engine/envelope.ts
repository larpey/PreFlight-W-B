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
