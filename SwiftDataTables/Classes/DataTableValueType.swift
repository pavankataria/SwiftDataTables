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
}
