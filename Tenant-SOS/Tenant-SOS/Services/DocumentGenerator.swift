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
        // Tenant Documents
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

        // Employment Documents
        case employmentVerification = "Employment Verification"
        case incomeVerification = "Income Verification"
        case w4Form = "W-4 Tax Form"

        // Tax Documents
        case rentalIncomeReport = "Rental Income Report"
        case propertyTaxEstimate = "Property Tax Estimate"

        // Other Legal Documents
        case powerOfAttorney = "Power of Attorney"
        case leaseTermination = "Lease Termination"
        case repairRequest = "Repair Request"

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
            case .employmentVerification: return "checkmark.seal"
            case .incomeVerification: return "dollarsign.circle"
            case .w4Form: return "doc.text.fill"
            case .rentalIncomeReport: return "chart.bar.doc.horizontal"
            case .propertyTaxEstimate: return "house.and.flag"
            case .powerOfAttorney: return "person.badge.key"
            case .leaseTermination: return "xmark.circle"
            case .repairRequest: return "hammer"
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

            _ = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .semibold)
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
            case .rentIncreaseNotice:
                drawRentIncreaseNotice(context: context, formData: formData, yPosition: &yPosition, pageWidth: pageWidth, margin: margin, attributes: bodyAttributes)
            case .roommateAgreement:
                drawRoommateAgreement(context: context, formData: formData, yPosition: &yPosition, pageWidth: pageWidth, margin: margin, attributes: bodyAttributes)
            case .petAddendum:
                drawPetAddendum(context: context, formData: formData, yPosition: &yPosition, pageWidth: pageWidth, margin: margin, attributes: bodyAttributes)
            case .subleasesAgreement:
                drawSubleaseAgreement(context: context, formData: formData, yPosition: &yPosition, pageWidth: pageWidth, margin: margin, attributes: bodyAttributes)
            case .moveInChecklist:
                drawMoveInChecklist(context: context, formData: formData, yPosition: &yPosition, pageWidth: pageWidth, margin: margin, attributes: bodyAttributes)
            case .employmentVerification:
                drawEmploymentVerification(context: context, formData: formData, yPosition: &yPosition, pageWidth: pageWidth, margin: margin, attributes: bodyAttributes)
            case .incomeVerification:
                drawIncomeVerification(context: context, formData: formData, yPosition: &yPosition, pageWidth: pageWidth, margin: margin, attributes: bodyAttributes)
            case .w4Form:
                drawW4Form(context: context, formData: formData, yPosition: &yPosition, pageWidth: pageWidth, margin: margin, attributes: bodyAttributes)
            case .rentalIncomeReport:
                drawRentalIncomeReport(context: context, formData: formData, yPosition: &yPosition, pageWidth: pageWidth, margin: margin, attributes: bodyAttributes)
            case .propertyTaxEstimate:
                drawPropertyTaxEstimate(context: context, formData: formData, yPosition: &yPosition, pageWidth: pageWidth, margin: margin, attributes: bodyAttributes)
            case .powerOfAttorney:
                drawPowerOfAttorney(context: context, formData: formData, yPosition: &yPosition, pageWidth: pageWidth, margin: margin, attributes: bodyAttributes)
            case .leaseTermination:
                drawLeaseTermination(context: context, formData: formData, yPosition: &yPosition, pageWidth: pageWidth, margin: margin, attributes: bodyAttributes)
            case .repairRequest:
                drawRepairRequest(context: context, formData: formData, yPosition: &yPosition, pageWidth: pageWidth, margin: margin, attributes: bodyAttributes)
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

    private func drawRentIncreaseNotice(context: UIGraphicsPDFRendererContext, formData: [String: Any], yPosition: inout CGFloat, pageWidth: CGFloat, margin: CGFloat, attributes: [NSAttributedString.Key: Any]) {
        let sections = [
            "NOTICE OF RENT INCREASE",
            "",
            "Date: \(formData["date"] as? String ?? "[Date]")",
            "",
            "To: \(formData["tenantName"] as? String ?? "[Tenant Name]")",
            "Property Address: \(formData["propertyAddress"] as? String ?? "[Property Address]")",
            "",
            "Dear \(formData["tenantName"] as? String ?? "[Tenant Name]"),",
            "",
            "This letter serves as official notice of a rent increase for the above property.",
            "",
            "Current Monthly Rent: $\(formData["currentRent"] as? String ?? "[Current Amount]")",
            "New Monthly Rent: $\(formData["newRent"] as? String ?? "[New Amount]")",
            "Increase Amount: $\(formData["increaseAmount"] as? String ?? "[Difference]")",
            "Effective Date: \(formData["effectiveDate"] as? String ?? "[Date]")",
            "Notice Period: \(formData["noticePeriod"] as? String ?? "[30/60 days]")",
            "",
            "Reason for Increase:",
            "\(formData["reason"] as? String ?? "[Reason for rent increase]")",
            "",
            "All other terms and conditions of your lease remain unchanged.",
            "",
            "If you have any questions, please contact us at:",
            "Phone: \(formData["landlordPhone"] as? String ?? "[Phone]")",
            "Email: \(formData["landlordEmail"] as? String ?? "[Email]")",
            "",
            "Sincerely,",
            "",
            "_______________________",
            "\(formData["landlordName"] as? String ?? "[Landlord/Property Manager Name]")",
            "Date: _______________________"
        ]

        for section in sections {
            if section == "NOTICE OF RENT INCREASE" {
                let boldAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 16, weight: .bold)
                ]
                section.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: boldAttributes)
            } else {
                section.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: attributes)
            }
            yPosition += section.isEmpty ? 10 : 20
        }
    }

    private func drawRoommateAgreement(context: UIGraphicsPDFRendererContext, formData: [String: Any], yPosition: inout CGFloat, pageWidth: CGFloat, margin: CGFloat, attributes: [NSAttributedString.Key: Any]) {
        let sections = [
            "ROOMMATE AGREEMENT",
            "",
            "This agreement is made on \(formData["date"] as? String ?? "[Date]")",
            "",
            "Between the following roommates:",
            "Roommate 1: \(formData["roommate1"] as? String ?? "[Name]")",
            "Roommate 2: \(formData["roommate2"] as? String ?? "[Name]")",
            "Roommate 3: \(formData["roommate3"] as? String ?? "")",
            "",
            "Property Address: \(formData["propertyAddress"] as? String ?? "[Address]")",
            "",
            "RENT DIVISION",
            "Total Monthly Rent: $\(formData["totalRent"] as? String ?? "[Amount]")",
            "Roommate 1 Share: $\(formData["rent1"] as? String ?? "[Amount]")",
            "Roommate 2 Share: $\(formData["rent2"] as? String ?? "[Amount]")",
            "Roommate 3 Share: $\(formData["rent3"] as? String ?? "")",
            "",
            "UTILITIES & EXPENSES",
            "Utilities Split: \(formData["utilitySplit"] as? String ?? "[Equal/Percentage]")",
            "Internet/Cable: $\(formData["internet"] as? String ?? "[Amount]")",
            "Utilities: $\(formData["utilities"] as? String ?? "[Amount]")",
            "",
            "HOUSE RULES",
            "Quiet Hours: \(formData["quietHours"] as? String ?? "[Time]")",
            "Guest Policy: \(formData["guestPolicy"] as? String ?? "[Policy]")",
            "Cleaning Schedule: \(formData["cleaning"] as? String ?? "[Schedule]")",
            "",
            "SIGNATURES",
            "",
            "_______________________  Date: __________",
            "Roommate 1",
            "",
            "_______________________  Date: __________",
            "Roommate 2"
        ]

        for section in sections {
            if section == "ROOMMATE AGREEMENT" || section == "RENT DIVISION" ||
               section == "UTILITIES & EXPENSES" || section == "HOUSE RULES" ||
               section == "SIGNATURES" {
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

    private func drawPetAddendum(context: UIGraphicsPDFRendererContext, formData: [String: Any], yPosition: inout CGFloat, pageWidth: CGFloat, margin: CGFloat, attributes: [NSAttributedString.Key: Any]) {
        let sections = [
            "PET ADDENDUM TO LEASE AGREEMENT",
            "",
            "Property Address: \(formData["propertyAddress"] as? String ?? "[Address]")",
            "Lease Date: \(formData["leaseDate"] as? String ?? "[Date]")",
            "",
            "TENANT INFORMATION",
            "Tenant Name: \(formData["tenantName"] as? String ?? "[Name]")",
            "",
            "PET INFORMATION",
            "Pet Type: \(formData["petType"] as? String ?? "[Dog/Cat/Other]")",
            "Breed: \(formData["breed"] as? String ?? "[Breed]")",
            "Name: \(formData["petName"] as? String ?? "[Pet Name]")",
            "Age: \(formData["petAge"] as? String ?? "[Age]")",
            "Weight: \(formData["weight"] as? String ?? "[Weight]")",
            "Color: \(formData["color"] as? String ?? "[Color]")",
            "",
            "FEES & DEPOSITS",
            "Pet Deposit: $\(formData["petDeposit"] as? String ?? "[Amount]") (Refundable/Non-refundable)",
            "Monthly Pet Rent: $\(formData["petRent"] as? String ?? "[Amount]")",
            "",
            "PET RULES",
            "- Pet must be vaccinated and licensed per local ordinances",
            "- Tenant responsible for all damage caused by pet",
            "- Pet waste must be cleaned immediately",
            "- Pet must not cause disturbance to neighbors",
            "- Additional pets require written approval",
            "",
            "Proof of vaccinations attached: [ ] Yes  [ ] No",
            "Pet license attached: [ ] Yes  [ ] No",
            "",
            "SIGNATURES",
            "",
            "_______________________  Date: __________",
            "Landlord/Property Manager",
            "",
            "_______________________  Date: __________",
            "Tenant"
        ]

        for section in sections {
            if section.contains("ADDENDUM") || section == "TENANT INFORMATION" ||
               section == "PET INFORMATION" || section == "FEES & DEPOSITS" ||
               section == "PET RULES" || section == "SIGNATURES" {
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

    private func drawSubleaseAgreement(context: UIGraphicsPDFRendererContext, formData: [String: Any], yPosition: inout CGFloat, pageWidth: CGFloat, margin: CGFloat, attributes: [NSAttributedString.Key: Any]) {
        let sections = [
            "SUBLEASE AGREEMENT",
            "",
            "Original Lease Date: \(formData["originalLeaseDate"] as? String ?? "[Date]")",
            "Sublease Start Date: \(formData["startDate"] as? String ?? "[Date]")",
            "Sublease End Date: \(formData["endDate"] as? String ?? "[Date]")",
            "",
            "ORIGINAL TENANT (Sublessor)",
            "Name: \(formData["originalTenant"] as? String ?? "[Name]")",
            "Phone: \(formData["originalPhone"] as? String ?? "[Phone]")",
            "",
            "SUBTENANT (Sublessee)",
            "Name: \(formData["subtenant"] as? String ?? "[Name]")",
            "Phone: \(formData["subtenantPhone"] as? String ?? "[Phone]")",
            "Email: \(formData["subtenantEmail"] as? String ?? "[Email]")",
            "",
            "PROPERTY",
            "Address: \(formData["propertyAddress"] as? String ?? "[Address]")",
            "Unit: \(formData["unit"] as? String ?? "[Unit #]")",
            "",
            "FINANCIAL TERMS",
            "Monthly Sublease Rent: $\(formData["rent"] as? String ?? "[Amount]")",
            "Security Deposit: $\(formData["deposit"] as? String ?? "[Amount]")",
            "Payment Due Date: \(formData["dueDate"] as? String ?? "[Day of Month]")",
            "",
            "LANDLORD APPROVAL",
            "Landlord Name: \(formData["landlordName"] as? String ?? "[Name]")",
            "Approval Date: \(formData["approvalDate"] as? String ?? "[Date]")",
            "",
            "TERMS",
            "- Subtenant agrees to abide by all terms of the original lease",
            "- Original tenant remains responsible to landlord",
            "- Utilities: \(formData["utilities"] as? String ?? "[Who pays]")",
            "",
            "SIGNATURES",
            "",
            "_______________________  Date: __________",
            "Original Tenant (Sublessor)",
            "",
            "_______________________  Date: __________",
            "Subtenant (Sublessee)",
            "",
            "_______________________  Date: __________",
            "Landlord (Approval)"
        ]

        for section in sections {
            if yPosition > 700 {
                context.beginPage()
                yPosition = margin
            }

            if section == "SUBLEASE AGREEMENT" || section.contains("TENANT") ||
               section == "PROPERTY" || section == "FINANCIAL TERMS" ||
               section == "LANDLORD APPROVAL" || section == "TERMS" ||
               section == "SIGNATURES" {
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

    private func drawMoveInChecklist(context: UIGraphicsPDFRendererContext, formData: [String: Any], yPosition: inout CGFloat, pageWidth: CGFloat, margin: CGFloat, attributes: [NSAttributedString.Key: Any]) {
        let sections = [
            "MOVE-IN INSPECTION CHECKLIST",
            "",
            "Property Address: \(formData["propertyAddress"] as? String ?? "[Address]")",
            "Move-In Date: \(formData["moveInDate"] as? String ?? "[Date]")",
            "Tenant: \(formData["tenantName"] as? String ?? "[Name]")",
            "",
            "Rate each item: E=Excellent, G=Good, F=Fair, P=Poor, N/A=Not Applicable",
            "",
            "LIVING ROOM",
            "[ ] Walls/Paint ____  Notes: _________________",
            "[ ] Carpet/Flooring ____  Notes: _________________",
            "[ ] Windows/Screens ____  Notes: _________________",
            "[ ] Light Fixtures ____  Notes: _________________",
            "[ ] Outlets/Switches ____  Notes: _________________",
            "",
            "KITCHEN",
            "[ ] Cabinets ____  Notes: _________________",
            "[ ] Countertops ____  Notes: _________________",
            "[ ] Appliances ____  Notes: _________________",
            "[ ] Sink/Faucet ____  Notes: _________________",
            "[ ] Flooring ____  Notes: _________________",
            "",
            "BATHROOM(S)",
            "[ ] Toilet ____  Notes: _________________",
            "[ ] Shower/Tub ____  Notes: _________________",
            "[ ] Sink/Vanity ____  Notes: _________________",
            "[ ] Tile/Flooring ____  Notes: _________________",
            "[ ] Ventilation Fan ____  Notes: _________________",
            "",
            "BEDROOM(S)",
            "[ ] Walls/Paint ____  Notes: _________________",
            "[ ] Closets ____  Notes: _________________",
            "[ ] Windows ____  Notes: _________________",
            "[ ] Flooring ____  Notes: _________________",
            "",
            "ADDITIONAL NOTES:",
            "\(formData["notes"] as? String ?? "[Additional observations]")",
            "",
            "Photos taken: [ ] Yes  [ ] No",
            "",
            "SIGNATURES",
            "",
            "_______________________  Date: __________",
            "Tenant",
            "",
            "_______________________  Date: __________",
            "Landlord/Property Manager"
        ]

        for section in sections {
            if yPosition > 700 {
                context.beginPage()
                yPosition = margin
            }

            if section == "MOVE-IN INSPECTION CHECKLIST" || section == "LIVING ROOM" ||
               section == "KITCHEN" || section == "BATHROOM(S)" || section == "BEDROOM(S)" ||
               section == "ADDITIONAL NOTES:" || section == "SIGNATURES" {
                let boldAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
                ]
                section.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: boldAttributes)
            } else {
                section.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: attributes)
            }
            yPosition += section.isEmpty ? 10 : 18
        }
    }

    private func drawEmploymentVerification(context: UIGraphicsPDFRendererContext, formData: [String: Any], yPosition: inout CGFloat, pageWidth: CGFloat, margin: CGFloat, attributes: [NSAttributedString.Key: Any]) {
        let sections = [
            "EMPLOYMENT VERIFICATION LETTER",
            "",
            "Date: \(formData["date"] as? String ?? "[Date]")",
            "",
            "To Whom It May Concern:",
            "",
            "This letter confirms that \(formData["employeeName"] as? String ?? "[Employee Name]") is currently employed with our company.",
            "",
            "EMPLOYEE INFORMATION",
            "Employee Name: \(formData["employeeName"] as? String ?? "[Name]")",
            "Position: \(formData["position"] as? String ?? "[Job Title]")",
            "Department: \(formData["department"] as? String ?? "[Department]")",
            "Employee ID: \(formData["employeeId"] as? String ?? "[ID Number]")",
            "",
            "EMPLOYMENT DETAILS",
            "Employment Start Date: \(formData["startDate"] as? String ?? "[Date]")",
            "Employment Status: \(formData["employmentStatus"] as? String ?? "[Full-time/Part-time]")",
            "Work Schedule: \(formData["schedule"] as? String ?? "[Hours per week]")",
            "",
            "COMPANY INFORMATION",
            "Company Name: \(formData["companyName"] as? String ?? "[Company Name]")",
            "Company Address: \(formData["companyAddress"] as? String ?? "[Address]")",
            "HR Contact: \(formData["hrContact"] as? String ?? "[Name]")",
            "Phone: \(formData["phone"] as? String ?? "[Phone]")",
            "Email: \(formData["email"] as? String ?? "[Email]")",
            "",
            "If you require additional information, please contact our Human Resources department.",
            "",
            "Sincerely,",
            "",
            "_______________________",
            "\(formData["signerName"] as? String ?? "[HR Manager Name]")",
            "\(formData["signerTitle"] as? String ?? "[Title]")",
            "",
            "Company Stamp/Seal: _______________"
        ]

        for section in sections {
            if section == "EMPLOYMENT VERIFICATION LETTER" || section == "EMPLOYEE INFORMATION" ||
               section == "EMPLOYMENT DETAILS" || section == "COMPANY INFORMATION" {
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

    private func drawIncomeVerification(context: UIGraphicsPDFRendererContext, formData: [String: Any], yPosition: inout CGFloat, pageWidth: CGFloat, margin: CGFloat, attributes: [NSAttributedString.Key: Any]) {
        let sections = [
            "INCOME VERIFICATION LETTER",
            "",
            "Date: \(formData["date"] as? String ?? "[Date]")",
            "",
            "To Whom It May Concern:",
            "",
            "This letter verifies the income of \(formData["employeeName"] as? String ?? "[Employee Name]").",
            "",
            "EMPLOYEE INFORMATION",
            "Name: \(formData["employeeName"] as? String ?? "[Name]")",
            "Position: \(formData["position"] as? String ?? "[Job Title]")",
            "Employment Status: \(formData["status"] as? String ?? "[Full-time/Part-time]")",
            "Hire Date: \(formData["hireDate"] as? String ?? "[Date]")",
            "",
            "INCOME DETAILS",
            "Annual Gross Salary: $\(formData["annualSalary"] as? String ?? "[Amount]")",
            "Pay Frequency: \(formData["payFrequency"] as? String ?? "[Weekly/Bi-weekly/Monthly]")",
            "Gross Pay per Period: $\(formData["payPerPeriod"] as? String ?? "[Amount]")",
            "",
            "ADDITIONAL COMPENSATION (if applicable)",
            "Bonuses: $\(formData["bonuses"] as? String ?? "[Amount]")",
            "Commission: $\(formData["commission"] as? String ?? "[Amount]")",
            "Overtime: $\(formData["overtime"] as? String ?? "[Amount]")",
            "Other Income: $\(formData["otherIncome"] as? String ?? "[Amount]")",
            "",
            "Total Annual Income: $\(formData["totalIncome"] as? String ?? "[Total Amount]")",
            "",
            "This information is current as of \(formData["currentDate"] as? String ?? "[Date]").",
            "",
            "For verification purposes, please contact:",
            "HR Department: \(formData["hrContact"] as? String ?? "[Name]")",
            "Phone: \(formData["phone"] as? String ?? "[Phone]")",
            "Email: \(formData["email"] as? String ?? "[Email]")",
            "",
            "Sincerely,",
            "",
            "_______________________",
            "\(formData["signerName"] as? String ?? "[HR Manager/Supervisor]")",
            "\(formData["signerTitle"] as? String ?? "[Title]")",
            "\(formData["companyName"] as? String ?? "[Company Name]")"
        ]

        for section in sections {
            if yPosition > 700 {
                context.beginPage()
                yPosition = margin
            }

            if section == "INCOME VERIFICATION LETTER" || section == "EMPLOYEE INFORMATION" ||
               section == "INCOME DETAILS" || section == "ADDITIONAL COMPENSATION (if applicable)" {
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

    private func drawW4Form(context: UIGraphicsPDFRendererContext, formData: [String: Any], yPosition: inout CGFloat, pageWidth: CGFloat, margin: CGFloat, attributes: [NSAttributedString.Key: Any]) {
        let sections = [
            "Form W-4 Worksheet",
            "Employee's Withholding Certificate",
            "",
            "Note: This is a simplified worksheet. For official IRS Form W-4, visit www.irs.gov",
            "",
            "EMPLOYEE INFORMATION",
            "First Name: \(formData["firstName"] as? String ?? "[First]")  Last Name: \(formData["lastName"] as? String ?? "[Last]")",
            "Social Security Number: \(formData["ssn"] as? String ?? "[XXX-XX-XXXX]")",
            "Address: \(formData["address"] as? String ?? "[Address]")",
            "City: \(formData["city"] as? String ?? "[City]")  State: \(formData["state"] as? String ?? "[State]")  ZIP: \(formData["zip"] as? String ?? "[ZIP]")",
            "",
            "FILING STATUS",
            "[ ] Single or Married filing separately",
            "[ ] Married filing jointly or Qualifying surviving spouse",
            "[ ] Head of household",
            "",
            "MULTIPLE JOBS OR SPOUSE WORKS",
            "Complete if you have more than one job or are married filing jointly and spouse works.",
            "Check here: [ ]  (Use IRS worksheet or calculator)",
            "",
            "CLAIM DEPENDENTS",
            "Number of qualifying children: \(formData["children"] as? String ?? "[Number]")",
            "Number of other dependents: \(formData["otherDependents"] as? String ?? "[Number]")",
            "",
            "OTHER ADJUSTMENTS",
            "Other income (not from jobs): $\(formData["otherIncome"] as? String ?? "[Amount]")",
            "Deductions: $\(formData["deductions"] as? String ?? "[Amount]")",
            "Extra withholding per pay period: $\(formData["extraWithholding"] as? String ?? "[Amount]")",
            "",
            "Under penalties of perjury, I declare that this certificate is true, correct, and complete.",
            "",
            "Employee Signature: _______________________  Date: __________",
            "",
            "EMPLOYER USE ONLY",
            "Employer Name: \(formData["employerName"] as? String ?? "[Company Name]")",
            "Employer ID (EIN): \(formData["ein"] as? String ?? "[XX-XXXXXXX]")"
        ]

        for section in sections {
            if yPosition > 700 {
                context.beginPage()
                yPosition = margin
            }

            if section.contains("Form W-4") || section == "EMPLOYEE INFORMATION" ||
               section == "FILING STATUS" || section == "MULTIPLE JOBS OR SPOUSE WORKS" ||
               section == "CLAIM DEPENDENTS" || section == "OTHER ADJUSTMENTS" ||
               section == "EMPLOYER USE ONLY" {
                let boldAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
                ]
                section.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: boldAttributes)
            } else {
                section.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: attributes)
            }
            yPosition += section.isEmpty ? 10 : 18
        }
    }

    private func drawRentalIncomeReport(context: UIGraphicsPDFRendererContext, formData: [String: Any], yPosition: inout CGFloat, pageWidth: CGFloat, margin: CGFloat, attributes: [NSAttributedString.Key: Any]) {
        let sections = [
            "RENTAL INCOME REPORT",
            "",
            "Tax Year: \(formData["taxYear"] as? String ?? "[Year]")",
            "Report Date: \(formData["reportDate"] as? String ?? "[Date]")",
            "",
            "PROPERTY OWNER INFORMATION",
            "Owner Name: \(formData["ownerName"] as? String ?? "[Name]")",
            "SSN/EIN: \(formData["taxId"] as? String ?? "[XXX-XX-XXXX]")",
            "Address: \(formData["ownerAddress"] as? String ?? "[Address]")",
            "",
            "RENTAL PROPERTY",
            "Property Address: \(formData["propertyAddress"] as? String ?? "[Address]")",
            "Property Type: \(formData["propertyType"] as? String ?? "[Single-family/Multi-unit]")",
            "Number of Units: \(formData["units"] as? String ?? "[Number]")",
            "",
            "RENTAL INCOME",
            "Total Rent Collected: $\(formData["totalRent"] as? String ?? "[Amount]")",
            "Security Deposits Retained: $\(formData["depositsRetained"] as? String ?? "[Amount]")",
            "Other Income: $\(formData["otherIncome"] as? String ?? "[Amount]")",
            "TOTAL INCOME: $\(formData["totalIncome"] as? String ?? "[Total]")",
            "",
            "RENTAL EXPENSES",
            "Mortgage Interest: $\(formData["mortgageInterest"] as? String ?? "[Amount]")",
            "Property Tax: $\(formData["propertyTax"] as? String ?? "[Amount]")",
            "Insurance: $\(formData["insurance"] as? String ?? "[Amount]")",
            "Repairs & Maintenance: $\(formData["repairs"] as? String ?? "[Amount]")",
            "Utilities: $\(formData["utilities"] as? String ?? "[Amount]")",
            "Management Fees: $\(formData["managementFees"] as? String ?? "[Amount]")",
            "HOA Fees: $\(formData["hoaFees"] as? String ?? "[Amount]")",
            "Other Expenses: $\(formData["otherExpenses"] as? String ?? "[Amount]")",
            "TOTAL EXPENSES: $\(formData["totalExpenses"] as? String ?? "[Total]")",
            "",
            "DEPRECIATION",
            "Building Depreciation: $\(formData["depreciation"] as? String ?? "[Amount]")",
            "",
            "NET RENTAL INCOME/LOSS: $\(formData["netIncome"] as? String ?? "[Amount]")",
            "",
            "This report is for tax preparation purposes. Consult a tax professional.",
            "",
            "Prepared by: _______________________  Date: __________"
        ]

        for section in sections {
            if yPosition > 700 {
                context.beginPage()
                yPosition = margin
            }

            if section == "RENTAL INCOME REPORT" || section.contains("INFORMATION") ||
               section == "RENTAL PROPERTY" || section == "RENTAL INCOME" ||
               section == "RENTAL EXPENSES" || section == "DEPRECIATION" {
                let boldAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
                ]
                section.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: boldAttributes)
            } else {
                section.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: attributes)
            }
            yPosition += section.isEmpty ? 10 : 18
        }
    }

    private func drawPropertyTaxEstimate(context: UIGraphicsPDFRendererContext, formData: [String: Any], yPosition: inout CGFloat, pageWidth: CGFloat, margin: CGFloat, attributes: [NSAttributedString.Key: Any]) {
        let sections = [
            "PROPERTY TAX ESTIMATE",
            "",
            "Estimate Date: \(formData["date"] as? String ?? "[Date]")",
            "Tax Year: \(formData["taxYear"] as? String ?? "[Year]")",
            "",
            "PROPERTY INFORMATION",
            "Property Address: \(formData["propertyAddress"] as? String ?? "[Address]")",
            "Parcel Number: \(formData["parcelNumber"] as? String ?? "[Parcel ID]")",
            "County: \(formData["county"] as? String ?? "[County]")",
            "",
            "ASSESSMENT",
            "Assessed Property Value: $\(formData["assessedValue"] as? String ?? "[Amount]")",
            "Market Value: $\(formData["marketValue"] as? String ?? "[Amount]")",
            "Assessment Ratio: \(formData["assessmentRatio"] as? String ?? "[Percentage]")",
            "",
            "TAX RATES (per $1,000 of assessed value)",
            "County Tax Rate: \(formData["countyRate"] as? String ?? "[Rate]")",
            "City Tax Rate: \(formData["cityRate"] as? String ?? "[Rate]")",
            "School District Rate: \(formData["schoolRate"] as? String ?? "[Rate]")",
            "Special Assessments: \(formData["specialRate"] as? String ?? "[Rate]")",
            "Total Combined Rate: \(formData["totalRate"] as? String ?? "[Rate]")",
            "",
            "ESTIMATED TAX BREAKDOWN",
            "County Tax: $\(formData["countyTax"] as? String ?? "[Amount]")",
            "City Tax: $\(formData["cityTax"] as? String ?? "[Amount]")",
            "School District Tax: $\(formData["schoolTax"] as? String ?? "[Amount]")",
            "Special Assessments: $\(formData["specialTax"] as? String ?? "[Amount]")",
            "",
            "TOTAL ESTIMATED ANNUAL TAX: $\(formData["totalTax"] as? String ?? "[Total]")",
            "",
            "Estimated Monthly Escrow: $\(formData["monthlyEscrow"] as? String ?? "[Amount]")",
            "",
            "PAYMENT SCHEDULE",
            "Due Date 1: \(formData["dueDate1"] as? String ?? "[Date]")  Amount: $\(formData["payment1"] as? String ?? "[Amount]")",
            "Due Date 2: \(formData["dueDate2"] as? String ?? "[Date]")  Amount: $\(formData["payment2"] as? String ?? "[Amount]")",
            "",
            "Note: This is an estimate only. Actual tax amounts may vary.",
            "Contact your local tax assessor's office for official tax bills.",
            "",
            "Prepared by: _______________________  Date: __________"
        ]

        for section in sections {
            if yPosition > 700 {
                context.beginPage()
                yPosition = margin
            }

            if section == "PROPERTY TAX ESTIMATE" || section == "PROPERTY INFORMATION" ||
               section == "ASSESSMENT" || section.contains("TAX RATES") ||
               section == "ESTIMATED TAX BREAKDOWN" || section == "PAYMENT SCHEDULE" {
                let boldAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
                ]
                section.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: boldAttributes)
            } else {
                section.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: attributes)
            }
            yPosition += section.isEmpty ? 10 : 18
        }
    }

    private func drawPowerOfAttorney(context: UIGraphicsPDFRendererContext, formData: [String: Any], yPosition: inout CGFloat, pageWidth: CGFloat, margin: CGFloat, attributes: [NSAttributedString.Key: Any]) {
        let sections = [
            "POWER OF ATTORNEY",
            "",
            "PRINCIPAL (Person Granting Power)",
            "Name: \(formData["principalName"] as? String ?? "[Your Full Name]")",
            "Address: \(formData["principalAddress"] as? String ?? "[Address]")",
            "Date of Birth: \(formData["principalDOB"] as? String ?? "[Date]")",
            "",
            "ATTORNEY-IN-FACT (Person Receiving Power)",
            "Name: \(formData["agentName"] as? String ?? "[Agent Full Name]")",
            "Address: \(formData["agentAddress"] as? String ?? "[Address]")",
            "Phone: \(formData["agentPhone"] as? String ?? "[Phone]")",
            "",
            "GRANT OF AUTHORITY",
            "I, the Principal, grant the Attorney-in-Fact the authority to act on my behalf regarding:",
            "",
            "Powers Granted (check all that apply):",
            "[ ] Real estate transactions",
            "[ ] Banking and financial matters",
            "[ ] Legal proceedings",
            "[ ] Healthcare decisions",
            "[ ] Tax matters",
            "[ ] Insurance matters",
            "[ ] Other: \(formData["otherPowers"] as? String ?? "")",
            "",
            "EFFECTIVE DATE",
            "This Power of Attorney:",
            "[ ] Becomes effective immediately",
            "[ ] Becomes effective on: \(formData["effectiveDate"] as? String ?? "[Date]")",
            "[ ] Becomes effective upon my incapacity",
            "",
            "TERMINATION",
            "This Power of Attorney:",
            "[ ] Continues indefinitely until revoked",
            "[ ] Terminates on: \(formData["terminationDate"] as? String ?? "[Date]")",
            "[ ] Is durable (survives incapacity)",
            "",
            "LIMITATIONS",
            "Special instructions or limitations: \(formData["limitations"] as? String ?? "[Any restrictions]")",
            "",
            "WARNING: This is a general form. Consult an attorney for specific legal advice.",
            "",
            "PRINCIPAL'S SIGNATURE",
            "_______________________  Date: __________",
            "\(formData["principalName"] as? String ?? "[Principal Name]")",
            "",
            "WITNESS 1",
            "_______________________  Date: __________",
            "Name: _______________________",
            "",
            "WITNESS 2",
            "_______________________  Date: __________",
            "Name: _______________________",
            "",
            "NOTARY PUBLIC",
            "Subscribed and sworn before me on __________",
            "_______________________",
            "Notary Public Signature",
            "My commission expires: __________"
        ]

        for section in sections {
            if yPosition > 700 {
                context.beginPage()
                yPosition = margin
            }

            if section == "POWER OF ATTORNEY" || section.contains("PRINCIPAL") ||
               section.contains("ATTORNEY-IN-FACT") || section == "GRANT OF AUTHORITY" ||
               section == "EFFECTIVE DATE" || section == "TERMINATION" ||
               section == "LIMITATIONS" || section.contains("SIGNATURE") ||
               section.contains("WITNESS") || section.contains("NOTARY") {
                let boldAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
                ]
                section.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: boldAttributes)
            } else {
                section.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: attributes)
            }
            yPosition += section.isEmpty ? 10 : 18
        }
    }

    private func drawLeaseTermination(context: UIGraphicsPDFRendererContext, formData: [String: Any], yPosition: inout CGFloat, pageWidth: CGFloat, margin: CGFloat, attributes: [NSAttributedString.Key: Any]) {
        let sections = [
            "MUTUAL LEASE TERMINATION AGREEMENT",
            "",
            "Date: \(formData["date"] as? String ?? "[Date]")",
            "",
            "PARTIES",
            "Landlord: \(formData["landlordName"] as? String ?? "[Landlord Name]")",
            "Tenant: \(formData["tenantName"] as? String ?? "[Tenant Name]")",
            "",
            "PROPERTY",
            "Address: \(formData["propertyAddress"] as? String ?? "[Property Address]")",
            "",
            "ORIGINAL LEASE",
            "Lease Start Date: \(formData["leaseStartDate"] as? String ?? "[Date]")",
            "Original Lease End Date: \(formData["leaseEndDate"] as? String ?? "[Date]")",
            "",
            "TERMINATION TERMS",
            "Termination Date: \(formData["terminationDate"] as? String ?? "[Date]")",
            "Reason for Early Termination: \(formData["reason"] as? String ?? "[Reason]")",
            "",
            "FINANCIAL SETTLEMENT",
            "Security Deposit Held: $\(formData["depositHeld"] as? String ?? "[Amount]")",
            "Amount to be Returned: $\(formData["depositReturn"] as? String ?? "[Amount]")",
            "Deductions (if any): $\(formData["deductions"] as? String ?? "[Amount]")",
            "Early Termination Fee: $\(formData["terminationFee"] as? String ?? "[Amount]")",
            "Outstanding Rent: $\(formData["outstandingRent"] as? String ?? "[Amount]")",
            "",
            "MOVE-OUT CONDITIONS",
            "Move-Out Date: \(formData["moveOutDate"] as? String ?? "[Date]")",
            "Move-Out Inspection Date: \(formData["inspectionDate"] as? String ?? "[Date]")",
            "",
            "Tenant agrees to:",
            "- Return property in clean condition",
            "- Remove all personal belongings",
            "- Return all keys and access devices",
            "- Pay all utilities through move-out date",
            "",
            "MUTUAL RELEASE",
            "Both parties agree this terminates all obligations under the original lease.",
            "Neither party shall have further claims against the other except as stated herein.",
            "",
            "SIGNATURES",
            "",
            "_______________________  Date: __________",
            "Landlord Signature",
            "\(formData["landlordName"] as? String ?? "[Landlord Name]")",
            "",
            "_______________________  Date: __________",
            "Tenant Signature",
            "\(formData["tenantName"] as? String ?? "[Tenant Name]")"
        ]

        for section in sections {
            if yPosition > 700 {
                context.beginPage()
                yPosition = margin
            }

            if section.contains("AGREEMENT") || section == "PARTIES" ||
               section == "PROPERTY" || section == "ORIGINAL LEASE" ||
               section == "TERMINATION TERMS" || section == "FINANCIAL SETTLEMENT" ||
               section == "MOVE-OUT CONDITIONS" || section == "MUTUAL RELEASE" ||
               section == "SIGNATURES" {
                let boldAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
                ]
                section.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: boldAttributes)
            } else {
                section.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: attributes)
            }
            yPosition += section.isEmpty ? 10 : 18
        }
    }

    private func drawRepairRequest(context: UIGraphicsPDFRendererContext, formData: [String: Any], yPosition: inout CGFloat, pageWidth: CGFloat, margin: CGFloat, attributes: [NSAttributedString.Key: Any]) {
        let sections = [
            "REPAIR REQUEST FORM",
            "",
            "Request Date: \(formData["date"] as? String ?? "[Date]")",
            "Request Number: #\(formData["requestNumber"] as? String ?? "\(Int.random(in: 1000...9999))")",
            "",
            "TENANT INFORMATION",
            "Name: \(formData["tenantName"] as? String ?? "[Tenant Name]")",
            "Property Address: \(formData["propertyAddress"] as? String ?? "[Address]")",
            "Unit: \(formData["unit"] as? String ?? "[Unit #]")",
            "Phone: \(formData["phone"] as? String ?? "[Phone]")",
            "Email: \(formData["email"] as? String ?? "[Email]")",
            "Best Contact Time: \(formData["contactTime"] as? String ?? "[Morning/Afternoon/Evening]")",
            "",
            "REPAIR DETAILS",
            "Area/Room: \(formData["area"] as? String ?? "[Kitchen/Bathroom/Bedroom/Living Room/Other]")",
            "Item Needing Repair: \(formData["item"] as? String ?? "[Appliance/Plumbing/Electrical/HVAC/Other]")",
            "",
            "Problem Description:",
            "\(formData["description"] as? String ?? "[Detailed description of the problem]")",
            "",
            "URGENCY LEVEL",
            "[ ] Emergency (Safety hazard, no heat/water, severe leak)",
            "[ ] Urgent (Major inconvenience, requires prompt attention)",
            "[ ] Normal (Standard repair, can wait a few days)",
            "[ ] Low Priority (Cosmetic or minor issue)",
            "",
            "ADDITIONAL INFORMATION",
            "When did problem start? \(formData["problemStart"] as? String ?? "[Date/Time]")",
            "Has problem worsened? \(formData["worsened"] as? String ?? "[Yes/No]")",
            "Previous repairs to this item? \(formData["previousRepairs"] as? String ?? "[Yes/No]")",
            "",
            "ACCESS PERMISSION",
            "[ ] Permission granted to enter unit for repairs",
            "[ ] Tenant will be present during repair",
            "[ ] Contact tenant first to schedule: Phone _____________",
            "",
            "LANDLORD/PROPERTY MANAGER USE",
            "Date Received: _____________",
            "Assigned to: _____________",
            "Scheduled Date: _____________",
            "Completed Date: _____________",
            "Cost: $ _____________",
            "",
            "Notes: _______________________________________",
            "",
            "Tenant Signature: _______________________  Date: __________"
        ]

        for section in sections {
            if yPosition > 700 {
                context.beginPage()
                yPosition = margin
            }

            if section == "REPAIR REQUEST FORM" || section == "TENANT INFORMATION" ||
               section == "REPAIR DETAILS" || section == "URGENCY LEVEL" ||
               section == "ADDITIONAL INFORMATION" || section == "ACCESS PERMISSION" ||
               section.contains("LANDLORD") {
                let boldAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
                ]
                section.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: boldAttributes)
            } else {
                section.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: attributes)
            }
            yPosition += section.isEmpty ? 10 : 18
        }
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