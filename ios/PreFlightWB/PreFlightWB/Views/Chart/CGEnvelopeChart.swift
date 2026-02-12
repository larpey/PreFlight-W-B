import SwiftUI

/// CG envelope chart using Canvas for custom drawing.
/// Draws the envelope polygon, current loading point, grid lines, and axis labels.
/// Uses @State proxy variables for animated CG dot positioning.
struct CGEnvelopeChart: View {
    let envelope: CGEnvelope
    let currentWeight: Double
    let currentCG: Double
    let isWithinEnvelope: Bool
    let maxGrossWeight: Double
    var landingWeight: Double? = nil
    var landingCG: Double? = nil
    var isLandingWithinEnvelope: Bool? = nil

    // MARK: - Animated State

    @State private var animatedWeight: Double = 0
    @State private var animatedCG: Double = 0
    @State private var animatedLandingWeight: Double = 0
    @State private var animatedLandingCG: Double = 0
    @Environment(\.colorScheme) var colorScheme

    // MARK: - Data Bounds

    private var allCG: [Double] { envelope.points.map(\.cg) }
    private var allWeight: [Double] { envelope.points.map(\.weight) }

    private var minCG: Double { (allCG.min() ?? 0) - 2 }
    private var maxCG: Double { (allCG.max() ?? 0) + 2 }
    private var minWeight: Double { (allWeight.min() ?? 0) - 100 }
    private var maxWeight: Double { (allWeight.max() ?? 0) + 200 }

    // MARK: - Tick Calculation

    private var cgStep: Double {
        let raw = (maxCG - minCG) / 5
        return max(1, ceil(raw))
    }

    private var weightStep: Double {
        let raw = (maxWeight - minWeight) / 5
        return max(100, ceil(raw / 100) * 100)
    }

    private var cgTicks: [Double] {
        var ticks: [Double] = []
        var cg = ceil(minCG)
        while cg <= maxCG {
            ticks.append(cg)
            cg += cgStep
        }
        return ticks
    }

    private var weightTicks: [Double] {
        var ticks: [Double] = []
        var w = ceil(minWeight / 100) * 100
        while w <= maxWeight {
            ticks.append(w)
            w += weightStep
        }
        return ticks
    }

    // MARK: - Layout Constants

    private let paddingTop: CGFloat = 16
    private let paddingBottom: CGFloat = 36
    private let paddingLeft: CGFloat = 50
    private let paddingRight: CGFloat = 16

    // MARK: - Derived Colors

    private var gridColor: Color {
        colorScheme == .dark
            ? Color.secondary.opacity(0.2)
            : Color.secondary.opacity(0.15)
    }

    private var pointBorderColor: Color {
        colorScheme == .dark
            ? Color(uiColor: .systemBackground)
            : .white
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: Spacing.xs) {
            // Header
            HStack {
                Text("CG Envelope")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                AnimatedStatusBadge(
                    status: isWithinEnvelope ? .safe : .danger,
                    text: isWithinEnvelope ? "Within Envelope" : "Outside Envelope"
                )
            }

            // Canvas chart
            Canvas { context, size in
                let plotW = size.width - paddingLeft - paddingRight
                let plotH = size.height - paddingTop - paddingBottom

                // Coordinate transforms
                func toCGx(_ cg: Double) -> CGFloat {
                    paddingLeft + CGFloat((cg - minCG) / (maxCG - minCG)) * plotW
                }
                func toWeightY(_ w: Double) -> CGFloat {
                    paddingTop + plotH - CGFloat((w - minWeight) / (maxWeight - minWeight)) * plotH
                }

                // ----- Grid lines -----
                for cg in cgTicks {
                    let x = toCGx(cg)
                    var path = Path()
                    path.move(to: CGPoint(x: x, y: paddingTop))
                    path.addLine(to: CGPoint(x: x, y: paddingTop + plotH))
                    context.stroke(path, with: .color(gridColor), lineWidth: 0.5)
                }

                for w in weightTicks {
                    let y = toWeightY(w)
                    var path = Path()
                    path.move(to: CGPoint(x: paddingLeft, y: y))
                    path.addLine(to: CGPoint(x: paddingLeft + plotW, y: y))
                    context.stroke(path, with: .color(gridColor), lineWidth: 0.5)
                }

                // ----- Envelope polygon -----
                var envelopePath = Path()
                for (index, point) in envelope.points.enumerated() {
                    let pt = CGPoint(x: toCGx(point.cg), y: toWeightY(point.weight))
                    if index == 0 {
                        envelopePath.move(to: pt)
                    } else {
                        envelopePath.addLine(to: pt)
                    }
                }
                envelopePath.closeSubpath()

                // Fill
                let envelopeFillColor: Color = isWithinEnvelope
                    ? Color.statusSafe.opacity(0.15)
                    : Color.statusSafe.opacity(0.08)
                context.fill(envelopePath, with: .color(envelopeFillColor))

                // Stroke
                context.stroke(
                    envelopePath,
                    with: .color(Color.statusSafe.opacity(0.6)),
                    lineWidth: 2
                )

                // ----- Max gross weight reference line -----
                let maxGrossY = toWeightY(maxGrossWeight)
                var maxGrossPath = Path()
                maxGrossPath.move(to: CGPoint(x: paddingLeft, y: maxGrossY))
                maxGrossPath.addLine(to: CGPoint(x: paddingLeft + plotW, y: maxGrossY))
                context.stroke(
                    maxGrossPath,
                    with: .color(Color.statusDanger.opacity(0.4)),
                    style: StrokeStyle(lineWidth: 1, dash: [4, 3])
                )

                // ----- Current loading point (reads animated state) -----
                let cx = toCGx(animatedCG)
                let cy = toWeightY(animatedWeight)
                let pointColor: Color = isWithinEnvelope ? .statusSafe : .statusDanger

                // Outer ring
                let outerRing = Path(ellipseIn: CGRect(
                    x: cx - 12, y: cy - 12, width: 24, height: 24
                ))
                context.stroke(
                    outerRing,
                    with: .color(pointColor.opacity(0.3)),
                    lineWidth: 2
                )

                // White/background border
                let border = Path(ellipseIn: CGRect(
                    x: cx - 7, y: cy - 7, width: 14, height: 14
                ))
                context.fill(border, with: .color(pointBorderColor))

                // Filled dot
                let innerDot = Path(ellipseIn: CGRect(
                    x: cx - 6, y: cy - 6, width: 12, height: 12
                ))
                context.fill(innerDot, with: .color(pointColor))

                // ----- Landing point and trajectory (if fuel burn specified) -----
                if let _ = landingWeight, let _ = landingCG {
                    let lx = toCGx(animatedLandingCG)
                    let ly = toWeightY(animatedLandingWeight)
                    let landingInEnvelope = isLandingWithinEnvelope ?? true
                    let landingColor: Color = landingInEnvelope ? .statusInfo : .statusDanger

                    // Trajectory line from takeoff to landing
                    var trajectoryPath = Path()
                    trajectoryPath.move(to: CGPoint(x: cx, y: cy))
                    trajectoryPath.addLine(to: CGPoint(x: lx, y: ly))
                    context.stroke(
                        trajectoryPath,
                        with: .color(landingColor.opacity(0.6)),
                        style: StrokeStyle(lineWidth: 2, dash: [6, 4])
                    )

                    // Arrow indicator at landing point
                    let landingBorder = Path(ellipseIn: CGRect(
                        x: lx - 5, y: ly - 5, width: 10, height: 10
                    ))
                    context.fill(landingBorder, with: .color(pointBorderColor))

                    let landingDot = Path(ellipseIn: CGRect(
                        x: lx - 4, y: ly - 4, width: 8, height: 8
                    ))
                    context.fill(landingDot, with: .color(landingColor))

                    // Landing label
                    let landingLabelX = lx > paddingLeft + plotW * 0.7 ? lx - 18 : lx + 18
                    let landingAnchor: UnitPoint = lx > paddingLeft + plotW * 0.7 ? .trailing : .leading
                    let ldgLabel = Text("Ldg \(Int(animatedLandingWeight)) lbs")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(landingColor)
                    context.draw(
                        context.resolve(ldgLabel),
                        at: CGPoint(x: landingLabelX, y: ly + 8),
                        anchor: landingAnchor
                    )
                }

                // ----- Point label with collision avoidance -----
                let pointInRightZone = cx > paddingLeft + plotW * 0.7
                let labelX = pointInRightZone ? cx - 18 : cx + 18
                let labelAnchor: UnitPoint = pointInRightZone ? .trailing : .leading

                let weightLabelText = Text("\(Int(animatedWeight)) lbs")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.primary)
                context.draw(
                    context.resolve(weightLabelText),
                    at: CGPoint(x: labelX, y: cy - 6),
                    anchor: labelAnchor
                )

                let cgLabelText = Text("CG \(String(format: "%.1f", animatedCG))\"")
                    .font(.system(size: 10))
                    .foregroundColor(Color.pfTextSecondary)
                context.draw(
                    context.resolve(cgLabelText),
                    at: CGPoint(x: labelX, y: cy + 6),
                    anchor: labelAnchor
                )

                // ----- X-axis labels (CG) -----
                for cg in cgTicks {
                    let x = toCGx(cg)
                    let label = Text("\(Int(cg))")
                        .font(.system(size: 10))
                        .foregroundColor(Color.pfTextSecondary)
                    context.draw(
                        context.resolve(label),
                        at: CGPoint(x: x, y: size.height - 10),
                        anchor: .center
                    )
                }

                // X-axis title
                let xTitle = Text("CG (inches aft of datum)")
                    .font(.system(size: 10))
                    .foregroundColor(Color.pfTextSecondary)
                context.draw(
                    context.resolve(xTitle),
                    at: CGPoint(x: paddingLeft + plotW / 2, y: size.height - 1),
                    anchor: .center
                )

                // ----- Y-axis labels (Weight) -----
                for w in weightTicks {
                    let y = toWeightY(w)
                    let label = Text(formattedWeight(w))
                        .font(.system(size: 10))
                        .foregroundColor(Color.pfTextSecondary)
                    context.draw(
                        context.resolve(label),
                        at: CGPoint(x: paddingLeft - 6, y: y),
                        anchor: .trailing
                    )
                }
            }
            .frame(height: 280)
            .accessibilityLabel(
                "CG envelope chart showing current loading at \(Int(currentWeight)) lbs and CG \(String(format: "%.1f", currentCG)) inches. \(isWithinEnvelope ? "Within" : "Outside") approved envelope."
            )

            // Legend row
            HStack(spacing: Spacing.md) {
                legendItem(color: .statusSafe, text: "Takeoff")
                if landingWeight != nil {
                    legendItem(color: .statusInfo, text: "Landing", isDashed: true)
                }
                legendItem(color: .statusDanger, text: "Outside")
                legendItem(color: .statusDanger.opacity(0.4), text: "Max Gross", isDashed: true)
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .padding(Spacing.md)
        .background(Color.pfCard)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
        .onAppear {
            animatedWeight = currentWeight
            animatedCG = currentCG
            animatedLandingWeight = landingWeight ?? currentWeight
            animatedLandingCG = landingCG ?? currentCG
        }
        .onChange(of: currentWeight) { _, newValue in
            withAnimation(.interpolatingSpring(stiffness: 200, damping: 20)) {
                animatedWeight = newValue
            }
        }
        .onChange(of: currentCG) { _, newValue in
            withAnimation(.interpolatingSpring(stiffness: 200, damping: 20)) {
                animatedCG = newValue
            }
        }
        .onChange(of: landingWeight) { _, newValue in
            withAnimation(.interpolatingSpring(stiffness: 200, damping: 20)) {
                animatedLandingWeight = newValue ?? currentWeight
            }
        }
        .onChange(of: landingCG) { _, newValue in
            withAnimation(.interpolatingSpring(stiffness: 200, damping: 20)) {
                animatedLandingCG = newValue ?? currentCG
            }
        }
    }

    // MARK: - Legend Item

    @ViewBuilder
    private func legendItem(color: Color, text: String, isDashed: Bool = false) -> some View {
        HStack(spacing: Spacing.xxs) {
            if isDashed {
                // Dashed line indicator
                Rectangle()
                    .fill(color)
                    .frame(width: 14, height: 2)
                    .mask(
                        HStack(spacing: 2) {
                            ForEach(0..<3, id: \.self) { _ in
                                Rectangle().frame(width: 3, height: 2)
                            }
                        }
                    )
            } else {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
            }
            Text(text)
        }
    }

    // MARK: - Formatting

    private func formattedWeight(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(Int(value))"
    }
}

#Preview {
    CGEnvelopeChart(
        envelope: CGEnvelope(
            points: [
                EnvelopePoint(weight: 1500, cg: 35.0),
                EnvelopePoint(weight: 1950, cg: 35.0),
                EnvelopePoint(weight: 2300, cg: 35.0),
                EnvelopePoint(weight: 2300, cg: 47.3),
                EnvelopePoint(weight: 1500, cg: 47.3)
            ],
            source: SourceAttribution(
                primary: .init(
                    document: "POH",
                    section: "6-5",
                    publisher: "Cessna",
                    datePublished: "1976",
                    tcdsNumber: nil,
                    url: nil
                ),
                secondary: nil,
                confidence: .high,
                lastVerified: "2024-01-01",
                notes: nil
            )
        ),
        currentWeight: 2100,
        currentCG: 40.5,
        isWithinEnvelope: true,
        maxGrossWeight: 2300
    )
    .padding()
    .background(Color.pfBackground)
}
