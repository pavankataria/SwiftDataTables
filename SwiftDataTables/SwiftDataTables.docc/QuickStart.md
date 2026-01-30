# Quick Start

Learn SwiftDataTables step by step, from your first table to handling real-world requirements.

## Overview

In this quick start, we'll build an employee directory - a common use case where you need to display a list of people with their details. Along the way, you'll learn the main features of SwiftDataTables: displaying data, updating it dynamically, formatting values, customizing appearance, and responding to user interactions.

## Hello World

Let's start with the absolute minimum to display a table.

### Import the framework

```swift
import SwiftDataTables
```

> Tip: Make sure you have SwiftDataTables installed via Swift Package Manager. See <doc:GettingStarted> for installation instructions.

### Define your data model

Every data table needs a model - a Swift struct that represents one row of data. For our employee directory, we'll create an `Employee` struct with the properties we want to display as columns:

```swift
struct Employee {
    let name: String
    let department: String
}
```

### Create some sample data

With the model defined, let's create a few employees to display. In a real app, this data would come from a database or API, but hardcoded data works perfectly for learning:

```swift
let employees = [
    Employee(name: "Alice", department: "Engineering"),
    Employee(name: "Bob", department: "Design"),
    Employee(name: "Carol", department: "Marketing")
]
```

### Define your columns

Columns connect your model properties to table headers. Each column needs two things:

1. **A title** - what users see in the header (e.g., "Name")
2. **A key path** - which property to display (e.g., `\.name`)

The key path also determines sorting behavior. When a user taps a column header, SwiftDataTables automatically sorts by that property.

```swift
let columns: [DataTableColumn<Employee>] = [
    .init("Name", \.name),
    .init("Department", \.department)
]
```

> Tip: See <doc:TypeSafeColumns> for all column initializers, including custom formatters, non-sortable columns, and computed values.

### Create the table

With your data and columns ready, create the table by passing both to the initializer:

```swift
let dataTable = SwiftDataTable(data: employees, columns: columns)
```

That's it - you now have a fully functional data table with sortable columns, a built-in search bar, and alternating row colors.

> Note: See <doc:ColumnSorting> for controlling sort behavior and disabling sorting on specific columns.

## Adding to a View Controller

Now let's put the table on screen. SwiftDataTables is a `UIView` subclass, so you add it to your view hierarchy like any other view.

The following example shows a complete view controller that displays our employee table. We use `autoresizingMask` for simplicity, but you can also use Auto Layout constraints if you prefer:

```swift
class EmployeeListViewController: UIViewController {
    let employees = [
        Employee(name: "Alice", department: "Engineering"),
        Employee(name: "Bob", department: "Design"),
        Employee(name: "Carol", department: "Marketing")
    ]

    let columns: [DataTableColumn<Employee>] = [
        .init("Name", \.name),
        .init("Department", \.department)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        let dataTable = SwiftDataTable(data: employees, columns: columns)
        view.addSubview(dataTable)

        // Make the table fill the entire view
        dataTable.frame = view.bounds
        dataTable.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}
```

> Tip: You can also use Auto Layout. Just set `translatesAutoresizingMaskIntoConstraints = false` and add your constraints as usual.

## Updating Data

So far we've used hardcoded data. In a real app, you'll load data from a server and need to update the table when new data arrives. SwiftDataTables makes this seamless with animated diffing.

### The problem with naive reloading

Without proper handling, updating a table means reloading everything at once. This creates a poor user experience:

- The user loses their scroll position
- Changes appear jarring with no visual context
- There's no indication of what actually changed

SwiftDataTables solves this with automatic diffing. When you update your data, it calculates exactly what changed and animates appropriately:

- New rows slide in smoothly
- Deleted rows slide out
- Changed rows update in place
- Scroll position is preserved

### Make your model Identifiable

For SwiftDataTables to track which rows are new, deleted, or moved, each row needs a unique identifier. Conform your model to Swift's `Identifiable` protocol:

```swift
struct Employee: Identifiable {
    let id: Int        // Unique identifier - could be from your API, database, or UUID
    let name: String
    let department: String
}
```

The `id` can be any `Hashable` type - `Int`, `String`, `UUID`, or even a custom type. The important thing is that each row has a unique, stable identifier.

> Important: The `id` should remain constant for a given record. If you use array indices as IDs, SwiftDataTables can't distinguish between "row moved" and "row deleted + new row added".

### Set up for dynamic data

When working with dynamic data, you need two changes to your view controller:

1. Store your data in a `var` (not `let`) so it can change
2. Keep a reference to the table so you can call `setData()` later

```swift
class EmployeeListViewController: UIViewController {
    var employees: [Employee] = []      // Mutable array, starts empty
    var dataTable: SwiftDataTable!      // Reference to update later

    let columns: [DataTableColumn<Employee>] = [
        .init("Name", \.name),
        .init("Department", \.department)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create table with empty data initially
        dataTable = SwiftDataTable(data: employees, columns: columns)
        view.addSubview(dataTable)
        dataTable.frame = view.bounds
        dataTable.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Load data from server
        fetchEmployees()
    }

    func fetchEmployees() {
        Task {
            let response = try await api.getEmployees()
            employees = response
            dataTable.setData(employees, animatingDifferences: false)  // No animation for initial load
        }
    }
}
```

### Handle refreshes and updates

When new data arrives - whether from a pull-to-refresh, a WebSocket update, or polling - update your array and call `setData()` with animation enabled:

```swift
func refresh() {
    Task {
        let latest = try await api.getEmployees()
        employees = latest
        dataTable.setData(employees, animatingDifferences: true)
    }
}
```

SwiftDataTables compares the new array to the previous one using the `id` property. It figures out which employees are new (slides them in), which were removed (slides them out), and which changed position (moves them). The user's scroll position is preserved throughout.

### Add or remove individual items

You can also make targeted changes. Just modify your array and call `setData()`:

```swift
func addEmployee(_ employee: Employee) {
    employees.append(employee)
    dataTable.setData(employees, animatingDifferences: true)  // New row slides in
}

func removeEmployee(at index: Int) {
    employees.remove(at: index)
    dataTable.setData(employees, animatingDifferences: true)  // Row slides out
}
```

> Tip: Always modify your data array first, then call `setData()`. SwiftDataTables diffs the new array against what it had before - it doesn't track individual mutations.

> Note: See <doc:AnimatedUpdates> for more on diffing, batch updates, and performance considerations with large datasets.

## Formatting Values

As your model grows, you'll want to format values for display. Raw numbers and dates rarely look good in a table.

### The problem with raw values

Consider adding salary and start date to our employee model:

```swift
struct Employee: Identifiable {
    let id: Int
    let name: String
    let department: String
    let salary: Double       // e.g., 75000.0
    let startDate: Date      // e.g., 2024-01-15
}
```

Without formatting, the salary displays as "75000.0" and the date displays in a verbose ISO format. What you want is "$75,000" and "Jan 15, 2024".

### Use the key path + formatter pattern

SwiftDataTables provides a column initializer that takes both a key path (for sorting) and a formatting closure (for display):

```swift
let columns: [DataTableColumn<Employee>] = [
    .init("Name", \.name),
    .init("Department", \.department),

    // Key path determines sorting, closure determines display
    .init("Salary", \.salary) { salary in
        "$\(String(format: "%.0f", salary))"
    },

    .init("Started", \.startDate) { date in
        date.formatted(date: .abbreviated, time: .omitted)
    }
]
```

This pattern is powerful because it separates concerns:

- **The key path** (`\.salary`) determines how the column sorts - numerically in this case
- **The closure** determines how values display - as formatted currency

> Important: This ensures "$9,000" sorts before "$80,000" (numerically by the underlying value), not after it (which would happen with alphabetical string sorting).

> Note: See <doc:TypeSafeColumns> for all column definition options including custom sorting and non-sortable columns.

## Customizing Appearance

SwiftDataTables comes with sensible defaults, but you can customize nearly every aspect of its appearance through the `DataTableConfiguration` object.

### Create a configuration

Start by creating a configuration object. You'll modify its properties, then pass it when creating the table:

```swift
var config = DataTableConfiguration()

// Customize properties here...

let dataTable = SwiftDataTable(data: employees, columns: columns, options: config)
```

### Common customizations

Here are the most frequently used options:

**Row heights** - Choose between fixed height (fastest) or automatic height (for variable content):

```swift
config.rowHeightMode = .fixed(50)                    // All rows are 50pt tall
config.rowHeightMode = .automatic(estimated: 44)    // Height based on content
```

**Show/hide elements** - Turn off the search bar or footer if you don't need them:

```swift
config.shouldShowSearchSection = false
config.shouldShowFooter = false
```

**Alternating row colors** - Customize the colors for sorted and unsorted columns:

```swift
// Colors for the currently sorted column
config.highlightedAlternatingRowColors = [
    .systemBlue.withAlphaComponent(0.1),
    .systemBlue.withAlphaComponent(0.05)
]

// Colors for other columns
config.unhighlightedAlternatingRowColors = [
    .systemBackground,
    .secondarySystemBackground
]
```

**Column width constraints** - Set minimum and maximum widths:

```swift
config.minColumnWidth = 80
config.maxColumnWidth = 200
```

> Tip: Use semantic colors like `.systemBackground` for automatic dark mode support.

> Note: See <doc:ConfigurationReference> for all available options, <doc:RowHeights> for height modes, and <doc:ColumnWidths> for width strategies.

## Responding to Selection

Handle row taps to show details, present actions, or navigate to another screen.

### Set up the delegate

SwiftDataTables uses the delegate pattern for user interactions. Conform your view controller to `SwiftDataTableDelegate` and set itself as the delegate:

```swift
class EmployeeListViewController: UIViewController, SwiftDataTableDelegate {
    var employees: [Employee] = []
    var dataTable: SwiftDataTable!

    override func viewDidLoad() {
        super.viewDidLoad()

        dataTable = SwiftDataTable(data: employees, columns: columns)
        dataTable.delegate = self  // Set the delegate
        view.addSubview(dataTable)
        // ... layout code ...
    }
}
```

### Implement the selection callback

When a user taps a row, SwiftDataTables calls `didSelectItem(_:indexPath:)`. The `indexPath.section` gives you the row index in your data array:

```swift
func didSelectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath) {
    let employee = employees[indexPath.section]
    print("Selected: \(employee.name)")

    // Example: Navigate to a detail screen
    let detailVC = EmployeeDetailViewController(employee: employee)
    navigationController?.pushViewController(detailVC, animated: true)
}
```

> Note: The delegate has other methods too - respond to header taps, customize search behavior, and more. See <doc:RowSelection> for selection modes, highlighting, and multi-select.

## What's Next

You've learned the essentials of SwiftDataTables. Explore these guides for specific features:

- <doc:TypeSafeColumns> - All column definition options
- <doc:ColumnSorting> - Control how columns sort
- <doc:AnimatedUpdates> - Deep dive into data updates
- <doc:DefaultCellConfiguration> - Style cells without subclassing
- <doc:AdvancedPatterns> - Real-world recipes (live updates, filtering, editing)
