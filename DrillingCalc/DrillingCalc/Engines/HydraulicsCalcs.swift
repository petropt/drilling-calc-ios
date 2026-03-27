import Foundation

enum HydraulicsCalcs {

    /// Parse comma-separated nozzle sizes (in 32nds of an inch)
    static func parseNozzles(_ input: String) -> [Double] {
        input.split(separator: ",")
            .compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
    }

    /// Total Flow Area from nozzle sizes in 32nds of an inch
    static func totalFlowArea(nozzleSizes: [Double]) -> Double {
        nozzleSizes.reduce(0.0) { sum, d in
            let dInches = d / 32.0
            return sum + (Double.pi / 4.0) * dInches * dInches
        }
    }

    /// Nozzle TFA
    static func nozzleTFA(nozzlesInput: String) -> [ResultItem] {
        let nozzles = parseNozzles(nozzlesInput)
        guard !nozzles.isEmpty else {
            return [ResultItem(label: "Error", value: "Enter at least one nozzle size", unit: "")]
        }
        let tfa = totalFlowArea(nozzleSizes: nozzles)
        return [
            ResultItem(label: "Number of Nozzles", value: "\(nozzles.count)", unit: ""),
            ResultItem(label: "Total Flow Area", value: String(format: "%.4f", tfa), unit: "sq in"),
        ]
    }

    /// Bit Hydraulics: TFA, HSI, dP_bit
    static func bitHydraulics(q: Double, mw: Double, nozzlesInput: String, bitSize: Double) -> [ResultItem] {
        let nozzles = parseNozzles(nozzlesInput)
        guard !nozzles.isEmpty else {
            return [ResultItem(label: "Error", value: "Enter at least one nozzle size", unit: "")]
        }
        let tfa = totalFlowArea(nozzleSizes: nozzles)
        guard tfa > 0 else {
            return [ResultItem(label: "Error", value: "TFA must be > 0", unit: "")]
        }

        // dP_bit = 156.5 * MW * Q^2 / TFA^2   (TFA in sq in)
        let dpBit = 156.5 * mw * q * q / (tfa * tfa)

        // Bit area
        let bitArea = (Double.pi / 4.0) * bitSize * bitSize

        // HSI = dP_bit * Q / (1714 * bit_area)
        let hsi = bitArea > 0 ? dpBit * q / (1714.0 * bitArea) : 0

        return [
            ResultItem(label: "Total Flow Area", value: String(format: "%.4f", tfa), unit: "sq in"),
            ResultItem(label: "Bit Pressure Drop", value: String(format: "%.1f", dpBit), unit: "psi"),
            ResultItem(label: "Hydraulic Horsepower / sq in", value: String(format: "%.2f", hsi), unit: "HSI"),
        ]
    }

    /// Annular Velocity = 24.51 * Q / (Dh^2 - Dp^2)
    static func annularVelocity(q: Double, dh: Double, dp: Double) -> [ResultItem] {
        let denom = dh * dh - dp * dp
        guard denom > 0 else {
            return [ResultItem(label: "Error", value: "Hole ID must be > Pipe OD", unit: "")]
        }
        let av = 24.51 * q / denom
        return [ResultItem(label: "Annular Velocity", value: String(format: "%.1f", av), unit: "ft/min")]
    }

    /// Swab Pressure (simplified): Effective MW = MW - swabLoss / (0.052 * TVD)
    static func swabPressure(mw: Double, tvd: Double, swabLoss: Double) -> [ResultItem] {
        guard tvd > 0 else { return [ResultItem(label: "Error", value: "TVD must be > 0", unit: "")] }
        let hydrostaticP = 0.052 * mw * tvd
        let effectiveP = hydrostaticP - swabLoss
        let effectiveMW = mw - swabLoss / (0.052 * tvd)
        return [
            ResultItem(label: "Hydrostatic Pressure", value: String(format: "%.1f", hydrostaticP), unit: "psi"),
            ResultItem(label: "Effective BHP (after swab)", value: String(format: "%.1f", effectiveP), unit: "psi"),
            ResultItem(label: "Effective Mud Weight", value: String(format: "%.2f", effectiveMW), unit: "ppg"),
        ]
    }
}
