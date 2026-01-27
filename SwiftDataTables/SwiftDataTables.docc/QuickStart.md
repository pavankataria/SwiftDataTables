# Quick Start

Jump straight into code with these ready-to-use examples.

## Overview

This page provides copy-paste examples for common scenarios. Each example is self-contained and ready to use.

## Basic Table with String Arrays

The simplest way to display data:

```swift
import SwiftDataTables

class BasicTableViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let data = [
            ["iPhone 15", "999", "In Stock"],
            ["MacBook Pro", "1999", "Limited"],
            ["iPad Air", "599", "In Stock"]
        ]

        let dataTable = SwiftDataTable(
            data: data,
            headerTitles: ["Product", "Price", "Status"]
        )

        view.addSubview(dataTable)
        dataTable.frame = view.bounds
        dataTable.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}
```

## Type-Safe Table with Models

Use your own model types for compile-time safety:

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
                .init("Salary") { .string("$\($0.salary.formatted())") }
            ]
        )

        view.addSubview(dataTable)
        dataTable.frame = view.bounds
        dataTable.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}
```

## Dynamic Updates with Animation

Update data smoothly without losing scroll position:

```swift
class DynamicTableViewController: UIViewController {
    var employees: [Employee] = []
    var dataTable: SwiftDataTable!

    let columns: [DataTableColumn<Employee>] = [
        .init("Name", \.name),
        .init("Department", \.department),
        .init("Salary") { .string("$\($0.salary.formatted())") }
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        dataTable = SwiftDataTable(data: employees, columns: columns)
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
        dataTable.setData(employees, columns: columns, animatingDifferences: true)
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

        let dataTable = SwiftDataTable(
            data: myData,
            headerTitles: headers,
            options: config
        )

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

        dataTable = SwiftDataTable(data: myData, headerTitles: headers)
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

Optimize for massive datasets:

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
