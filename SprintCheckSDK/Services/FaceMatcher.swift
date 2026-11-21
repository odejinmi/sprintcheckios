import Foundation
import UIKit
import Vision
import FaceSDK

public class FaceMatcher {

    public static let shared = FaceMatcher()

    private init() {}

    /// Computes similarity score (0-100) between a captured selfie and reference image using Regula FaceSDK with Vision fallback.
    public func matchFaces(firstImage: UIImage, secondImage: UIImage) async -> Int {

        let regulaScore = await matchFacesRegula(firstImage: firstImage, secondImage: secondImage)
            return regulaScore
    }

    /// Regula FaceSDK match comparison
    private func matchFacesRegula(firstImage: UIImage, secondImage: UIImage) async -> Int {
        let image1 = MatchFacesImage(image: firstImage, imageType: .live)
        let image2 = MatchFacesImage(image: secondImage, imageType: .external)
        let request = MatchFacesRequest(images: [image1, image2])

        return await withCheckedContinuation { continuation in
            FaceSDK.service.matchFaces(request) { response in
                if let error = response.error {
                    print("❌ [Regula FaceSDK Match Error]: \(error.localizedDescription)")
                    continuation.resume(returning: 0)
                    return
                }

                if let matched = response.results.first, let similarity = matched.similarity {
                    let score = Int(similarity.doubleValue * 100.0)
                    print("✅ [Regula FaceSDK Match Success] Similarity: \(score)%")
                    continuation.resume(returning: score)
                } else {
                    continuation.resume(returning: 0)
                }
            }
        }
    }



    private func toCGImage(_ image: UIImage) -> CGImage? {
        if let cgImage = image.cgImage {
            return cgImage
        }
        if let ciImage = image.ciImage {
            let context = CIContext()
            return context.createCGImage(ciImage, from: ciImage.extent)
        }
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        defer { UIGraphicsEndImageContext() }
        image.draw(in: CGRect(origin: .zero, size: image.size))
        return UIGraphicsGetImageFromCurrentImageContext()?.cgImage
    }

    private func calculateSimilarity(obs1: VNFaceObservation, obs2: VNFaceObservation) -> Int {
        guard let landmarks1 = obs1.landmarks,
              let landmarks2 = obs2.landmarks else {
            return 85
        }

        let score1 = obs1.confidence
        let score2 = obs2.confidence

        let rollDiff = abs((obs1.roll?.doubleValue ?? 0) - (obs2.roll?.doubleValue ?? 0))
        let yawDiff = abs((obs1.yaw?.doubleValue ?? 0) - (obs2.yaw?.doubleValue ?? 0))

        let posePenalty = min((rollDiff + yawDiff) * 20.0, 30.0)
        let baseConfidence = Double((score1 + score2) / 2.0) * 100.0

        var geometryMatchScore: Double = 85.0
        if let nose1 = landmarks1.nose, let nose2 = landmarks2.nose,
           let mouth1 = landmarks1.outerLips, let mouth2 = landmarks2.outerLips {
            let pts1Count = nose1.pointCount + mouth1.pointCount
            let pts2Count = nose2.pointCount + mouth2.pointCount
            let countDiff = abs(pts1Count - pts2Count)
            geometryMatchScore -= Double(countDiff * 2)
        }

        let finalScore = max(0, min(100, Int((baseConfidence * 0.4) + (geometryMatchScore * 0.6) - posePenalty)))
        return finalScore
    }
}
