import Foundation

public enum CheckoutMethod: String, Codable, CaseIterable {
    case bvn
    case nin
    case facial
    case documentreader
    case selectable

    public var displayName: String {
        switch self {
        case .bvn: return "BVN"
        case .nin: return "NIN"
        case .facial: return "FACIAL"
        case .documentreader: return "Document Reader"
        case .selectable: return "Selectable"
        }
    }
}
