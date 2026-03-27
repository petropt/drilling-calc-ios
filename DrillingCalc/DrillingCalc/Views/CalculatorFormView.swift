import SwiftUI

struct CalculatorFormView: View {
    let calculator: Calculator

    @AppStorage("favorites") private var favoritesData: Data = Data()
    @State private var values: [String: String] = [:]
    @State private var results: [ResultItem] = []
    @State private var showFormula = false

    private var favoriteIDs: Set<String> {
        get { (try? JSONDecoder().decode(Set<String>.self, from: favoritesData)) ?? [] }
    }

    private var isFavorite: Bool {
        favoriteIDs.contains(calculator.rawValue)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Tier badge
                if calculator.tier == .pro {
                    HStack {
                        ProBadge()
                        Text("Pro Calculator")
                            .font(.caption)
                            .foregroundColor(AppTheme.secondaryText)
                        Spacer()
                    }
                }

                // Input fields
                VStack(spacing: 12) {
                    ForEach(calculator.inputs) { field in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(field.label)
                                    .font(.caption)
                                    .foregroundColor(AppTheme.secondaryText)
                                if !field.unit.isEmpty {
                                    Text("(\(field.unit))")
                                        .font(.caption2)
                                        .foregroundColor(AppTheme.secondaryText.opacity(0.7))
                                }
                            }
                            TextField(field.placeholder, text: binding(for: field))
                                .keyboardType(field.id == "nozzles" ? .default : .decimalPad)
                                .textFieldStyle(.plain)
                                .padding()
                                .background(AppTheme.cardBackground)
                                .cornerRadius(10)
                                .foregroundColor(.white)
                        }
                    }
                }

                // Calculate button
                Button(action: calculate) {
                    Text("Calculate")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.accent)
                        .cornerRadius(12)
                }
                .padding(.top, 4)

                // Results
                if !results.isEmpty {
                    VStack(spacing: 8) {
                        ForEach(results) { item in
                            ResultCard(item: item)
                        }
                    }
                    .transition(.opacity)
                }

                // Formula disclosure
                DisclosureGroup(isExpanded: $showFormula) {
                    Text(calculator.formula)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(AppTheme.secondaryText)
                        .padding(.top, 8)
                } label: {
                    Text("Formula")
                        .font(.subheadline.bold())
                        .foregroundColor(AppTheme.accent)
                }
                .tint(AppTheme.accent)
                .padding()
                .background(AppTheme.cardBackground)
                .cornerRadius(12)
            }
            .padding()
        }
        .background(AppTheme.background)
        .navigationTitle(calculator.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: toggleFavorite) {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .foregroundColor(AppTheme.accent)
                }
            }
        }
        .onAppear {
            // Pre-fill defaults
            for field in calculator.inputs {
                if let def = field.defaultValue {
                    values[field.id] = values[field.id] ?? String(format: "%.0f", def)
                }
            }
        }
    }

    private func binding(for field: InputField) -> Binding<String> {
        Binding(
            get: { values[field.id, default: ""] },
            set: { values[field.id] = $0 }
        )
    }

    private func toggleFavorite() {
        var ids = favoriteIDs
        if ids.contains(calculator.rawValue) {
            ids.remove(calculator.rawValue)
        } else {
            ids.insert(calculator.rawValue)
        }
        favoritesData = (try? JSONEncoder().encode(ids)) ?? Data()
    }

    private func val(_ key: String) -> Double {
        Double(values[key, default: ""] .replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    private func str(_ key: String) -> String {
        values[key, default: ""]
    }

    private func calculate() {
        withAnimation {
            switch calculator {
            case .hydrostatic:
                results = PressureCalcs.hydrostatic(mw: val("mw"), tvd: val("tvd"))
            case .ecd:
                results = PressureCalcs.ecd(mw: val("mw"), apl: val("apl"), tvd: val("tvd"))
            case .fpg:
                results = PressureCalcs.fpg(pressure: val("pressure"), tvd: val("tvd"))
            case .mudWeightEquivalent:
                results = PressureCalcs.mudWeightEquivalent(pressure: val("pressure"), tvd: val("tvd"))
            case .buoyancy:
                results = MiscCalcs.buoyancyFactor(mw: val("mw"))
            case .pipeCapacity:
                results = MiscCalcs.pipeCapacity(id: val("id"), length: val("length"))
            case .annularCapacity:
                results = MiscCalcs.annularCapacity(dh: val("dh"), dp: val("dp"), length: val("length"))
            case .annularVelocity:
                results = HydraulicsCalcs.annularVelocity(q: val("q"), dh: val("dh"), dp: val("dp"))
            case .doglegSeverity:
                results = SurveyCalcs.doglegSeverity(
                    inc1: val("inc1"), azi1: val("azi1"),
                    inc2: val("inc2"), azi2: val("azi2"),
                    courseLength: val("md")
                )
            case .bht:
                results = MiscCalcs.bht(surfaceTemp: val("surfaceTemp"), gradient: val("gradient"), tvd: val("tvd"))
            case .killMW:
                results = WellControlCalcs.killMudWeight(origMW: val("origMW"), sidp: val("sidp"), tvd: val("tvd"))
            case .icp:
                results = WellControlCalcs.icp(sidp: val("sidp"), slowCircPressure: val("scp"))
            case .fcp:
                results = WellControlCalcs.fcp(scp: val("scp"), killMW: val("killMW"), origMW: val("origMW"))
            case .maasp:
                results = WellControlCalcs.maasp(fracGrad: val("fracGrad"), mw: val("mw"), shoeTVD: val("shoeTVD"))
            case .bitHydraulics:
                results = HydraulicsCalcs.bitHydraulics(q: val("q"), mw: val("mw"), nozzlesInput: str("nozzles"), bitSize: val("bitSize"))
            case .casingBurst:
                results = CasingCalcs.casingBurst(fy: val("fy"), t: val("t"), od: val("od"))
            case .nozzleTFA:
                results = HydraulicsCalcs.nozzleTFA(nozzlesInput: str("nozzles"))
            case .cementVolume:
                results = MiscCalcs.cementVolume(dh: val("dh"), dp: val("dp"), length: val("length"), excess: val("excess"))
            case .swabPressure:
                results = HydraulicsCalcs.swabPressure(mw: val("mw"), tvd: val("tvd"), swabLoss: val("swabFactor"))
            case .kickTolerance:
                results = WellControlCalcs.kickTolerance(fracGrad: val("fracGrad"), mw: val("mw"), tvd: val("tvd"), shoeTVD: val("shoeTVD"))
            }
        }
    }
}
