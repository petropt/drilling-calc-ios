import XCTest
@testable import DrillingCalc

final class EngineTests: XCTestCase {

    // MARK: - Helpers

    private func firstValue(_ results: [ResultItem]) -> Double {
        Double(results.first!.value) ?? .nan
    }

    private func value(at index: Int, from results: [ResultItem]) -> Double {
        Double(results[index].value) ?? .nan
    }

    // MARK: - Pressure Calcs

    func testHydrostatic() {
        // P = 0.052 * 10 * 10000 = 5200
        let r = PressureCalcs.hydrostatic(mw: 10.0, tvd: 10000)
        XCTAssertEqual(firstValue(r), 5200.0, accuracy: 0.1)
    }

    func testECD() {
        // ECD = 10 + 200/(0.052*10000) = 10 + 0.3846 = 10.38
        let r = PressureCalcs.ecd(mw: 10.0, apl: 200, tvd: 10000)
        XCTAssertEqual(firstValue(r), 10.38, accuracy: 0.01)
    }

    func testFPG() {
        // FPG = 5200 / (0.052*10000) = 10.0
        let r = PressureCalcs.fpg(pressure: 5200, tvd: 10000)
        XCTAssertEqual(firstValue(r), 10.0, accuracy: 0.01)
    }

    func testMudWeightEquivalent() {
        let r = PressureCalcs.mudWeightEquivalent(pressure: 5200, tvd: 10000)
        XCTAssertEqual(firstValue(r), 10.0, accuracy: 0.01)
    }

    // MARK: - Well Control

    func testKillMW() {
        // Kill MW = 10 + 300/(0.052*10000) = 10 + 0.577 = 10.58
        let r = WellControlCalcs.killMudWeight(origMW: 10.0, sidp: 300, tvd: 10000)
        XCTAssertEqual(firstValue(r), 10.58, accuracy: 0.01)
    }

    func testICP() {
        // ICP = 300 + 650 = 950
        let r = WellControlCalcs.icp(sidp: 300, slowCircPressure: 650)
        XCTAssertEqual(firstValue(r), 950.0, accuracy: 0.1)
    }

    func testFCP() {
        // FCP = 650 * (10.6/10.0) = 689
        let r = WellControlCalcs.fcp(scp: 650, killMW: 10.6, origMW: 10.0)
        XCTAssertEqual(firstValue(r), 689.0, accuracy: 0.1)
    }

    func testMAASP() {
        // MAASP = (0.75 - 10*0.052)*5000 = (0.75 - 0.52)*5000 = 1150
        let r = WellControlCalcs.maasp(fracGrad: 0.75, mw: 10.0, shoeTVD: 5000)
        XCTAssertEqual(firstValue(r), 1150.0, accuracy: 0.1)
    }

    func testKickTolerance() {
        // MAASP = (0.75 - 10*0.052)*5000 = 1150
        // KT = 1150 / (0.052*12000) = 1.843
        let r = WellControlCalcs.kickTolerance(fracGrad: 0.75, mw: 10.0, tvd: 12000, shoeTVD: 5000)
        XCTAssertEqual(value(at: 0, from: r), 1150.0, accuracy: 0.1) // MAASP
        XCTAssertEqual(value(at: 1, from: r), 1.84, accuracy: 0.01)  // KT ppg
    }

    // MARK: - Hydraulics

    func testAnnularVelocity() {
        // AV = 24.51 * 400 / (8.5^2 - 5^2) = 9804 / (72.25-25) = 9804/47.25 = 207.5
        let r = HydraulicsCalcs.annularVelocity(q: 400, dh: 8.5, dp: 5.0)
        XCTAssertEqual(firstValue(r), 207.5, accuracy: 0.5)
    }

    func testNozzleTFA() {
        // 3 x 12/32 nozzles: each area = pi/4*(12/32)^2 = pi/4*0.140625 = 0.11045
        // total = 0.33134
        let r = HydraulicsCalcs.nozzleTFA(nozzlesInput: "12,12,12")
        XCTAssertEqual(value(at: 1, from: r), 0.3314, accuracy: 0.001)
    }

    func testBitHydraulics() {
        let r = HydraulicsCalcs.bitHydraulics(q: 400, mw: 10.0, nozzlesInput: "12,12,12", bitSize: 8.5)
        // Should have 3 results: TFA, dP_bit, HSI
        XCTAssertEqual(r.count, 3)
        // TFA should be ~0.3314
        XCTAssertEqual(Double(r[0].value)!, 0.3314, accuracy: 0.001)
    }

    func testSwabPressure() {
        // hydro = 0.052*10*10000 = 5200
        // effective BHP = 5200 - 150 = 5050
        // effective MW = 10 - 150/(0.052*10000) = 10 - 0.288 = 9.71
        let r = HydraulicsCalcs.swabPressure(mw: 10.0, tvd: 10000, swabLoss: 150)
        XCTAssertEqual(value(at: 0, from: r), 5200.0, accuracy: 0.1)
        XCTAssertEqual(value(at: 1, from: r), 5050.0, accuracy: 0.1)
        XCTAssertEqual(value(at: 2, from: r), 9.71, accuracy: 0.01)
    }

    // MARK: - Casing

    func testCasingBurst() {
        // Burst = 0.875 * 2 * 80000 * 0.362 / 9.625 = 5274.6
        let r = CasingCalcs.casingBurst(fy: 80000, t: 0.362, od: 9.625)
        XCTAssertEqual(firstValue(r), 5265, accuracy: 1.0)
    }

    // MARK: - Survey

    func testDoglegSeverityZero() {
        // Same survey stations -> DLS = 0
        let r = SurveyCalcs.doglegSeverity(inc1: 15, azi1: 120, inc2: 15, azi2: 120, courseLength: 100)
        XCTAssertEqual(firstValue(r), 0.0, accuracy: 0.01)
    }

    func testDoglegSeverity() {
        // inc change only: 15->18 over 100ft -> DLS = 3.0
        let r = SurveyCalcs.doglegSeverity(inc1: 15, azi1: 120, inc2: 18, azi2: 120, courseLength: 100)
        XCTAssertEqual(firstValue(r), 3.0, accuracy: 0.01)
    }

    // MARK: - Misc

    func testBuoyancyFactor() {
        // BF = 1 - 10/65.4 = 0.8471
        let r = MiscCalcs.buoyancyFactor(mw: 10.0)
        XCTAssertEqual(firstValue(r), 0.8471, accuracy: 0.0001)
    }

    func testPipeCapacity() {
        // Cap = 0.000971 * 4.276^2 * 10000 = 0.000971 * 18.284 * 10000 = 177.54
        let r = MiscCalcs.pipeCapacity(id: 4.276, length: 10000)
        XCTAssertEqual(firstValue(r), 177.54, accuracy: 0.5)
    }

    func testAnnularCapacity() {
        // Cap = 0.000971 * (8.5^2 - 5^2) * 10000 = 0.000971*47.25*10000 = 458.80
        let r = MiscCalcs.annularCapacity(dh: 8.5, dp: 5.0, length: 10000)
        XCTAssertEqual(firstValue(r), 458.80, accuracy: 0.5)
    }

    func testBHT() {
        // BHT = 70 + 1.2 * 10000/100 = 70 + 120 = 190
        let r = MiscCalcs.bht(surfaceTemp: 70, gradient: 1.2, tvd: 10000)
        XCTAssertEqual(firstValue(r), 190.0, accuracy: 0.1)
    }

    func testCementVolume() {
        // Annular = 0.000971*(12.25^2 - 9.625^2)*3000 = 0.000971*(150.0625-92.640625)*3000
        //         = 0.000971*57.421875*3000 = 167.26
        // With 50% excess: 167.26 * 1.5 = 250.89
        let r = MiscCalcs.cementVolume(dh: 12.25, dp: 9.625, length: 3000, excess: 50)
        XCTAssertEqual(value(at: 0, from: r), 167.26, accuracy: 0.5)  // annular vol
        XCTAssertEqual(value(at: 1, from: r), 250.89, accuracy: 0.5)  // with excess
    }

    // MARK: - Edge Cases

    func testZeroTVDReturnsError() {
        let r = PressureCalcs.ecd(mw: 10, apl: 200, tvd: 0)
        XCTAssertTrue(r.first!.label == "Error")
    }

    func testZeroCourseLength() {
        let r = SurveyCalcs.doglegSeverity(inc1: 15, azi1: 120, inc2: 18, azi2: 125, courseLength: 0)
        XCTAssertTrue(r.first!.label == "Error")
    }
}
