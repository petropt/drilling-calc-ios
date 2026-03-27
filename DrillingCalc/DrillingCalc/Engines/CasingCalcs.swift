import Foundation

enum CasingCalcs {

    /// Casing Burst (Barlow): Burst = 0.875 * 2 * Fy * t / OD
    static func casingBurst(fy: Double, t: Double, od: Double) -> [ResultItem] {
        guard od > 0 else { return [ResultItem(label: "Error", value: "OD must be > 0", unit: "")] }
        let burst = 0.875 * 2.0 * fy * t / od
        return [ResultItem(label: "Burst Pressure Rating", value: String(format: "%.0f", burst), unit: "psi")]
    }
}
