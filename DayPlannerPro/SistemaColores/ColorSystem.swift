//
//  ColorSystem.swift
//  DayPlannerPro
//
//  Created by Valentino De Paola Gallardo on 25/05/25.
//

//
//  ColorSystem.swift
//  DayPlannerPro
//
//  Sistema de colores moderno para la aplicación
//

import SwiftUI

// MARK: - App Color System
extension Color {
    // MARK: - Primary Colors
    static let appPrimary = Color(red: 0.39, green: 0.40, blue: 0.95)      // #6366F1 - Indigo vibrante
    static let appSecondary = Color(red: 0.55, green: 0.36, blue: 0.96)    // #8B5CF6 - Púrpura
    static let appAccent = Color(red: 0.02, green: 0.84, blue: 0.63)       // #06D6A0 - Verde esmeralda
    
    // MARK: - Category Colors (Más vibrantes y modernos)
    static let categoryWork = Color(red: 0.23, green: 0.51, blue: 0.96)    // #3B82F6 - Azul brillante
    static let categoryPersonal = Color(red: 0.06, green: 0.72, blue: 0.51) // #10B981 - Verde moderno
    static let categoryHealth = Color(red: 0.94, green: 0.27, blue: 0.27)   // #EF4444 - Rojo coral
    static let categorySocial = Color(red: 0.55, green: 0.36, blue: 0.96)   // #8B5CF6 - Púrpura
    static let categoryOther = Color(red: 0.42, green: 0.45, blue: 0.50)    // #6B7280 - Gris elegante
    
    // MARK: - Priority Colors
    static let priorityHigh = Color(red: 0.94, green: 0.27, blue: 0.27)     // #EF4444 - Rojo urgente
    static let priorityMedium = Color(red: 0.98, green: 0.55, blue: 0.11)   // #F97316 - Naranja
    static let priorityLow = Color(red: 0.06, green: 0.72, blue: 0.51)      // #10B981 - Verde
    
    // MARK: - Neutral Colors
    static let surfacePrimary = Color(red: 0.98, green: 0.98, blue: 0.98)   // #FAFAFA - Background
    static let surfaceSecondary = Color.white                                // #FFFFFF - Cards
    static let surfaceTertiary = Color(red: 0.96, green: 0.97, blue: 0.98)  // #F6F7F8 - Subtle bg
    
    // MARK: - Text Colors
    static let textPrimary = Color(red: 0.07, green: 0.09, blue: 0.15)      // #111827 - Texto principal
    static let textSecondary = Color(red: 0.42, green: 0.45, blue: 0.50)    // #6B7280 - Texto secundario
    static let textTertiary = Color(red: 0.64, green: 0.68, blue: 0.75)     // #A3A8B5 - Texto sutil
    
    // MARK: - Border Colors
    static let borderPrimary = Color(red: 0.90, green: 0.91, blue: 0.92)    // #E5E7EB - Bordes principales
    static let borderSecondary = Color(red: 0.95, green: 0.95, blue: 0.96)  // #F2F3F4 - Bordes sutiles
    
    // MARK: - Status Colors
    static let statusSuccess = Color(red: 0.06, green: 0.72, blue: 0.51)    // #10B981 - Verde éxito
    static let statusWarning = Color(red: 0.98, green: 0.55, blue: 0.11)    // #F97316 - Naranja alerta
    static let statusError = Color(red: 0.94, green: 0.27, blue: 0.27)      // #EF4444 - Rojo error
    static let statusInfo = Color(red: 0.23, green: 0.51, blue: 0.96)       // #3B82F6 - Azul info
    
    // MARK: - Dark Mode Colors
    static let darkBackground = Color(red: 0.06, green: 0.06, blue: 0.14)   // #0F0F23 - Fondo oscuro
    static let darkSurface = Color(red: 0.10, green: 0.10, blue: 0.18)      // #1A1A2E - Superficie oscura
    static let darkSurfaceSecondary = Color(red: 0.14, green: 0.14, blue: 0.22) // #242438 - Surface elevada
    
    // MARK: - Adaptive Colors (se adaptan automáticamente al modo)
    static let adaptiveBackground = Color("AdaptiveBackground") // Crear en Assets.xcassets
    static let adaptiveSurface = Color("AdaptiveSurface")
    static let adaptiveText = Color("AdaptiveText")
    static let adaptiveBorder = Color("AdaptiveBorder")
}

// MARK: - Category Color Extension
extension TaskCategory {
    var modernColor: Color {
        switch self {
        case .work: return .categoryWork
        case .personal: return .categoryPersonal
        case .health: return .categoryHealth
        case .social: return .categorySocial
        case .other: return .categoryOther
        }
    }
}

// MARK: - Priority Color Extension
extension Priority {
    var modernColor: Color {
        switch self {
        case .high: return .priorityHigh
        case .medium: return .priorityMedium
        case .low: return .priorityLow
        }
    }
}

// MARK: - Gradient Helpers
extension Color {
    // MARK: - Gradient Presets
    static let primaryGradient = LinearGradient(
        colors: [.appPrimary, .appSecondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let successGradient = LinearGradient(
        colors: [.statusSuccess, .categoryPersonal],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let warningGradient = LinearGradient(
        colors: [.statusWarning, .priorityMedium],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let accentGradient = LinearGradient(
        colors: [.appAccent, .categoryPersonal],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Shadow Presets
struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    
    static let small = ShadowStyle(
        color: .black.opacity(0.08),
        radius: 4,
        x: 0,
        y: 2
    )
    
    static let medium = ShadowStyle(
        color: .black.opacity(0.10),
        radius: 8,
        x: 0,
        y: 4
    )
    
    static let large = ShadowStyle(
        color: .black.opacity(0.12),
        radius: 16,
        x: 0,
        y: 8
    )
    
    static let pressed = ShadowStyle(
        color: .black.opacity(0.05),
        radius: 2,
        x: 0,
        y: 1
    )
}

// MARK: - View Extension for Shadows
extension View {
    func applyShadow(_ style: ShadowStyle) -> some View {
        self.shadow(
            color: style.color,
            radius: style.radius,
            x: style.x,
            y: style.y
        )
    }
}
