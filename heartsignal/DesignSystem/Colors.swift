import SwiftUI

extension Color {
    static let main700 = Color(hex: "#FF008C")
    static let main600 = Color(hex: "#FFBAE0")
    static let brown700 = Color(hex: "#330914")
    static let gray900 = Color(hex: "#606060")
    static let gray800 = Color(hex: "#C8C8C8")
    static let gray700 = Color(hex: "#D9D9D9")
    static let gray500 = Color(hex: "#EFEFEF")
    static let bg = Color(hex: "#F8F8F8")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
