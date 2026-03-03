import SwiftUI

extension Font {
    static func pretendard(_ weight: PretendardWeight, size: CGFloat) -> Font {
        .custom("Pretendard-\(weight.rawValue)", size: size)
    }

    enum PretendardWeight: String {
        case regular = "Regular"
        case medium = "Medium"
        case semiBold = "SemiBold"
    }

    static let body12R = pretendard(.regular, size: 12)
    static let body14R = pretendard(.regular, size: 14)
    static let body14SB = pretendard(.semiBold, size: 14)
    static let body16R = pretendard(.regular, size: 16)
    static let body18M = pretendard(.medium, size: 18)
    static let body18SB = pretendard(.semiBold, size: 18)
}
