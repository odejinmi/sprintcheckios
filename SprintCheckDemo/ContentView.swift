import SwiftUI

class KYCDemoDelegate: ObservableObject, KYCCallback {
    @Published var statusMessage: String = "Select a verification method to start"
    @Published var showingAlert: Bool = false
    @Published var alertTitle: String = ""
    @Published var alertBody: String = ""

    func onKYCSuccess(result: KYCResult.SuccessResult) {
        DispatchQueue.main.async {
            self.statusMessage = "Verification Successful! ID: \(result.reference), Score: \(result.confidenceLevel)%"
            self.alertTitle = "Success"
            self.alertBody = "Verification Completed Successfully!\nName: \(result.name)\nReference: \(result.reference)\nScore: \(result.confidenceLevel)%"
            self.showingAlert = true
        }
    }

    func onKYCFailure(result: KYCResult.FailureResult) {
        DispatchQueue.main.async {
            self.statusMessage = "Verification Failed: \(result.errorMessage)"
            self.alertTitle = "Verification Failed"
            self.alertBody = "Code: \(result.errorCode)\nMessage: \(result.errorMessage)"
            self.showingAlert = true
        }
    }

    func onKYCCancelled() {
        DispatchQueue.main.async {
            self.statusMessage = "Verification was cancelled by user"
            self.alertTitle = "Cancelled"
            self.alertBody = "Verification process was cancelled."
            self.showingAlert = true
        }
    }
}

struct ContentView: View {

    @StateObject private var delegate = KYCDemoDelegate()

    @State private var apiKey: String = "scbzvH8StBC3M6r0jVfMpScvem6kaxvYOqbuHD2XWS4Df"
    @State private var encryptionKey: String = "encDDtFVWfHGoELdaRtcMflcpP7jWy1e"
    @State private var identifier: String = "odejinmiabraham@gmail.com"
    @State private var verificationNumber: String = "22314756491"

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header Logo
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.shield.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .foregroundColor(.blue)

                        Text("SprintCheck Identity SDK")
                            .font(.title2)
                            .bold()

                        Text(delegate.statusMessage)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 8)

                    // Form Inputs Section
                    VStack(alignment: .leading, spacing: 14) {
                        Text("SDK Configuration")
                            .font(.headline)
                            .foregroundColor(.primary)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("API Key")
                                .font(.caption)
                                .bold()
                                .foregroundColor(.secondary)
                            TextField("Enter API Key", text: $apiKey)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Encryption Key")
                                .font(.caption)
                                .bold()
                                .foregroundColor(.secondary)
                            TextField("Enter Encryption Key", text: $encryptionKey)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Identifier (Email / User ID)")
                                .font(.caption)
                                .bold()
                                .foregroundColor(.secondary)
                            TextField("Enter User Identifier", text: $identifier)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Verification Number (Optional BVN / NIN)")
                                .font(.caption)
                                .bold()
                                .foregroundColor(.secondary)
                            TextField("Enter 11-digit BVN or NIN", text: $verificationNumber)
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    .padding(16)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)

                    // Action Buttons Section
                    VStack(spacing: 12) {
                        Button(action: startBVNVerification) {
                            HStack {
                                Image(systemName: "person.text.rectangle")
                                Text("Start BVN Verification")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }

                        Button(action: startNINVerification) {
                            HStack {
                                Image(systemName: "doc.text.fill")
                                Text("Start NIN Verification")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.indigo)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }

                        Button(action: startFaceVerification) {
                            HStack {
                                Image(systemName: "face.dashed")
                                Text("Start Face Verification")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer().frame(height: 20)
                }
            }
            .navigationTitle("SprintCheck iOS")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $delegate.showingAlert) {
                Alert(title: Text(delegate.alertTitle), message: Text(delegate.alertBody), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func startBVNVerification() {
        startVerification(method: .bvn)
    }

    private func startNINVerification() {
        startVerification(method: .nin)
    }

    private func startFaceVerification() {
        startVerification(method: .facial)
    }

    private func startVerification(method: CheckoutMethod) {
        let trimmedApiKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEncryptionKey = encryptionKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedIdentifier = identifier.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedApiKey.isEmpty, !trimmedEncryptionKey.isEmpty else {
            delegate.alertTitle = "Configuration Error"
            delegate.alertBody = "Please enter a valid API Key and Encryption Key."
            delegate.showingAlert = true
            return
        }

        let config = KYCConfig(
            apiKey: trimmedApiKey,
            encryptionKey: trimmedEncryptionKey
        )
        let initResult = KYCVerificationManager.shared.initialize(config: config)

        switch initResult {
        case .success:
            print("✅ SprintCheck SDK Initialized Successfully")
        case .failure(let errorCode, let errorMessage):
            print("❌ SDK Init Failed: \(errorCode) - \(errorMessage)")
            delegate.alertTitle = "Initialization Error"
            delegate.alertBody = "\(errorCode): \(errorMessage)"
            delegate.showingAlert = true
            return
        }

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            return
        }

        let trimmedVerificationNumber = verificationNumber.trimmingCharacters(in: .whitespacesAndNewlines)

        KYCVerificationManager.shared.startVerification(
            presentingViewController: rootVC,
            type: method,
            identifier: trimmedIdentifier.isEmpty ? "odejinmiabraham@gmail.com" : trimmedIdentifier,
            prefilledNumber: trimmedVerificationNumber.isEmpty ? nil : trimmedVerificationNumber,
            callback: delegate
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
