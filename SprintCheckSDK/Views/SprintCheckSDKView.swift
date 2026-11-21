import SwiftUI

public struct SprintCheckSDKView: View {

    @StateObject private var viewModel = KYCVerificationViewModel()

    public init() {}

    public var body: some View {
        ZStack {
            Group {
                switch viewModel.currentStep {
                case .welcome:
                    WelcomeView(viewModel: viewModel)
                case .details, .validatingCredentials, .validationSuccessful:
                    VerificationDetailView(viewModel: viewModel)
                case .livenessInstructions:
                    LivenessInstructionsView(viewModel: viewModel)
                case .livenessCheck:
                    LivenessCheckView(viewModel: viewModel)
                case .scoreResult:
                    SuccessView(viewModel: viewModel)
                }
            }

            // Screen 8: Cancel Confirmation Dialog Popup Overlay
            if viewModel.showCancelDialog {
                CancelConfirmationDialogView(
                    onIgnore: {
                        viewModel.showCancelDialog = false
                    },
                    onCancel: {
                        viewModel.showCancelDialog = false
                        viewModel.cancelVerification()
                    }
                )
                .transition(.opacity)
            }
        }
    }
}
