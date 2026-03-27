import Foundation

enum SurveyCalcs {

    /// Dogleg Severity using the standard formula:
    /// DLS = (100 / CL) * arccos[cos(I2-I1) - sin(I1)*sin(I2)*(1-cos(A2-A1))]
    static func doglegSeverity(inc1: Double, azi1: Double, inc2: Double, azi2: Double, courseLength: Double) -> [ResultItem] {
        guard courseLength > 0 else {
            return [ResultItem(label: "Error", value: "Course length must be > 0", unit: "")]
        }
        let i1 = inc1 * .pi / 180
        let i2 = inc2 * .pi / 180
        let a1 = azi1 * .pi / 180
        let a2 = azi2 * .pi / 180

        var cosAngle = cos(i2 - i1) - sin(i1) * sin(i2) * (1 - cos(a2 - a1))
        // Clamp for numerical safety
        cosAngle = min(max(cosAngle, -1.0), 1.0)
        let angle = acos(cosAngle)
        let dls = (100.0 / courseLength) * angle * (180.0 / .pi)

        return [ResultItem(label: "Dogleg Severity", value: String(format: "%.2f", dls), unit: "deg/100ft")]
    }
}
