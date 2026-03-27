import Foundation

enum MiscCalcs {

    /// Buoyancy Factor = 1 - MW / 65.4
    static func buoyancyFactor(mw: Double) -> [ResultItem] {
        let bf = 1.0 - mw / 65.4
        return [ResultItem(label: "Buoyancy Factor", value: String(format: "%.4f", bf), unit: "")]
    }

    /// Pipe Capacity = 0.000971 * ID^2 * length (bbl)
    static func pipeCapacity(id: Double, length: Double) -> [ResultItem] {
        let cap = 0.000971 * id * id * length
        return [ResultItem(label: "Pipe Capacity", value: String(format: "%.2f", cap), unit: "bbl")]
    }

    /// Annular Capacity = 0.000971 * (Dh^2 - Dp^2) * length (bbl)
    static func annularCapacity(dh: Double, dp: Double, length: Double) -> [ResultItem] {
        let cap = 0.000971 * (dh * dh - dp * dp) * length
        return [ResultItem(label: "Annular Capacity", value: String(format: "%.2f", cap), unit: "bbl")]
    }

    /// BHT = surface_T + gradient * TVD / 100
    static func bht(surfaceTemp: Double, gradient: Double, tvd: Double) -> [ResultItem] {
        let bhtVal = surfaceTemp + gradient * tvd / 100.0
        return [ResultItem(label: "Bottom Hole Temperature", value: String(format: "%.1f", bhtVal), unit: "F")]
    }

    /// Cement Volume = annular capacity * (1 + excess/100)
    static func cementVolume(dh: Double, dp: Double, length: Double, excess: Double) -> [ResultItem] {
        let annCap = 0.000971 * (dh * dh - dp * dp) * length
        let vol = annCap * (1.0 + excess / 100.0)
        return [
            ResultItem(label: "Annular Volume", value: String(format: "%.2f", annCap), unit: "bbl"),
            ResultItem(label: "Cement Volume (with excess)", value: String(format: "%.2f", vol), unit: "bbl"),
        ]
    }
}
