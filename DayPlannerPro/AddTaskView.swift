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
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Formulario para agregar tarea")
                    .font(.title2)
                    .padding()
                
                Text("(Implementaremos esto en el siguiente paso)")
                    .foregroundColor(.secondary)
                
                Spacer()
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
                        // TODO: Implementar guardado
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
