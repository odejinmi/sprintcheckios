import SwiftUI
import AVFoundation

public struct CameraPreviewView: UIViewRepresentable {

    @Binding var capturedImage: UIImage?
    public var onPhotoCaptured: (UIImage) -> Void

    public init(capturedImage: Binding<UIImage?>, onPhotoCaptured: @escaping (UIImage) -> Void) {
        self._capturedImage = capturedImage
        self.onPhotoCaptured = onPhotoCaptured
    }

    public func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        context.coordinator.setupSession(in: view)
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(context.coordinator.handleCaptureTrigger),
            name: Notification.Name("TriggerPhotoCapture"),
            object: nil
        )
        return view
    }

    public func updateUIView(_ uiView: UIView, context: Context) {}

    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    public class Coordinator: NSObject, AVCapturePhotoCaptureDelegate {
        var parent: CameraPreviewView
        var session: AVCaptureSession?
        var output: AVCapturePhotoOutput?
        var previewLayer: AVCaptureVideoPreviewLayer?

        init(parent: CameraPreviewView) {
            self.parent = parent
        }

        @objc public func handleCaptureTrigger() {
            if output == nil {
                // iOS Simulator Fallback: Generate a sample selfie image for simulator testing
                if let dummyImage = generateSimulatorSelfieImage() {
                    DispatchQueue.main.async {
                        self.parent.capturedImage = dummyImage
                        self.parent.onPhotoCaptured(dummyImage)
                    }
                }
            } else {
                capturePhoto()
            }
        }

        private func generateSimulatorSelfieImage() -> UIImage? {
            let size = CGSize(width: 400, height: 500)
            let format = UIGraphicsImageRendererFormat()
            format.opaque = true
            format.scale = 1.0

            let renderer = UIGraphicsImageRenderer(size: size, format: format)
            return renderer.image { ctx in
                UIColor.white.setFill()
                ctx.fill(CGRect(origin: .zero, size: size))

                let config = UIImage.SymbolConfiguration(pointSize: 180, weight: .regular)
                if let faceSymbol = UIImage(systemName: "person.crop.circle.fill", withConfiguration: config) {
                    let rect = CGRect(x: 110, y: 140, width: 180, height: 180)
                    faceSymbol.withTintColor(.black).draw(in: rect)
                }
            }
        }

        func setupSession(in view: UIView) {
            let session = AVCaptureSession()
            session.sessionPreset = .photo

            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
                  let input = try? AVCaptureDeviceInput(device: device) else {
                return
            }

            let output = AVCapturePhotoOutput()

            if session.canAddInput(input) && session.canAddOutput(output) {
                session.addInput(input)
                session.addOutput(output)
            }

            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.frame = view.bounds
            view.layer.addSublayer(previewLayer)

            self.session = session
            self.output = output
            self.previewLayer = previewLayer

            DispatchQueue.global(qos: .userInitiated).async {
                session.startRunning()
            }
        }

        public func capturePhoto() {
            let settings = AVCapturePhotoSettings()
            output?.capturePhoto(with: settings, delegate: self)
        }

        public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            guard let data = photo.fileDataRepresentation(),
                  let image = UIImage(data: data) else { return }

            DispatchQueue.main.async {
                self.parent.capturedImage = image
                self.parent.onPhotoCaptured(image)
            }
        }
    }
}
