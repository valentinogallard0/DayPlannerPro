//
//  AddTaskView.swift
//  DayPlannerPro
//
//  Created by Valentino De Paola Gallardo on 25/05/25.
//
import SwiftUI

struct AddTaskView: View {
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
    
    // MARK: - Validation
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // Alert time options
    private let alertOptions = [5, 10, 15, 30, 60, 120] // minutes
    
    var body: some View {
        NavigationView {
            Form {
                // MARK: - Información Básica
                Section("Información Básica") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Título")
                            .font(.headline)
                        TextField("¿Qué necesitas hacer?", text: $title)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.vertical, 4)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Descripción")
                            .font(.headline)
                        TextField("Detalles adicionales (opcional)", text: $description, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...6)
                    }
                    .padding(.vertical, 4)
                }
                
                // MARK: - Programación
                Section("Programación") {
                    VStack(spacing: 16) {
                        // Selector de fecha
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.blue)
                                .frame(width: 20)
                            Text("Fecha")
                                .font(.headline)
                            Spacer()
                            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                                .labelsHidden()
                        }
                        
                        // Selector de hora
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.blue)
                                .frame(width: 20)
                            Text("Hora")
                                .font(.headline)
                            Spacer()
                            DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // MARK: - Categoría y Prioridad
                Section("Categorización") {
                    // Selector de categoría
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "folder")
                                .foregroundColor(.blue)
                                .frame(width: 20)
                            Text("Categoría")
                                .font(.headline)
                        }
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                            ForEach(TaskCategory.allCases, id: \.self) { category in
                                CategoryButton(
                                    category: category,
                                    isSelected: selectedCategory == category
                                ) {
                                    selectedCategory = category
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                    
                    // Selector de prioridad
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.blue)
                                .frame(width: 20)
                            Text("Prioridad")
                                .font(.headline)
                        }
                        
                        HStack(spacing: 12) {
                            ForEach(Priority.allCases, id: \.self) { priority in
                                PriorityButton(
                                    priority: priority,
                                    isSelected: selectedPriority == priority
                                ) {
                                    selectedPriority = priority
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // MARK: - Alertas
                Section("Recordatorios") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "bell")
                                .foregroundColor(.blue)
                                .frame(width: 20)
                            Text("Alerta")
                                .font(.headline)
                            Spacer()
                            Text("\(alertTime) min antes")
                                .foregroundColor(.secondary)
                        }
                        
                        // Selector de tiempo de alerta
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(alertOptions, id: \.self) { minutes in
                                    AlertTimeButton(
                                        minutes: minutes,
                                        isSelected: alertTime == minutes
                                    ) {
                                        alertTime = minutes
                                    }
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // MARK: - Vista Previa
                Section("Vista Previa") {
                    if !title.isEmpty {
                        TaskPreviewRow(
                            title: title,
                            description: description,
                            scheduledTime: combinedDateTime,
                            category: selectedCategory,
                            priority: selectedPriority,
                            alertTime: alertTime
                        )
                    } else {
                        Text("Escribe un título para ver la vista previa")
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
            }
            .navigationTitle("Nueva Tarea")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveTask()
                    }
                    .fontWeight(.semibold)
                    .disabled(title.isEmpty)
                }
            }
            .alert("Error", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
        .onAppear {
            // Si viene con fecha y hora preset desde el timeline
            if let preset = presetDate {
                selectedDate = preset
            }
            if let hour = presetHour {
                let calendar = Calendar.current
                if let newTime = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: selectedTime) {
                    selectedTime = newTime
                }
            }
        }
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
    private func saveTask() {
        // Validaciones
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alertMessage = "El título es obligatorio"
            showingAlert = true
            return
        }
        
        guard combinedDateTime > Date() else {
            alertMessage = "La fecha y hora deben ser en el futuro"
            showingAlert = true
            return
        }
        
        // Crear nueva tarea
        let newTask = Task(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            scheduledTime: combinedDateTime,
            alertTime: alertTime,
            category: selectedCategory,
            isCompleted: false,
            priority: selectedPriority
        )
        
        // Agregar a la lista
        tasks.append(newTask)
        
        // Cerrar modal
        dismiss()
    }
}

// MARK: - Category Button Component
struct CategoryButton: View {
    let category: TaskCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.caption)
                Text(category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .white : category.color)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? category.color : category.color.opacity(0.1))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(category.color, lineWidth: isSelected ? 0 : 1)
            )
        }
    }
}

// MARK: - Priority Button Component
struct PriorityButton: View {
    let priority: Priority
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(priority.rawValue)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : priority.color)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? priority.color : priority.color.opacity(0.1))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(priority.color, lineWidth: isSelected ? 0 : 1)
                )
        }
    }
}

// MARK: - Alert Time Button Component
struct AlertTimeButton: View {
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
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? .blue : .blue.opacity(0.1))
                .cornerRadius(6)
        }
    }
}

// MARK: - Task Preview Component
struct TaskPreviewRow: View {
    let title: String
    let description: String
    let scheduledTime: Date
    let category: TaskCategory
    let priority: Priority
    let alertTime: Int
    
    var body: some View {
        HStack(spacing: 12) {
            // Categoría
            VStack {
                Image(systemName: category.icon)
                    .font(.caption)
                    .foregroundColor(category.color)
                Text(category.rawValue)
                    .font(.caption2)
                    .foregroundColor(category.color)
            }
            .frame(width: 50)
            
            // Contenido
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .lineLimit(1)
                
                if !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack {
                    Text(scheduledTime, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("🔔 \(alertTime) min antes")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            
            Spacer()
            
            // Indicador de prioridad
            Rectangle()
                .fill(priority.color)
                .frame(width: 3, height: 40)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}
