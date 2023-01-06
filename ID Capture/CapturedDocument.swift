//
//  CapturedDocument.swift
//  ID Capture
//
//  Created by Jakub Dolejs on 07/12/2022.
//

import Foundation
import VerIDCore
import DocumentVerificationClient
import Microblink

struct CapturedDocument {
    
    let faceCapture: FaceCapture
    var frontCapture: UIImage? = nil
    var backCapture: UIImage? = nil
    let authenticityScore: Float?
    let documentVerificationResult: DocumentVerificationResult?
    var documentNumber: String?
    var firstName: String?
    var lastName: String?
    var fullName: String?
    var address: String?
    var street: String?
    var city: String?
    var jurisdiction: String?
    var postCode: String?
    var country: String?
    var dateOfBirth: Date?
    var dateOfIssue: Date?
    var dateOfExpiry: Date?
    var frontBackMatchCheck: MBDataMatchDetailedInfo?
    
    init(scanResult: MBBlinkIdCombinedRecognizerResult, faceCapture: FaceCapture, authenticityScore: Float? = nil, documentVerificationResult: DocumentVerificationResult? = nil) {
        self.faceCapture = faceCapture
        self.frontCapture = scanResult.frontCameraFrame?.image
        self.backCapture = scanResult.backCameraFrame?.image
        self.authenticityScore = authenticityScore
        self.documentVerificationResult = documentVerificationResult
        self.documentNumber = scanResult.documentNumber
        self.firstName = scanResult.firstName
        self.lastName = scanResult.lastName
        self.fullName = scanResult.fullName
        self.address = scanResult.address
        self.street = scanResult.barcodeResult?.street
        self.city = scanResult.barcodeResult?.city
        self.jurisdiction = scanResult.barcodeResult?.jurisdiction
        self.postCode = scanResult.barcodeResult?.postalCode
        self.country = scanResult.classInfo?.countryName
        self.dateOfBirth = scanResult.dateOfBirth?.date
        self.dateOfIssue = scanResult.dateOfIssue?.date
        self.dateOfExpiry = scanResult.dateOfExpiry?.date
        self.frontBackMatchCheck = scanResult.dataMatchDetailedInfo
    }
    
    init(faceCapture: FaceCapture) {
        self.faceCapture = faceCapture
        self.authenticityScore = nil
        self.documentVerificationResult = nil
    }
    
    static let sample: CapturedDocument? = {
        do {
            guard let image = UIImage(named: "sample_card") else {
                return nil
            }
            let face = Face()
            face.bounds = CGRect(x: 110, y: 232, width: 107, height: 134)
            let recognizableFace = RecognizableFace(face: face, recognitionData: Data(), version: 5)
            var doc = CapturedDocument(faceCapture: try FaceCapture(face: recognizableFace, bearing: .straight, image: image))
            doc.firstName = "Jane"
            doc.lastName = "Doe"
            return doc
        } catch {
            return nil
        }
    }()
    
    let dateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        return formatter
    }()
    
    var textFields: [DocumentSection] {
        var sections = [DocumentSection]()
        var docSection = DocumentSection(title: "Document", fields: [])
        if let docNumber = self.documentNumber, !docNumber.isEmpty {
            docSection.fields.append(DocumentField(name: "Document number", value: docNumber))
        }
        if let doi = self.dateOfIssue {
            docSection.fields.append(DocumentField(name: "Date of issue", value: dateFormatter.string(from: doi)))
        }
        if let doe = self.dateOfExpiry {
            docSection.fields.append(DocumentField(name: "Date of expiry", value: dateFormatter.string(from: doe)))
        }
        if let authScore = self.authenticityScore {
            docSection.fields.append(DocumentField(name: "Authenticity score", value: String(format: "%.02f", authScore)))
        }
        if !docSection.fields.isEmpty {
            sections.append(docSection)
        }
        var holderSection = DocumentSection(title: "Document holder", fields: [])
        if let name = self.firstName, !name.isEmpty {
            holderSection.fields.append(DocumentField(name: "First name", value: name))
        }
        if let name = self.lastName, !name.isEmpty {
            holderSection.fields.append(DocumentField(name: "Last name", value: name))
        } else if let name = self.fullName, !name.isEmpty {
            holderSection.fields.append(DocumentField(name: "Name", value: name))
        }
        if let street = self.street, !street.isEmpty {
            holderSection.fields.append(DocumentField(name: "Street", value: street))
            if let city = self.city, !city.isEmpty {
                holderSection.fields.append(DocumentField(name: "City", value: city))
            }
            if let jurisdiction = self.jurisdiction, !jurisdiction.isEmpty {
                holderSection.fields.append(DocumentField(name: "Jurisdiction", value: jurisdiction))
            }
            if let postalCode = self.postCode, !postalCode.isEmpty {
                holderSection.fields.append(DocumentField(name: "Postal code", value: postalCode))
            }
        } else if let address = self.address, !address.isEmpty {
            holderSection.fields.append(DocumentField(name: "Address", value: address))
        }
        if let country = self.country, !country.isEmpty {
            holderSection.fields.append(DocumentField(name: "Country", value: country))
        }
        if let dob = self.dateOfBirth {
            holderSection.fields.append(DocumentField(name: "Date of birth", value: dateFormatter.string(from: dob)))
        }
        if !holderSection.fields.isEmpty {
            sections.append(holderSection)
        }
        if let frontBackMatchCheck = self.frontBackMatchCheck, frontBackMatchCheck.getDataMatchResult() != .notPerformed {
            var dataMatchSection = DocumentSection(title: "Data match checks", fields: [])
            dataMatchSection.fields.append(DocumentField(name: "Data match check", dataMatchResult: frontBackMatchCheck.getDataMatchResult()))
            dataMatchSection.fields.append(DocumentField(name: "Document number check", dataMatchResult: frontBackMatchCheck.getDocumentNumber()))
            dataMatchSection.fields.append(DocumentField(name: "Date of birth check", dataMatchResult: frontBackMatchCheck.getDateOfBirth()))
            dataMatchSection.fields.append(DocumentField(name: "Date of expiry check", dataMatchResult: frontBackMatchCheck.getDateOfExpiry()))
            sections.append(dataMatchSection)
        }
        if let docVerResult: DocumentVerificationResult = self.documentVerificationResult {
            if let fraudCheck: DocumentVerificationClient.OverallFraudCheck = docVerResult.overallFraudCheck, fraudCheck.result != .notPerformed {
                var verificationSection = DocumentSection(title: "Fraud checks", fields: [])
                verificationSection.fields.append(DocumentField(name: "Overall fraud check", checkResult: fraudCheck.result))
                verificationSection.fields.append(DocumentField(name: "Score", value: String(format: "%.02f", fraudCheck.score)))
                verificationSection.fields.append(DocumentField(name: "Checks performed", value: String(format: "%d/%d", fraudCheck.performedChecks, fraudCheck.totalChecks)))
                verificationSection.fields.append(DocumentField(name: "Checks passed", value: String(format: "%d", fraudCheck.passedChecks)))
                sections.append(verificationSection)
            }
            if let dataCheck: DataCheck = docVerResult.dataCheck {
                var dataCheckSection = DocumentSection(title: "Data checks", fields: [])
                if let overallCheck = dataCheck.overall, overallCheck.result != .notPerformed {
                    dataCheckSection.fields.append(DocumentField(name: "Overall check", detailedCheckResult: overallCheck))
                }
                if let barcodeAnomalyCheck = dataCheck.barcodeAnomalyCheck?.overall, barcodeAnomalyCheck.result != .notPerformed {
                    dataCheckSection.fields.append(DocumentField(name: "Barcode anomaly check", detailedCheckResult: barcodeAnomalyCheck))
                }
                if let simpleStringCheck = dataCheck.sampleStringCheck, simpleStringCheck.result != .notPerformed {
                    dataCheckSection.fields.append(DocumentField(name: "Simple string check", detailedCheckResult: simpleStringCheck))
                }
                if !dataCheckSection.fields.isEmpty {
                    sections.append(dataCheckSection)
                }
                if let formatCheck = dataCheck.formatCheck {
                    var formatCheckSection = DocumentSection(title: "Format checks", fields: [])
                    if let overall = formatCheck.overall, overall.result != .notPerformed {
                        formatCheckSection.fields.append(DocumentField(name: "Overall format check", detailedCheckResult: overall))
                    }
                    if let dobCheck = formatCheck.dateOfBirthCheck?.check, dobCheck.result != .notPerformed {
                        formatCheckSection.fields.append(DocumentField(name: "Date of birth check", detailedCheckResult: dobCheck))
                    }
                    if let doeCheck = formatCheck.dateOfExpiryCheck?.check, doeCheck.result != .notPerformed {
                        formatCheckSection.fields.append(DocumentField(name: "Date of expiry check", detailedCheckResult: doeCheck))
                    }
                    if let doiCheck = formatCheck.dateOfIssueCheck?.check, doiCheck.result != .notPerformed {
                        formatCheckSection.fields.append(DocumentField(name: "Date of issue check", detailedCheckResult: doiCheck))
                    }
                    if let docNumberCheck = formatCheck.documentNumberCheck?.check, docNumberCheck.result != .notPerformed {
                        formatCheckSection.fields.append(DocumentField(name: "Document number check", detailedCheckResult: docNumberCheck))
                    }
                    if let genderCheck = formatCheck.genderCheck?.check, genderCheck.result != .notPerformed {
                        formatCheckSection.fields.append(DocumentField(name: "Gender check", detailedCheckResult: genderCheck))
                    }
                    if let issuingAuthorityCheck = formatCheck.issuingAuthorityCheck?.check, issuingAuthorityCheck.result != .notPerformed {
                        formatCheckSection.fields.append(DocumentField(name: "Issuing authority check", detailedCheckResult: issuingAuthorityCheck))
                    }
                    if let nationalityCheck = formatCheck.nationalityCheck?.check, nationalityCheck.result != .notPerformed {
                        formatCheckSection.fields.append(DocumentField(name: "Nationality check", detailedCheckResult: nationalityCheck))
                    }
                    if !formatCheckSection.fields.isEmpty {
                        sections.append(formatCheckSection)
                    }
                }
                if let logicCheck = dataCheck.logicCheck {
                    var logicCheckSection = DocumentSection(title: "Logic checks", fields: [])
                    if let overall = logicCheck.overall, overall.result != .notPerformed {
                        logicCheckSection.fields.append(DocumentField(name: "Overall logic check", detailedCheckResult: overall))
                    }
                    if let checkDigitCheck = logicCheck.checkDigitCheck?.mrz, checkDigitCheck.result != .notPerformed {
                        logicCheckSection.fields.append(DocumentField(name: "Check digit check", detailedCheckResult: checkDigitCheck))
                    }
                    if !logicCheckSection.fields.isEmpty {
                        sections.append(logicCheckSection)
                    }
                    if let dateLogicCheck = logicCheck.dateLogicCheck {
                        var dateLogicCheckSection = DocumentSection(title: "Date logic checks", fields: [])
                        if dateLogicCheck.overall != .notPerformed {
                            dateLogicCheckSection.fields.append(DocumentField(name: "Overall", checkResult: dateLogicCheck.overall))
                        }
                        if dateLogicCheck.dateOfBirthBeforeDateOfExpiryCheck != .notPerformed {
                            dateLogicCheckSection.fields.append(DocumentField(name: "Birth before expiry", checkResult: dateLogicCheck.dateOfBirthBeforeDateOfExpiryCheck))
                        }
                        if dateLogicCheck.dateOfBirthInPastCheck != .notPerformed {
                            dateLogicCheckSection.fields.append(DocumentField(name: "Birth in the past", checkResult: dateLogicCheck.dateOfBirthInPastCheck))
                        }
                        if dateLogicCheck.dateOfBirthBeforeDateOfIssueCheck != .notPerformed {
                            dateLogicCheckSection.fields.append(DocumentField(name: "Birth before issue", checkResult: dateLogicCheck.dateOfBirthBeforeDateOfIssueCheck))
                        }
                        if dateLogicCheck.dateOfIssueInPastCheck != .notPerformed {
                            dateLogicCheckSection.fields.append(DocumentField(name: "Issue in the past", checkResult: dateLogicCheck.dateOfIssueInPastCheck))
                        }
                        if dateLogicCheck.dateOfIssueBeforeDateOfExpiryCheck != .notPerformed {
                            dateLogicCheckSection.fields.append(DocumentField(name: "Issue before expiry", checkResult: dateLogicCheck.dateOfIssueBeforeDateOfExpiryCheck))
                        }
                        if dateLogicCheck.dateOfExpiryInFutureCheck != .notPerformed {
                            dateLogicCheckSection.fields.append(DocumentField(name: "Expiry in future", checkResult: dateLogicCheck.dateOfExpiryInFutureCheck))
                        }
                        if !dateLogicCheckSection.fields.isEmpty {
                            sections.append(dateLogicCheckSection)
                        }
                    }
                }
                if let matchCheck = dataCheck.matchCheck {
                    var matchCheckSection = DocumentSection(title: "Match checks", fields: [])
                    if let overall = matchCheck.overall, overall.result != .notPerformed {
                        matchCheckSection.fields.append(DocumentField(name: "Overall match check", detailedCheckResult: overall))
                    }
                    if let documentNumberMatch = matchCheck.documentNumberMatch?.check, documentNumberMatch.result != .notPerformed {
                        matchCheckSection.fields.append(DocumentField(name: "Document number match", detailedCheckResult: documentNumberMatch))
                    }
                    if let issuingAuthorityMatch = matchCheck.issuingAuthorityMatch?.check, issuingAuthorityMatch.result != .notPerformed {
                        matchCheckSection.fields.append(DocumentField(name: "Issuing authority match", detailedCheckResult: issuingAuthorityMatch))
                    }
                    if let fathersNameMatch = matchCheck.fathersNameMatch?.check, fathersNameMatch.result != .notPerformed {
                        matchCheckSection.fields.append(DocumentField(name: "Father's name match", detailedCheckResult: fathersNameMatch))
                    }
                    if let mothersNameMatch = matchCheck.mothersNameMatch?.check, mothersNameMatch.result != .notPerformed {
                        matchCheckSection.fields.append(DocumentField(name: "Mothers name match", detailedCheckResult: mothersNameMatch))
                    }
                    if let fullNameMatch = matchCheck.fullNameMatch?.check, fullNameMatch.result != .notPerformed {
                        matchCheckSection.fields.append(DocumentField(name: "Full name match", detailedCheckResult: fullNameMatch))
                    }
                    if let firstNameMatch = matchCheck.firstNameMatch?.check, firstNameMatch.result != .notPerformed {
                        matchCheckSection.fields.append(DocumentField(name: "First name match", detailedCheckResult: firstNameMatch))
                    }
                    if let lastNameMatch = matchCheck.lastNameMatch?.check, lastNameMatch.result != .notPerformed {
                        matchCheckSection.fields.append(DocumentField(name: "Last name match", detailedCheckResult: lastNameMatch))
                    }
                    if let localizedNameMatch = matchCheck.localizedNameMatch?.check, localizedNameMatch.result != .notPerformed {
                        matchCheckSection.fields.append(DocumentField(name: "Localized name match", detailedCheckResult: localizedNameMatch))
                    }
                    if let nationalityMatch = matchCheck.nationalityMatch?.check, nationalityMatch.result != .notPerformed {
                        matchCheckSection.fields.append(DocumentField(name: "Nationality match", detailedCheckResult: nationalityMatch))
                    }
                    if let personalIdNumberMatch = matchCheck.personalIdNumberMatch?.check, personalIdNumberMatch.result != .notPerformed {
                        matchCheckSection.fields.append(DocumentField(name: "Personal ID number match", detailedCheckResult: personalIdNumberMatch))
                    }
                    if let placeOfBirthMatch = matchCheck.placeOfBirthMatch?.check, placeOfBirthMatch.result != .notPerformed {
                        matchCheckSection.fields.append(DocumentField(name: "Place of birth match", detailedCheckResult: placeOfBirthMatch))
                    }
                    if let sexMatch = matchCheck.sexMatch?.check, sexMatch.result != .notPerformed {
                        matchCheckSection.fields.append(DocumentField(name: "Sex match", detailedCheckResult: sexMatch))
                    }
                    if let addressMatch = matchCheck.addressMatch?.check, addressMatch.result != .notPerformed {
                        matchCheckSection.fields.append(DocumentField(name: "Address Match", detailedCheckResult: addressMatch))
                    }
                    if let dateOfBirthMatch = matchCheck.dateOfBirthMatch?.check, dateOfBirthMatch.result != .notPerformed {
                        matchCheckSection.fields.append(DocumentField(name: "Date of birth match", detailedCheckResult: dateOfBirthMatch))
                    }
                    if let dateOfIssueMatch = matchCheck.dateOfIssueMatch?.check, dateOfIssueMatch.result != .notPerformed {
                        matchCheckSection.fields.append(DocumentField(name: "Date of issue match", detailedCheckResult: dateOfIssueMatch))
                    }
                    if let dateOfExpiryMatch = matchCheck.dateOfExpiryMatch?.check, dateOfExpiryMatch.result != .notPerformed {
                        matchCheckSection.fields.append(DocumentField(name: "Date of expiry match", detailedCheckResult: dateOfExpiryMatch))
                    }
                    if let additionalNameInformationMatch = matchCheck.additionalNameInformationMatch?.check, additionalNameInformationMatch.result != .notPerformed {
                        matchCheckSection.fields.append(DocumentField(name: "Additional name information match", detailedCheckResult: additionalNameInformationMatch))
                    }
                    if let additionalAddressInformationMatch = matchCheck.additionalAddressInformationMatch?.check, additionalAddressInformationMatch.result != .notPerformed {
                        matchCheckSection.fields.append(DocumentField(name: "Additional address information match", detailedCheckResult: additionalAddressInformationMatch))
                    }
                    if let additionalPersonalIdNumberMatch = matchCheck.additionalPersonalIdNumberMatch?.check, additionalPersonalIdNumberMatch.result != .notPerformed {
                        matchCheckSection.fields.append(DocumentField(name: "Additional personal ID number match", detailedCheckResult: additionalPersonalIdNumberMatch))
                    }
                    if let documentAdditionalNumberMatch = matchCheck.documentAdditionalNumberMatch?.check, documentAdditionalNumberMatch.result != .notPerformed {
                        matchCheckSection.fields.append(DocumentField(name: "Document additional number match", detailedCheckResult: documentAdditionalNumberMatch))
                    }
                    if let documentOptionalAdditionalNumberMatch = matchCheck.documentOptionalAdditionalNumberMatch?.check, documentOptionalAdditionalNumberMatch.result != .notPerformed {
                        matchCheckSection.fields.append(DocumentField(name: "Document optional additional number match", detailedCheckResult: documentOptionalAdditionalNumberMatch))
                    }
                    if let additionalOptionalAddressInformationMatch = matchCheck.additionalOptionalAddressInformationMatch?.check, additionalOptionalAddressInformationMatch.result != .notPerformed {
                        matchCheckSection.fields.append(DocumentField(name: "Additional optional address information match", detailedCheckResult: additionalOptionalAddressInformationMatch))
                    }
                    if !matchCheckSection.fields.isEmpty {
                        sections.append(matchCheckSection)
                    }
                }
            }
            if let docLivenessCheck: DocumentVerificationClient.DocumentLivenessCheck = docVerResult.documentLivenessCheck {
                var docLivenessSection = DocumentSection(title: "Document liveness checks", fields: [])
                if docLivenessCheck.overall != .notPerformed {
                    docLivenessSection.fields.append(DocumentField(name: "Overall", checkResult: docLivenessCheck.overall))
                }
                if docLivenessCheck.handPresenceCheck != .notPerformed {
                    docLivenessSection.fields.append(DocumentField(name: "Hand presence", checkResult: docLivenessCheck.handPresenceCheck))
                }
                if let photocopyCheck = docLivenessCheck.photocopyCheck, photocopyCheck.result != .notPerformed {
                    docLivenessSection.fields.append(DocumentField(name: "Photo copy", tieredCheckResult: photocopyCheck))
                }
                if let screenCheck = docLivenessCheck.screenCheck, screenCheck.result != .notPerformed {
                    docLivenessSection.fields.append(DocumentField(name: "Screen", tieredCheckResult: screenCheck))
                }
                if !docLivenessSection.fields.isEmpty {
                    sections.append(docLivenessSection)
                }
            }
            if let docValidityCheck: DocumentVerificationClient.DocumentValidityCheck = docVerResult.documentValidityCheck, docValidityCheck.expiredCheck != .notPerformed {
                sections.append(DocumentSection(title: "Document validity checks", fields: [
                    DocumentField(name: "Document expiration check", checkResult: docValidityCheck.expiredCheck)
                ]))
            }
            if let imageQualityCheck: DocumentVerificationClient.ImageQualityCheck = docVerResult.imageQualityCheck, imageQualityCheck.blurCheck != .notPerformed {
                sections.append(DocumentSection(title: "Image quality checks", fields: [
                    DocumentField(name: "Blur check", checkResult: imageQualityCheck.blurCheck)
                ]))
            }
            if let visualCheck: DocumentVerificationClient.VisualCheck = docVerResult.visualCheck {
                var visualCheckSection = DocumentSection(title: "Visual checks", fields: [])
                if visualCheck.overall != .notPerformed {
                    visualCheckSection.fields.append(DocumentField(name: "Overall", checkResult: visualCheck.overall))
                }
                if let anomalyCheck = visualCheck.anomalyCheck, anomalyCheck.result != .notPerformed {
                    visualCheckSection.fields.append(DocumentField(name: "Anomaly check", checkResult: anomalyCheck.result))
                    if let image = anomalyCheck.heatmapImage {
                        visualCheckSection.fields.append(DocumentField(name: "Heatmap", image: image))
                    }
                }
                if visualCheck.backgroundCheck != .notPerformed {
                    visualCheckSection.fields.append(DocumentField(name: "Background check", checkResult: visualCheck.backgroundCheck))
                }
                if visualCheck.fontCheck != .notPerformed {
                    visualCheckSection.fields.append(DocumentField(name: "Font check", checkResult: visualCheck.fontCheck))
                }
                if visualCheck.layoutCheck != .notPerformed {
                    visualCheckSection.fields.append(DocumentField(name: "Layout check", checkResult: visualCheck.layoutCheck))
                }
                if visualCheck.photoForgeryCheck != .notPerformed {
                    visualCheckSection.fields.append(DocumentField(name: "Photo forgery check", checkResult: visualCheck.photoForgeryCheck))
                }
                if !visualCheckSection.fields.isEmpty {
                    sections.append(visualCheckSection)
                }
                if let securityFeatures = visualCheck.securityFeatures, (securityFeatures.processingStatus != .notPerformed && securityFeatures.processingStatus != .unsupportedByLicense) {
                    var securityFeaturesSection = DocumentSection(title: "Security features", fields: [
                        DocumentField(name: "Processing status", value: securityFeatures.processingStatus == .performed ? "Check performed" : "Document not supported")
                    ])
                    if securityFeatures.processingStatus == .performed {
                        securityFeaturesSection.fields.append(DocumentField(name: "Score", value: String(format: "%.02f", securityFeatures.score)))
                        if let image = securityFeatures.fullDocumentImage, let segments = securityFeatures.segmentResult {
                            for segment in segments {
                                securityFeaturesSection.fields.append(DocumentField(segmentResult: segment, image: image))
                            }
                        }
                    }
                    sections.append(securityFeaturesSection)
                }
            }
        }
        return sections
    }
}

struct DocumentSection: Identifiable {
    
    let id = UUID()
    let title: String
    var fields: [DocumentField]
}

struct DocumentField: Identifiable {
    
    let id = UUID()
    let name: String
    var value: String?
    var image: UIImage?
    
    let passImage: UIImage? = UIImage(systemName: "checkmark.circle")
    let failImage: UIImage? = UIImage(systemName: "x.circle")
    
    init(name: String, value: String) {
        self.name = name
        self.value = value
    }
    
    init(name: String, checkResult: CheckResult) {
        self.name = name
        self.value = DocumentField.stringFromCheckResult(checkResult)
    }
    
    init(name: String, detailedCheckResult: DetailedCheck) {
        self.name = name
        if detailedCheckResult.result == .notPerformed {
            self.value = "Not performed"
        } else {
            var val = detailedCheckResult.result == .pass ? "Passed" : "Failed"
            switch detailedCheckResult.certaintyLevel {
            case .high:
                val += " (high certainty)"
            case .medium:
                val += " (medium certainty)"
            case .low:
                val += " (low certainty)"
            default:
                break
            }
            self.value = val
        }
    }
    
    init(name: String, tieredCheckResult: TieredCheck) {
        self.name = name
        if tieredCheckResult.result == .notPerformed {
            self.value = "Not performed"
        }
        self.value = tieredCheckResult.result == .pass ? "Passed" : "Failed"
        if tieredCheckResult.matchLevel != .levelDisabled {
            self.value! += " (level \(tieredCheckResult.matchLevel.rawValue))"
        }
    }
    
    init(segmentResult: SegmentResult, image: UIImage) {
        self.name = DocumentField.stringFromCheckResult(segmentResult.checkResult)
        let scaleTransform = CGAffineTransform(scaleX: image.size.width, y: image.size.height)
        let rect = segmentResult.rectangle.applying(scaleTransform)
        UIGraphicsBeginImageContext(rect.size)
        defer {
            UIGraphicsEndImageContext()
        }
        image.draw(at: CGPoint(x: 0-rect.minX, y: 0-rect.minY))
        self.image = UIGraphicsGetImageFromCurrentImageContext()
    }
    
    init(name: String, image: UIImage) {
        self.name = name
        self.image = image
    }
    
    init(name: String, dataMatchResult: MBDataMatchResult) {
        self.name = name
        switch dataMatchResult {
        case .success:
            self.value = "Passed"
        case .failed:
            self.value = "Failed"
        default:
            self.value = "N/A"
        }
    }
    
    static func stringFromCheckResult(_ checkResult: CheckResult) -> String {
        switch checkResult {
        case .pass:
            return "Passed"
        case .fail:
            return "Failed"
        default:
            return "N/A"
        }
    }
    
    func imageFromCheckResult(_ checkResult: CheckResult) -> UIImage? {
        switch checkResult {
        case .pass:
            return passImage
        case .fail:
            return failImage
        default:
            return nil
        }
    }
}

extension CertaintyLevel {
    
    var stringValue: String {
        switch self {
        case .high:
            return "High"
        case .medium:
            return "Medium"
        case .low:
            return "Low"
        case .notPerformed:
            return "Not performed"
        @unknown default:
            return "Unknown"
        }
    }
}
