import Foundation

public struct KYCConfig {
    public let apiKey: String
    public let encryptionKey: String

    public init(apiKey: String, encryptionKey: String) {
        self.apiKey = apiKey
        self.encryptionKey = encryptionKey
    }
}

public enum KYCInitializationResult {
    case success
    case failure(errorCode: String, errorMessage: String)
}
