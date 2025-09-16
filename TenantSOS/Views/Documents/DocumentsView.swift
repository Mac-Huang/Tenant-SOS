import SwiftUI
import PDFKit

struct DocumentsView: View {
    @StateObject private var documentGenerator = DocumentGenerator()
    @EnvironmentObject var storeManager: StoreManager
    @EnvironmentObject var dataController: DataController

    @State private var selectedTemplate: DocumentGenerator.DocumentTemplate?
    @State private var showingDocumentForm = false
    @State private var documentsGenerated = 0
    @State private var showingProUpgrade = false

    @AppStorage("documentsGeneratedThisMonth") private var documentsGeneratedThisMonth = 0
    @AppStorage("lastResetDate") private var lastResetDate = Date().timeIntervalSince1970

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    DocumentQuotaCard(
                        documentsUsed: documentsGeneratedThisMonth,
                        monthlyLimit: storeManager.monthlyDocumentLimit(),
                        isPro: storeManager.isPro()
                    )

                    TemplatesSection(
                        selectedTemplate: $selectedTemplate,
                        showingDocumentForm: $showingDocumentForm
                    )

                    if !documentGenerator.generatedDocuments.isEmpty {
                        GeneratedDocumentsSection(documents: documentGenerator.generatedDocuments)
                    }
                }
                .padding()
            }
            .navigationTitle("Documents")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingProUpgrade = true
                    }) {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.yellow)
                    }
                }
            }
            .sheet(isPresented: $showingDocumentForm) {
                if let template = selectedTemplate {
                    DocumentFormView(
                        template: template,
                        documentGenerator: documentGenerator,
                        documentsGeneratedThisMonth: $documentsGeneratedThisMonth
                    )
                }
            }
            .sheet(isPresented: $showingProUpgrade) {
                ProUpgradeView()
            }
        }
        .onAppear {
            checkMonthlyReset()
        }
    }

    private func checkMonthlyReset() {
        let lastReset = Date(timeIntervalSince1970: lastResetDate)
        let calendar = Calendar.current

        if !calendar.isDate(lastReset, equalTo: Date(), toGranularity: .month) {
            documentsGeneratedThisMonth = 0
            lastResetDate = Date().timeIntervalSince1970
        }
    }
}

struct DocumentQuotaCard: View {
    let documentsUsed: Int
    let monthlyLimit: Int
    let isPro: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "doc.badge.plus")
                    .foregroundColor(.blue)
                Text("Document Generation")
                    .font(.headline)
                Spacer()
                if isPro {
                    Label("Pro", systemImage: "crown.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                }
            }

            if !isPro {
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(documentsUsed) of \(monthlyLimit) documents used this month")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    ProgressView(value: Double(documentsUsed), total: Double(monthlyLimit))
                        .tint(documentsUsed >= monthlyLimit ? .red : .blue)

                    if documentsUsed >= monthlyLimit {
                        Text("Monthly limit reached. Upgrade to Pro for unlimited documents.")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            } else {
                Text("Unlimited document generation")
                    .font(.subheadline)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct TemplatesSection: View {
    @Binding var selectedTemplate: DocumentGenerator.DocumentTemplate?
    @Binding var showingDocumentForm: Bool

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Document Templates")
                .font(.headline)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(DocumentGenerator.DocumentTemplate.allCases, id: \\.rawValue) { template in
                    TemplateCard(template: template) {
                        selectedTemplate = template
                        showingDocumentForm = true
                    }
                }
            }
        }
    }
}

struct TemplateCard: View {
    let template: DocumentGenerator.DocumentTemplate
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: template.icon)
                    .font(.title2)
                    .foregroundColor(.blue)

                Text(template.rawValue)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct GeneratedDocumentsSection: View {
    let documents: [DocumentGenerator.GeneratedDocument]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Documents")
                .font(.headline)

            ForEach(documents.reversed()) { document in
                GeneratedDocumentRow(document: document)
            }
        }
    }
}

struct GeneratedDocumentRow: View {
    let document: DocumentGenerator.GeneratedDocument
    @StateObject private var documentGenerator = DocumentGenerator()

    var body: some View {
        HStack {
            Image(systemName: "doc.fill")
                .foregroundColor(.blue)

            VStack(alignment: .leading, spacing: 4) {
                Text(document.templateType.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(document.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            HStack(spacing: 16) {
                Button(action: {
                    documentGenerator.shareDocument(document)
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.blue)
                }

                Button(action: {
                    documentGenerator.saveToFiles(document)
                }) {
                    Image(systemName: "folder")
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct DocumentFormView: View {
    let template: DocumentGenerator.DocumentTemplate
    let documentGenerator: DocumentGenerator
    @Binding var documentsGeneratedThisMonth: Int

    @Environment(\\.dismiss) private var dismiss
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var storeManager: StoreManager

    @State private var formData: [String: String] = [:]
    @State private var showingGeneratedDocument = false

    var body: some View {
        NavigationView {
            Form {
                Section("Document Information") {
                    Text(template.rawValue)
                        .font(.headline)

                    Text("State: \(locationManager.currentState ?? "Unknown")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Section("Required Information") {
                    ForEach(getFormFields(), id: \\.self) { field in
                        HStack {
                            Text(field)
                                .font(.subheadline)
                            TextField("Enter \(field)", text: binding(for: field))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                }
            }
            .navigationTitle("Fill Document")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Generate") {
                        generateDocument()
                    }
                    .disabled(!canGenerate())
                }
            }
        }
    }

    private func getFormFields() -> [String] {
        switch template {
        case .leaseAgreement:
            return ["Landlord Name", "Tenant Name", "Property Address", "Monthly Rent", "Start Date"]
        case .rentReceipt:
            return ["Tenant Name", "Property Address", "Amount", "Payment Period"]
        case .maintenanceRequest:
            return ["Tenant Name", "Unit", "Issue Description", "Priority Level"]
        case .noticeToVacate:
            return ["Landlord Name", "Move Out Date", "Forwarding Address"]
        case .securityDepositClaim:
            return ["Tenant Name", "Deposit Amount", "Dispute Reason"]
        default:
            return ["Name", "Address", "Date", "Details"]
        }
    }

    private func binding(for key: String) -> Binding<String> {
        Binding(
            get: { formData[key] ?? "" },
            set: { formData[key] = $0 }
        )
    }

    private func canGenerate() -> Bool {
        if !storeManager.isPro() && documentsGeneratedThisMonth >= storeManager.monthlyDocumentLimit() {
            return false
        }

        return !formData.values.contains(where: { $0.isEmpty })
    }

    private func generateDocument() {
        if let document = documentGenerator.generateDocument(
            template: template,
            formData: formData,
            state: locationManager.currentState ?? "Unknown"
        ) {
            documentsGeneratedThisMonth += 1
            dismiss()
        }
    }
}