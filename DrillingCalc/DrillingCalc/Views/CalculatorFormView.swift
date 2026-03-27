import SwiftUI

struct CalculatorFormView: View {
    let calculator: Calculator

    @AppStorage("favorites") private var favoritesData: Data = Data()
    @StateObject private var history = HistoryManager.shared
    @State private var values: [String: String] = [:]
    @State private var results: [ResultItem] = []
    @State private var showFormula = false
    @State private var validationErrors: Set<String> = []
    @State private var showShareSheet = false
    @State private var resultsVisible = false
    @State private var showProUpgrade = false
    @FocusState private var focusedField: String?

    private var favoriteIDs: Set<String> {
        get { (try? JSONDecoder().decode(Set<String>.self, from: favoritesData)) ?? [] }
    }

    private var isFavorite: Bool {
        favoriteIDs.contains(calculator.rawValue)
    }

    // Build a shareable text summary of the calculation
    private var shareText: String {
        var lines = [calculator.name]
        lines.append(String(repeating: "-", count: calculator.name.count))
        for field in calculator.inputs {
            let v = values[field.id, default: ""]
            if !v.isEmpty {
                lines.append("\(field.label): \(v) \(field.unit)")
            }
        }
        lines.append("")
        for item in results {
            let unit = item.unit.isEmpty ? "" : " \(item.unit)"
            lines.append("\(item.label): \(item.value)\(unit)")
        }
        lines.append("")
        lines.append("Calculated with Drilling Calc")
        return lines.joined(separator: "\n")
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: AppTheme.spacingXL) {
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
                    VStack(spacing: AppTheme.spacingLG) {
                        ForEach(calculator.inputs) { field in
                            VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                                HStack {
                                    Text(field.label)
                                        .font(AppTheme.inputLabelFont)
                                        .foregroundColor(AppTheme.secondaryText)
                                    if !field.unit.isEmpty {
                                        Text("(\(field.unit))")
                                            .font(AppTheme.inputUnitFont)
                                            .foregroundColor(AppTheme.secondaryText.opacity(0.8))
                                    }
                                }

                                HStack {
                                    TextField(field.placeholder, text: binding(for: field))
                                        .keyboardType(field.id == "nozzles" ? .default : .decimalPad)
                                        .textFieldStyle(.plain)
                                        .font(AppTheme.inputValueFont)
                                        .foregroundColor(.white)
                                        .focused($focusedField, equals: field.id)

                                    // Clear button
                                    if !(values[field.id, default: ""].isEmpty) {
                                        Button {
                                            values[field.id] = ""
                                            validationErrors.remove(field.id)
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(AppTheme.secondaryText)
                                                .imageScale(.medium)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(AppTheme.spacingLG)
                                .background(AppTheme.cardBackground)
                                .cornerRadius(AppTheme.spacingMD)
                                .overlay(
                                    // Orange bottom border on focus, red full border on error
                                    Group {
                                        if validationErrors.contains(field.id) {
                                            RoundedRectangle(cornerRadius: AppTheme.spacingMD)
                                                .stroke(Color.red, lineWidth: 1.5)
                                        } else if focusedField == field.id {
                                            VStack {
                                                Spacer()
                                                AppTheme.accent
                                                    .frame(height: 2)
                                                    .cornerRadius(1)
                                            }
                                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.spacingMD))
                                        }
                                    }
                                )
                                .animation(.easeInOut(duration: 0.2), value: focusedField)

                                // Inline validation error
                                if validationErrors.contains(field.id) {
                                    Text("\(field.label) is required")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }

                    // Formula disclosure
                    DisclosureGroup(isExpanded: $showFormula) {
                        Text(calculator.formula)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(AppTheme.secondaryText)
                            .padding(.top, AppTheme.spacingSM)
                    } label: {
                        Text("Formula")
                            .font(.headline)
                            .foregroundColor(AppTheme.accent)
                    }
                    .tint(AppTheme.accent)
                    .padding(AppTheme.spacingLG)
                    .background(AppTheme.cardBackground)
                    .cornerRadius(AppTheme.spacingMD)

                    // Results
                    if !results.isEmpty {
                        VStack(spacing: AppTheme.spacingSM) {
                            ForEach(Array(results.enumerated()), id: \.element.id) { index, item in
                                ResultCard(item: item)
                                    .opacity(resultsVisible ? 1 : 0)
                                    .offset(y: resultsVisible ? 0 : AppTheme.spacingMD)
                                    .animation(
                                        .spring(response: 0.45, dampingFraction: 0.75).delay(Double(index) * 0.08),
                                        value: resultsVisible
                                    )
                            }

                            // Share button
                            Button(action: { showShareSheet = true }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Share Results")
                                }
                                .font(.body.weight(.medium))
                                .foregroundColor(AppTheme.accent)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppTheme.spacingMD)
                                .background(AppTheme.cardBackground)
                                .cornerRadius(AppTheme.spacingMD)
                            }
                            .buttonStyle(ScaleButtonStyle())
                            .opacity(resultsVisible ? 1 : 0)
                            .animation(.spring(response: 0.45, dampingFraction: 0.75).delay(Double(results.count) * 0.08), value: resultsVisible)
                        }
                        .id("results")
                    }

                    // Bottom spacer for sticky calculate button
                    Spacer()
                        .frame(height: AppTheme.spacing3XL)
                }
                .padding(AppTheme.spacingLG)
            }
            // Sticky Calculate button in thumb zone
            .safeAreaInset(edge: .bottom) {
                Button(action: {
                    calculate()
                    // Auto-scroll to results
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation {
                            proxy.scrollTo("results", anchor: .top)
                        }
                    }
                }) {
                    Text("Calculate")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppTheme.spacingLG)
                        .background(AppTheme.accent)
                        .cornerRadius(AppTheme.spacingMD)
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.horizontal, AppTheme.spacingLG)
                .padding(.vertical, AppTheme.spacingMD)
                .background(.ultraThinMaterial)
            }
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
                    let formatted = def.truncatingRemainder(dividingBy: 1) == 0
                        ? String(format: "%.0f", def)
                        : String(def)
                    values[field.id] = values[field.id] ?? formatted
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [shareText])
        }
        .sheet(isPresented: $showProUpgrade) {
            ProUpgradeSheet()
                .presentationDetents([.medium])
        }
    }

    private func binding(for field: InputField) -> Binding<String> {
        Binding(
            get: { values[field.id, default: ""] },
            set: {
                values[field.id] = $0
                validationErrors.remove(field.id)
            }
        )
    }

    private func toggleFavorite() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

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

    /// Validate that required fields are filled. Returns true if valid.
    private func validateInputs() -> Bool {
        validationErrors.removeAll()
        var isValid = true

        for field in calculator.inputs {
            let v = values[field.id, default: ""].trimmingCharacters(in: .whitespaces)
            // Nozzle field validated differently
            if field.id == "nozzles" {
                if v.isEmpty {
                    validationErrors.insert(field.id)
                    isValid = false
                }
            } else {
                if v.isEmpty || Double(v.replacingOccurrences(of: ",", with: ".")) == nil {
                    validationErrors.insert(field.id)
                    isValid = false
                }
            }
        }

        return isValid
    }

    private func calculate() {
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        // Validate inputs
        guard validateInputs() else {
            // Error haptic
            let notif = UINotificationFeedbackGenerator()
            notif.notificationOccurred(.error)
            return
        }

        resultsVisible = false

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

        // Trigger staggered result animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            resultsVisible = true
        }

        // Save to history
        history.add(
            calculatorID: calculator.rawValue,
            calculatorName: calculator.name,
            inputs: values,
            results: results
        )

        // Success haptic
        if results.first?.label != "Error" {
            let notif = UINotificationFeedbackGenerator()
            notif.notificationOccurred(.success)
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
