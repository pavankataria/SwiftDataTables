//
//  SampleData.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 27/02/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import Foundation

// MARK: - Sample Person Model

/// Sample Person model conforming to Identifiable for type-safe data table usage
public struct SamplePerson: Identifiable {
    public let id: Int
    public let name: String
    public let email: String
    public let phone: String
    public let city: String
    public let balance: String

    public init(id: Int, name: String, email: String, phone: String, city: String, balance: String) {
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        self.city = city
        self.balance = balance
    }
}

// MARK: - Sample Data

/// Returns sample Person data for demos (typed API)
public func samplePeople() -> [SamplePerson] {
    return [
        SamplePerson(id: 1, name: "Meggie Block", email: "meggie@example.com", phone: "(397) 102-5456", city: "New York", balance: "$876.06"),
        SamplePerson(id: 2, name: "Waldo Sporer", email: "waldo@example.com", phone: "(726) 447-9616", city: "London", balance: "$220.69"),
        SamplePerson(id: 3, name: "Vickie Stroman", email: "vickie@example.com", phone: "1-347-447-3401", city: "Tokyo", balance: "$340.64"),
        SamplePerson(id: 4, name: "Kiley Denesik", email: "kiley@example.com", phone: "069.128.7032", city: "Paris", balance: "$271.01"),
        SamplePerson(id: 5, name: "Shanie Langworth", email: "shanie@example.com", phone: "185-323-3421", city: "Sydney", balance: "$342.04"),
        SamplePerson(id: 6, name: "Clifford Green", email: "clifford@example.com", phone: "1-445-170-5544", city: "Berlin", balance: "$660.10"),
        SamplePerson(id: 7, name: "Lurline Rolfson", email: "lurline@example.com", phone: "1-839-002-7378", city: "Toronto", balance: "$401.82"),
        SamplePerson(id: 8, name: "Sallie Kiehn", email: "sallie@example.com", phone: "617-589-5786", city: "Singapore", balance: "$771.67"),
        SamplePerson(id: 9, name: "Rubie Walker", email: "rubie@example.com", phone: "(599) 852-8825", city: "Dubai", balance: "$743.72"),
        SamplePerson(id: 10, name: "Michale Prosacco", email: "michale@example.com", phone: "359-441-2319", city: "Mumbai", balance: "$121.52"),
        SamplePerson(id: 11, name: "Willa Kautzer", email: "willa@example.com", phone: "433-002-8109", city: "Amsterdam", balance: "$8.85"),
        SamplePerson(id: 12, name: "Ezra Erdman", email: "ezra@example.com", phone: "(664) 950-3514", city: "Madrid", balance: "$631.18"),
        SamplePerson(id: 13, name: "Fatima Conn", email: "fatima@example.com", phone: "568-341-9829", city: "Rome", balance: "$695.77"),
        SamplePerson(id: 14, name: "Ladarius Kautzer", email: "ladarius@example.com", phone: "627-225-2065", city: "Vienna", balance: "$396.39"),
        SamplePerson(id: 15, name: "Madeline Moen", email: "madeline@example.com", phone: "851-692-9961", city: "Prague", balance: "$151.96"),
        SamplePerson(id: 16, name: "Trever Senger", email: "trever@example.com", phone: "(074) 145-9347", city: "Dublin", balance: "$546.10"),
        SamplePerson(id: 17, name: "Jaycee Hane", email: "jaycee@example.com", phone: "(612) 926-0774", city: "Seoul", balance: "$59.69"),
        SamplePerson(id: 18, name: "Brigitte Monahan", email: "brigitte@example.com", phone: "457.890.1634", city: "Bangkok", balance: "$21.88"),
        SamplePerson(id: 19, name: "Mackenzie Gorczany", email: "mackenzie@example.com", phone: "1-214-143-6076", city: "Istanbul", balance: "$545.30"),
        SamplePerson(id: 20, name: "Shawna Collins", email: "shawna@example.com", phone: "1-952-483-1123", city: "Shanghai", balance: "$851.26"),
    ]
}

// MARK: - Legacy Data Format

/// Returns sample data in legacy [[Any]] format for backward compatibility
public func exampleDataSet() -> [[Any]] {
    return samplePeople().map { person in
        [person.id, person.name, person.email, person.phone, person.city, person.balance] as [Any]
    }
}
