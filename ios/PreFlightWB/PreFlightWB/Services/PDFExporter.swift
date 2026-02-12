import UIKit
import PDFKit

/// Generates a professional W&B load sheet PDF from calculation results.
enum PDFExporter {

    /// Generate a PDF load sheet and return the file URL.
    @MainActor
    static func generateLoadSheet(
        aircraft: Aircraft,
        result: CalculationResult,
        landingResult: LandingResult?,
        pilotName: String?
    ) -> URL? {
        let pageWidth: CGFloat = 612   // US Letter
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 40
        let contentWidth = pageWidth - margin * 2

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))

        let data = renderer.pdfData { context in
            context.beginPage()
            var y: CGFloat = margin

            let titleFont = UIFont.systemFont(ofSize: 18, weight: .bold)
            let headerFont = UIFont.systemFont(ofSize: 12, weight: .semibold)
            let bodyFont = UIFont.systemFont(ofSize: 10, weight: .regular)
            let smallFont = UIFont.systemFont(ofSize: 8, weight: .regular)
            let boldBodyFont = UIFont.systemFont(ofSize: 10, weight: .bold)

            // ----- Title -----
            let title = "Weight & Balance Load Sheet"
            title.draw(at: CGPoint(x: margin, y: y), withAttributes: [
                .font: titleFont,
                .foregroundColor: UIColor.black,
            ])
            y += 28

            // ----- Aircraft Info -----
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            let dateStr = dateFormatter.string(from: Date())

            let infoLines = [
                "Aircraft: \(aircraft.name) (\(aircraft.model))",
                "Date: \(dateStr)",
                pilotName.map { "Pilot: \($0)" },
                "TCDS: \(aircraft.regulatory.tcdsNumber)  |  FAR Basis: \(aircraft.regulatory.farBasis)",
            ].compactMap { $0 }

            for line in infoLines {
                line.draw(at: CGPoint(x: margin, y: y), withAttributes: [
                    .font: bodyFont,
                    .foregroundColor: UIColor.darkGray,
                ])
                y += 14
            }
            y += 10

            // ----- Separator -----
            drawLine(at: y, margin: margin, width: contentWidth, context: context)
            y += 8

            // ----- Summary -----
            "TAKEOFF SUMMARY".draw(at: CGPoint(x: margin, y: y), withAttributes: [
                .font: headerFont,
                .foregroundColor: UIColor.black,
            ])
            y += 18

            let statusText = result.isWithinWeightLimit && result.isWithinCGEnvelope
                ? "WITHIN LIMITS"
                : "OUTSIDE LIMITS"
            let statusColor = result.isWithinWeightLimit && result.isWithinCGEnvelope
                ? UIColor.systemGreen
                : UIColor.systemRed

            drawKeyValue("Status:", value: statusText, at: CGPoint(x: margin, y: y), bodyFont: bodyFont, valueFont: boldBodyFont, valueColor: statusColor)
            y += 14
            drawKeyValue("Total Weight:", value: "\(fmt(result.totalWeight, 0)) lbs", at: CGPoint(x: margin, y: y), bodyFont: bodyFont, valueFont: boldBodyFont, valueColor: result.isWithinWeightLimit ? .black : .systemRed)
            drawKeyValue("Max Gross:", value: "\(fmt(aircraft.maxGrossWeight.value, 0)) lbs", at: CGPoint(x: margin + contentWidth / 2, y: y), bodyFont: bodyFont, valueFont: bodyFont, valueColor: .darkGray)
            y += 14
            drawKeyValue("CG Position:", value: "\(fmt(result.cg, 2))\"", at: CGPoint(x: margin, y: y), bodyFont: bodyFont, valueFont: boldBodyFont, valueColor: result.isWithinCGEnvelope ? .black : .systemRed)
            drawKeyValue("CG Range:", value: "\(fmt(aircraft.cgRange.forward.value, 1))\" - \(fmt(aircraft.cgRange.aft.value, 1))\"", at: CGPoint(x: margin + contentWidth / 2, y: y), bodyFont: bodyFont, valueFont: bodyFont, valueColor: .darkGray)
            y += 14
            drawKeyValue("Weight Margin:", value: "\(fmt(result.weightMargin, 0)) lbs", at: CGPoint(x: margin, y: y), bodyFont: bodyFont, valueFont: bodyFont, valueColor: .darkGray)
            y += 20

            // ----- Landing section (if fuel burn specified) -----
            if let landing = landingResult {
                drawLine(at: y, margin: margin, width: contentWidth, context: context)
                y += 8
                "LANDING (after fuel burn)".draw(at: CGPoint(x: margin, y: y), withAttributes: [
                    .font: headerFont,
                    .foregroundColor: UIColor.black,
                ])
                y += 18
                drawKeyValue("Fuel Burn:", value: "\(fmt(landing.fuelBurnGallons, 0)) gal (\(fmt(landing.fuelBurnWeight, 0)) lbs)", at: CGPoint(x: margin, y: y), bodyFont: bodyFont, valueFont: bodyFont, valueColor: .darkGray)
                y += 14
                drawKeyValue("Landing Weight:", value: "\(fmt(landing.landingWeight, 0)) lbs", at: CGPoint(x: margin, y: y), bodyFont: bodyFont, valueFont: boldBodyFont, valueColor: landing.isWithinWeightLimit ? .black : .systemRed)
                y += 14
                drawKeyValue("Landing CG:", value: "\(fmt(landing.landingCG, 2))\"", at: CGPoint(x: margin, y: y), bodyFont: bodyFont, valueFont: boldBodyFont, valueColor: landing.isWithinCGEnvelope ? .black : .systemRed)
                y += 20
            }

            // ----- Breakdown table -----
            drawLine(at: y, margin: margin, width: contentWidth, context: context)
            y += 8
            "LOADING BREAKDOWN".draw(at: CGPoint(x: margin, y: y), withAttributes: [
                .font: headerFont,
                .foregroundColor: UIColor.black,
            ])
            y += 18

            // Table header
            let cols: [(String, CGFloat, CGFloat)] = [
                ("Item", margin, 200),
                ("Weight (lbs)", margin + 210, 70),
                ("Arm (in)", margin + 290, 60),
                ("Moment", margin + 360, 80),
            ]
            for (label, x, _) in cols {
                label.draw(at: CGPoint(x: x, y: y), withAttributes: [
                    .font: headerFont,
                    .foregroundColor: UIColor.darkGray,
                ])
            }
            y += 16

            // Empty weight row
            y = drawTableRow("Empty Weight", weight: aircraft.emptyWeight.value, arm: aircraft.emptyWeightArm.value, at: y, margin: margin, font: bodyFont)

            // Station rows
            for detail in result.stationDetails where detail.weight > 0 {
                y = drawTableRow(detail.name, weight: detail.weight, arm: detail.arm, at: y, margin: margin, font: bodyFont)
            }

            // Fuel rows
            for detail in result.fuelDetails where detail.weight > 0 {
                y = drawTableRow("\(detail.name) (\(fmt(detail.gallons, 0)) gal)", weight: detail.weight, arm: detail.arm, at: y, margin: margin, font: bodyFont)
            }

            // Total row
            drawLine(at: y, margin: margin, width: contentWidth, context: context)
            y += 4
            y = drawTableRow("TOTAL", weight: result.totalWeight, arm: result.cg, at: y, margin: margin, font: boldBodyFont)
            y += 10

            // ----- Warnings -----
            if !result.warnings.isEmpty {
                drawLine(at: y, margin: margin, width: contentWidth, context: context)
                y += 8
                "WARNINGS".draw(at: CGPoint(x: margin, y: y), withAttributes: [
                    .font: headerFont,
                    .foregroundColor: UIColor.systemRed,
                ])
                y += 16

                for warning in result.warnings {
                    let prefix = warning.level == .danger ? "DANGER" : warning.level == .warning ? "WARNING" : "CAUTION"
                    let warningText = "\(prefix): \(warning.message)"
                    warningText.draw(at: CGPoint(x: margin, y: y), withAttributes: [
                        .font: bodyFont,
                        .foregroundColor: warning.level == .danger ? UIColor.systemRed : UIColor.systemOrange,
                    ])
                    y += 12
                    if let detail = warning.detail {
                        detail.draw(at: CGPoint(x: margin + 10, y: y), withAttributes: [
                            .font: smallFont,
                            .foregroundColor: UIColor.gray,
                        ])
                        y += 10
                    }
                    if let remediation = warning.remediation {
                        remediation.draw(at: CGPoint(x: margin + 10, y: y), withAttributes: [
                            .font: UIFont.systemFont(ofSize: 8, weight: .medium),
                            .foregroundColor: UIColor.systemBlue,
                        ])
                        y += 10
                    }
                    y += 4
                }
            }

            // ----- Footer disclaimer -----
            let footerY = pageHeight - margin - 30
            drawLine(at: footerY, margin: margin, width: contentWidth, context: context)
            let disclaimer = "For flight planning reference only. Always verify W&B using your aircraft\u{2019}s official POH/AFM. This does not replace required preflight planning per FAR 91.103."
            disclaimer.draw(in: CGRect(x: margin, y: footerY + 4, width: contentWidth, height: 30), withAttributes: [
                .font: UIFont.systemFont(ofSize: 7, weight: .regular),
                .foregroundColor: UIColor.gray,
            ])

            "Generated by PreFlight W&B".draw(at: CGPoint(x: margin, y: pageHeight - margin - 8), withAttributes: [
                .font: UIFont.systemFont(ofSize: 7, weight: .medium),
                .foregroundColor: UIColor.lightGray,
            ])
        }

        // Save to temp file
        let fileName = "WB_\(aircraft.model)_\(ISO8601DateFormatter().string(from: Date()).prefix(10)).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        do {
            try data.write(to: url)
            return url
        } catch {
            return nil
        }
    }

    // MARK: - Drawing Helpers

    private static func drawLine(at y: CGFloat, margin: CGFloat, width: CGFloat, context: UIGraphicsPDFRendererContext) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: margin, y: y))
        path.addLine(to: CGPoint(x: margin + width, y: y))
        UIColor.lightGray.setStroke()
        path.lineWidth = 0.5
        path.stroke()
    }

    private static func drawKeyValue(_ key: String, value: String, at point: CGPoint, bodyFont: UIFont, valueFont: UIFont, valueColor: UIColor) {
        key.draw(at: point, withAttributes: [
            .font: bodyFont,
            .foregroundColor: UIColor.darkGray,
        ])
        let keyWidth = (key as NSString).size(withAttributes: [.font: bodyFont]).width
        value.draw(at: CGPoint(x: point.x + keyWidth + 4, y: point.y), withAttributes: [
            .font: valueFont,
            .foregroundColor: valueColor,
        ])
    }

    private static func drawTableRow(_ item: String, weight: Double, arm: Double, at y: CGFloat, margin: CGFloat, font: UIFont) -> CGFloat {
        let moment = weight * arm
        let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.black]
        item.draw(at: CGPoint(x: margin, y: y), withAttributes: attrs)
        fmt(weight, 0).draw(at: CGPoint(x: margin + 210, y: y), withAttributes: attrs)
        fmt(arm, 1).draw(at: CGPoint(x: margin + 290, y: y), withAttributes: attrs)
        fmt(moment, 0).draw(at: CGPoint(x: margin + 360, y: y), withAttributes: attrs)
        return y + 14
    }

    private static func fmt(_ value: Double, _ decimals: Int) -> String {
        String(format: "%.\(decimals)f", value)
    }
}
