# ``SwiftDataTables``

The powerful, flexible data table component that iOS deserves.

@Metadata {
    @DisplayName("SwiftDataTables")
    @PageImage(purpose: icon, source: "swiftdatatables-icon", alt: "SwiftDataTables logo")
    @PageColor(blue)
}

## Overview

SwiftDataTables lets you display beautiful, interactive data tables in just a few lines of code. Whether you're building a dashboard, admin panel, or data-heavy app, SwiftDataTables handles the complexity so you can focus on your app.

```swift
let dataTable = SwiftDataTable(
    data: employees,
    columns: [
        .init("Name", \.name),
        .init("Role", \.role),
        .init("Salary") { "$\($0.salary)" }
    ]
)
```

That's it. You now have a fully functional data table with sorting, searching, and smooth 60fps scrolling.

## Why SwiftDataTables?

### Get Started in Minutes

No complex setup. No boilerplate. Just create a table, add your data, and you're done. The <doc:GettingStarted> guide will have you displaying data in under 5 minutes.

### Built for Real Apps

- **100,000+ rows** with lazy measurement and smooth scrolling
- **Type-safe API** using `Identifiable`, key paths, and modern Swift
- **Animated updates** that preserve scroll position
- **Fixed columns** for keeping identifiers visible
- **Built-in search** with native or embedded styles

### Production Ready

SwiftDataTables is battle-tested and actively maintained. It supports iOS 12+ and works seamlessly with both UIKit and SwiftUI (via `UIViewRepresentable`).

## What's in This Documentation

Find what you need based on what you're trying to do:

- **Getting Started** – Setup and first table
- **Data** – Columns, updates, and animated diffing
- **Layout** – Column widths, row heights, text wrapping
- **Cells** – Cell configuration and custom layouts
- **Interaction** – Selection, sorting, search

Every feature is designed to be easy to use. Custom cells and automatic heights aren't "advanced" – they're just different tools for different needs.

## Topics

### Getting Started

- <doc:GettingStarted>
- <doc:QuickStart>

### Data

- <doc:WorkingWithData>
- <doc:TypeSafeColumns>
- <doc:AnimatedUpdates>
- <doc:IncrementalUpdates>

### Layout

- <doc:ColumnWidths>
- <doc:RowHeights>
- <doc:TextWrapping>
- <doc:FixedColumns>

### Cells

- <doc:DefaultCellConfiguration>
- <doc:CustomCells>
- <doc:LargeDatasets>

### Interaction

- <doc:RowSelection>
- <doc:ColumnSorting>
- <doc:SearchIntegration>

### Styling

- <doc:Styling>

### Patterns

- <doc:AdvancedPatterns>

### Reference

- <doc:ConfigurationReference>
- ``SwiftDataTable``
- ``DataTableColumn``
- ``DataTableValueType``
- ``DataTableConfiguration``
- ``DataTableRowHeightMode``
- ``DataTableColumnWidthMode``
- ``DataTableTextLayout``
- ``DataTableFixedColumnType``
- ``SwiftDataTableDelegate``

### Migration

- <doc:MigratingTo09>
