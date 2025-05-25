//
//  EmptyStateView.swift
//  DayPlannerPro
//
//  Created by Valentino De Paola Gallardo on 25/05/25.
//

import SwiftUI

struct EmptyStateView: View {
    let onAddTask: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text("¡Planifica tu día!")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Agrega tareas para organizar tu jornada")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: onAddTask) {
                HStack {
                    Image(systemName: "plus")
                    Text("Agregar Primera Tarea")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }
        }
        .padding()
    }
}
