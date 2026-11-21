import Foundation

public enum KYCResult {
    case success(SuccessResult)
    case failure(FailureResult)
    case cancelled

    public struct SuccessResult {
        public let message: String
        public let reference: String
        public let name: String
        public let bvn: String
        public let nin: String
        public let confidenceLevel: Int
        public let status: Bool
        public let verify: Bool
        public let method: CheckoutMethod?

        public init(
            message: String,
            reference: String,
            name: String,
            bvn: String,
            nin: String,
            confidenceLevel: Int,
            status: Bool,
            verify: Bool,
            method: CheckoutMethod?
        ) {
            self.message = message
            self.reference = reference
            self.name = name
            self.bvn = bvn
            self.nin = nin
            self.confidenceLevel = confidenceLevel
            self.status = status
            self.verify = verify
            self.method = method
        }
    }

    public struct FailureResult {
        public let errorCode: String
        public let errorMessage: String
        public let confidenceLevel: Int

        public init(errorCode: String, errorMessage: String, confidenceLevel: Int = 0) {
            self.errorCode = errorCode
            self.errorMessage = errorMessage
            self.confidenceLevel = confidenceLevel
        }
    }
}
