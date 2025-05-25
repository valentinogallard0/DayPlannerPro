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
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header con fecha y resumen
                HeaderView(
                    selectedDate: selectedDate,
                    totalTasks: filteredTasks.count,
                    completedTasks: completedTasksCount
                )
                
                // Lista de tareas del día
                if filteredTasks.isEmpty {
                    EmptyStateView {
                        showingAddTask = true
                    }
                } else {
                    tasksList
                }
                
                Spacer()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Mi Día")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTask = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView(tasks: $tasks)
            }
        }
        .onAppear {
            loadSampleData()
        }
    }
    
    // MARK: - Lista de Tareas
    private var tasksList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(sortedTasks) { task in
                    TaskRowView(task: task) {
                        toggleTaskCompletion(task)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)
        }
    }
    
    // MARK: - Propiedades Computadas
    private var filteredTasks: [Task] {
        let calendar = Calendar.current
        return tasks.filter { calendar.isDate($0.scheduledTime, inSameDayAs: selectedDate) }
    }
    
    private var sortedTasks: [Task] {
        filteredTasks.sorted { $0.scheduledTime < $1.scheduledTime }
    }
    
    private var completedTasksCount: Int {
        filteredTasks.filter { $0.isCompleted }.count
    }
    
    // MARK: - Funciones
    private func toggleTaskCompletion(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
        }
    }
    
    private func loadSampleData() {
        if tasks.isEmpty {
            let sampleTasks = [
                Task(
                    title: "Reunión de equipo",
                    description: "Revisar avances del proyecto",
                    scheduledTime: Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date(),
                    alertTime: 15,
                    category: .work
                ),
                Task(
                    title: "Ejercicio matutino",
                    description: "30 minutos de cardio",
                    scheduledTime: Calendar.current.date(byAdding: .hour, value: -1, to: Date()) ?? Date(),
                    alertTime: 5,
                    category: .health
                ),
                Task(
                    title: "Llamar a mamá",
                    description: "Ponerse al día",
                    scheduledTime: Calendar.current.date(byAdding: .hour, value: 4, to: Date()) ?? Date(),
                    alertTime: 30,
                    category: .personal
                )
            ]
            tasks = sampleTasks
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
