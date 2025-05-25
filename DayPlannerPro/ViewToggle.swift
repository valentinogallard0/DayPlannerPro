//
//  ViewToggle.swift
//  DayPlannerPro
//
//  Created by Valentino De Paola Gallardo on 25/05/25.
//

import SwiftUI

enum ViewMode: String, CaseIterable {
    case list = "Lista"
    case calendar = "Timeline"
    
    var icon: String {
        switch self {
        case .list: return "list.bullet"
        case .calendar: return "calendar"
        }
    }
}

struct ViewToggle: View {
    @Binding var selectedMode: ViewMode
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(ViewMode.allCases, id: \.self) { mode in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedMode = mode
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: mode.icon)
                            .font(.caption)
                        Text(mode.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(selectedMode == mode ? .white : .blue)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        selectedMode == mode ?
                        Color.blue : Color.clear
                    )
                    .cornerRadius(8)
                }
            }
        }
        .padding(4)
        .background(Color(.systemGray5))
        .cornerRadius(12)
    }
}
