# SprintCheck iOS SDK & Demo App

A native iOS SDK written in Swift for identity verification, supporting **BVN**, **NIN**, and **Facial Liveness Verification**. 

This iOS project is a direct 1:1 port of the `SprintCheck` Android SDK (`sprintcheckandroid`), implementing the exact same network cryptographic signing (`HMAC-SHA512`), verification workflows, and callbacks.

---

## 📁 Directory Structure

```
sprintcheckios/
├── Package.swift               # Swift Package Manager configuration
├── SprintCheckSDK.podspec       # CocoaPods specification
├── README.md                   # Documentation
├── SprintCheckSDK/              # The SprintCheck iOS SDK Core
│   ├── KYCConfig.swift         # Configuration & Init Result
│   ├── KYCResult.swift         # Verification Result Types
│   ├── CheckoutMethod.swift    # Verification types (bvn, nin, facial, etc.)
│   ├── KYCCallback.swift       # Delegate interface for success/failure/cancellation
│   ├── KYCVerificationManager.swift # SDK Manager singleton & entry point
│   ├── Network/
│   │   ├── HMACUtil.swift      # HMAC-SHA512 signature generator
│   │   └── HttpJsonParser.swift # Async API Network Client
│   ├── Services/
│   │   └── FaceMatcher.swift   # Vision framework face recognition & similarity matcher
│   ├── ViewModel/
│   │   └── KYCVerificationViewModel.swift # Verification state & API controller
│   └── Views/
│       ├── SprintCheckSDKView.swift        # Root container view
│       ├── VerificationDetailView.swift    # BVN / NIN input screen
│       ├── LivenessCheckView.swift         # Camera selfie capture screen
│       ├── CameraPreviewView.swift         # AVFoundation live camera preview
│       └── SuccessView.swift               # Result & confidence score view
└── SprintCheckDemo/            # Sample iOS Application
    ├── SprintCheckDemoApp.swift
    ├── ContentView.swift       # Demo UI triggering BVN, NIN, & Face Verification
    └── Info.plist              # Contains NSCameraUsageDescription
```

---

## 🚀 Quick Start & Integration

### 1. Add Camera Permission

Add `NSCameraUsageDescription` to your app's `Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>SprintCheck requires camera access to perform facial liveness verification.</string>
```

---

### 2. Initialize the SDK

In your `AppDelegate` or main `View`:

```swift
import SprintCheckSDK

let config = KYCConfig(
    apiKey: "YOUR_API_KEY_HERE",
    encryptionKey: "YOUR_ENCRYPTION_KEY_HERE"
)

let result = KYCVerificationManager.shared.initialize(config: config)
switch result {
case .success:
    print("SprintCheck SDK Initialized")
case .failure(let errorCode, let errorMessage):
    print("Initialization error: \(errorCode) - \(errorMessage)")
}
```

---

### 3. Start Identity Verification

```swift
import SprintCheckSDK

// Implement KYCCallback in your class or struct
class MyViewController: UIViewController, KYCCallback {

    func startBVNCheck() {
        KYCVerificationManager.shared.startVerification(
            presentingViewController: self,
            type: .bvn, // Options: .bvn, .nin, .facial
            identifier: "user@email.com",
            callback: self
        )
    }

    // MARK: - KYCCallback
    func onKYCSuccess(result: KYCResult.SuccessResult) {
        print("Verification Succeeded!")
        print("Name: \(result.name), Ref: \(result.reference), Score: \(result.confidenceLevel)%")
    }

    func onKYCFailure(result: KYCResult.FailureResult) {
        print("Verification Failed: \(result.errorMessage)")
    }

    func onKYCCancelled() {
        print("User cancelled verification")
    }
}
```

---

## 🔐 Cryptography & API Specs

- **Base URL**: `https://api.sprintcheck.megasprintlimited.com.ng/api/sdk/`
- **Authentication**: `Authorization` header containing the `apiKey`.
- **HMAC Signature**: Generated via `HMAC-SHA512` using `encryptionKey` on parameter ordering `{"number":"...", "identifier":"..."}`.
- **Verification Endpoints**:
  - `POST /api/sdk/{type}`: Initial identity lookup.
  - `PUT /api/sdk/{type}`: Liveness selfie verification submission.

---

## 🛠 Integration Support
- **Swift Package Manager**: Drag `sprintcheckios` folder into your Xcode Workspace, or reference repository URL.
- **CocoaPods**: Add `pod 'SprintCheckSDK', :path => '../sprintcheckios'` to your `Podfile`.
