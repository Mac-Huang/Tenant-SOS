import PDFKit
import SwiftUI
import Combine

class DocumentGenerator: ObservableObject {
    @Published var isGenerating = false
    @Published var generatedDocuments: [GeneratedDocument] = []

    struct GeneratedDocument: Identifiable {
        let id = UUID()
        let title: String
        let pdfData: Data
        let createdAt: Date
        let templateType: DocumentTemplate
    }

    enum DocumentTemplate: String, CaseIterable {
        case leaseAgreement = "Lease Agreement"
        case rentReceipt = "Rent Receipt"
        case maintenanceRequest = "Maintenance Request"
        case noticeToVacate = "Notice to Vacate"
        case securityDepositClaim = "Security Deposit Claim"
        case rentIncreaseNotice = "Rent Increase Notice"
        case roommateAgreement = "Roommate Agreement"
        case petAddendum = "Pet Addendum"
        case subleasesAgreement = "Sublease Agreement"
        case moveInChecklist = "Move-In Checklist"

        var icon: String {
            switch self {
            case .leaseAgreement: return "doc.text"
            case .rentReceipt: return "dollarsign.square"
            case .maintenanceRequest: return "wrench.and.screwdriver"
            case .noticeToVacate: return "calendar.badge.exclamationmark"
            case .securityDepositClaim: return "shield.lefthalf.filled"
            case .rentIncreaseNotice: return "chart.line.uptrend.xyaxis"
            case .roommateAgreement: return "person.2"
            case .petAddendum: return "pawprint"
            case .subleasesAgreement: return "arrow.triangle.swap"
            case .moveInChecklist: return "checklist"
            }
        }
    }

    func generateDocument(
        template: DocumentTemplate,
        formData: [String: Any],
        state: String
    ) -> GeneratedDocument? {
        isGenerating = true

        defer { isGenerating = false }

        let pdfMetaData = [
            kCGPDFContextCreator: "Tenant SOS",
            kCGPDFContextAuthor: "Tenant SOS App",
            kCGPDFContextTitle: template.rawValue
        ]

        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let margin: CGFloat = 50

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let data = renderer.pdfData { (context) in
            context.beginPage()

            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .bold)
            ]

            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
            ]

            let bodyAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12)
            ]

            let title = template.rawValue
            let titleSize = title.size(withAttributes: attributes)
            let titleRect = CGRect(
                x: (pageWidth - titleSize.width) / 2,
                y: margin,
                width: titleSize.width,
                height: titleSize.height
            )
            title.draw(in: titleRect, withAttributes: attributes)

            var yPosition = margin + titleSize.height + 20

            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            let dateString = "Date: \(dateFormatter.string(from: Date()))"
            dateString.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: bodyAttributes)

            yPosition += 30

            let stateString = "State: \(state)"
            stateString.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: bodyAttributes)

            yPosition += 40

            switch template {
            case .leaseAgreement:
                drawLeaseAgreement(context: context, formData: formData, yPosition: &yPosition, pageWidth: pageWidth, margin: margin, attributes: bodyAttributes)
            case .rentReceipt:
                drawRentReceipt(context: context, formData: formData, yPosition: &yPosition, pageWidth: pageWidth, margin: margin, attributes: bodyAttributes)
            case .maintenanceRequest:
                drawMaintenanceRequest(context: context, formData: formData, yPosition: &yPosition, pageWidth: pageWidth, margin: margin, attributes: bodyAttributes)
            case .noticeToVacate:
                drawNoticeToVacate(context: context, formData: formData, yPosition: &yPosition, pageWidth: pageWidth, margin: margin, attributes: bodyAttributes)
            case .securityDepositClaim:
                drawSecurityDepositClaim(context: context, formData: formData, yPosition: &yPosition, pageWidth: pageWidth, margin: margin, attributes: bodyAttributes)
            default:
                drawGenericTemplate(context: context, formData: formData, yPosition: &yPosition, pageWidth: pageWidth, margin: margin, attributes: bodyAttributes)
            }

            yPosition = pageHeight - 100

            let footerText = "Generated by Tenant SOS on \(dateFormatter.string(from: Date()))"
            let footerSize = footerText.size(withAttributes: bodyAttributes)
            let footerRect = CGRect(
                x: (pageWidth - footerSize.width) / 2,
                y: yPosition,
                width: footerSize.width,
                height: footerSize.height
            )
            footerText.draw(in: footerRect, withAttributes: bodyAttributes)

            let disclaimerText = "This document is for informational purposes only. Consult with a legal professional for advice."
            let disclaimerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.italicSystemFont(ofSize: 10),
                .foregroundColor: UIColor.gray
            ]
            let disclaimerSize = disclaimerText.size(withAttributes: disclaimerAttributes)
            let disclaimerRect = CGRect(
                x: (pageWidth - disclaimerSize.width) / 2,
                y: yPosition + 20,
                width: disclaimerSize.width,
                height: disclaimerSize.height
            )
            disclaimerText.draw(in: disclaimerRect, withAttributes: disclaimerAttributes)
        }

        let document = GeneratedDocument(
            title: "\(template.rawValue) - \(Date())",
            pdfData: data,
            createdAt: Date(),
            templateType: template
        )

        generatedDocuments.append(document)

        return document
    }

    private func drawLeaseAgreement(context: UIGraphicsPDFRendererContext, formData: [String: Any], yPosition: inout CGFloat, pageWidth: CGFloat, margin: CGFloat, attributes: [NSAttributedString.Key: Any]) {
        let sections = [
            "LANDLORD INFORMATION",
            "Name: \(formData["landlordName"] as? String ?? "[Landlord Name]")",
            "Address: \(formData["landlordAddress"] as? String ?? "[Landlord Address]")",
            "Phone: \(formData["landlordPhone"] as? String ?? "[Phone Number]")",
            "",
            "TENANT INFORMATION",
            "Name: \(formData["tenantName"] as? String ?? "[Tenant Name]")",
            "Address: \(formData["tenantAddress"] as? String ?? "[Current Address]")",
            "Phone: \(formData["tenantPhone"] as? String ?? "[Phone Number]")",
            "",
            "PROPERTY INFORMATION",
            "Address: \(formData["propertyAddress"] as? String ?? "[Property Address]")",
            "Type: \(formData["propertyType"] as? String ?? "[Apartment/House]")",
            "Bedrooms: \(formData["bedrooms"] as? String ?? "[Number]")",
            "Bathrooms: \(formData["bathrooms"] as? String ?? "[Number]")",
            "",
            "LEASE TERMS",
            "Lease Start Date: \(formData["startDate"] as? String ?? "[Start Date]")",
            "Lease End Date: \(formData["endDate"] as? String ?? "[End Date]")",
            "Monthly Rent: $\(formData["monthlyRent"] as? String ?? "[Amount]")",
            "Security Deposit: $\(formData["securityDeposit"] as? String ?? "[Amount]")",
            "Payment Due Date: \(formData["paymentDueDate"] as? String ?? "[Day of Month]")",
            "",
            "SIGNATURES",
            "",
            "_______________________          Date: __________",
            "Landlord Signature",
            "",
            "_______________________          Date: __________",
            "Tenant Signature"
        ]

        for section in sections {
            if yPosition > 700 {
                context.beginPage()
                yPosition = margin
            }

            if section.hasPrefix("LANDLORD") || section.hasPrefix("TENANT") ||
               section.hasPrefix("PROPERTY") || section.hasPrefix("LEASE") ||
               section.hasPrefix("SIGNATURES") {
                let boldAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
                ]
                section.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: boldAttributes)
            } else {
                section.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: attributes)
            }

            yPosition += section.isEmpty ? 10 : 20
        }
    }

    private func drawRentReceipt(context: UIGraphicsPDFRendererContext, formData: [String: Any], yPosition: inout CGFloat, pageWidth: CGFloat, margin: CGFloat, attributes: [NSAttributedString.Key: Any]) {
        let receiptNumber = "RECEIPT #\(Int.random(in: 10000...99999))"
        receiptNumber.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: attributes)
        yPosition += 30

        let sections = [
            "Received From: \(formData["tenantName"] as? String ?? "[Tenant Name]")",
            "Property Address: \(formData["propertyAddress"] as? String ?? "[Property Address]")",
            "Payment Amount: $\(formData["amount"] as? String ?? "[Amount]")",
            "Payment Period: \(formData["period"] as? String ?? "[Month/Year]")",
            "Payment Method: \(formData["paymentMethod"] as? String ?? "[Cash/Check/Electronic]")",
            "Date Received: \(formData["dateReceived"] as? String ?? "[Date]")",
            "",
            "Received By: _______________________",
            "Signature: _______________________",
            "Date: _______________________"
        ]

        for section in sections {
            section.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: attributes)
            yPosition += section.isEmpty ? 10 : 25
        }
    }

    private func drawMaintenanceRequest(context: UIGraphicsPDFRendererContext, formData: [String: Any], yPosition: inout CGFloat, pageWidth: CGFloat, margin: CGFloat, attributes: [NSAttributedString.Key: Any]) {
        let sections = [
            "MAINTENANCE REQUEST FORM",
            "",
            "Date: \(formData["date"] as? String ?? "[Date]")",
            "Tenant Name: \(formData["tenantName"] as? String ?? "[Your Name]")",
            "Unit/Address: \(formData["unit"] as? String ?? "[Unit Number/Address]")",
            "Contact Phone: \(formData["phone"] as? String ?? "[Phone Number]")",
            "Best Time to Contact: \(formData["contactTime"] as? String ?? "[Morning/Afternoon/Evening]")",
            "",
            "ISSUE DETAILS",
            "Location in Unit: \(formData["location"] as? String ?? "[Kitchen/Bathroom/Bedroom/etc.]")",
            "Priority Level: \(formData["priority"] as? String ?? "[Emergency/High/Normal/Low]")",
            "",
            "Description of Problem:",
            "\(formData["description"] as? String ?? "[Detailed description of the maintenance issue]")",
            "",
            "How long has this been an issue? \(formData["duration"] as? String ?? "[Duration]")",
            "Permission to Enter: \(formData["permission"] as? String ?? "[Yes/No]")",
            "",
            "Tenant Signature: _______________________",
            "Date: _______________________"
        ]

        for section in sections {
            if section == "MAINTENANCE REQUEST FORM" || section == "ISSUE DETAILS" {
                let boldAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
                ]
                section.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: boldAttributes)
            } else {
                section.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: attributes)
            }
            yPosition += section.isEmpty ? 10 : 20
        }
    }

    private func drawNoticeToVacate(context: UIGraphicsPDFRendererContext, formData: [String: Any], yPosition: inout CGFloat, pageWidth: CGFloat, margin: CGFloat, attributes: [NSAttributedString.Key: Any]) {
        let sections = [
            "NOTICE TO VACATE",
            "",
            "Date: \(formData["date"] as? String ?? "[Date]")",
            "",
            "To: \(formData["landlordName"] as? String ?? "[Landlord/Property Manager Name]")",
            "Property Address: \(formData["propertyAddress"] as? String ?? "[Property Address]")",
            "",
            "Dear \(formData["landlordName"] as? String ?? "[Landlord/Property Manager]"),",
            "",
            "This letter serves as my official notice to vacate the above-referenced property.",
            "",
            "Move-Out Date: \(formData["moveOutDate"] as? String ?? "[Date]")",
            "Notice Period: \(formData["noticePeriod"] as? String ?? "[30/60 days]")",
            "",
            "Forwarding Address:",
            "\(formData["forwardingAddress"] as? String ?? "[New Address]")",
            "",
            "Please send my security deposit refund to the forwarding address above.",
            "",
            "I will ensure the property is clean and in good condition upon move-out.",
            "Please contact me to schedule a move-out inspection.",
            "",
            "Sincerely,",
            "",
            "_______________________",
            "\(formData["tenantName"] as? String ?? "[Tenant Name]")",
            "Date: _______________________"
        ]

        for section in sections {
            if section == "NOTICE TO VACATE" {
                let boldAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 16, weight: .bold)
                ]
                let size = section.size(withAttributes: boldAttributes)
                let rect = CGRect(
                    x: (pageWidth - size.width) / 2,
                    y: yPosition,
                    width: size.width,
                    height: size.height
                )
                section.draw(in: rect, withAttributes: boldAttributes)
            } else {
                section.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: attributes)
            }
            yPosition += section.isEmpty ? 10 : 20
        }
    }

    private func drawSecurityDepositClaim(context: UIGraphicsPDFRendererContext, formData: [String: Any], yPosition: inout CGFloat, pageWidth: CGFloat, margin: CGFloat, attributes: [NSAttributedString.Key: Any]) {
        let sections = [
            "SECURITY DEPOSIT CLAIM FORM",
            "",
            "Tenant Information:",
            "Name: \(formData["tenantName"] as? String ?? "[Name]")",
            "Previous Address: \(formData["previousAddress"] as? String ?? "[Previous Address]")",
            "Move-Out Date: \(formData["moveOutDate"] as? String ?? "[Date]")",
            "",
            "Deposit Information:",
            "Original Deposit Amount: $\(formData["depositAmount"] as? String ?? "[Amount]")",
            "Date Deposit Paid: \(formData["depositDate"] as? String ?? "[Date]")",
            "",
            "Claimed Deductions (if any):",
            "\(formData["deductions"] as? String ?? "[List any deductions claimed by landlord]")",
            "",
            "Dispute Reason:",
            "\(formData["disputeReason"] as? String ?? "[Explain why you dispute the deductions]")",
            "",
            "Amount Claimed: $\(formData["amountClaimed"] as? String ?? "[Amount]")",
            "",
            "Supporting Documentation:",
            "[ ] Move-in inspection report",
            "[ ] Move-out inspection report",
            "[ ] Photos/videos",
            "[ ] Receipts for cleaning/repairs",
            "[ ] Other: \(formData["otherDocs"] as? String ?? "")",
            "",
            "Signature: _______________________",
            "Date: _______________________"
        ]

        for section in sections {
            section.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: attributes)
            yPosition += 20
        }
    }

    private func drawGenericTemplate(context: UIGraphicsPDFRendererContext, formData: [String: Any], yPosition: inout CGFloat, pageWidth: CGFloat, margin: CGFloat, attributes: [NSAttributedString.Key: Any]) {
        let text = "This template is under development. Please check back later for updates."
        text.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: attributes)
    }

    func shareDocument(_ document: GeneratedDocument) {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(document.templateType.rawValue).pdf")

        do {
            try document.pdfData.write(to: tempURL)
            let activityViewController = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)

            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(activityViewController, animated: true, completion: nil)
            }
        } catch {
            print("Error sharing document: \(error)")
        }
    }

    func saveToFiles(_ document: GeneratedDocument) {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(document.templateType.rawValue).pdf")

        do {
            try document.pdfData.write(to: tempURL)

            let documentPicker = UIDocumentPickerViewController(forExporting: [tempURL])

            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(documentPicker, animated: true, completion: nil)
            }
        } catch {
            print("Error saving document: \(error)")
        }
    }
}