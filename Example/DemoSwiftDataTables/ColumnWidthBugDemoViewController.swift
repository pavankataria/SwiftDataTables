//
//  ColumnWidthBugDemoViewController.swift
//  SwiftDataTables
//
//  Demo to show column width bug - uses average instead of max width
//

import UIKit
import SwiftDataTables

/// Demonstrates GitHub Issue #74: Column width uses average instead of max
///
/// The "Notes" column has 9 empty rows and 1 row with long text.
/// With average calculation: column width ≈ long_text_width / 10 = too narrow
/// With max calculation: column width = long_text_width = correct
class ColumnWidthBugDemoViewController: UIViewController {

    lazy var dataTable = makeDataTable()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }

    func setupViews() {
        title = "Column Width Bug Demo"
        view.backgroundColor = UIColor.white
        view.addSubview(dataTable)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            dataTable.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            dataTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dataTable.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            dataTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    func makeDataTable() -> SwiftDataTable {
        let dataTable = SwiftDataTable(
            data: bugDemoData(),
            headerTitles: ["ID", "Name", "Notes"],
            options: DataTableConfiguration()
        )
        dataTable.translatesAutoresizingMaskIntoConstraints = false
        dataTable.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        return dataTable
    }

    /// Test data where "Notes" column has mostly empty values but one long value
    /// This causes the average width to be much smaller than the max width needed
    func bugDemoData() -> [[DataTableValueType]] {
        return [
            [.int(1), .string("Alice"), .string("")],
            [.int(2), .string("Bob"), .string("")],
            [.int(3), .string("Charlie"), .string("This is a very long note that should determine the column width but gets truncated because we use average instead of max")],
            [.int(4), .string("Diana"), .string("")],
            [.int(5), .string("Eve"), .string("")],
            [.int(6), .string("Frank"), .string("")],
            [.int(7), .string("Grace"), .string("")],
            [.int(8), .string("Henry"), .string("")],
            [.int(9), .string("Ivy"), .string("")],
            [.int(10), .string("Jack"), .string("")],
        ]
    }
}
