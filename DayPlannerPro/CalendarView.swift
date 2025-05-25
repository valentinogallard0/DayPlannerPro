//
//  CalendarView.swift
//  DayPlannerPro
//
//  Created by Valentino De Paola Gallardo on 25/05/25.
//

import SwiftUI

struct CalendarView: View {
    @Binding var tasks: [Task]
    @Binding var selectedDate: Date
    let onAddTask: () -> Void
    
    @State private var currentWeek = Date()
    @State private var selectedHour: Int? = nil
    
    private let calendar = Calendar.current
    private let hourHeight: CGFloat = 60
    
    var body: some View {
        VStack(spacing: 0) {
            // Header con navegación de semana
            weekHeader
            
            // Días de la semana
            weekDaysHeader
            
            // Timeline principal
            timelineView
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            // Seleccionar automáticamente el día actual si es la primera vez
            if calendar.isDateInToday(currentWeek) {
                selectedDate = Date()
            }
        }
    }
    
    // MARK: - Week Header
    private var weekHeader: some View {
        HStack {
            Button(action: previousWeek) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            Text(weekTitle)
                .font(.title2)
                .fontWeight(.bold)
            
            Spacer()
            
            Button(action: nextWeek) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Week Days Header
    private var weekDaysHeader: some View {
        HStack(spacing: 0) {
            // Espacio para las horas
            VStack {
                Text("")
                    .font(.caption)
                Text("")
                    .font(.caption2)
            }
            .frame(width: 50)
            
            // Días de la semana
            ForEach(weekDays, id: \.self) { date in
                VStack(spacing: 4) {
                    Text(dayFormatter.string(from: date))
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text(dayNumberFormatter.string(from: date))
                        .font(.title3)
                        .fontWeight(calendar.isDate(date, inSameDayAs: selectedDate) ? .bold : .medium)
                        .foregroundColor(calendar.isDate(date, inSameDayAs: selectedDate) ? .white :
                                       (calendar.isDateInToday(date) ? .blue : .primary))
                        .frame(width: 32, height: 32)
                        .background(
                            calendar.isDate(date, inSameDayAs: selectedDate) ?
                            Color.blue : (calendar.isDateInToday(date) ? Color.blue.opacity(0.1) : Color.clear)
                        )
                        .clipShape(Circle())
                }
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    selectedDate = date
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Timeline View
    private var timelineView: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                ZStack(alignment: .topLeading) {
                    // Grid de fondo
                    timelineGrid
                    
                    // Tareas superpuestas
                    tasksOverlay
                    
                    // Línea de tiempo actual
                    if calendar.isDate(selectedDate, inSameDayAs: Date()) {
                        currentTimeLine
                    }
                }
                .padding(.horizontal)
            }
            .onAppear {
                // Scroll automático a la hora actual
                if calendar.isDateInToday(selectedDate) {
                    let currentHour = calendar.component(.hour, from: Date())
                    withAnimation(.easeInOut(duration: 1.0)) {
                        proxy.scrollTo("hour-\(currentHour)", anchor: .center)
                    }
                }
            }
            .background(Color(.systemBackground))
        }
    }
    
    // MARK: - Timeline Grid
    private var timelineGrid: some View {
        VStack(spacing: 0) {
            ForEach(0..<24, id: \.self) { hour in
                HStack(spacing: 0) {
                    // Etiqueta de hora
                    VStack(alignment: .trailing) {
                        if hour > 0 {
                            Text(hourString(for: hour))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .frame(width: 50, height: hourHeight)
                    
                    // Línea separadora y área de contenido
                    VStack(spacing: 0) {
                        if hour > 0 {
                            Rectangle()
                                .fill(Color(.systemGray4))
                                .frame(height: 0.5)
                        }
                        
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: hourHeight - (hour > 0 ? 0.5 : 0))
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedHour = hour
                                onAddTask()
                            }
                    }
                }
                .id("hour-\(hour)")
            }
        }
    }
    
    // MARK: - Tasks Overlay
    private var tasksOverlay: some View {
        ForEach(tasksForSelectedDay, id: \.id) { task in
            TaskTimelineBlock(
                task: task,
                hourHeight: hourHeight,
                onToggle: {
                    toggleTaskCompletion(task)
                },
                onTap: {
                    // Aquí se podría abrir edición de tarea
                }
            )
            .offset(x: 50) // Offset para alinear con el grid
        }
    }
    
    // MARK: - Current Time Line
    private var currentTimeLine: some View {
        let now = Date()
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let offsetY = CGFloat(hour) * hourHeight + (CGFloat(minute) / 60.0) * hourHeight
        
        return HStack(spacing: 0) {
            Circle()
                .fill(Color.red)
                .frame(width: 8, height: 8)
                .offset(x: 46) // Alinear con el borde izquierdo del grid
            
            Rectangle()
                .fill(Color.red)
                .frame(height: 1)
        }
        .offset(y: offsetY)
    }
    
    // MARK: - Computed Properties
    private var weekDays: [Date] {
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: currentWeek)?.start ?? currentWeek
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: startOfWeek)
        }
    }
    
    private var weekTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        
        let startOfWeek = weekDays.first ?? currentWeek
        let endOfWeek = weekDays.last ?? currentWeek
        
        if calendar.isDate(startOfWeek, equalTo: endOfWeek, toGranularity: .month) {
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: startOfWeek)
        } else {
            formatter.dateFormat = "MMM"
            let startMonth = formatter.string(from: startOfWeek)
            let endMonth = formatter.string(from: endOfWeek)
            
            let yearFormatter = DateFormatter()
            yearFormatter.dateFormat = "yyyy"
            let year = yearFormatter.string(from: endOfWeek)
            
            return "\(startMonth) - \(endMonth) \(year)"
        }
    }
    
    private var tasksForSelectedDay: [Task] {
        tasks.filter { calendar.isDate($0.scheduledTime, inSameDayAs: selectedDate) }
    }
    
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "E"
        return formatter
    }
    
    private var dayNumberFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }
    
    // MARK: - Functions
    private func previousWeek() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: currentWeek) ?? currentWeek
        }
    }
    
    private func nextWeek() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: currentWeek) ?? currentWeek
        }
    }
    
    private func hourString(for hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = hour < 12 ? "h a" : "h a"
        formatter.locale = Locale(identifier: "es_ES")
        
        let date = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: Date()) ?? Date()
        return formatter.string(from: date)
    }
    
    private func toggleTaskCompletion(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
        }
    }
}

// MARK: - Task Timeline Block
struct TaskTimelineBlock: View {
    let task: Task
    let hourHeight: CGFloat
    let onToggle: () -> Void
    let onTap: () -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        let startHour = calendar.component(.hour, from: task.scheduledTime)
        let startMinute = calendar.component(.minute, from: task.scheduledTime)
        let offsetY = CGFloat(startHour) * hourHeight + (CGFloat(startMinute) / 60.0) * hourHeight
        
        HStack(spacing: 8) {
            // Línea de categoría
            Rectangle()
                .fill(task.category.color)
                .frame(width: 4)
            
            // Contenido
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(task.title)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(task.isCompleted ? .secondary : .primary)
                        .strikethrough(task.isCompleted)
                    
                    Spacer()
                    
                    Button(action: onToggle) {
                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.caption)
                            .foregroundColor(task.isCompleted ? .green : .gray)
                    }
                }
                
                Text(task.scheduledTime, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            task.isCompleted ?
            Color(.systemGray5) : task.category.color.opacity(0.1)
        )
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(task.category.color.opacity(0.3), lineWidth: 0.5)
        )
        .frame(minHeight: 40)
        .offset(y: offsetY)
        .onTapGesture {
            onTap()
        }
        .opacity(task.isCompleted ? 0.7 : 1.0)
    }
}
