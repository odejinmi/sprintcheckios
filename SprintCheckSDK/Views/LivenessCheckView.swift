import SwiftUI

public struct LivenessCheckView: View {

    @ObservedObject var viewModel: KYCVerificationViewModel
    @State private var capturedImage: UIImage?

    public init(viewModel: KYCVerificationViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            // Camera feed
            CameraPreviewView(capturedImage: $capturedImage) { image in
                viewModel.matchFaces(capturedImage: image)
            }
            .edgesIgnoringSafeArea(.all)

            // Overlay Oval Face Guide
            VStack {
                // Header
                HStack {
                    Button(action: {
                        viewModel.restartVerification()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
                    }
                    Spacer()
                    Text(viewModel.faceTitle)
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Circle().fill(Color.clear).frame(width: 44, height: 44)
                }
                .padding(.horizontal)
                .padding(.top, 40)

                Spacer()

                // Oval Cutout Target
                ZStack {
                    Ellipse()
                        .stroke(Color.green, lineWidth: 4)
                        .frame(width: 250, height: 320)

                    Text("Center your face in the oval")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(8)
                        .offset(y: 180)
                }

                Spacer()

                // Capture Action Button
                VStack(spacing: 16) {
                    Button(action: {
                        NotificationCenter.default.post(name: Notification.Name("TriggerPhotoCapture"), object: nil)
                    }) {
                        ZStack {
                            Circle()
                                .stroke(Color.white, lineWidth: 4)
                                .frame(width: 72, height: 72)
                            Circle()
                                .fill(Color.green)
                                .frame(width: 60, height: 60)
                        }
                    }

                    Text("Tap to capture selfie")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.bottom, 40)
            }

            // Loading Overlay
            if viewModel.isProcessing {
                Color.black.opacity(0.7)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)

                    Text("Validating Face...")
                        .font(.headline)
                        .foregroundColor(.white)

                    Text("Please wait while we verify your details")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(32)
                .background(Color(UIColor.darkGray))
                .cornerRadius(16)
            }
        }
    }
}
