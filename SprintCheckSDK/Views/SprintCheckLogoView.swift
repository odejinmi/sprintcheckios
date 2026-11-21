import SwiftUI

public struct SprintCheckLogoView: View {
    public enum Size {
        case small
        case medium
        case large
    }

    let size: Size

    public init(size: Size = .medium) {
        self.size = size
    }

    public var body: some View {
        if let uiImage = logoImage {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: logoHeight)
        } else {
            // Built-in Vector Logo Fallback matching SprintCheck Branding
            VStack(spacing: 6) {
                ZStack {
                    // Speedy checkmark vector shape
                    Path { path in
                        path.move(to: CGPoint(x: 10, y: 22))
                        path.addLine(to: CGPoint(x: 22, y: 34))
                        path.addLine(to: CGPoint(x: 44, y: 10))
                    }
                    .stroke(Color.black, style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))

                    // Speed lines
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: 16))
                        path.addLine(to: CGPoint(x: 10, y: 16))
                        path.move(to: CGPoint(x: 4, y: 24))
                        path.addLine(to: CGPoint(x: 14, y: 24))
                    }
                    .stroke(Color.black, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                }
                .frame(width: iconSize, height: iconSize)

                Text("SprintCheck")
                    .font(.system(size: textSize, weight: .black, design: .default))
                    .foregroundColor(.black)
            }
        }
    }

    private var logoHeight: CGFloat {
        switch size {
        case .small: return 32
        case .medium: return 54
        case .large: return 72
        }
    }

    private var iconSize: CGFloat {
        switch size {
        case .small: return 24
        case .medium: return 40
        case .large: return 52
        }
    }

    private var textSize: CGFloat {
        switch size {
        case .small: return 12
        case .medium: return 18
        case .large: return 24
        }
    }

    private var logoImage: UIImage? {
        SprintCheckAsset.uiImage(named: "sprintcheck_logo") ?? SprintCheckAsset.uiImage(named: "SprintCheckLogo")
    }
}

public enum SprintCheckAsset {
    public static func uiImage(named name: String) -> UIImage? {
        let cleanName = (name as NSString).deletingPathExtension
        let ext = (name as NSString).pathExtension.isEmpty ? "png" : (name as NSString).pathExtension

        let bundlesToSearch = [
            Bundle.main,
            Bundle(for: KYCVerificationManager.self)
        ]

        // 1. Check all candidate bundles for the file directly or in subdirectories
        for bundle in bundlesToSearch {
            if let path = bundle.path(forResource: cleanName, ofType: ext) ??
                          bundle.path(forResource: cleanName, ofType: ext, inDirectory: "Assets") ??
                          bundle.path(forResource: name, ofType: nil) ??
                          bundle.path(forResource: name, ofType: nil, inDirectory: "Assets"),
               let image = UIImage(contentsOfFile: path) {
                return image
            }

            if let url = bundle.url(forResource: cleanName, withExtension: ext) ??
                         bundle.url(forResource: cleanName, withExtension: ext, subdirectory: "Assets") ??
                         bundle.url(forResource: name, withExtension: nil) ??
                         bundle.url(forResource: name, withExtension: nil, subdirectory: "Assets"),
               let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                return image
            }

            if let image = UIImage(named: cleanName, in: bundle, with: nil) ??
                           UIImage(named: name, in: bundle, with: nil) ??
                           UIImage(named: "Assets/\(cleanName)", in: bundle, with: nil) {
                return image
            }
        }

        // 2. Try Swift Package Manager resource bundle if available
        #if SWIFT_PACKAGE
        if let image = UIImage(named: cleanName, in: Bundle.module, with: nil) {
            return image
        }
        if let url = Bundle.module.url(forResource: cleanName, withExtension: ext) ??
                     Bundle.module.url(forResource: name, withExtension: nil),
           let data = try? Data(contentsOf: url),
           let image = UIImage(data: data) {
            return image
        }
        #endif

        // 3. Try nested resource bundle (e.g. SprintCheckSDK_SprintCheckSDK.bundle)
        let sdkBundle = Bundle(for: KYCVerificationManager.self)
        if let bundleUrl = Bundle.main.url(forResource: "SprintCheckSDK_SprintCheckSDK", withExtension: "bundle") ??
                           sdkBundle.url(forResource: "SprintCheckSDK_SprintCheckSDK", withExtension: "bundle"),
           let resourceBundle = Bundle(url: bundleUrl) {
            if let image = UIImage(named: cleanName, in: resourceBundle, with: nil) ??
                           UIImage(named: name, in: resourceBundle, with: nil) {
                return image
            }
            if let path = resourceBundle.path(forResource: cleanName, ofType: ext) ??
                          resourceBundle.path(forResource: name, ofType: nil),
               let image = UIImage(contentsOfFile: path) {
                return image
            }
        }

        // 4. Fallback to standard asset catalog lookup
        if let image = UIImage(named: cleanName) ?? UIImage(named: name) {
            return image
        }

        return nil
    }

    public static func image(named name: String) -> Image? {
        if let uiImage = uiImage(named: name) {
            return Image(uiImage: uiImage)
        }
        return nil
    }
}
