# ``SwiftDataTables``

The powerful, flexible data table component that iOS deserves.

@Metadata {
    @DisplayName("SwiftDataTables")
    @PageImage(purpose: icon, source: "swiftdatatables-icon", alt: "SwiftDataTables logo")
    @PageColor(blue)
}

## Overview

SwiftDataTables lets you display grid-like data with sorting, searching, and smooth animations — all in just a few lines of code. Whether you're building a dashboard, admin panel, or data-heavy app, SwiftDataTables handles the complexity so you can focus on your app.

```swift
let dataTable = SwiftDataTable(
    data: employees,
    columns: [
        .init("Name", \.name),
        .init("Role", \.role),
        .init("Salary") { .string("$\($0.salary)") }
    ]
)
```

### Why SwiftDataTables?

- **5 lines of code** to add a full-featured data table
- **100,000+ rows** with smooth 60fps scrolling
- **Type-safe API** with `Identifiable`, key paths, and modern Swift
- **Animated updates** that preserve scroll position

## Topics

### Essentials

Start here to get up and running quickly.

- <doc:GettingStarted>
- <doc:QuickStart>
- ``SwiftDataTable``

### Displaying Data

Learn the different ways to populate your table.

- <doc:WorkingWithData>
- <doc:TypeSafeColumns>
- ``DataTableColumn``
- ``DataTableValueType``

### Updating Data

Handle dynamic data with smooth animations.

- <doc:AnimatedUpdates>
- <doc:IncrementalUpdates>

### Layout and Sizing

Control how your table looks and fits content.

- <doc:ColumnWidths>
- <doc:RowHeights>
- <doc:TextWrapping>
- ``DataTableConfiguration``

### Advanced Features

Unlock the full power of SwiftDataTables.

- <doc:CustomCells>
- <doc:LargeDatasets>
- <doc:FixedColumns>
- <doc:SearchIntegration>
- <doc:ColumnSorting>

### Configuration

Fine-tune every aspect of your table.

- ``DataTableConfiguration``
- ``DataTableRowHeightMode``
- ``DataTableColumnWidthMode``
- ``DataTableTextLayout``

### Migration

Upgrading from an earlier version? Start here.

- <doc:MigratingTo09>
