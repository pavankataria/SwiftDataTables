# Column Sorting

Enable users to sort data by tapping column headers.

## Overview

Sorting is enabled by default. Users tap a column header to sort ascending, tap again for descending, and a third tap returns to the original order.

## Default Behavior

```swift
let dataTable = SwiftDataTable(data: myData, headerTitles: headers)
// Sorting is enabled automatically
```

## Sort Indicators

Headers display arrows indicating sort direction:
- **▲** Ascending (A→Z, 1→100)
- **▼** Descending (Z→A, 100→1)

### Customizing Sort Arrow Colors

```swift
var config = DataTableConfiguration()
config.sortArrowTintColor = .systemBlue
```

### Hiding Sort Indicators

```swift
config.shouldShowHeaderSortingIndicator = false
config.shouldShowFooterSortingIndicator = false
```

## Disabling Sorting Per Column

Prevent sorting on specific columns:

```swift
config.isColumnSortable = { columnIndex in
    // Disable sorting on action column (index 4)
    return columnIndex != 4
}
```

## Default Sort Order

Set an initial sort when the table loads:

```swift
config.defaultSortingColumn = (index: 1, order: .ascending)
```

## Sort Types

Sorting behavior depends on ``DataTableValueType``:

| Type | Sort Behavior |
|------|---------------|
| `.string` | Alphabetical (A, B, C) |
| `.int` | Numeric (1, 2, 10) |
| `.float` | Numeric (1.1, 1.5, 2.0) |
| `.double` | Numeric |

### Ensuring Correct Sort Order

```swift
// Numeric sorting
.init("Age") { .int($0.age) }

// Alphabetic sorting
.init("Name") { .string($0.name) }

// Be careful: "10" < "2" < "9" with strings!
.init("ID") { .int($0.id) }  // Use .int for numeric IDs
```

## See Also

- ``DataTableConfiguration``
- ``DataTableSortType``
