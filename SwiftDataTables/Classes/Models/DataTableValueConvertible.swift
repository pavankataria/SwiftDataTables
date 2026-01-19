//
//  DataTableValueConvertible.swift
//  SwiftDataTables
//
//  Created for SwiftDataTables.
//

import Foundation

/// Protocol for types that can be converted to DataTableValueType.
/// Conform your model properties to this protocol for automatic column mapping.
public protocol DataTableValueConvertible {
    func asDataTableValue() -> DataTableValueType
}

// MARK: - Standard Type Conformances

extension String: DataTableValueConvertible {
    public func asDataTableValue() -> DataTableValueType {
        return .string(self)
    }
}

extension Int: DataTableValueConvertible {
    public func asDataTableValue() -> DataTableValueType {
        return .int(self)
    }
}

extension Float: DataTableValueConvertible {
    public func asDataTableValue() -> DataTableValueType {
        return .float(self)
    }
}

extension Double: DataTableValueConvertible {
    public func asDataTableValue() -> DataTableValueType {
        return .double(self)
    }
}

// MARK: - Optional Support

extension Optional: DataTableValueConvertible where Wrapped: DataTableValueConvertible {
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
    public func asDataTableValue() -> DataTableValueType {
        return self
    }
}
