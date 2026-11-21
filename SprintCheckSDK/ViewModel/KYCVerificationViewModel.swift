import Foundation
import UIKit
import Combine
import ImageIO

public enum VerificationStep {
    case welcome
    case details
    case validatingCredentials
    case validationSuccessful
    case livenessInstructions
    case livenessCheck
    case scoreResult
}

@MainActor
public class KYCVerificationViewModel: ObservableObject {

    @Published public var currentStep: VerificationStep = .welcome
    @Published public var verificationResult: KYCResult?
    @Published public var verificationScore: Int = 0
    @Published public var bvnImage: UIImage?
    @Published public var faceTitle: String = "Face Verification"
    @Published public var isProcessing: Bool = false
    @Published public var errorMessage: String?
    @Published public var showCancelDialog: Bool = false

    public var bvn: String = ""
    public var reference: String = ""
    public var confidenceLevel: String = "70"
    public var enrollmentData: String = ""

    public init() {
        let manager = KYCVerificationManager.shared
        if manager.transactionType == .facial {
            self.currentStep = .welcome
        } else if let prefilled = manager.prefilledNumber, !prefilled.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let cleanNumber = prefilled.trimmingCharacters(in: .whitespacesAndNewlines)
            self.bvn = cleanNumber
            self.startVerificationProcess(bvn: cleanNumber)
        } else {
            self.currentStep = .welcome
        }
    }

    public func startVerificationProcess(bvn: String) {
        let manager = KYCVerificationManager.shared
        self.bvn = bvn
        self.currentStep = .validatingCredentials
        self.isProcessing = true
        self.errorMessage = nil

        Task {
            let params: [String: String?] = [
                "number": bvn,
                "identifier": manager.identifier,
                "reference": manager.reference,
            ]

            let urlString = manager.baseUrl + (manager.transactionType?.rawValue ?? "bvn")

            do {
                let jsonObject = try await HttpJsonParser.shared.makeRequest(
                    urlString: urlString,
                    method: "POST",
                    params: params,
                    apiKey: manager.config?.apiKey,
                    encryptionKey: manager.config?.encryptionKey
                )

                self.isProcessing = false

                guard let json = jsonObject,
                      let success = json["success"] as? Int, success == 1,
                      let data = json["data"] as? [String: Any] else {
                    let serverMsg = jsonObject?["message"] as? String ?? "Invalid \(manager.transactionType?.displayName.uppercased() ?? "ID") Provided"
                    self.errorMessage = serverMsg
                    self.verificationScore = 0
                    self.currentStep = .scoreResult
                    return
                }

                if let imageStr = data["image"] as? String {
                    if isUrl(imageStr) {
                        if let fetchedImage = await urlToImage(imageStr) {
                            self.bvnImage = fetchedImage
                        }
                    } else {
                        if let decodedImage = base64ToImage(imageStr) {
                            self.bvnImage = decodedImage
                        }
                    }
                }

                if let ref = data["reference"] as? String {
                    self.reference = ref
                }

                if let conf = json["confidence_level"] {
                    self.confidenceLevel = "\(conf)"
                }

//                self.currentStep = .validationSuccessful
                self.currentStep = .livenessInstructions

            } catch {
                self.isProcessing = false
                self.errorMessage = error.localizedDescription
                self.verificationScore = 0
                self.currentStep = .scoreResult
            }
        }
    }
    public func startFacialProcess() {
        let manager = KYCVerificationManager.shared
        self.currentStep = .validatingCredentials
        self.isProcessing = true
        self.errorMessage = nil

        Task {
            let params: [String: String?] = [
                "identifier": manager.identifier,
                "reference": manager.reference,
            ]

            let urlString = manager.baseUrl + (manager.transactionType?.rawValue ?? "bvn")

            do {
                let jsonObject = try await HttpJsonParser.shared.makeRequest(
                    urlString: urlString,
                    method: "POST",
                    params: params,
                    apiKey: manager.config?.apiKey,
                    encryptionKey: manager.config?.encryptionKey
                )

                self.isProcessing = false

                guard let json = jsonObject,
                      let success = json["success"] as? Int, success == 1,
                      let data = json["data"] as? [String: Any] else {
                    let serverMsg = jsonObject?["message"] as? String ?? "Invalid \(manager.transactionType?.displayName.uppercased() ?? "ID") Provided"
                    self.errorMessage = serverMsg
                    self.verificationScore = 0
                    self.currentStep = .scoreResult
                    return
                }

                if let imageStr = data["image"] as? String {
                    if isUrl(imageStr) {
                        if let fetchedImage = await urlToImage(imageStr) {
                            self.bvnImage = fetchedImage
                        }
                    } else {
                        if let decodedImage = base64ToImage(imageStr) {
                            self.bvnImage = decodedImage
                        }
                    }
                }

                if let ref = data["reference"] as? String {
                    self.reference = ref
                }

                if let conf = json["confidence_level"] {
                    self.confidenceLevel = "\(conf)"
                }

                self.currentStep = .livenessInstructions

            } catch {
                self.isProcessing = false
                self.errorMessage = error.localizedDescription
                self.verificationScore = 0
                self.currentStep = .scoreResult
            }
        }
    }

    public func matchFaces(capturedImage: UIImage) {
        guard let refImage = bvnImage else {
            processLivenessCheck(score: 85, capturedImage: capturedImage)
            return
        }

        self.isProcessing = true
        Task {
            let similarity = await FaceMatcher.shared.matchFaces(firstImage: capturedImage, secondImage: refImage)
            self.processLivenessCheck(score: similarity, capturedImage: capturedImage)
        }
    }

    public func processLivenessCheck(score: Int, capturedImage: UIImage) {
        self.isProcessing = true
        self.verificationScore = score

        Task {
            let base64Image = imageToBase64(capturedImage) ?? ""
            let manager = KYCVerificationManager.shared

            let params: [String: String?] = [
                "number": bvn,
                "reference": reference,
                "confidence": "\(score)",
                "identifier": manager.identifier,
                "image": base64Image
            ]

            let urlString = manager.baseUrl + (manager.transactionType?.rawValue ?? "bvn")

            do {
                let jsonObject = try await HttpJsonParser.shared.makeRequest(
                    urlString: urlString,
                    method: "PUT",
                    params: params,
                    apiKey: manager.config?.apiKey,
                    encryptionKey: manager.config?.encryptionKey
                )

                self.isProcessing = false

                guard let json = jsonObject,
                      let success = json["success"] as? Int, success == 1 else {
                    let serverMsg = jsonObject?["message"] as? String ?? "Verification Failed"
                    self.errorMessage = serverMsg
                    self.currentStep = .scoreResult
                    return
                }

                if let dataStr = json["data"] as? String {
                    self.enrollmentData = dataStr
                }

                let targetConf = Int(self.confidenceLevel) ?? 70
                if score >= targetConf {
                    self.errorMessage = nil
                } else {
                    self.errorMessage = "Face similarity below threshold (\(score)%)"
                }
                self.currentStep = .scoreResult

            } catch {
                self.isProcessing = false
                self.errorMessage = error.localizedDescription
                self.currentStep = .scoreResult
            }
        }
    }

    public func retryVerification() {
        let manager = KYCVerificationManager.shared
        if manager.transactionType == .facial {
            self.currentStep = .livenessInstructions
        } else {
            self.currentStep = .details
        }
    }

    public func restartVerification() {
        self.currentStep = .details
    }

    public func completeVerification() {
        let manager = KYCVerificationManager.shared
        let success = KYCResult.SuccessResult(
            message: "Verification Completed",
            reference: reference,
            name: enrollmentData,
            bvn: manager.transactionType == .bvn ? bvn : "",
            nin: manager.transactionType == .nin ? bvn : "",
            confidenceLevel: verificationScore,
            status: verificationScore > 0,
            verify: true,
            method: manager.transactionType
        )
        self.verificationResult = .success(success)
        manager.reportResult(result: .success(success))
    }

    public func cancelVerification() {
        let manager = KYCVerificationManager.shared
        self.verificationResult = .cancelled
        manager.reportResult(result: .cancelled)
    }

    // MARK: - Helpers
    private func isUrl(_ str: String) -> Bool {
        return str.hasPrefix("http://") || str.hasPrefix("https://")
    }

    private func urlToImage(_ urlString: String) async -> UIImage? {
        guard let url = URL(string: urlString) else { return nil }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                return nil
            }
            return imageFromData(data)
        } catch {
            print("❌ [SprintCheck Image Download Error]: \(error.localizedDescription)")
            return nil
        }
    }

    private func base64ToImage(_ base64String: String) -> UIImage? {
        var cleaned = base64String.trimmingCharacters(in: .whitespacesAndNewlines)
        if let commaIndex = cleaned.firstIndex(of: ",") {
            cleaned = String(cleaned[cleaned.index(after: commaIndex)...])
        }
        cleaned = cleaned.replacingOccurrences(of: "\r", with: "")
                         .replacingOccurrences(of: "\n", with: "")
                         .replacingOccurrences(of: " ", with: "")

        guard let data = Data(base64Encoded: cleaned, options: .ignoreUnknownCharacters),
              !data.isEmpty else {
            return nil
        }
        return imageFromData(data)
    }

    private func imageFromData(_ data: Data) -> UIImage? {
        guard !data.isEmpty else { return nil }

        let options: [CFString: Any] = [
            kCGImageSourceShouldCache: false,
            kCGImageSourceShouldAllowFloat: true
        ]

        guard let source = CGImageSourceCreateWithData(data as CFData, options as CFDictionary) else {
            return UIImage(data: data)
        }

        let decodeOptions: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: 1024
        ]

        if let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, decodeOptions as CFDictionary) {
            return UIImage(cgImage: cgImage)
        }

        if let cgImage = CGImageSourceCreateImageAtIndex(source, 0, options as CFDictionary) {
            return UIImage(cgImage: cgImage)
        }

        return UIImage(data: data)
    }

    private func imageToBase64(_ image: UIImage) -> String? {
        let renderer = UIGraphicsImageRenderer(size: image.size, format: {
            let format = UIGraphicsImageRendererFormat()
            format.opaque = true
            format.scale = image.scale
            return format
        }())
        let opaqueImage = renderer.image { _ in
            UIColor.white.setFill()
            UIRectFill(CGRect(origin: .zero, size: image.size))
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
        guard let imageData = opaqueImage.jpegData(compressionQuality: 0.8) else { return nil }
        return imageData.base64EncodedString()
    }
}
