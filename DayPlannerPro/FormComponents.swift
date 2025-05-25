//
//  FormComponents.swift
//  DayPlannerPro
//
//  Created by Valentino De Paola Gallardo on 25/05/25.



import SwiftUI

// MARK: - Modern Form Section
struct ModernFormSection<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundColor(.textPrimary)
                
                Spacer()
            }
            
            // Section content
            content
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.surfaceSecondary)
                .applyShadow(.small)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(color.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Modern Text Field
struct ModernTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let icon: String
    var isRequired: Bool = false
    var axis: Axis = .horizontal
    var isFocused: Bool = false
    
    @State private var isActive = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Label
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(labelColor)
                    .frame(width: 12)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(labelColor)
                
                if isRequired {
                    Text("*")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(Color.statusError)
                }
            }
            
            // Text field
            TextField(placeholder, text: $text, axis: axis)
                .font(.body)
                .foregroundColor(.textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(fieldBackground)
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isActive = true
                    }
                }
                .onChange(of: isFocused) { _, focused in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isActive = focused
                    }
                }
        }
    }
    
    private var labelColor: Color {
        if isActive || !text.isEmpty {
            return .appPrimary
        } else if isRequired && text.isEmpty {
            return Color.statusError
        } else {
            return .textSecondary
        }
    }
    
    private var fieldBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.surfaceTertiary)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
    }
    
    private var borderColor: Color {
        if isActive {
            return .appPrimary
        } else if isRequired && text.isEmpty {
            return Color.statusError.opacity(0.3)
        } else {
            return .borderSecondary
        }
    }
    
    private var borderWidth: CGFloat {
        isActive ? 2 : 1
    }
}

// MARK: - Modern Date Time Selector
struct ModernDateTimeSelector: View {
    let title: String
    let icon: String
    let value: String
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(color)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.textSecondary)
                    
                    Text(value)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.textTertiary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.surfaceTertiary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(color.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
            action()
        }
    }
}

// MARK: - Modern Category Button
struct ModernCategoryButton: View {
    let category: TaskCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? category.modernColor : category.modernColor.opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: category.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(isSelected ? .white : category.modernColor)
                }
                
                // Label
                Text(category.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? category.modernColor : .textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(categoryBackground)
            .overlay(categoryBorder)
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var categoryBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(isSelected ? category.modernColor.opacity(0.1) : Color.surfaceTertiary)
    }
    
    private var categoryBorder: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(isSelected ? category.modernColor.opacity(0.3) : Color.borderSecondary, lineWidth: isSelected ? 2 : 1)
    }
}

// MARK: - Modern Priority Button
struct ModernPriorityButton: View {
    let priority: Priority
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                // Priority indicator
                Circle()
                    .fill(priority.modernColor)
                    .frame(width: 8, height: 8)
                
                Text(priority.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(isSelected ? .white : priority.modernColor)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(priorityBackground)
            .overlay(priorityBorder)
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var priorityBackground: some View {
        Capsule()
            .fill(isSelected ? priority.modernColor : priority.modernColor.opacity(0.1))
    }
    
    private var priorityBorder: some View {
        Capsule()
            .stroke(isSelected ? Color.clear : priority.modernColor.opacity(0.3), lineWidth: 1)
    }
}

// MARK: - Modern Alert Time Button
struct ModernAlertTimeButton: View {
    let minutes: Int
    let isSelected: Bool
    let action: () -> Void
    
    private var displayText: String {
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            return "\(hours)h"
        }
    }
    
    var body: some View {
        Button(action: action) {
            Text(displayText)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .white : Color.statusWarning)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(alertBackground)
                .overlay(alertBorder)
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var alertBackground: some View {
        Capsule()
            .fill(isSelected ? Color.statusWarning : Color.statusWarning.opacity(0.1))
    }
    
    private var alertBorder: some View {
        Capsule()
            .stroke(isSelected ? Color.clear : Color.statusWarning.opacity(0.3), lineWidth: 1)
    }
}

// MARK: - Modern Task Preview
struct ModernTaskPreview: View {
    let title: String
    let description: String
    let scheduledTime: Date
    let category: TaskCategory
    let priority: Priority
    let alertTime: Int
    
    var body: some View {
        HStack(spacing: 16) {
            // Category indicator
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(category.modernColor.opacity(0.15))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: category.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(category.modernColor)
                }
                
                Text(category.rawValue)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(category.modernColor)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                // Title
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                    .lineLimit(2)
                
                // Description
                if !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                        .lineLimit(2)
                }
                
                // Time and alert info
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                        Text(scheduledTime, style: .time)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.textSecondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "bell.fill")
                            .font(.caption)
                        Text("\(alertTime) min")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(Color.statusWarning)
                }
            }
            
            Spacer()
            
            // Priority indicator
            VStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(priority.modernColor)
                    .frame(width: 4, height: 32)
                
                Circle()
                    .fill(priority.modernColor)
                    .frame(width: 6, height: 6)
            }
        }
        .padding(16)
        .background(previewBackground)
        .applyShadow(.small)
    }
    
    private var previewBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.surfaceTertiary)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(category.modernColor.opacity(0.2), lineWidth: 1)
            )
    }
}

// MARK: - Empty Preview Placeholder
struct EmptyPreviewPlaceholder: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "eye.slash")
                .font(.title2)
                .foregroundColor(.textTertiary)
            
            Text("Escribe un título para ver la vista previa")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(placeholderBackground)
    }
    
    private var placeholderBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.surfaceTertiary.opacity(0.5))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        Color.borderSecondary,
                        style: StrokeStyle(lineWidth: 1, dash: [5, 5])
                    )
            )
    }
}

// MARK: - Modern Date Picker Sheet
struct ModernDatePicker: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                pickerHeader(title: "Seleccionar Fecha")
                
                // Date picker
                DatePicker(
                    "Fecha",
                    selection: $selectedDate,
                    in: Date()...,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding(20)
                .background(Color.surfacePrimary)
                
                Spacer()
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    private func pickerHeader(title: String) -> some View {
        VStack(spacing: 16) {
            HStack {
                Button("Cancelar") {
                    dismiss()
                }
                .foregroundColor(.textSecondary)
                
                Spacer()
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Button("Listo") {
                    dismiss()
                }
                .fontWeight(.semibold)
                .foregroundColor(.appPrimary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            Divider()
        }
        .background(Color.surfaceSecondary)
    }
}

// MARK: - Modern Time Picker Sheet
struct ModernTimePicker: View {
    @Binding var selectedTime: Date
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                pickerHeader(title: "Seleccionar Hora")
                
                // Time picker content
                timePickerContent
                
                Spacer()
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    private func pickerHeader(title: String) -> some View {
        VStack(spacing: 16) {
            HStack {
                Button("Cancelar") {
                    dismiss()
                }
                .foregroundColor(.textSecondary)
                
                Spacer()
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Button("Listo") {
                    dismiss()
                }
                .fontWeight(.semibold)
                .foregroundColor(.appPrimary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            Divider()
        }
        .background(Color.surfaceSecondary)
    }
    
    private var timePickerContent: some View {
        VStack(spacing: 24) {
            DatePicker(
                "Hora",
                selection: $selectedTime,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            
            // Quick time suggestions
            VStack(alignment: .leading, spacing: 12) {
                Text("Horarios Sugeridos")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
                    ForEach(suggestedTimes, id: \.self) { time in
                        Button(action: {
                            selectedTime = time
                        }) {
                            Text(time, style: .time)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.appPrimary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(Color.appPrimary.opacity(0.1))
                                )
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                }
            }
        }
        .padding(20)
        .background(Color.surfacePrimary)
    }
    
    private var suggestedTimes: [Date] {
        let calendar = Calendar.current
        let now = Date()
        
        // Simplified to avoid compiler timeout
        var times: [Date] = []
        let hours = [9, 12, 14, 17, 19, 21]
        
        for hour in hours {
            if let time = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: now) {
                times.append(time)
            }
        }
        
        return times
    }
}

// MARK: - Preview Helpers
struct FormComponents_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 20) {
                ModernFormSection(
                    title: "Test Section",
                    icon: "info.circle.fill",
                    color: .appPrimary
                ) {
                    ModernTextField(
                        title: "Título",
                        placeholder: "Escribe algo...",
                        text: .constant(""),
                        icon: "text.cursor",
                        isRequired: true
                    )
                }
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(TaskCategory.allCases, id: \.self) { category in
                        ModernCategoryButton(
                            category: category,
                            isSelected: category == .work
                        ) { }
                    }
                }
                
                HStack {
                    ForEach(Priority.allCases, id: \.self) { priority in
                        ModernPriorityButton(
                            priority: priority,
                            isSelected: priority == .medium
                        ) { }
                    }
                }
            }
            .padding()
        }
        .background(Color.surfacePrimary)
        .previewLayout(.sizeThatFits)
    }
}
