//
//  ModernAddTaskView.swift
//  DayPlannerPro
//
//  Created by Valentino De Paola Gallardo on 25/05/25.
//


import SwiftUI

struct ModernAddTaskView: View {
    @Binding var tasks: [Task]
    @Environment(\.dismiss) private var dismiss
    
    // Para auto-completar si se viene desde el calendario
    var presetDate: Date? = nil
    var presetHour: Int? = nil
    
    // MARK: - Form State
    @State private var title = ""
    @State private var description = ""
    @State private var selectedDate = Date()
    @State private var selectedTime = Date()
    @State private var selectedCategory: TaskCategory = .personal
    @State private var selectedPriority: Priority = .medium
    @State private var alertTime = 15
    
    // MARK: - UI State
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isFormValid = false
    @State private var hasAppeared = false
    @State private var showingDatePicker = false
    @State private var showingTimePicker = false
    
    // Focus states
    @FocusState private var titleFocused: Bool
    @FocusState private var descriptionFocused: Bool
    
    // Alert time options
    private let alertOptions = [5, 10, 15, 30, 60, 120] // minutes
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                backgroundGradient
                    .ignoresSafeArea()
                
                // Main content
                ScrollView {
                    VStack(spacing: 24) {
                        // Header illustration
                        headerIllustration
                        
                        // Form sections
                        VStack(spacing: 20) {
                            basicInfoSection
                            schedulingSection
                            categorizationSection
                            reminderSection
                            previewSection
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100) // Space for buttons
                    }
                }
                
                // Floating bottom bar
                VStack {
                    Spacer()
                    bottomActionBar
                }
            }
            .navigationBarHidden(true)
            .alert("Error", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
            .sheet(isPresented: $showingDatePicker) {
                ModernDatePicker(selectedDate: $selectedDate)
            }
            .sheet(isPresented: $showingTimePicker) {
                ModernTimePicker(selectedTime: $selectedTime)
            }
        }
        .onAppear {
            setupInitialState()
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                hasAppeared = true
            }
        }
        .onChange(of: title) { _, _ in
            validateForm()
        }
    }
    
    // MARK: - Background
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color.surfacePrimary,
                Color.appPrimary.opacity(0.05),
                Color.appAccent.opacity(0.03)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Header Illustration
    private var headerIllustration: some View {
        VStack(spacing: 16) {
            // Close button
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.textSecondary)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(.ultraThinMaterial))
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            
            // Illustration
            ZStack {
                // Background circles
                Circle()
                    .fill(Color.appPrimary.opacity(0.1))
                    .frame(width: 120, height: 120)
                    .scaleEffect(hasAppeared ? 1.0 : 0.8)
                
                Circle()
                    .fill(Color.appAccent.opacity(0.15))
                    .frame(width: 80, height: 80)
                    .scaleEffect(hasAppeared ? 1.0 : 0.6)
                
                // Icon
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.primaryGradient)
                    .scaleEffect(hasAppeared ? 1.0 : 0.4)
            }
            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2), value: hasAppeared)
            
            // Title
            VStack(spacing: 8) {
                Text("Nueva Tarea")
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundColor(.textPrimary)
                
                Text("Organiza tu tiempo y alcanza tus metas")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .opacity(hasAppeared ? 1.0 : 0.0)
            .animation(.easeInOut(duration: 0.6).delay(0.4), value: hasAppeared)
        }
    }
    
    // MARK: - Basic Info Section
    private var basicInfoSection: some View {
        ModernFormSection(
            title: "Información Básica",
            icon: "info.circle.fill",
            color: .appPrimary
        ) {
            VStack(spacing: 16) {
                ModernTextField(
                    title: "Título",
                    placeholder: "¿Qué necesitas hacer?",
                    text: $title,
                    icon: "text.cursor",
                    isRequired: true,
                    isFocused: titleFocused
                )
                .focused($titleFocused)
                
                ModernTextField(
                    title: "Descripción",
                    placeholder: "Detalles adicionales (opcional)",
                    text: $description,
                    icon: "text.alignleft",
                    axis: .vertical,
                    isFocused: descriptionFocused
                )
                .focused($descriptionFocused)
            }
        }
    }
    
    // MARK: - Scheduling Section
    private var schedulingSection: some View {
        ModernFormSection(
            title: "Programación",
            icon: "calendar.circle.fill",
            color: .categoryWork
        ) {
            VStack(spacing: 16) {
                // Date selector
                ModernDateTimeSelector(
                    title: "Fecha",
                    icon: "calendar",
                    value: selectedDate.formatted(.dateTime.weekday(.wide).month().day()),
                    color: .categoryWork
                ) {
                    showingDatePicker = true
                }
                
                // Time selector
                ModernDateTimeSelector(
                    title: "Hora",
                    icon: "clock",
                    value: selectedTime.formatted(.dateTime.hour().minute()),
                    color: .categoryWork
                ) {
                    showingTimePicker = true
                }
            }
        }
    }
    
    // MARK: - Categorization Section
    private var categorizationSection: some View {
        ModernFormSection(
            title: "Categorización",
            icon: "folder.circle.fill",
            color: .appAccent
        ) {
            VStack(spacing: 20) {
                // Category selection
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "folder.fill")
                            .foregroundColor(.appAccent)
                        Text("Categoría")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.textPrimary)
                    }
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(TaskCategory.allCases, id: \.self) { category in
                            ModernCategoryButton(
                                category: category,
                                isSelected: selectedCategory == category
                            ) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    selectedCategory = category
                                }
                            }
                        }
                    }
                }
                
                // Priority selection
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.appAccent)
                        Text("Prioridad")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.textPrimary)
                    }
                    
                    HStack(spacing: 12) {
                        ForEach(Priority.allCases, id: \.self) { priority in
                            ModernPriorityButton(
                                priority: priority,
                                isSelected: selectedPriority == priority
                            ) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    selectedPriority = priority
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Reminder Section
    private var reminderSection: some View {
        ModernFormSection(
            title: "Recordatorios",
            icon: "bell.circle.fill",
            color: Color.statusWarning
        ) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "bell.fill")
                        .foregroundColor(Color.statusWarning)
                    Text("Alerta")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    Text("\(alertTime) min antes")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Color.statusWarning)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.statusWarning.opacity(0.1))
                        )
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(alertOptions, id: \.self) { minutes in
                            ModernAlertTimeButton(
                                minutes: minutes,
                                isSelected: alertTime == minutes
                            ) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    alertTime = minutes
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
    }
    
    // MARK: - Preview Section
    private var previewSection: some View {
        ModernFormSection(
            title: "Vista Previa",
            icon: "eye.circle.fill",
            color: .categorySocial
        ) {
            if !title.isEmpty {
                ModernTaskPreview(
                    title: title,
                    description: description,
                    scheduledTime: combinedDateTime,
                    category: selectedCategory,
                    priority: selectedPriority,
                    alertTime: alertTime
                )
            } else {
                EmptyPreviewPlaceholder()
            }
        }
    }
    
    // MARK: - Bottom Action Bar
    private var bottomActionBar: some View {
        VStack(spacing: 0) {
            // Gradient fade
            LinearGradient(
                colors: [Color.clear, Color.surfacePrimary.opacity(0.8), Color.surfacePrimary],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 20)
            
            // Action buttons
            HStack(spacing: 16) {
                // Cancel button
                Button(action: { dismiss() }) {
                    Text("Cancelar")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.surfaceSecondary)
                                .applyShadow(.small)
                        )
                }
                .buttonStyle(ScaleButtonStyle())
                
                // Save button
                Button(action: saveTask) {
                    HStack(spacing: 8) {
                        if !isFormValid {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.callout)
                        }
                        Text(isFormValid ? "Guardar Tarea" : "Completa el título")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        Group {
                            if isFormValid {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.primaryGradient)
                                    .applyShadow(.medium)
                            } else {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.textTertiary)
                                    .applyShadow(.small)
                            }
                        }
                    )
                }
                .buttonStyle(ScaleButtonStyle())
                .disabled(!isFormValid)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 34) // Safe area
            .background(Color.surfacePrimary)
        }
        .offset(y: hasAppeared ? 0 : 100)
        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.6), value: hasAppeared)
    }
    
    // MARK: - Computed Properties
    private var combinedDateTime: Date {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: selectedTime)
        
        var combined = DateComponents()
        combined.year = dateComponents.year
        combined.month = dateComponents.month
        combined.day = dateComponents.day
        combined.hour = timeComponents.hour
        combined.minute = timeComponents.minute
        
        return calendar.date(from: combined) ?? Date()
    }
    
    // MARK: - Functions
    private func setupInitialState() {
        // Auto-completar si viene con preset
        if let preset = presetDate {
            selectedDate = preset
        }
        if let hour = presetHour {
            let calendar = Calendar.current
            if let newTime = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: selectedTime) {
                selectedTime = newTime
            }
        }
        
        validateForm()
    }
    
    private func validateForm() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isFormValid = !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
    
    private func saveTask() {
        // Validaciones
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedTitle.isEmpty else {
            showAlert("El título es obligatorio")
            return
        }
        
        guard trimmedTitle.count >= 3 else {
            showAlert("El título debe tener al menos 3 caracteres")
            return
        }
        
        guard combinedDateTime > Date().addingTimeInterval(60) else {
            showAlert("La tarea debe programarse al menos 1 minuto en el futuro")
            return
        }
        
        // Verificar conflictos de horario
        let conflictingTasks = tasks.filter { task in
            let timeDifference = abs(task.scheduledTime.timeIntervalSince(combinedDateTime))
            return timeDifference < 900 // 15 minutos
        }
        
        if !conflictingTasks.isEmpty {
            showAlert("Ya tienes una tarea programada cerca de este horario")
            return
        }
        
        // Crear nueva tarea
        let newTask = Task(
            title: trimmedTitle,
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            scheduledTime: combinedDateTime,
            alertTime: alertTime,
            category: selectedCategory,
            isCompleted: false,
            priority: selectedPriority
        )
        
        // Agregar con animación
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            tasks.append(newTask)
        }
        
        // Cerrar modal
        dismiss()
    }
    
    private func showAlert(_ message: String) {
        alertMessage = message
        showingAlert = true
    }
}

// MARK: - Preview
struct ModernAddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        ModernAddTaskView(tasks: .constant([]))
    }
}
