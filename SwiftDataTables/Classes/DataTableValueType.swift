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
    case string(String)
    case int(Int)
    case float(Float)
    case double(Double)
    
    var stringRepresentation: String {
        get {
            switch self {
            case .string(let value):
                return String(value)
            case .int(let value):
                return String(value)
            case .float(let value):
                return String(value)
            case .double(let value):
                return String(value)
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
