import SwiftUI

public struct WelcomeView: View {

    @ObservedObject var viewModel: KYCVerificationViewModel

    public init(viewModel: KYCVerificationViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            HStack {
                Button(action: {
                    viewModel.showCancelDialog = true
                }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black)
                }
                Spacer()
                Button(action: {
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
                VStack(spacing: 28) {
                    Spacer().frame(height: 10)

                    SprintCheckLogoView(size: .large)

                    Text("This application uses SprintCheck\nto verify your identity")
                        .font(.system(size: 17, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)

                    VStack(alignment: .leading, spacing: 20) {
                        BulletPointRow(text: "All personal and login information is confidential. Our system uses end-to-end encryption to ensure secure verification.")
                        BulletPointRow(text: "This verification step helps us confirm it's really you. Do not share your code or authentication details with anyone, even if they claim to be from our team.")
                        BulletPointRow(text: "Your personal and account information is handled under strict security protocols")
                    }
                    .padding(.horizontal, 24)

                    Spacer().frame(height: 10)
                }
            }

            // Bottom Policy & Continue Button
            VStack(spacing: 16) {
                Text("By clicking \"Continue\" you agree to the\n[SprintCheck privacy policy](https://sprintcheck.com/privacy)")
                    .font(.caption2)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)

                Button(action: {
                    let manager = KYCVerificationManager.shared
                    if manager.transactionType == .facial {
                        viewModel.startFacialProcess()
                    } else {
                        viewModel.currentStep = .details
                    }
                }) {
                    Text("Continue")
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
    }
}

public struct BulletPointRow: View {
    let text: String

    public init(text: String) {
        self.text = text
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.black)
                .padding(.top, 2)

            Text(text)
                .font(.footnote)
                .foregroundColor(.black)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
