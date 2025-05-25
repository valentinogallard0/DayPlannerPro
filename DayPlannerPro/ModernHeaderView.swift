//
//  ModernHeaderView.swift
//  DayPlannerPro
//
//  Created by Valentino De Paola Gallardo on 25/05/25.
//

//
//  ModernHeaderView.swift
//  DayPlannerPro
//
//  HeaderView con efecto glassmorphism y diseño moderno
//

//
//  ModernHeaderView.swift
//  DayPlannerPro
//
//  HeaderView con efecto glassmorphism y diseño moderno
//

import SwiftUI

struct ModernHeaderView: View {
    let selectedDate: Date
    let totalTasks: Int
    let completedTasks: Int
    let onDateTap: (() -> Void)?
    let onProfileTap: (() -> Void)?
    
    @State private var hasAppeared = false
    @State private var progressAnimation: CGFloat = 0
    
    // Para animación de números
    @State private var animatedCompleted = 0
    @State private var animatedTotal = 0
    
    init(
        selectedDate: Date,
        totalTasks: Int,
        completedTasks: Int,
        onDateTap: (() -> Void)? = nil,
        onProfileTap: (() -> Void)? = nil
    ) {
        self.selectedDate = selectedDate
        self.totalTasks = totalTasks
        self.completedTasks = completedTasks
        self.onDateTap = onDateTap
        self.onProfileTap = onProfileTap
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header principal con glassmorphism
            mainHeader
            
            // Progress section
            progressSection
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                hasAppeared = true
            }
            
            // Animar números
            withAnimation(.easeOut(duration: 1.2).delay(0.3)) {
                animatedCompleted = completedTasks
                animatedTotal = totalTasks
            }
            
            // Animar progreso
            withAnimation(.easeInOut(duration: 1.5).delay(0.5)) {
                progressAnimation = progressValue
            }
        }
        .onChange(of: completedTasks) { _ in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animatedCompleted = completedTasks
                progressAnimation = progressValue
            }
        }
        .onChange(of: totalTasks) { _ in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animatedTotal = totalTasks
                progressAnimation = progressValue
            }
        }
    }
    
    // MARK: - Main Header
    private var mainHeader: some View {
        HStack(spacing: 16) {
            // Sección de fecha y saludo
            VStack(alignment: .leading, spacing: 6) {
                greetingSection
                dateSection
            }
            
            Spacer()
            
            // Avatar/Profile section
            profileSection
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(glassmorphicBackground)
        .scaleEffect(hasAppeared ? 1.0 : 0.95)
        .opacity(hasAppeared ? 1.0 : 0.0)
    }
    
    // MARK: - Greeting Section
    private var greetingSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(greetingText)
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundColor(.textPrimary)
            
            Text("¡Organiza tu día con éxito!")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
        }
    }
    
    // MARK: - Date Section
    private var dateSection: some View {
        Button(action: { onDateTap?() }) {
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.subheadline)
                    .foregroundColor(.appPrimary)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(selectedDate.formatted(.dateTime.weekday(.wide)))
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                    
                    Text(selectedDate.formatted(.dateTime.day().month(.wide)))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                }
                
                if onDateTap != nil {
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                        .foregroundColor(.textTertiary)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.top, 4)
    }
    
    // MARK: - Profile Section
    private var profileSection: some View {
        Button(action: { onProfileTap?() }) {
            ZStack {
                // Background gradient
                Circle()
                    .fill(Color.primaryGradient)
                    .frame(width: 50, height: 50)
                
                // Profile icon/image
                Image(systemName: "person.crop.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                
                // Notification badge si hay tareas pendientes
                if totalTasks > 0 && completedTasks < totalTasks {
                    VStack {
                        HStack {
                            Spacer()
                            notificationBadge
                        }
                        Spacer()
                    }
                }
            }
        }
        .buttonStyle(ProfileButtonStyle())
    }
    
    // MARK: - Notification Badge
    private var notificationBadge: some View {
        let pendingTasks = totalTasks - completedTasks
        
        return Circle()
            .fill(Color.statusError)
            .frame(width: 20, height: 20)
            .overlay(
                Text("\(pendingTasks)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            )
            .scaleEffect(hasAppeared ? 1.0 : 0.0)
            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(1.0), value: hasAppeared)
    }
    
    // MARK: - Progress Section
    private var progressSection: some View {
        VStack(spacing: 16) {
            // Stats row
            HStack {
                statsCard(
                    title: "Total",
                    value: "\(animatedTotal)",
                    icon: "list.bullet.rectangle",
                    color: .appPrimary,
                    delay: 0.6
                )
                
                Spacer()
                
                statsCard(
                    title: "Completadas",
                    value: "\(animatedCompleted)",
                    icon: "checkmark.circle.fill",
                    color: .statusSuccess,
                    delay: 0.8
                )
                
                Spacer()
                
                statsCard(
                    title: "Progreso",
                    value: "\(Int(progressValue * 100))%",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .appAccent,
                    delay: 1.0
                )
            }
            
            // Progress bar mejorada
            modernProgressBar
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(progressBackground)
    }
    
    // MARK: - Stats Card
    private func statsCard(title: String, value: String, icon: String, color: Color, delay: Double) -> some View {
        VStack(spacing: 8) {
            // Icon con background
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
            }
            
            // Value
            Text(value)
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundColor(.textPrimary)
            
            // Title
            Text(title)
                .font(.caption)
                .foregroundColor(.textSecondary)
                .fontWeight(.medium)
        }
        .scaleEffect(hasAppeared ? 1.0 : 0.8)
        .opacity(hasAppeared ? 1.0 : 0.0)
        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(delay), value: hasAppeared)
    }
    
    // MARK: - Modern Progress Bar
    private var modernProgressBar: some View {
        VStack(spacing: 12) {
            // Progress label
            HStack {
                Text("Progreso del día")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Text(progressText)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.textSecondary)
            }
            
            // Progress track
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.borderSecondary)
                        .frame(height: 12)
                    
                    // Progress fill con gradient
                    RoundedRectangle(cornerRadius: 6)
                        .fill(progressGradient)
                        .frame(
                            width: geometry.size.width * progressAnimation,
                            height: 12
                        )
                        .overlay(
                            // Shine effect
                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                    LinearGradient(
                                        colors: [.white.opacity(0.3), .clear, .white.opacity(0.2)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(
                                    width: geometry.size.width * progressAnimation,
                                    height: 12
                                )
                        )
                    
                    // Progress indicator dot
                    if progressAnimation > 0.05 {
                        Circle()
                            .fill(.white)
                            .frame(width: 8, height: 8)
                            .offset(x: (geometry.size.width * progressAnimation) - 4)
                            .applyShadow(.small)
                    }
                }
            }
            .frame(height: 12)
        }
        .padding(.top, 8)
        .scaleEffect(hasAppeared ? 1.0 : 0.9)
        .opacity(hasAppeared ? 1.0 : 0.0)
        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(1.2), value: hasAppeared)
    }
    
    // MARK: - Computed Properties
    private var progressValue: CGFloat {
        guard totalTasks > 0 else { return 0 }
        return CGFloat(completedTasks) / CGFloat(totalTasks)
    }
    
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Buenos días"
        case 12..<17: return "Buenas tardes"
        case 17..<22: return "Buenas noches"
        default: return "Hola"
        }
    }
    
    private var progressText: String {
        if totalTasks == 0 {
            return "Sin tareas programadas"
        } else if completedTasks == totalTasks {
            return "¡Día completado! 🎉"
        } else {
            let remaining = totalTasks - completedTasks
            return "\(remaining) tarea\(remaining == 1 ? "" : "s") pendiente\(remaining == 1 ? "" : "s")"
        }
    }
    
    private var progressGradient: LinearGradient {
        if progressValue == 1.0 {
            return Color.successGradient
        } else if progressValue > 0.7 {
            return Color.primaryGradient
        } else if progressValue > 0.3 {
            return Color.accentGradient
        } else {
            return Color.warningGradient
        }
    }
    
    // MARK: - Background Styles
    private var glassmorphicBackground: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.2), .clear, .white.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .applyShadow(.medium)
    }
    
    private var progressBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.surfaceSecondary)
            .applyShadow(.small)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.borderSecondary, lineWidth: 1)
            )
    }
}

// MARK: - Profile Button Style
struct ProfileButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Motivational Messages
extension ModernHeaderView {
    private var motivationalMessage: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let progress = progressValue
        
        if progress == 1.0 {
            return "¡Excelente trabajo! Has completado todas tus tareas 🎉"
        } else if progress > 0.7 {
            return "¡Vas muy bien! Solo te faltan unas pocas tareas 💪"
        } else if progress > 0.3 {
            return "¡Buen progreso! Sigue así 🚀"
        } else if hour < 12 {
            return "¡Buenos días! Es hora de ser productivo ☀️"
        } else if hour < 17 {
            return "¡Buenas tardes! Mantén el enfoque 🎯"
        } else {
            return "¡Buenas noches! Termina fuerte el día 🌙"
        }
    }
}

// MARK: - Accessibility
extension ModernHeaderView {
    private var accessibilityLabel: String {
        "Header. \(greetingText). \(selectedDate.formatted(.dateTime.weekday(.wide).month().day())). \(completedTasks) de \(totalTasks) tareas completadas."
    }
}

// MARK: - Preview
struct ModernHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ModernHeaderView(
                selectedDate: Date(),
                totalTasks: 8,
                completedTasks: 5,
                onDateTap: {},
                onProfileTap: {}
            )
            
            ModernHeaderView(
                selectedDate: Date(),
                totalTasks: 5,
                completedTasks: 5
            )
            
            ModernHeaderView(
                selectedDate: Date(),
                totalTasks: 0,
                completedTasks: 0
            )
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.appPrimary.opacity(0.1), Color.appAccent.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .previewLayout(.sizeThatFits)
    }
}
