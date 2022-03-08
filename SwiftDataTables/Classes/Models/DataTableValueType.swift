//
//  DataTableDataType.swift
//  Pods
//
//  Created by Pavan Kataria on 12/03/2017.
//
//

import Foundation

//MARK: - TODO: 11 march - TODO: See if you can make the multidimensional array a generic object so that it can accept any value type.
//This will probably make sorting easier and could potenntially allow us to get rid of this class

public enum DataTableValueType {
    
    //MARK: - Properties
    case string(String, String? = nil)
    case int(Int, String? = nil)
    case float(Float, String? = nil)
    case double(Double, String? = nil)
    
    public var stringRepresentation: String {
        get {
            switch self {
            case .string(let value, let format):
                if let format = format {
                    return String(format: format, value)
                } else {
                    return String(value)
                }
            case .int(let value, let format):
                if let format = format {
                    return String(format: format, value)
                } else {
                    return String(value)
                }
            case .float(let value, let format):
                if let format = format {
                    return String(format: format, value)
                } else {
                    return String(value)
                }
            case .double(let value, let format):
                if let format = format {
                    return String(format: format, value)
                } else {
                    return String(value)
                }
            }
        }
    }
    
    public init(_ value: Any){
        //Determine the actual type first
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

extension DataTableValueType: Comparable {
    public static func == (lhs: DataTableValueType, rhs: DataTableValueType) -> Bool {
        return lhs.stringRepresentation == rhs.stringRepresentation
    }
    public static func < (lhs: DataTableValueType, rhs: DataTableValueType) -> Bool {
        switch (lhs, rhs) {
        case (.string(let lhsValue, _), .string(let rhsValue, _)):
            return lhsValue < rhsValue
        case (.int(let lhsValue, _), .int(let rhsValue, _)):
            return lhsValue < rhsValue
        case (.float(let lhsValue, _), .float(let rhsValue, _)):
            return lhsValue < rhsValue
        case (.double(let lhsValue, _), .double(let rhsValue, _)):
            return lhsValue < rhsValue
        default:
            return lhs.stringRepresentation < rhs.stringRepresentation
        }
    }
}
