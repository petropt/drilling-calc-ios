import Foundation

enum PressureCalcs {

    /// Hydrostatic pressure: P = 0.052 * MW * TVD
    static func hydrostatic(mw: Double, tvd: Double) -> [ResultItem] {
        let p = 0.052 * mw * tvd
        return [ResultItem(label: "Hydrostatic Pressure", value: String(format: "%.1f", p), unit: "psi")]
    }

    /// ECD = MW + APL / (0.052 * TVD)
    static func ecd(mw: Double, apl: Double, tvd: Double) -> [ResultItem] {
        guard tvd > 0 else { return [ResultItem(label: "Error", value: "TVD must be > 0", unit: "")] }
        let ecdVal = mw + apl / (0.052 * tvd)
        return [ResultItem(label: "ECD", value: String(format: "%.2f", ecdVal), unit: "ppg")]
    }

    /// Formation Pressure Gradient = P / (0.052 * TVD)
    static func fpg(pressure: Double, tvd: Double) -> [ResultItem] {
        guard tvd > 0 else { return [ResultItem(label: "Error", value: "TVD must be > 0", unit: "")] }
        let grad = pressure / (0.052 * tvd)
        return [ResultItem(label: "Formation Pressure Gradient", value: String(format: "%.2f", grad), unit: "ppg")]
    }

    /// Mud Weight Equivalent = P / (0.052 * TVD)
    static func mudWeightEquivalent(pressure: Double, tvd: Double) -> [ResultItem] {
        guard tvd > 0 else { return [ResultItem(label: "Error", value: "TVD must be > 0", unit: "")] }
        let emw = pressure / (0.052 * tvd)
        return [ResultItem(label: "Equivalent Mud Weight", value: String(format: "%.2f", emw), unit: "ppg")]
    }
}
