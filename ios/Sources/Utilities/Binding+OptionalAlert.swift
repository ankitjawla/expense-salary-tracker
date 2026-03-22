//
//  Binding+OptionalAlert.swift
//  Expense & Salary Tracker
//

import SwiftUI

extension Binding where Value == String? {
    /// Use with `.alert(_:isPresented:)` when the alert message is stored as an optional string.
    /// Dismissing the alert sets the binding to `nil`.
    var alertPresented: Binding<Bool> {
        Binding<Bool>(
            get: { wrappedValue != nil },
            set: { presented in
                if !presented { wrappedValue = nil }
            }
        )
    }
}
