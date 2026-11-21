import Foundation
import UIKit
import SwiftUI

public class KYCVerificationManager: ObservableObject {

    public static let shared = KYCVerificationManager()

    private init() {}

    public var config: KYCConfig?
    public var transactionType: CheckoutMethod?
    public var identifier: String?
    public var reference: String?
    private weak var callback: KYCCallback?
    private var isInitialized: Bool = false

    public var baseUrl: String {
        return "https://api.sprintcheck.megasprintlimited.com.ng/api/sdk/"
    }

    public func initialize(config: KYCConfig) -> KYCInitializationResult {
        let validation = validateConfig(config)
        if let failure = validation {
            return failure
        }

        self.config = config
        self.isInitialized = true
        return .success
    }

    private func validateConfig(_ config: KYCConfig) -> KYCInitializationResult? {
        if config.apiKey.trimmingCharacters(in: .whitespaces).isEmpty {
            return .failure(errorCode: "INVALID_API_KEY", errorMessage: "API key cannot be empty")
        }
        if config.apiKey.count < 10 {
            return .failure(errorCode: "INVALID_API_KEY", errorMessage: "API key is too short")
        }
        if config.encryptionKey.trimmingCharacters(in: .whitespaces).isEmpty {
            return .failure(errorCode: "INVALID_ENCRYPTION_KEY", errorMessage: "Encryption key cannot be empty")
        }
        if config.encryptionKey.count < 16 {
            return .failure(errorCode: "INVALID_ENCRYPTION_KEY", errorMessage: "Encryption key must be at least 16 characters")
        }
        return nil
    }

    public func isSDKInitialized() -> Bool {
        return isInitialized && config != nil
    }

    public var prefilledNumber: String?

    @discardableResult
    public func startVerification(
        presentingViewController: UIViewController,
        type: CheckoutMethod,
        identifier: String,
        prefilledNumber: String? = nil,
        reference: String? = nil,
        callback: KYCCallback
    ) -> Bool {
        guard isSDKInitialized() else {
            callback.onKYCFailure(
                result: KYCResult.FailureResult(
                    errorCode: "SDK_NOT_INITIALIZED",
                    errorMessage: "KYC SDK is not initialized. Please call initialize() first."
                )
            )
            return false
        }

        self.transactionType = type
        self.identifier = identifier
        self.prefilledNumber = prefilledNumber
        self.reference = reference
        self.callback = callback

        let hostingController = UIHostingController(rootView: SprintCheckSDKView())
        hostingController.modalPresentationStyle = .fullScreen
        presentingViewController.present(hostingController, animated: true, completion: nil)
        return true
    }

    internal func reportResult(result: KYCResult) {
        Task { @MainActor in
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
                return
            }
            rootVC.dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                switch result {
                case .success(let successResult):
                    self.callback?.onKYCSuccess(result: successResult)
                case .failure(let failureResult):
                    self.callback?.onKYCFailure(result: failureResult)
                case .cancelled:
                    self.callback?.onKYCCancelled()
                }
                self.callback = nil
            }
        }
    }
}
