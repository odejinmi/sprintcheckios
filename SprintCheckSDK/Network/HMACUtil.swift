import Foundation
import CommonCrypto

public struct HMACUtil {

    /// Converts parameters to a JSON-like string format used by SprintCheck API for HMAC hashing.
    public static func mapToJsonLikeString(params: [String: String?]) -> String {
        let priorityOrder = ["number", "reference", "confidence", "identifier", "image"]
        var keys = priorityOrder.filter { params.keys.contains($0) }
        for k in params.keys.sorted() {
            if !keys.contains(k) {
                keys.append(k)
            }
        }

        var parts: [String] = []
        for key in keys {
            if let val = params[key], let value = val {
                parts.append("\"\(key)\":\"\(value)\"")
            }
        }
        return "{" + parts.joined(separator: ",") + "}"
    }

    /// Generates HMAC-SHA512 hash string in hex format.
    public static func generateHmacSha512(message: String, secretKey: String) -> String {
        guard let keyData = secretKey.data(using: .utf8),
              let messageData = message.data(using: .utf8),
              !keyData.isEmpty,
              !messageData.isEmpty else {
            return ""
        }

        var digest = Data(count: Int(CC_SHA512_DIGEST_LENGTH))

        digest.withUnsafeMutableBytes { digestBytes in
            keyData.withUnsafeBytes { keyBytes in
                messageData.withUnsafeBytes { messageBytes in
                    if let digestRaw = digestBytes.baseAddress,
                       let keyRaw = keyBytes.baseAddress,
                       let msgRaw = messageBytes.baseAddress {
                        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA512),
                               keyRaw, keyData.count,
                               msgRaw, messageData.count,
                               digestRaw)
                    }
                }
            }
        }

        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
