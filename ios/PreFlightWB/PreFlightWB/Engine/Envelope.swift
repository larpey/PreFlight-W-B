import Foundation

// MARK: - CG Envelope Geometry

/// Pure functions for CG envelope polygon intersection and containment testing.
/// Ported from envelope.ts — safety-critical, do not modify without verification.
enum Envelope {

    // MARK: - Point-in-Polygon

    /// Ray-casting (even-odd rule) point-in-polygon test.
    ///
    /// Tests if the point (`cg`, `weight`) is inside the CG envelope polygon.
    /// The envelope points define a closed polygon where:
    ///   - x-axis = CG position (inches aft of datum)
    ///   - y-axis = weight (lbs)
    ///
    /// A horizontal ray is cast rightward from (`cg`, `weight`). Each time it
    /// crosses a polygon edge the inside/outside state toggles (even-odd rule).
    ///
    /// - Parameters:
    ///   - weight: Aircraft total weight in lbs (y-coordinate).
    ///   - cg: Center of gravity in inches aft of datum (x-coordinate).
    ///   - envelope: The CG envelope containing the polygon boundary points.
    /// - Returns: `true` if the point is inside the envelope polygon.
    static func isPointInEnvelope(weight: Double, cg: Double, envelope: CGEnvelope) -> Bool {
        let points = envelope.points
        let n = points.count
        guard n >= 3 else { return false }

        var inside = false

        var j = n - 1
        for i in 0..<n {
            let xi = points[i].cg,  yi = points[i].weight
            let xj = points[j].cg, yj = points[j].weight

            // Check if the horizontal ray at `weight` crosses this edge
            if ((yi > weight) != (yj > weight)) &&
               (cg < ((xj - xi) * (weight - yi)) / (yj - yi) + xi) {
                inside = !inside
            }

            j = i
        }

        return inside
    }

    // MARK: - Limits at Weight

    /// Find the forward (min CG) and aft (max CG) limits at a given weight
    /// by intersecting a horizontal line at `weight` with all envelope edges.
    ///
    /// For each polygon edge that spans the given weight vertically, the CG
    /// value where the horizontal line intersects is calculated via linear
    /// interpolation. The minimum and maximum of all such intersections give
    /// the forward and aft limits respectively.
    ///
    /// - Parameters:
    ///   - weight: The aircraft weight at which to find CG limits.
    ///   - envelope: The CG envelope containing the polygon boundary points.
    /// - Returns: A tuple of `(forward, aft)` CG limits, or `nil` if the
    ///   weight is entirely outside the envelope's vertical range.
    static func getLimitsAtWeight(_ weight: Double, envelope: CGEnvelope) -> (forward: Double, aft: Double)? {
        let points = envelope.points
        let n = points.count
        guard n >= 3 else { return nil }

        var intersections: [Double] = []

        for i in 0..<n {
            let j = (i + 1) % n
            let p1 = points[i]
            let p2 = points[j]

            let minW = min(p1.weight, p2.weight)
            let maxW = max(p1.weight, p2.weight)

            if weight >= minW && weight <= maxW {
                if p1.weight == p2.weight {
                    // Horizontal edge: both endpoints are intersections
                    intersections.append(p1.cg)
                    intersections.append(p2.cg)
                } else {
                    // Linear interpolation along the edge
                    let t = (weight - p1.weight) / (p2.weight - p1.weight)
                    intersections.append(p1.cg + t * (p2.cg - p1.cg))
                }
            }
        }

        guard !intersections.isEmpty else { return nil }

        let forward = intersections.min()!
        let aft = intersections.max()!
        return (forward: forward, aft: aft)
    }
}
