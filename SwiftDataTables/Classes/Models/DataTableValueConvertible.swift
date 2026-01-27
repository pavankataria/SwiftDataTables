//
//  DataTableValueConvertible.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 22/01/2026.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import Foundation

/// A type that can be converted to `DataTableValueType` for display in a data table.
///
/// Conform your model property types to this protocol to enable automatic column
/// mapping with the typed API. The library provides default conformances for
/// common types including `String`, `Int`, `Float`, `Double`, and their optionals.
///
/// ## Built-in Conformances
///
/// The following types conform out of the box:
/// - `String` → `.string(_)`
/// - `Int` → `.int(_)`
/// - `Float` → `.float(_)`
/// - `Double` → `.double(_)`
/// - `Optional<T>` where `T: DataTableValueConvertible` → unwraps or returns `.string("")`
/// - `DataTableValueType` → returns itself
///
/// ## Custom Conformance
///
/// Add conformance for your own types:
/// ```swift
/// extension Date: DataTableValueConvertible {
///     public func asDataTableValue() -> DataTableValueType {
///         let formatter = DateFormatter()
///         formatter.dateStyle = .short
///         return .string(formatter.string(from: self))
///     }
/// }
///
/// extension Decimal: DataTableValueConvertible {
///     public func asDataTableValue() -> DataTableValueType {
///         return .double(NSDecimalNumber(decimal: self).doubleValue)
///     }
/// }
/// ```
///
/// ## Usage with Typed API
///
/// Properties that conform to this protocol work automatically with `DataTableColumn`:
/// ```swift
/// struct User: Identifiable {
///     let id: Int
///     let name: String      // String conforms
///     let balance: Double   // Double conforms
///     let joinDate: Date    // Add conformance above
/// }
///
/// let columns: [DataTableColumn<User>] = [
///     .init("Name", \.name),
///     .init("Balance", \.balance),
///     .init("Joined", \.joinDate)
/// ]
/// ```
public protocol DataTableValueConvertible {

    /// Converts this value to a `DataTableValueType` for table display.
    ///
    /// - Returns: The appropriate value type for this instance.
    func asDataTableValue() -> DataTableValueType
}

// MARK: - Standard Type Conformances

extension String: DataTableValueConvertible {

    /// Converts the string to a data table value.
    ///
    /// - Returns: `.string(self)`
    public func asDataTableValue() -> DataTableValueType {
        return .string(self)
    }
}

extension Int: DataTableValueConvertible {

    /// Converts the integer to a data table value.
    ///
    /// - Returns: `.int(self)`
    public func asDataTableValue() -> DataTableValueType {
        return .int(self)
    }
}

extension Float: DataTableValueConvertible {

    /// Converts the float to a data table value.
    ///
    /// - Returns: `.float(self)`
    public func asDataTableValue() -> DataTableValueType {
        return .float(self)
    }
}

extension Double: DataTableValueConvertible {

    /// Converts the double to a data table value.
    ///
    /// - Returns: `.double(self)`
    public func asDataTableValue() -> DataTableValueType {
        return .double(self)
    }
}

// MARK: - Optional Support

extension Optional: DataTableValueConvertible where Wrapped: DataTableValueConvertible {

    /// Converts the optional to a data table value.
    ///
    /// - Returns: The wrapped value's conversion if present, or `.string("")` if nil.
    public func asDataTableValue() -> DataTableValueType {
        switch self {
        case .some(let value):
            return value.asDataTableValue()
        case .none:
            return .string("")
        }
    }
}

// MARK: - DataTableValueType Self-Conformance

extension DataTableValueType: DataTableValueConvertible {

    /// Returns self, as `DataTableValueType` already represents a table value.
    ///
    /// - Returns: `self`
    public func asDataTableValue() -> DataTableValueType {
        return self
    }
}
