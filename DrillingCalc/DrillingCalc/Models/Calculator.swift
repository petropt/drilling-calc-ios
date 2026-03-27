import Foundation

// MARK: - Category

enum CalculatorCategory: String, CaseIterable, Identifiable {
    case pressure = "Pressure"
    case wellControl = "Well Control"
    case hydraulics = "Hydraulics"
    case casing = "Casing"
    case survey = "Survey"
    case misc = "Misc"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .pressure: return "gauge.with.dots.needle.bottom.50percent"
        case .wellControl: return "shield.checkered"
        case .hydraulics: return "drop.fill"
        case .casing: return "cylinder"
        case .survey: return "location.north.line"
        case .misc: return "wrench.and.screwdriver"
        }
    }
}

// MARK: - Tier

enum CalculatorTier: String {
    case free = "Free"
    case pro = "Pro"
}

// MARK: - Input Field

struct InputField: Identifiable {
    let id: String
    let label: String
    let unit: String
    let placeholder: String
    let defaultValue: Double?

    init(_ id: String, label: String, unit: String, placeholder: String = "", defaultValue: Double? = nil) {
        self.id = id
        self.label = label
        self.unit = unit
        self.placeholder = placeholder
        self.defaultValue = defaultValue
    }
}

// MARK: - Result Item

struct ResultItem: Identifiable {
    let id = UUID()
    let label: String
    let value: String
    let unit: String
}

// MARK: - Calculator Definition

enum Calculator: String, CaseIterable, Identifiable {
    // Free
    case hydrostatic
    case ecd
    case fpg
    case buoyancy
    case pipeCapacity
    case annularCapacity
    case annularVelocity
    case doglegSeverity
    case mudWeightEquivalent
    case bht

    // Pro
    case killMW
    case icp
    case fcp
    case maasp
    case bitHydraulics
    case casingBurst
    case nozzleTFA
    case cementVolume
    case swabPressure
    case kickTolerance

    var id: String { rawValue }

    var name: String {
        switch self {
        case .hydrostatic: return "Hydrostatic Pressure"
        case .ecd: return "ECD"
        case .fpg: return "Formation Pressure Gradient"
        case .buoyancy: return "Buoyancy Factor"
        case .pipeCapacity: return "Pipe Capacity"
        case .annularCapacity: return "Annular Capacity"
        case .annularVelocity: return "Annular Velocity"
        case .doglegSeverity: return "Dogleg Severity"
        case .mudWeightEquivalent: return "Mud Weight Equivalent"
        case .bht: return "Bottom Hole Temperature"
        case .killMW: return "Kill Mud Weight"
        case .icp: return "Initial Circulating Pressure"
        case .fcp: return "Final Circulating Pressure"
        case .maasp: return "MAASP"
        case .bitHydraulics: return "Bit Hydraulics"
        case .casingBurst: return "Casing Burst (Barlow)"
        case .nozzleTFA: return "Nozzle TFA"
        case .cementVolume: return "Cement Volume"
        case .swabPressure: return "Swab Pressure"
        case .kickTolerance: return "Kick Tolerance"
        }
    }

    var category: CalculatorCategory {
        switch self {
        case .hydrostatic, .ecd, .fpg, .mudWeightEquivalent:
            return .pressure
        case .killMW, .icp, .fcp, .maasp, .kickTolerance:
            return .wellControl
        case .annularVelocity, .bitHydraulics, .nozzleTFA, .swabPressure:
            return .hydraulics
        case .casingBurst:
            return .casing
        case .doglegSeverity:
            return .survey
        case .buoyancy, .pipeCapacity, .annularCapacity, .bht, .cementVolume:
            return .misc
        }
    }

    var tier: CalculatorTier {
        switch self {
        case .hydrostatic, .ecd, .fpg, .buoyancy, .pipeCapacity,
             .annularCapacity, .annularVelocity, .doglegSeverity,
             .mudWeightEquivalent, .bht:
            return .free
        case .killMW, .icp, .fcp, .maasp, .bitHydraulics,
             .casingBurst, .nozzleTFA, .cementVolume,
             .swabPressure, .kickTolerance:
            return .pro
        }
    }

    var inputs: [InputField] {
        switch self {
        case .hydrostatic:
            return [
                InputField("mw", label: "Mud Weight", unit: "ppg", placeholder: "e.g. 10.0"),
                InputField("tvd", label: "True Vertical Depth", unit: "ft", placeholder: "e.g. 10000"),
            ]
        case .ecd:
            return [
                InputField("mw", label: "Static Mud Weight", unit: "ppg", placeholder: "e.g. 10.0"),
                InputField("apl", label: "Annular Pressure Loss", unit: "psi", placeholder: "e.g. 200"),
                InputField("tvd", label: "True Vertical Depth", unit: "ft", placeholder: "e.g. 10000"),
            ]
        case .fpg:
            return [
                InputField("pressure", label: "Formation Pressure", unit: "psi", placeholder: "e.g. 5200"),
                InputField("tvd", label: "True Vertical Depth", unit: "ft", placeholder: "e.g. 10000"),
            ]
        case .buoyancy:
            return [
                InputField("mw", label: "Mud Weight", unit: "ppg", placeholder: "e.g. 10.0"),
            ]
        case .pipeCapacity:
            return [
                InputField("id", label: "Inside Diameter", unit: "in", placeholder: "e.g. 4.276"),
                InputField("length", label: "Length", unit: "ft", placeholder: "e.g. 10000"),
            ]
        case .annularCapacity:
            return [
                InputField("dh", label: "Hole / Casing ID", unit: "in", placeholder: "e.g. 8.5"),
                InputField("dp", label: "Pipe OD", unit: "in", placeholder: "e.g. 5.0"),
                InputField("length", label: "Length", unit: "ft", placeholder: "e.g. 10000"),
            ]
        case .annularVelocity:
            return [
                InputField("q", label: "Flow Rate", unit: "gpm", placeholder: "e.g. 400"),
                InputField("dh", label: "Hole / Casing ID", unit: "in", placeholder: "e.g. 8.5"),
                InputField("dp", label: "Pipe OD", unit: "in", placeholder: "e.g. 5.0"),
            ]
        case .doglegSeverity:
            return [
                InputField("inc1", label: "Inclination 1", unit: "deg", placeholder: "e.g. 15"),
                InputField("azi1", label: "Azimuth 1", unit: "deg", placeholder: "e.g. 120"),
                InputField("inc2", label: "Inclination 2", unit: "deg", placeholder: "e.g. 18"),
                InputField("azi2", label: "Azimuth 2", unit: "deg", placeholder: "e.g. 125"),
                InputField("md", label: "Course Length", unit: "ft", placeholder: "e.g. 100"),
            ]
        case .mudWeightEquivalent:
            return [
                InputField("pressure", label: "Pressure", unit: "psi", placeholder: "e.g. 5200"),
                InputField("tvd", label: "True Vertical Depth", unit: "ft", placeholder: "e.g. 10000"),
            ]
        case .bht:
            return [
                InputField("surfaceTemp", label: "Surface Temperature", unit: "F", placeholder: "e.g. 70", defaultValue: 70),
                InputField("gradient", label: "Geothermal Gradient", unit: "F/100ft", placeholder: "e.g. 1.2", defaultValue: 1.2),
                InputField("tvd", label: "True Vertical Depth", unit: "ft", placeholder: "e.g. 10000"),
            ]
        case .killMW:
            return [
                InputField("origMW", label: "Original Mud Weight", unit: "ppg", placeholder: "e.g. 10.0"),
                InputField("sidp", label: "SIDP", unit: "psi", placeholder: "e.g. 300"),
                InputField("tvd", label: "True Vertical Depth", unit: "ft", placeholder: "e.g. 10000"),
            ]
        case .icp:
            return [
                InputField("sidp", label: "SIDP", unit: "psi", placeholder: "e.g. 300"),
                InputField("scp", label: "Slow Circ Pressure", unit: "psi", placeholder: "e.g. 650"),
            ]
        case .fcp:
            return [
                InputField("scp", label: "Slow Circ Pressure", unit: "psi", placeholder: "e.g. 650"),
                InputField("killMW", label: "Kill Mud Weight", unit: "ppg", placeholder: "e.g. 10.6"),
                InputField("origMW", label: "Original Mud Weight", unit: "ppg", placeholder: "e.g. 10.0"),
            ]
        case .maasp:
            return [
                InputField("fracGrad", label: "Frac Gradient", unit: "psi/ft", placeholder: "e.g. 0.75"),
                InputField("mw", label: "Current Mud Weight", unit: "ppg", placeholder: "e.g. 10.0"),
                InputField("shoeTVD", label: "Shoe TVD", unit: "ft", placeholder: "e.g. 5000"),
            ]
        case .bitHydraulics:
            return [
                InputField("q", label: "Flow Rate", unit: "gpm", placeholder: "e.g. 400"),
                InputField("mw", label: "Mud Weight", unit: "ppg", placeholder: "e.g. 10.0"),
                InputField("nozzles", label: "Nozzle Sizes (comma separated)", unit: "32nds in", placeholder: "e.g. 12,12,12"),
                InputField("bitSize", label: "Bit Size", unit: "in", placeholder: "e.g. 8.5"),
            ]
        case .casingBurst:
            return [
                InputField("fy", label: "Yield Strength", unit: "psi", placeholder: "e.g. 80000"),
                InputField("t", label: "Wall Thickness", unit: "in", placeholder: "e.g. 0.362"),
                InputField("od", label: "Outside Diameter", unit: "in", placeholder: "e.g. 9.625"),
            ]
        case .nozzleTFA:
            return [
                InputField("nozzles", label: "Nozzle Sizes (comma separated)", unit: "32nds in", placeholder: "e.g. 12,12,12"),
            ]
        case .cementVolume:
            return [
                InputField("dh", label: "Hole / Casing ID", unit: "in", placeholder: "e.g. 12.25"),
                InputField("dp", label: "Casing OD", unit: "in", placeholder: "e.g. 9.625"),
                InputField("length", label: "Cement Column Length", unit: "ft", placeholder: "e.g. 3000"),
                InputField("excess", label: "Excess", unit: "%", placeholder: "e.g. 50", defaultValue: 50),
            ]
        case .swabPressure:
            return [
                InputField("mw", label: "Mud Weight", unit: "ppg", placeholder: "e.g. 10.0"),
                InputField("tvd", label: "True Vertical Depth", unit: "ft", placeholder: "e.g. 10000"),
                InputField("swabFactor", label: "Swab Pressure Loss", unit: "psi", placeholder: "e.g. 150"),
            ]
        case .kickTolerance:
            return [
                InputField("fracGrad", label: "Frac Gradient", unit: "psi/ft", placeholder: "e.g. 0.75"),
                InputField("mw", label: "Current Mud Weight", unit: "ppg", placeholder: "e.g. 10.0"),
                InputField("tvd", label: "Well TVD", unit: "ft", placeholder: "e.g. 12000"),
                InputField("shoeTVD", label: "Shoe TVD", unit: "ft", placeholder: "e.g. 5000"),
            ]
        }
    }

    var formula: String {
        switch self {
        case .hydrostatic:
            return "P = 0.052 x MW x TVD"
        case .ecd:
            return "ECD = MW + APL / (0.052 x TVD)"
        case .fpg:
            return "FPG = P / (0.052 x TVD)"
        case .buoyancy:
            return "BF = 1 - MW / 65.4"
        case .pipeCapacity:
            return "Capacity = 0.000971 x ID^2 x Length (bbl)"
        case .annularCapacity:
            return "Capacity = 0.000971 x (Dh^2 - Dp^2) x Length (bbl)"
        case .annularVelocity:
            return "AV = 24.51 x Q / (Dh^2 - Dp^2) (ft/min)"
        case .doglegSeverity:
            return "DLS = (100/CL) x arccos[cos(I2-I1) - sinI1 x sinI2 x (1-cos(A2-A1))]"
        case .mudWeightEquivalent:
            return "EMW = P / (0.052 x TVD)"
        case .bht:
            return "BHT = Tsurface + Gradient x TVD / 100"
        case .killMW:
            return "Kill MW = Orig MW + SIDP / (0.052 x TVD)"
        case .icp:
            return "ICP = SIDP + Slow Circ Pressure"
        case .fcp:
            return "FCP = SCP x (Kill MW / Orig MW)"
        case .maasp:
            return "MAASP = (Frac Grad - MW x 0.052) x Shoe TVD"
        case .bitHydraulics:
            return "TFA = Sum(pi/4 x (d/32)^2)\nHSI = dP_bit x Q / (1714 x BitArea)\ndP_bit = 156.5 x MW x Q^2 / TFA^2"
        case .casingBurst:
            return "Burst = 0.875 x 2 x Fy x t / OD"
        case .nozzleTFA:
            return "TFA = Sum(pi/4 x (d/32)^2) (sq in)"
        case .cementVolume:
            return "Vol = 0.000971 x (Dh^2 - Dp^2) x Length x (1 + Excess/100)"
        case .swabPressure:
            return "Effective MW = MW - Swab Loss / (0.052 x TVD)\nSwab P = Hydrostatic - Swab Loss"
        case .kickTolerance:
            return "KT (ppg) = (Frac Grad - MW x 0.052) x Shoe TVD / (0.052 x TVD)"
        }
    }

    static func grouped() -> [(category: CalculatorCategory, calculators: [Calculator])] {
        CalculatorCategory.allCases.compactMap { cat in
            let calcs = Calculator.allCases.filter { $0.category == cat }
            return calcs.isEmpty ? nil : (category: cat, calculators: calcs)
        }
    }
}
