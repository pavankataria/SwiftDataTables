# Fixed Columns

Freeze columns on the left or right while scrolling horizontally.

## Overview

Fixed columns stay visible while the user scrolls horizontally through other columns. This is useful for keeping identifier columns visible.

## Usage

### Fix Columns on the Left

```swift
var config = DataTableConfiguration()
config.fixedColumns = .left(count: 1)  // Freeze first column
```

### Fix Columns on the Right

```swift
config.fixedColumns = .right(count: 2)  // Freeze last 2 columns
```

### Fix Columns on Both Sides

```swift
config.fixedColumns = .both(left: 1, right: 1)
```

### No Fixed Columns

```swift
config.fixedColumns = .none  // Default
```

## Example: Employee Directory

```swift
// ID column stays visible while scrolling through details
var config = DataTableConfiguration()
config.fixedColumns = .left(count: 1)

let columns: [DataTableColumn<Employee>] = [
    .init("ID", \.employeeId),        // Fixed
    .init("Name", \.name),            // Scrolls
    .init("Department", \.department), // Scrolls
    .init("Email", \.email),          // Scrolls
    .init("Phone", \.phone)           // Scrolls
]

let dataTable = SwiftDataTable(data: employees, columns: columns, options: config)
```

## Visual Effect

```
Fixed │ Scrollable content →
──────┼────────────────────────
ID 001│ Alice    Engineering  alice@...
ID 002│ Bob      Design       bob@...
ID 003│ Carol    Marketing    carol@...
```

## See Also

- ``DataTableFixedColumnType``
- ``DataTableConfiguration``
