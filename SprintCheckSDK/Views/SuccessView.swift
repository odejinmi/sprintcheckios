import SwiftUI

public struct SuccessView: View {

    @ObservedObject var viewModel: KYCVerificationViewModel

    @State private var timeRemaining: Int = 10
    @State private var timer: Timer? = nil

    public init(viewModel: KYCVerificationViewModel) {
        self.viewModel = viewModel
    }

    public var isSuccess: Bool {
        return viewModel.errorMessage == nil && viewModel.verificationScore >= (Int(viewModel.confidenceLevel) ?? 70)
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            HStack {
                Button(action: {
                    timer?.invalidate()
                    viewModel.showCancelDialog = true
                }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black)
                }
                Spacer()
                SprintCheckLogoView(size: .small)
                Spacer()
                Button(action: {
                    timer?.invalidate()
                    viewModel.showCancelDialog = true
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Spacer().frame(height: 10)

                    Text("Verification Score")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.black)

                    // Gauge Speedometer Component
                    GaugeView(score: viewModel.verificationScore, isSuccess: isSuccess)

                    // Result Status Info
                    VStack(spacing: 6) {
                        Text(isSuccess ? "Verification Successful" : "Verification Failed")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)

                        Text(resultDetailMessage)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }

                    Spacer().frame(height: 10)
                }
            }

            // Bottom Auto-Close & Action Button
            VStack(spacing: 14) {
                Text("Closing in \(timeRemaining)")
                    .font(.footnote)
                    .bold()
                    .foregroundColor(.red)

                Button(action: {
                    timer?.invalidate()
                    if isSuccess {
                        viewModel.completeVerification()
                    } else {
                        viewModel.retryVerification()
                    }
                }) {
                    Text(isSuccess ? "Home" : "Try again")
                        .font(.headline)
                        .bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.black)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Color.white.edgesIgnoringSafeArea(.all))
        .onAppear {
            startCountdownTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private var resultDetailMessage: String {
        let method = KYCVerificationManager.shared.transactionType?.displayName.uppercased() ?? "ID"
        if isSuccess {
            return "\(method) Verified"
        } else {
            return viewModel.errorMessage ?? "Invalid \(method) Provided"
        }
    }

    private func startCountdownTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 1 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
                if isSuccess {
                    viewModel.completeVerification()
                } else {
                    viewModel.cancelVerification()
                }
            }
        }
    }
}
