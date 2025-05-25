//
//  TaskRowView.swift
//  DayPlannerPro
//
//  Created by Valentino De Paola Gallardo on 25/05/25.
//

import SwiftUI

struct TaskRowView: View {
    let task: Task
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Botón de completar
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(task.isCompleted ? .green : .gray)
            }
            
            // Contenido de la tarea
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    // Categoría e icono
                    HStack(spacing: 4) {
                        Image(systemName: task.category.icon)
                            .font(.caption)
                        Text(task.category.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(task.category.color)
                    
                    Spacer()
                    
                    // Hora programada
                    Text(task.scheduledTime, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Título y descripción
                VStack(alignment: .leading, spacing: 2) {
                    Text(task.title)
                        .font(.headline)
                        .strikethrough(task.isCompleted)
                        .foregroundColor(task.isCompleted ? .secondary : .primary)
                    
                    if !task.description.isEmpty {
                        Text(task.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                // Alert info
                HStack {
                    Image(systemName: "bell.fill")
                        .font(.caption2)
                    Text("Alerta \(task.alertTime) min antes")
                        .font(.caption2)
                }
                .foregroundColor(.orange)
            }
            
            Spacer()
            
            // Indicador de prioridad
            Rectangle()
                .fill(task.priority.color)
                .frame(width: 4)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .opacity(task.isCompleted ? 0.7 : 1.0)
    }
}
