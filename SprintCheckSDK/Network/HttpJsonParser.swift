import Foundation

public class HttpJsonParser {

    public static let shared = HttpJsonParser()

    private init() {}

    public func makeRequest(
        urlString: String,
        method: String,
        params: [String: String?]?,
        apiKey: String?,
        encryptionKey: String?
    ) async throws -> [String: Any]? {
        guard let url = URL(string: urlString) else {
            print("❌ [SprintCheck Network Error] Invalid URL: \(urlString)")
            throw NSError(domain: "HttpJsonParser", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL: \(urlString)"])
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.uppercased()

        // Compute HMAC signature
        let signature: String
        if let params = params {
            let jsonLikeString = HMACUtil.mapToJsonLikeString(params: params)
            print("🔐 [SprintCheck HMAC] Payload string to sign: \(jsonLikeString)")
            if let secret = encryptionKey, !secret.isEmpty {
                signature = HMACUtil.generateHmacSha512(message: jsonLikeString, secretKey: secret)
                print("🔐 [SprintCheck HMAC] Generated HMAC-SHA512: \(signature)")
            } else {
                signature = ""
            }
        } else {
            signature = ""
        }

        if let apiKey = apiKey {
            request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        }
        request.setValue(signature, forHTTPHeaderField: "signature")

        if method.uppercased() == "GET" {
            if let params = params, !params.isEmpty {
                var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
                components?.queryItems = params.compactMap { key, value in
                    guard let val = value else { return nil }
                    return URLQueryItem(name: key, value: val)
                }
                if let fullUrl = components?.url {
                    request.url = fullUrl
                }
            }
        } else if method.uppercased() == "POST" || method.uppercased() == "PUT" {
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            if let params = params {
                let bodyString = params.compactMap { key, value -> String? in
                    guard let val = value else { return nil }
                    let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? key
                    let encodedValue = val.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? val
                    return "\(encodedKey)=\(encodedValue)"
                }.joined(separator: "&")
                request.httpBody = bodyString.data(using: .utf8)
            }
        }

        print("==================================================")
        print("🌐 [SprintCheck Network Request]")
        print("➡️ URL: \(request.url?.absoluteString ?? urlString)")
        print("➡️ Method: \(method.uppercased())")
        print("➡️ Headers: \(request.allHTTPHeaderFields ?? [:])")
        if let params = params {
            let logParams = params.mapValues { val in
                if let v = val, v.count > 100 {
                    return "\(v.prefix(30))... (truncated \(v.count) chars)"
                }
                return val ?? "nil"
            }
            print("➡️ Parameters: \(logParams)")
        }
        print("==================================================")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ [SprintCheck Network Error] Invalid server response")
                throw NSError(domain: "HttpJsonParser", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid server response"])
            }

            let responseStr = String(data: data, encoding: .utf8) ?? ""

            print("==================================================")
            print("🌐 [SprintCheck Network Response]")
            print("⬅️ Status Code: \(httpResponse.statusCode)")
            print("⬅️ Raw Response Body:\n\(responseStr)")
            print("==================================================")

            if let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("⬅️ Parsed JSON Dictionary: \(jsonObj)")
                return jsonObj
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw NSError(domain: "HttpJsonParser", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Error \(httpResponse.statusCode): \(responseStr)"])
            }

            return nil
        } catch {
            print("❌ [SprintCheck Network Failure] Exception: \(error.localizedDescription)")
            throw error
        }
    }
}
