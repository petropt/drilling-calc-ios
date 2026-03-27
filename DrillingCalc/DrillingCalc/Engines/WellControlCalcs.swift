import Foundation

enum WellControlCalcs {

    /// Kill MW = orig MW + SIDP / (0.052 * TVD)
    static func killMudWeight(origMW: Double, sidp: Double, tvd: Double) -> [ResultItem] {
        guard tvd > 0 else { return [ResultItem(label: "Error", value: "TVD must be > 0", unit: "")] }
        let kmw = origMW + sidp / (0.052 * tvd)
        return [ResultItem(label: "Kill Mud Weight", value: String(format: "%.2f", kmw), unit: "ppg")]
    }

    /// ICP = SIDP + slow circ pressure
    static func icp(sidp: Double, slowCircPressure: Double) -> [ResultItem] {
        let icpVal = sidp + slowCircPressure
        return [ResultItem(label: "Initial Circulating Pressure", value: String(format: "%.1f", icpVal), unit: "psi")]
    }

    /// FCP = SCP * (kill MW / orig MW)
    static func fcp(scp: Double, killMW: Double, origMW: Double) -> [ResultItem] {
        guard origMW > 0 else { return [ResultItem(label: "Error", value: "Original MW must be > 0", unit: "")] }
        let fcpVal = scp * (killMW / origMW)
        return [ResultItem(label: "Final Circulating Pressure", value: String(format: "%.1f", fcpVal), unit: "psi")]
    }

    /// MAASP = (frac_grad - MW * 0.052) * shoe_TVD
    static func maasp(fracGrad: Double, mw: Double, shoeTVD: Double) -> [ResultItem] {
        let maaspVal = (fracGrad - mw * 0.052) * shoeTVD
        return [ResultItem(label: "MAASP", value: String(format: "%.1f", maaspVal), unit: "psi")]
    }

    /// Kick Tolerance (simplified) = (frac_grad - MW * 0.052) * shoe_TVD / (0.052 * TVD)
    static func kickTolerance(fracGrad: Double, mw: Double, tvd: Double, shoeTVD: Double) -> [ResultItem] {
        guard tvd > 0 else { return [ResultItem(label: "Error", value: "TVD must be > 0", unit: "")] }
        let maaspVal = (fracGrad - mw * 0.052) * shoeTVD
        let ktPPG = maaspVal / (0.052 * tvd)
        return [
            ResultItem(label: "MAASP at Shoe", value: String(format: "%.1f", maaspVal), unit: "psi"),
            ResultItem(label: "Kick Tolerance", value: String(format: "%.2f", ktPPG), unit: "ppg"),
        ]
    }
}
