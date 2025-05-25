//
//  Task.swift
//  DayPlannerPro
//
//  Created by Valentino De Paola Gallardo on 25/05/25.
//

import SwiftUI
import Foundation

// MARK: - Task Model
struct Task: Identifiable, Codable {
    let id = UUID()
    var title: String
    var description: String
    var scheduledTime: Date
    var alertTime: Int // minutos antes
    var category: TaskCategory
    var isCompleted: Bool = false
    var priority: Priority = .medium
}

// MARK: - Task Category
enum TaskCategory: String, CaseIterable, Codable {
    case work = "Trabajo"
    case personal = "Personal"
    case health = "Salud"
    case social = "Social"
    case other = "Otro"
    
    var color: Color {
        switch self {
        case .work: return .blue
        case .personal: return .green
        case .health: return .red
        case .social: return .purple
        case .other: return .gray
        }
    }
    
    var icon: String {
        switch self {
        case .work: return "briefcase.fill"
        case .personal: return "house.fill"
        case .health: return "heart.fill"
        case .social: return "person.2.fill"
        case .other: return "star.fill"
        }
    }
}

// MARK: - Priority
enum Priority: String, CaseIterable, Codable {
    case high = "Alta"
    case medium = "Media"
    case low = "Baja"
    
    var color: Color {
        switch self {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
    }
}
