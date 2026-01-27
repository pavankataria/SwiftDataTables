//
//  DataTableValueType.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 12/03/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import Foundation

/// A type-safe wrapper for cell values in a data table.
///
/// `DataTableValueType` provides a unified representation for different primitive types
/// that can be displayed in table cells. It supports strings, integers, floats, and doubles,
/// with automatic type detection and proper sorting behavior.
///
/// ## Overview
///
/// Each cell in a ``SwiftDataTable`` contains a `DataTableValueType` value. The type
/// preserves the original data type for proper sorting (numeric vs alphabetic) while
/// providing a common interface for display.
///
/// ## Creating Values
///
/// You can create values explicitly using the enum cases:
///
/// ```swift
/// let name: DataTableValueType = .string("John Doe")
/// let age: DataTableValueType = .int(25)
/// let price: DataTableValueType = .double(19.99)
/// let rating: DataTableValueType = .float(4.5)
/// ```
///
/// Or use the automatic type-detecting initializer:
///
/// ```swift
/// let value = DataTableValueType(42)        // .int(42)
/// let value = DataTableValueType(3.14)      // .double(3.14)
/// let value = DataTableValueType("Hello")   // .string("Hello")
/// ```
///
/// ## Sorting Behavior
///
/// Values of the same type are compared using their natural ordering:
/// - Strings: Alphabetical comparison
/// - Numbers: Numeric comparison
///
/// When comparing values of different types, the string representation is used
/// as a fallback for consistent ordering.
///
/// ## Display
///
/// Use ``stringRepresentation`` to get a displayable string for any value:
///
/// ```swift
/// let value: DataTableValueType = .double(19.99)
/// print(value.stringRepresentation)  // "19.99"
/// ```
///
/// - Note: For type-safe data binding with model objects, consider using
///   ``DataTableColumn`` with the typed API instead of raw `DataTableValueType` arrays.
///
/// - SeeAlso: ``DataTableRow``, ``DataTableContent``, ``DataTableValueConvertible``
public enum DataTableValueType {

    // MARK: - Cases

    /// A string value.
    case string(String)

    /// An integer value.
    case int(Int)

    /// A single-precision floating-point value.
    case float(Float)

    /// A double-precision floating-point value.
    case double(Double)

    // MARK: - Properties

    /// A string representation of the value suitable for display.
    ///
    /// This property converts any value type to its string form:
    /// - `.string("Hello")` → `"Hello"`
    /// - `.int(42)` → `"42"`
    /// - `.float(3.14)` → `"3.14"`
    /// - `.double(19.99)` → `"19.99"`
    public var stringRepresentation: String {
        switch self {
        case .string(let value):
            return value
        case .int(let value):
            return String(value)
        case .float(let value):
            return String(value)
        case .double(let value):
            return String(value)
        }
    }

    // MARK: - Initialization

    /// Creates a value by automatically detecting the type of the input.
    ///
    /// This initializer attempts to preserve the original type of the value:
    /// 1. If the value is `Int`, `Float`, or `Double`, it uses that type directly
    /// 2. Otherwise, it converts to a string and attempts to parse as a number
    /// 3. Falls back to `.string` if no numeric type matches
    ///
    /// - Parameter value: Any value to wrap. The type is detected automatically.
    ///
    /// ## Example
    ///
    /// ```swift
    /// DataTableValueType(42)       // .int(42)
    /// DataTableValueType(3.14)     // .double(3.14)
    /// DataTableValueType("Hello")  // .string("Hello")
    /// DataTableValueType("123")    // .int(123) - parsed from string
    /// ```
    ///
    /// - Note: String values that look like numbers (e.g., `"123"`) will be
    ///   converted to their numeric type. Use `.string("123")` explicitly
    ///   if you need to preserve the string type.
    public init(_ value: Any) {
        switch value {
        case let value as Int:
            self = .int(value)
        case let value as Float:
            self = .float(value)
        case let value as Double:
            self = .double(value)
        default:
            let temporaryStringRepresentation = String(describing: value)
            if let value = Int(temporaryStringRepresentation) {
                self = .int(value)
            }
            else if let value = Float(temporaryStringRepresentation) {
                self = .float(value)
            }
            else if let value = Double(temporaryStringRepresentation) {
                self = .double(value)
            }
            else {
                self = .string(temporaryStringRepresentation)
            }
        }
    }
}

// MARK: - Comparable

extension DataTableValueType: Comparable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is determined by comparing string representations.
    public static func == (lhs: DataTableValueType, rhs: DataTableValueType) -> Bool {
        return lhs.stringRepresentation == rhs.stringRepresentation
    }

    /// Returns a Boolean value indicating whether the first value is less than the second.
    ///
    /// When both values are the same type, native comparison is used:
    /// - Strings: Alphabetical ordering
    /// - Numbers: Numeric ordering
    ///
    /// For mixed types, string representation comparison is used as a fallback.
    public static func < (lhs: DataTableValueType, rhs: DataTableValueType) -> Bool {
        switch (lhs, rhs) {
        case (.string(let lhsValue), .string(let rhsValue)):
            return lhsValue < rhsValue
        case (.int(let lhsValue), .int(let rhsValue)):
            return lhsValue < rhsValue
        case (.float(let lhsValue), .float(let rhsValue)):
            return lhsValue < rhsValue
        case (.double(let lhsValue), .double(let rhsValue)):
            return lhsValue < rhsValue
        default:
            return lhs.stringRepresentation < rhs.stringRepresentation
        }
    }
}
