import SwiftUI

public struct LivenessInstructionsView: View {

    @ObservedObject var viewModel: KYCVerificationViewModel

    public init(viewModel: KYCVerificationViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            HStack {
                Spacer()
                SprintCheckLogoView(size: .small)
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

                    // Geometric Face Wireframe Graphic
                    FaceWireframeView()
                        .frame(height: 180)

                    // Instructions Bullet Points
                    VStack(alignment: .leading, spacing: 18) {
                        BulletPointRow(text: "Please make sure your face matches your \(methodName) details so we can verify your identity.")
                        BulletPointRow(text: "This verification step helps us confirm it's really you. Do not share your code or authentication details with anyone, even if they claim to be from our team.")
                        BulletPointRow(text: "Stay in a bright lite environment")
                        BulletPointRow(text: "Remove eye glasses, hats, face mask, or any face coverings")
                    }
                    .padding(.horizontal, 24)

                    Spacer().frame(height: 10)
                }
            }

            // Bottom Action & Footer
            VStack(spacing: 12) {
                Button(action: {
                    viewModel.currentStep = .livenessCheck
                }) {
                    Text("Start face verification")
                        .font(.headline)
                        .bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.black)
                        .cornerRadius(8)
                }

                Text("Powered by SprintCheck")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Color.white.edgesIgnoringSafeArea(.all))
    }

    private var methodName: String {
        let type = KYCVerificationManager.shared.transactionType ?? .bvn
        return type.displayName.uppercased()
    }
}
