# Getting Started

Add SwiftDataTables to your project and display your first table in minutes.

## Overview

This guide walks you through installing SwiftDataTables and creating your first data table. By the end, you'll have a working table displaying data with sorting and searching.

## Installation

### Swift Package Manager (Recommended)

Add SwiftDataTables via Xcode:

1. Open your project in Xcode
2. Go to **File → Add Package Dependencies...**
3. Enter the repository URL: `https://github.com/pavankataria/SwiftDataTables`
4. Select your version rules and add to your target

Or add it directly to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/pavankataria/SwiftDataTables", from: "0.9.0")
]
```

## Your First Table

### Step 1: Import the Framework

```swift
import SwiftDataTables
```

### Step 2: Define Your Model

Your model must conform to `Identifiable`. This enables SwiftDataTables to track individual rows - when you update data, rows animate smoothly (insertions slide in, deletions slide out) instead of the whole table reloading.

```swift
struct Employee: Identifiable {
    let id: Int  // Any Hashable type works: Int, String, UUID, etc.
    let name: String
    let role: String
    let city: String
}

let employees = [
    Employee(id: 1, name: "Alice", role: "Engineer", city: "London"),
    Employee(id: 2, name: "Bob", role: "Designer", city: "Paris"),
    Employee(id: 3, name: "Carol", role: "Manager", city: "Berlin")
]
```

### Step 3: Define Columns and Create the Table

Each `DataTableColumn` defines a column header and how to extract the value from your model. Using key paths (`\.name`) gives you compile-time safety - typos are caught at build time, not runtime.

```swift
let columns: [DataTableColumn<Employee>] = [
    .init("Name", \.name),      // Header: "Name", Value: employee.name
    .init("Role", \.role),
    .init("City", \.city)
]

let dataTable = SwiftDataTable(data: employees, columns: columns)
```

### Step 4: Add to Your View

```swift
override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(dataTable)
    dataTable.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
        dataTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        dataTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        dataTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        dataTable.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
}
```

That's it! You now have a fully functional data table with:
- ✅ Column sorting (tap headers)
- ✅ Built-in search bar
- ✅ Automatic column widths
- ✅ Row highlighting on selection

## Next Steps

- <doc:TypeSafeColumns> - Use your own model types with type-safe columns
- <doc:AnimatedUpdates> - Update data with smooth animations
- <doc:ColumnWidths> - Control how column widths are calculated
