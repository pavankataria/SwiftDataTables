# Quick Start

Jump straight into code with these ready-to-use examples.

## Overview

This page provides copy-paste examples for common scenarios. Each example is self-contained and ready to use.

## Basic Table

The simplest way to display data. Models conform to `Identifiable` so SwiftDataTables can track rows for animated updates:

```swift
import SwiftDataTables

struct Product: Identifiable {
    let id: Int
    let name: String
    let price: Int
    let status: String
}

class BasicTableViewController: UIViewController {
    let products = [
        Product(id: 1, name: "iPhone 15", price: 999, status: "In Stock"),
        Product(id: 2, name: "MacBook Pro", price: 1999, status: "Limited"),
        Product(id: 3, name: "iPad Air", price: 599, status: "In Stock")
    ]

    let columns: [DataTableColumn<Product>] = [
        .init("Product", \.name),
        .init("Price") { "$\($0.price)" },
        .init("Status", \.status)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        let dataTable = SwiftDataTable(data: products, columns: columns)

        view.addSubview(dataTable)
        dataTable.frame = view.bounds
        dataTable.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}
```

## Type-Safe Table with Models

Key paths like `\.name` give you compile-time safety - if you rename a property, Xcode catches it immediately instead of failing silently at runtime:

```swift
import SwiftDataTables

struct Employee: Identifiable {
    let id: Int
    let name: String
    let department: String
    let salary: Int
}

class TypedTableViewController: UIViewController {
    let employees = [
        Employee(id: 1, name: "Alice", department: "Engineering", salary: 95000),
        Employee(id: 2, name: "Bob", department: "Design", salary: 85000),
        Employee(id: 3, name: "Carol", department: "Marketing", salary: 78000)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        let dataTable = SwiftDataTable(
            data: employees,
            columns: [
                .init("Name", \.name),
                .init("Department", \.department),
                .init("Salary") { "$\($0.salary.formatted())" }
            ]
        )

        view.addSubview(dataTable)
        dataTable.frame = view.bounds
        dataTable.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}
```

## Dynamic Updates with Animation

Because your model is `Identifiable`, SwiftDataTables calculates exactly what changed and animates only those rows. Scroll position is preserved - your users won't lose their place:

```swift
class DynamicTableViewController: UIViewController {
    var employees: [Employee] = []
    var dataTable: SwiftDataTable!

    let columns: [DataTableColumn<Employee>] = [
        .init("Name", \.name),
        .init("Department", \.department),
        .init("Salary") { "$\($0.salary.formatted())" }
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        dataTable = SwiftDataTable(data: employees)
        view.addSubview(dataTable)
        dataTable.frame = view.bounds

        // Add a refresh button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Refresh",
            style: .plain,
            target: self,
            action: #selector(refreshData)
        )
    }

    @objc func refreshData() {
        // Simulate fetching new data
        employees = fetchEmployeesFromAPI()

        // Update with animation - scroll position preserved!
        dataTable.setData(employees, animatingDifferences: true)
    }
}
```

## Custom Configuration

Customize appearance and behavior:

```swift
class CustomTableViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        var config = DataTableConfiguration()

        // Row heights
        config.rowHeightMode = .automatic(estimated: 60)

        // Text wrapping for long content
        config.textLayout = .wrap

        // Column widths
        config.columnWidthMode = .fitContentText(strategy: .hybrid(sampleSize: 100, averageCharWidth: 7))
        config.minColumnWidth = 80
        config.maxColumnWidth = 300

        // Floating headers
        config.shouldSectionHeadersFloat = true
        config.shouldSectionFootersFloat = true

        // Hide search bar
        config.shouldShowSearchSection = false

        // Alternating row colors
        config.highlightedAlternatingRowColors = [
            UIColor.systemGray6,
            UIColor.systemBackground
        ]
        config.unhighlightedAlternatingRowColors = [
            UIColor.systemGray5,
            UIColor.systemGray6
        ]

        let dataTable = SwiftDataTable(data: items, columns: columns, options: config)

        view.addSubview(dataTable)
    }
}
```

## Navigation Bar Search

Use iOS native search instead of embedded search bar:

```swift
class SearchTableViewController: UIViewController {
    var dataTable: SwiftDataTable!

    override func viewDidLoad() {
        super.viewDidLoad()

        dataTable = SwiftDataTable(columns: columns)
        view.addSubview(dataTable)
        dataTable.frame = view.bounds

        // One line to enable navigation bar search
        dataTable.installSearchController(on: self)
    }
}
```

## Fixed Columns

Freeze columns while scrolling horizontally:

```swift
var config = DataTableConfiguration()
config.fixedColumns = .left(count: 1)  // Freeze first column

// Or freeze columns on the right
config.fixedColumns = .right(count: 2)

// Or freeze on both sides
config.fixedColumns = .both(left: 1, right: 1)
```

## Large Datasets (100k+ Rows)

For massive datasets, use lazy measurement. Only visible rows are measured; others use the estimated height until they scroll into view. The `prefetchWindow` controls how many rows ahead to pre-measure:

```swift
var config = DataTableConfiguration()
config.rowHeightMode = .automatic(estimated: 44, prefetchWindow: 10)

let dataTable = SwiftDataTable(
    data: massiveDataset,  // 100,000+ rows
    columns: columns,
    options: config
)
```

## Next Steps

Explore these guides to learn more:

- <doc:TypeSafeColumns> - Deep dive into the typed API
- <doc:AnimatedUpdates> - Master data updates
- <doc:CustomCells> - Create custom cell layouts
