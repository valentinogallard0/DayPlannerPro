//
//  ModernTaskRowView.swift
//  DayPlannerPro
//
//  Created by Valentino De Paola Gallardo on 25/05/25.
//


import SwiftUI

struct ModernTaskRowView: View {
    let task: Task
    let onToggle: () -> Void
    let onEdit: (() -> Void)?
    let onDelete: (() -> Void)?
    
    @State private var isPressed = false
    @State private var dragOffset = CGSize.zero
    @State private var showingDeleteConfirmation = false
    
    // Para animaciones de aparición
    @State private var hasAppeared = false
    
    init(task: Task, onToggle: @escaping () -> Void, onEdit: (() -> Void)? = nil, onDelete: (() -> Void)? = nil) {
        self.task = task
        self.onToggle = onToggle
        self.onEdit = onEdit
        self.onDelete = onDelete
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Contenido principal de la tarea
            mainContent
                .offset(x: dragOffset.width)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: dragOffset)
            
            // Acciones de swipe (ocultas por defecto)
            if dragOffset.width < -10 {
                swipeActions
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .clipped()
        .gesture(
            DragGesture()
                .onChanged { value in
                    // Solo permitir swipe hacia la izquierda
                    if value.translation.width < 0 {
                        dragOffset = CGSize(width: max(value.translation.width, -120), height: 0)
                    }
                }
                .onEnded { value in
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        if value.translation.width < -60 {
                            dragOffset = CGSize(width: -120, height: 0)
                        } else {
                            dragOffset = .zero
                        }
                    }
                }
        )
        .onTapGesture {
            if dragOffset != .zero {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    dragOffset = .zero
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                hasAppeared = true
            }
        }
        .alert("Eliminar Tarea", isPresented: $showingDeleteConfirmation) {
            Button("Cancelar", role: .cancel) { }
            Button("Eliminar", role: .destructive) {
                onDelete?()
            }
        } message: {
            Text("¿Estás seguro de que quieres eliminar '\(task.title)'?")
        }
    }
    
    // MARK: - Main Content
    private var mainContent: some View {
        HStack(spacing: 16) {
            // Checkbox animado
            AnimatedCheckbox(
                isCompleted: task.isCompleted,
                category: task.category,
                onToggle: onToggle
            )
            
            // Contenido de la tarea con jerarquía visual mejorada
            VStack(alignment: .leading, spacing: 8) {
                // Header con categoría y tiempo
                HStack(alignment: .center) {
                    CategoryPill(category: task.category, size: .small)
                    
                    Spacer()
                    
                    TimeDisplay(time: task.scheduledTime, isOverdue: isOverdue)
                }
                
                // Título con tipografía mejorada
                Text(task.title)
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .foregroundColor(task.isCompleted ? .textSecondary : .textPrimary)
                    .strikethrough(task.isCompleted, color: .textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // Descripción si existe
                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                        .lineLimit(2)
                        .opacity(task.isCompleted ? 0.6 : 1.0)
                }
                
                // Footer con alert y prioridad
                HStack(spacing: 12) {
                    AlertBadge(minutes: task.alertTime, isActive: !task.isCompleted)
                    
                    Spacer()
                    
                    if isOverdue && !task.isCompleted {
                        OverdueBadge()
                    }
                }
            }
            
            // Indicador de prioridad mejorado
            PriorityIndicator(priority: task.priority, isCompleted: task.isCompleted)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(cardBackground)
        .scaleEffect(isPressed ? 0.98 : (hasAppeared ? 1.0 : 0.9))
        .opacity(hasAppeared ? 1.0 : 0.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
                onEdit?()
            }
        }
    }
    
    // MARK: - Swipe Actions
    private var swipeActions: some View {
        HStack(spacing: 0) {
            // Botón editar
            if onEdit != nil {
                Button(action: { onEdit?() }) {
                    VStack(spacing: 4) {
                        Image(systemName: "pencil")
                            .font(.title3)
                        Text("Editar")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .frame(width: 60, height: 80)
                    .background(Color.statusInfo)
                }
            }
            
            // Botón eliminar
            if onDelete != nil {
                Button(action: { showingDeleteConfirmation = true }) {
                    VStack(spacing: 4) {
                        Image(systemName: "trash")
                            .font(.title3)
                        Text("Eliminar")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .frame(width: 60, height: 80)
                    .background(Color.statusError)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    private var isOverdue: Bool {
        task.scheduledTime < Date() && !task.isCompleted
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(task.isCompleted ? Color.surfaceTertiary : Color.surfaceSecondary)
            .applyShadow(isPressed ? .pressed : .medium)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        task.isCompleted ? Color.borderSecondary : task.category.modernColor.opacity(0.1),
                        lineWidth: task.isCompleted ? 1 : 2
                    )
            )
    }
}

// MARK: - Animated Checkbox
struct AnimatedCheckbox: View {
    let isCompleted: Bool
    let category: TaskCategory
    let onToggle: () -> Void
    
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                scale = 1.2
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    scale = 1.0
                }
                onToggle()
            }
        }) {
            ZStack {
                // Círculo base
                Circle()
                    .stroke(
                        isCompleted ? category.modernColor : Color.borderPrimary,
                        lineWidth: 2.5
                    )
                    .frame(width: 28, height: 28)
                
                // Círculo relleno cuando está completado
                if isCompleted {
                    Circle()
                        .fill(category.modernColor)
                        .frame(width: 28, height: 28)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .scaleEffect(isCompleted ? 1 : 0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isCompleted)
                }
                
                // Efecto de ripple
                if isCompleted {
                    Circle()
                        .stroke(category.modernColor.opacity(0.3), lineWidth: 1)
                        .frame(width: 36, height: 36)
                        .scaleEffect(scale)
                        .opacity(2 - scale)
                }
            }
        }
        .scaleEffect(scale)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: scale)
    }
}

// MARK: - Category Pill
struct CategoryPill: View {
    let category: TaskCategory
    let size: PillSize
    
    enum PillSize {
        case small, medium, large
        
        var padding: EdgeInsets {
            switch self {
            case .small: return EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
            case .medium: return EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
            case .large: return EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
            }
        }
        
        var font: Font {
            switch self {
            case .small: return .caption2
            case .medium: return .caption
            case .large: return .subheadline
            }
        }
        
        var iconSize: Font {
            switch self {
            case .small: return .caption2
            case .medium: return .caption
            case .large: return .callout
            }
        }
    }
    
    var body: some View {
        HStack(spacing: size == .small ? 3 : 4) {
            Image(systemName: category.icon)
                .font(size.iconSize)
            Text(category.rawValue)
                .font(size.font)
                .fontWeight(.medium)
        }
        .foregroundColor(category.modernColor)
        .padding(size.padding)
        .background(
            Capsule()
                .fill(category.modernColor.opacity(0.12))
        )
        .overlay(
            Capsule()
                .stroke(category.modernColor.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Time Display
struct TimeDisplay: View {
    let time: Date
    let isOverdue: Bool
    
    private var timeColor: Color {
        if isOverdue {
            return .statusError
        } else {
            return .textSecondary
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: isOverdue ? "clock.badge.exclamationmark" : "clock")
                .font(.caption)
                .foregroundColor(timeColor)
            
            Text(time, style: .time)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(timeColor)
        }
    }
}

// MARK: - Alert Badge
struct AlertBadge: View {
    let minutes: Int
    let isActive: Bool
    
    private var displayText: String {
        if minutes < 60 {
            return "\(minutes)m"
        } else {
            let hours = minutes / 60
            return "\(hours)h"
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "bell.fill")
                .font(.caption2)
            Text("Alerta \(displayText)")
                .font(.caption2)
                .fontWeight(.medium)
        }
        .foregroundColor(isActive ? .statusWarning : .textTertiary)
        .opacity(isActive ? 1.0 : 0.6)
    }
}

// MARK: - Overdue Badge
struct OverdueBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.caption2)
            Text("Vencida")
                .font(.caption2)
                .fontWeight(.bold)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(
            Capsule()
                .fill(Color.statusError)
        )
    }
}

// MARK: - Priority Indicator
struct PriorityIndicator: View {
    let priority: Priority
    let isCompleted: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            // Línea de prioridad
            RoundedRectangle(cornerRadius: 2)
                .fill(isCompleted ? Color.borderPrimary : priority.modernColor)
                .frame(width: 4, height: 24)
            
            // Punto de prioridad
            Circle()
                .fill(isCompleted ? Color.borderPrimary : priority.modernColor)
                .frame(width: 6, height: 6)
        }
        .opacity(isCompleted ? 0.5 : 1.0)
    }
}

// MARK: - Preview
struct ModernTaskRowView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            ModernTaskRowView(
                task: Task(
                    title: "Reunión de equipo",
                    description: "Revisar avances del proyecto y planificar próximos pasos",
                    scheduledTime: Date().addingTimeInterval(3600),
                    alertTime: 15,
                    category: .work,
                    priority: .high
                ),
                onToggle: {},
                onEdit: {},
                onDelete: {}
            )
            
            ModernTaskRowView(
                task: Task(
                    title: "Ejercicio matutino",
                    description: "30 minutos de cardio",
                    scheduledTime: Date().addingTimeInterval(-3600),
                    alertTime: 5,
                    category: .health,
                    isCompleted: true,
                    priority: .medium
                ),
                onToggle: {}
            )
        }
        .padding()
        .background(Color.surfacePrimary)
        .previewLayout(.sizeThatFits)
    }
}
