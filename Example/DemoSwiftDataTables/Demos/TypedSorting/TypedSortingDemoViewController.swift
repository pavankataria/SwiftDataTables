//
//  TypedSortingDemoViewController.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 29/01/2026.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import UIKit
import SwiftDataTables

/// Demo showcasing typed sorting: formatted display values that sort by their underlying type.
///
/// This demo shows how columns like "$1,234.56" can display formatted strings
/// while still sorting numerically by the underlying value.
final class TypedSortingDemoViewController: UIViewController {

    // MARK: - Model

    private struct Product: Identifiable {
        let id: Int
        let name: String
        let price: Double
        let quantity: Int
        let lastUpdated: Date

        var total: Double { price * Double(quantity) }
    }

    // MARK: - Data

    private let products: [Product] = [
        Product(id: 1, name: "Widget", price: 29.99, quantity: 100, lastUpdated: Date().addingTimeInterval(-86400 * 5)),
        Product(id: 2, name: "Gadget", price: 9.99, quantity: 500, lastUpdated: Date().addingTimeInterval(-86400 * 2)),
        Product(id: 3, name: "Appliance", price: 199.99, quantity: 10, lastUpdated: Date().addingTimeInterval(-86400 * 10)),
        Product(id: 4, name: "Tool", price: 49.99, quantity: 75, lastUpdated: Date().addingTimeInterval(-86400 * 1)),
        Product(id: 5, name: "Equipment", price: 149.99, quantity: 25, lastUpdated: Date().addingTimeInterval(-86400 * 7)),
        Product(id: 6, name: "Device", price: 79.99, quantity: 200, lastUpdated: Date().addingTimeInterval(-86400 * 3)),
        Product(id: 7, name: "Component", price: 4.99, quantity: 1000, lastUpdated: Date()),
        Product(id: 8, name: "Module", price: 249.99, quantity: 5, lastUpdated: Date().addingTimeInterval(-86400 * 15)),
    ]

    // MARK: - Columns

    /// Columns demonstrating different typed sorting approaches
    private lazy var columns: [DataTableColumn<Product>] = [
        // Simple keypath - sorts by name alphabetically
        .init("Name", \.name),

        // KeyPath + Format: displays "$29.99", sorts numerically by 29.99
        .init("Price", \.price) { "$\(String(format: "%.2f", $0))" },

        // Simple keypath for quantity
        .init("Qty", \.quantity),

        // Computed value: displays total, sorts by computed total
        .init("Total", sortedBy: { $0.total }) { product in
            "$\(String(format: "%.2f", product.total))"
        },

        // Date formatting: displays "Jan 29", sorts chronologically
        .init("Updated", \.lastUpdated) { date in
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        },
    ]

    // MARK: - UI

    private let instructions = InstructionsView(
        description: "Typed sorting: formatted values sort by their underlying type. Price displays '$29.99' but sorts numerically. Total is computed. Dates display abbreviated but sort chronologically.",
        config: "Tap column headers to sort. Notice Price and Total sort numerically, not alphabetically."
    )

    private lazy var dataTable: SwiftDataTable = {
        var config = DataTableConfiguration()
        config.shouldContentWidthScaleToFillFrame = false

        let table = SwiftDataTable(data: products, columns: columns, options: config)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        return table
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Typed Sorting"
        view.backgroundColor = .systemBackground

        view.addSubview(instructions)
        view.addSubview(dataTable)

        NSLayoutConstraint.activate([
            instructions.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            instructions.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            instructions.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            dataTable.topAnchor.constraint(equalTo: instructions.bottomAnchor, constant: 12),
            dataTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dataTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dataTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}
