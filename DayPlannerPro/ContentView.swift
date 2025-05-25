//
//  ContentView.swift
//  DayPlannerPro
//
//  Created by Valentino De Paola Gallardo on 25/05/25.
//


import SwiftUI

struct ContentView: View {
    @State private var tasks: [Task] = []
    @State private var showingAddTask = false
    @State private var selectedDate = Date()
    @State private var viewMode: ViewMode = .list
    @State private var showingDatePicker = false
    @State private var editingTask: Task? = nil
    
    // Para animaciones
    @State private var hasAppeared = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient sutil
                backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Modern Header
                    modernHeader
                    
                    // Toggle para cambiar entre vistas
                    viewToggleSection
                    
                    // Contenido principal
                    mainContent
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddTask) {
                ModernAddTaskView(
                    tasks: $tasks,
                    presetDate: viewMode == .calendar ? selectedDate : nil
                )
                .onDisappear {
                    // Si estamos en vista calendario y se agregó una tarea,
                    // actualizamos la fecha seleccionada si es necesario
                    if viewMode == .calendar, let lastTask = tasks.last {
                        selectedDate = lastTask.scheduledTime
                    }
                }
            }
            .sheet(item: $editingTask) { task in
                // Aquí iría EditTaskView cuando lo implementemos
                ModernAddTaskView(tasks: $tasks)
            }
            .sheet(isPresented: $showingDatePicker) {
                DatePickerSheet(selectedDate: $selectedDate)
            }
        }
        .onAppear {
            loadSampleData()
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2)) {
                hasAppeared = true
            }
        }
    }
    
    // MARK: - Background Gradient
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color.surfacePrimary,
                Color.appPrimary.opacity(0.03),
                Color.appAccent.opacity(0.02)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Modern Header
    private var modernHeader: some View {
        ModernHeaderView(
            selectedDate: selectedDate,
            totalTasks: filteredTasks.count,
            completedTasks: completedTasksCount,
            onDateTap: {
                showingDatePicker = true
            },
            onProfileTap: {
                // Aquí se podría abrir configuraciones de perfil
                print("Profile tapped")
            }
        )
        .padding(.top, 8)
        .scaleEffect(hasAppeared ? 1.0 : 0.9)
        .opacity(hasAppeared ? 1.0 : 0.0)
        .animation(.spring(response: 0.8, dampingFraction: 0.8), value: hasAppeared)
    }
    
    // MARK: - View Toggle Section
    private var viewToggleSection: some View {
        HStack {
            Spacer()
            ModernViewToggle(selectedMode: $viewMode)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 16)
        .background(Color.surfacePrimary.opacity(0.7))
        .offset(y: hasAppeared ? 0 : 50)
        .opacity(hasAppeared ? 1.0 : 0.0)
        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.3), value: hasAppeared)
    }
    
    // MARK: - Main Content
    private var mainContent: some View {
        Group {
            switch viewMode {
            case .list:
                modernListView
            case .calendar:
                CalendarView(
                    tasks: $tasks,
                    selectedDate: $selectedDate,
                    onAddTask: {
                        showingAddTask = true
                    }
                )
            }
        }
        .animation(.easeInOut(duration: 0.4), value: viewMode)
        .offset(y: hasAppeared ? 0 : 100)
        .opacity(hasAppeared ? 1.0 : 0.0)
        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.5), value: hasAppeared)
    }
    
    // MARK: - Modern List View
    private var modernListView: some View {
        VStack(spacing: 0) {
            // Date navigation bar
            dateNavigationBar
            
            // Task list or empty state
            if filteredTasks.isEmpty {
                modernEmptyState
            } else {
                modernTasksList
            }
            
            Spacer()
        }
    }
    
    // MARK: - Date Navigation Bar
    private var dateNavigationBar: some View {
        HStack {
            Button(action: { changeDate(-1) }) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundColor(.appPrimary)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.surfaceSecondary))
                    .applyShadow(.small)
            }
            
            Spacer()
            
            VStack(spacing: 2) {
                Text(selectedDate.formatted(.dateTime.weekday(.wide)))
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                
                Text(selectedDate.formatted(.dateTime.day().month(.abbreviated)))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
            }
            
            Spacer()
            
            Button(action: { changeDate(1) }) {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundColor(.appPrimary)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.surfaceSecondary))
                    .applyShadow(.small)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(Color.surfacePrimary.opacity(0.8))
    }
    
    // MARK: - Modern Tasks List
    private var modernTasksList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(Array(sortedTasks.enumerated()), id: \.element.id) { index, task in
                    ModernTaskRowView(
                        task: task,
                        onToggle: {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                toggleTaskCompletion(task)
                            }
                        },
                        onEdit: {
                            editingTask = task
                        },
                        onDelete: {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                deleteTask(task)
                            }
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                        removal: .scale(scale: 0.8).combined(with: .opacity)
                    ))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 100) // Espacio para el FAB
        }
        .overlay(
            // Floating Action Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    modernFAB
                        .padding(.trailing, 24)
                        .padding(.bottom, 24)
                }
            }
        )
    }
    
    // MARK: - Modern Empty State
    private var modernEmptyState: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Illustration
            ZStack {
                Circle()
                    .fill(Color.appPrimary.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Circle()
                    .fill(Color.appPrimary.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 40, weight: .light))
                    .foregroundColor(.appPrimary)
            }
            
            // Text content
            VStack(spacing: 12) {
                Text(emptyStateTitle)
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(emptyStateSubtitle)
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            .padding(.horizontal, 40)
            
            // Action button
            Button(action: { showingAddTask = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.headline)
                    Text("Agregar Primera Tarea")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(Color.primaryGradient)
                .cornerRadius(16)
                .applyShadow(.medium)
            }
            .buttonStyle(ScaleButtonStyle())
            
            Spacer()
        }
        .scaleEffect(hasAppeared ? 1.0 : 0.8)
        .opacity(hasAppeared ? 1.0 : 0.0)
        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.7), value: hasAppeared)
    }
    
    // MARK: - Modern FAB
    private var modernFAB: some View {
        Button(action: { showingAddTask = true }) {
            Image(systemName: "plus")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(Color.primaryGradient)
                .clipShape(Circle())
                .applyShadow(.large)
        }
        .buttonStyle(ScaleButtonStyle())
        .scaleEffect(hasAppeared ? 1.0 : 0.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(1.0), value: hasAppeared)
    }
    
    // MARK: - Computed Properties
    private var filteredTasks: [Task] {
        let calendar = Calendar.current
        return tasks.filter { calendar.isDate($0.scheduledTime, inSameDayAs: selectedDate) }
    }
    
    private var sortedTasks: [Task] {
        filteredTasks.sorted { first, second in
            // Primero por completado (no completadas primero)
            if first.isCompleted != second.isCompleted {
                return !first.isCompleted
            }
            // Luego por tiempo
            return first.scheduledTime < second.scheduledTime
        }
    }
    
    private var completedTasksCount: Int {
        filteredTasks.filter { $0.isCompleted }.count
    }
    
    private var emptyStateTitle: String {
        if Calendar.current.isDateInToday(selectedDate) {
            return "¡Planifica tu día!"
        } else if selectedDate > Date() {
            return "Un día libre"
        } else {
            return "Día tranquilo"
        }
    }
    
    private var emptyStateSubtitle: String {
        if Calendar.current.isDateInToday(selectedDate) {
            return "Agrega tareas para organizar tu jornada y ser más productivo"
        } else if selectedDate > Date() {
            return "No tienes tareas programadas para este día. ¡Perfecto para relajarte!"
        } else {
            return "No tuviste tareas programadas para este día"
        }
    }
    
    // MARK: - Functions
    private func toggleTaskCompletion(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
        }
    }
    
    private func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
    }
    
    private func changeDate(_ days: Int) {
        withAnimation(.easeInOut(duration: 0.3)) {
            selectedDate = Calendar.current.date(byAdding: .day, value: days, to: selectedDate) ?? selectedDate
        }
    }
    
    private func loadSampleData() {
        if tasks.isEmpty {
            let calendar = Calendar.current
            let today = Date()
            
            let sampleTasks = [
                Task(
                    title: "Reunión de equipo",
                    description: "Revisar avances del proyecto",
                    scheduledTime: calendar.date(byAdding: .hour, value: 2, to: today) ?? today,
                    alertTime: 15,
                    category: .work
                ),
                Task(
                    title: "Ejercicio matutino",
                    description: "30 minutos de cardio",
                    scheduledTime: calendar.date(byAdding: .hour, value: -1, to: today) ?? today,
                    alertTime: 5,
                    category: .health
                ),
                Task(
                    title: "Llamar a mamá",
                    description: "Ponerse al día",
                    scheduledTime: calendar.date(byAdding: .hour, value: 4, to: today) ?? today,
                    alertTime: 30,
                    category: .personal
                ),
                // Agregar tareas para otros días
                Task(
                    title: "Cita médica",
                    description: "Chequeo anual",
                    scheduledTime: calendar.date(byAdding: .day, value: 1, to: today) ?? today,
                    alertTime: 60,
                    category: .health
                ),
                Task(
                    title: "Presentación proyecto",
                    description: "Demo para cliente",
                    scheduledTime: calendar.date(byAdding: .day, value: 2, to: today) ?? today,
                    alertTime: 30,
                    category: .work,
                    priority: .high
                ),
                Task(
                    title: "Cena con amigos",
                    description: "Restaurante italiano",
                    scheduledTime: calendar.date(byAdding: .day, value: -1, to: today) ?? today,
                    alertTime: 15,
                    category: .social
                )
            ]
            tasks = sampleTasks
        }
    }
}

// MARK: - Modern View Toggle
struct ModernViewToggle: View {
    @Binding var selectedMode: ViewMode
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(ViewMode.allCases, id: \.self) { mode in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedMode = mode
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: mode.icon)
                            .font(.system(size: 14, weight: .medium))
                        Text(mode.rawValue)
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(selectedMode == mode ? .white : .appPrimary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        Group {
                            if selectedMode == mode {
                                Capsule()
                                    .fill(Color.primaryGradient)
                                    .applyShadow(.small)
                            } else {
                                Capsule()
                                    .fill(Color.clear)
                            }
                        }
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(4)
        .background(
            Capsule()
                .fill(Color.surfaceSecondary)
                .applyShadow(.small)
        )
        .overlay(
            Capsule()
                .stroke(Color.borderSecondary, lineWidth: 1)
        )
    }
}

// MARK: - Date Picker Sheet
struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                DatePicker(
                    "Seleccionar Fecha",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding()
                
                Spacer()
            }
            .navigationTitle("Seleccionar Fecha")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Listo") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
