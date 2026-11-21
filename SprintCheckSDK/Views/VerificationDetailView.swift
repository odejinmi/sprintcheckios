import SwiftUI

public struct VerificationDetailView: View {

    @ObservedObject var viewModel: KYCVerificationViewModel
    @State private var inputNumber: String = ""

    public var methodDisplayName: String {
        let type = KYCVerificationManager.shared.transactionType ?? .bvn
        switch type {
        case .bvn: return "Bank Verification Number\n(BVN)"
        case .nin: return "National Identity Number\n(NIN)"
        case .facial: return "Face Verification"
        case .documentreader: return "Document Reader"
        case .selectable: return "Identity Verification"
        }
    }

    public var inputPlaceholder: String {
        let type = KYCVerificationManager.shared.transactionType ?? .bvn
        return "Enter your \(type.rawValue.lowercased())"
    }

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

            if viewModel.currentStep == .validatingCredentials {
                // Screen 3: Validating Credentials (Loading)
                Spacer()

                VStack(spacing: 16) {
                    SprintCheckLogoView(size: .large)
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    Text("Validating Credentials...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: {}) {
                    Text("Continue")
                        .font(.headline)
                        .bold()
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(8)
                }
                .disabled(true)
                .padding(.horizontal, 24)

                Text("Powered by SprintCheck")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
                    .padding(.bottom, 24)

            } else if viewModel.currentStep == .validationSuccessful {
                // Screen 4: Validation Successful
                Spacer()

                VStack(spacing: 16) {
                    SprintCheckLogoView(size: .large)
                    Text("Validation Successful")
                        .font(.headline)
                        .bold()
                        .foregroundColor(.black)
                }

                Spacer()

                Button(action: {
                    viewModel.currentStep = .livenessInstructions
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
                .padding(.horizontal, 24)

                Text("Powered by SprintCheck")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
                    .padding(.bottom, 24)

            } else {
                // Screen 2: Input Details
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        Spacer().frame(height: 10)

                        Text(methodDisplayName)
                            .font(.title2)
                            .bold()
                            .foregroundColor(.black)

                        ZStack(alignment: .leading) {
                            if inputNumber.isEmpty {
                                Text(inputPlaceholder)
                                    .font(.system(size: 16))
                                    .foregroundColor(.black)
                                    .allowsHitTesting(false)
                            }
                            TextField("", text: $inputNumber)
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                                .keyboardType(.numberPad)
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 16)
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(UIColor.systemGray4), lineWidth: 1)
                        )

                        VStack(alignment: .leading, spacing: 16) {
                            BulletPointRow(text: "We need and collect your Full name, Phone number, Date of birth")
                            BulletPointRow(text: "This verification step helps us confirm it's really you. Do not share your code or authentication details with anyone, even if they claim to be from our team.")
                        }

                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, 24)
                }

                // Bottom Action & Footer
                VStack(spacing: 8) {
                    Button(action: {
                        viewModel.startVerificationProcess(bvn: inputNumber)
                    }) {
                        Text("Continue")
                            .font(.headline)
                            .bold()
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(isValidInput ? Color.black : Color.gray.opacity(0.4))
                            .cornerRadius(8)
                    }
                    .disabled(!isValidInput)

                    Text("Powered by SprintCheck")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .background(Color.white.edgesIgnoringSafeArea(.all))
        .onAppear {
            if !viewModel.bvn.isEmpty {
                inputNumber = viewModel.bvn
            }
        }
    }

    private var isValidInput: Bool {
        return inputNumber.count == 11 && inputNumber.allSatisfy { $0.isNumber }
    }
}
