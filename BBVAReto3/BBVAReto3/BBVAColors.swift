//
//  BBVAColors.swift
//  BBVAReto3
//
//  Created for BBVA Reto3.
//

import SwiftUI

extension Color {
    // Primary Colors
    static let bbvaCoreBlue = Color(hex: "004481")
    static let bbvaCoreBlueLight = Color(hex: "1464A5")
    static let bbvaCoreBlueDark = Color(hex: "043263")
    
    // Secondary Colors
    static let bbvaSkyBlue = Color(hex: "5BBEFF")
    static let bbvaAqua = Color(hex: "2DCCCD")
    
    // Background Colors
    static let bbvaAquaWhite = Color(hex: "EAF9FA")
    static let bbvaNavyBlue = Color(hex: "072146")
    
    // Helper initializer for hex colors
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
