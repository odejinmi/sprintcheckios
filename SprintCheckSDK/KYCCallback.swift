import Foundation

public protocol KYCCallback: AnyObject {
    func onKYCSuccess(result: KYCResult.SuccessResult)
    func onKYCFailure(result: KYCResult.FailureResult)
    func onKYCCancelled()
}
