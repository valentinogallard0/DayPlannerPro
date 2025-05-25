//
//  HeaderView.swift
//  DayPlannerPro
//
//  Created by Valentino De Paola Gallardo on 25/05/25.
//

import SwiftUI

struct HeaderView: View {
    let selectedDate: Date
    let totalTasks: Int
    let completedTasks: Int
    
    private var progressValue: Double {
        guard totalTasks > 0 else { return 0 }
        return Double(completedTasks) / Double(totalTasks)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Fecha actual
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedDate, style: .date)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Hoy tienes \(totalTasks) tareas")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Progreso del día
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(completedTasks)/\(totalTasks)")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("Completadas")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            
            // Barra de progreso
            ProgressView(value: progressValue)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .scaleEffect(y: 2)
                .padding(.horizontal)
        }
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
}
