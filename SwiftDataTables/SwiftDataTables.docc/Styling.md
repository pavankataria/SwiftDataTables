# Styling

Customise colours, fonts, spacing, and visual appearance of your data table.

## Overview

SwiftDataTables provides extensive styling options through `DataTableConfiguration`. Customise row colours, fonts, sort indicators, spacing, and more to match your app's design.

## Per-Cell Styling

The most flexible way to style cells is via ``DataTableConfiguration/defaultCellConfiguration``. This callback is invoked for every cell, giving you full control over appearance:

```swift
var config = DataTableConfiguration()
config.defaultCellConfiguration = { cell, value, indexPath, isHighlighted in
    // Custom font
    cell.dataLabel.font = UIFont(name: "Avenir-Medium", size: 14)

    // Conditional text colour
    if let number = value.doubleValue, number < 0 {
        cell.dataLabel.textColor = .systemRed
    } else {
        cell.dataLabel.textColor = .label
    }

    // Alternating row colours
    cell.backgroundColor = indexPath.item % 2 == 0 ? .systemGray6 : .systemBackground
}
```

### Parameters

| Parameter | Description |
|-----------|-------------|
| `cell` | The `DataCell` instance - access `cell.dataLabel` for font, text colour, alignment |
| `value` | The `DataTableValueType` being displayed |
| `indexPath` | Position where `section` = column index, `item` = row index |
| `isHighlighted` | `true` if the cell is in a sorted column |

### Common Patterns

**Highlight negative values:**

```swift
config.defaultCellConfiguration = { cell, value, _, _ in
    if let number = value.doubleValue, number < 0 {
        cell.dataLabel.textColor = .systemRed
    } else {
        cell.dataLabel.textColor = .label
    }
}
```

**Style specific columns:**

```swift
config.defaultCellConfiguration = { cell, _, indexPath, _ in
    switch indexPath.section {
    case 0:  // ID column
        cell.dataLabel.font = .monospacedDigitSystemFont(ofSize: 12, weight: .regular)
    case 3:  // Status column
        cell.dataLabel.textAlignment = .center
    default:
        break
    }
}
```

**Highlight sorted columns:**

```swift
config.defaultCellConfiguration = { cell, _, indexPath, isHighlighted in
    cell.backgroundColor = isHighlighted
        ? .systemYellow.withAlphaComponent(0.15)
        : (indexPath.item % 2 == 0 ? .systemGray6 : .systemBackground)
}
```

> Tip: Colour arrays and `defaultCellConfiguration` are composable! Colour arrays are applied first as baseline backgrounds, then your callback runs. This lets you use arrays for row colours while using the callback for fonts and conditional styling. See <doc:DefaultCellConfiguration> for examples.

For more details, see <doc:DefaultCellConfiguration>.

> Tip: If you need more than styling—such as custom subviews, images, buttons, or complex layouts—create custom cells using ``DataTableCustomCellProvider``. See <doc:CustomCells> for the complete guide.

## Row Colours (Simple)

For basic alternating row colours without per-cell logic, use the colour arrays. These arrays are also composable with `defaultCellConfiguration`—the arrays provide the baseline background, and your callback can add fonts, text colours, or override specific cells.

### Alternating Row Colours

Create visual separation with alternating background colours:

```swift
var config = DataTableConfiguration()

// Standard rows (non-sorted columns)
config.unhighlightedAlternatingRowColors = [
    .systemBackground,
    .secondarySystemBackground
]

// Sorted column rows (highlighted)
config.highlightedAlternatingRowColors = [
    UIColor.systemBlue.withAlphaComponent(0.08),
    UIColor.systemBlue.withAlphaComponent(0.12)
]

let dataTable = SwiftDataTable(columns: columns, options: config)
```

### More Than Two Colors

Use multiple colors for more complex patterns:

```swift
config.unhighlightedAlternatingRowColors = [
    UIColor(white: 1.0, alpha: 1),
    UIColor(white: 0.98, alpha: 1),
    UIColor(white: 0.96, alpha: 1)
]
```

Colors cycle through the array: row 0 uses color 0, row 1 uses color 1, row 2 uses color 2, row 3 uses color 0, etc.

### Dark Mode Support

Use semantic colors for automatic dark mode adaptation:

```swift
config.unhighlightedAlternatingRowColors = [
    .systemBackground,
    .secondarySystemBackground
]

config.highlightedAlternatingRowColors = [
    .systemFill,
    .secondarySystemFill
]
```

## Sort Indicators

### Arrow Color

Customize the sort indicator color:

```swift
config.sortArrowTintColor = .systemBlue
```

### Hide Sort Indicators

Remove visual indicators while keeping sorting functional:

```swift
config.shouldShowHeaderSortingIndicator = false
config.shouldShowFooterSortingIndicator = false
```

## Spacing and Heights

### Row Height

```swift
// Fixed height for all rows
config.rowHeightMode = .fixed(52)

// Or automatic based on content
config.rowHeightMode = .automatic(estimated: 44, prefetchWindow: 10)
```

### Inter-Row Spacing

Create gaps between rows:

```swift
config.heightOfInterRowSpacing = 2  // 2pt gap between rows
```

Set to 0 for no gaps:

```swift
config.heightOfInterRowSpacing = 0
```

### Header and Footer Heights

```swift
config.heightForSectionHeader = 50  // Taller headers
config.heightForSectionFooter = 40  // Shorter footers
```

### Search Bar Height

```swift
config.heightForSearchView = 56
```

## Column Widths

### Minimum and Maximum

```swift
config.minColumnWidth = 80   // No column narrower than 80pt
config.maxColumnWidth = 300  // No column wider than 300pt
```

### Fixed Width Columns

```swift
config.columnWidthModeProvider = { columnIndex in
    switch columnIndex {
    case 0: return .fixed(width: 60)   // ID column
    case 4: return .fixed(width: 100)  // Actions column
    default: return nil  // Use default calculation
    }
}
```

## Visibility Options

### Show/Hide Elements

```swift
// Search bar
config.shouldShowSearchSection = false

// Footer
config.shouldShowFooter = false

// Scroll indicators
config.shouldShowVerticalScrollBars = true
config.shouldShowHorizontalScrollBars = false
```

### Floating Behavior

Control whether elements stay visible during scroll:

```swift
// Header sticks to top
config.shouldSectionHeadersFloat = true

// Footer sticks to bottom
config.shouldSectionFootersFloat = true

// Search bar sticks to top
config.shouldSearchHeaderFloat = true
```

## Example: Dark Theme

```swift
var config = DataTableConfiguration()

// Dark backgrounds
config.unhighlightedAlternatingRowColors = [
    UIColor(white: 0.15, alpha: 1),
    UIColor(white: 0.12, alpha: 1)
]

config.highlightedAlternatingRowColors = [
    UIColor.systemIndigo.withAlphaComponent(0.3),
    UIColor.systemIndigo.withAlphaComponent(0.4)
]

// Accent color for sort arrows
config.sortArrowTintColor = .systemIndigo

// Comfortable spacing
config.heightOfInterRowSpacing = 1
config.heightForSectionHeader = 48
config.heightForSectionFooter = 48

let dataTable = SwiftDataTable(columns: columns, options: config)
```

## Example: Minimal Style

```swift
var config = DataTableConfiguration()

// No alternation
config.unhighlightedAlternatingRowColors = [.systemBackground]
config.highlightedAlternatingRowColors = [.systemBackground]

// Hide non-essential elements
config.shouldShowFooter = false
config.shouldShowSearchSection = false
config.shouldShowVerticalScrollBars = false
config.shouldShowHorizontalScrollBars = false

// No inter-row spacing
config.heightOfInterRowSpacing = 0

let dataTable = SwiftDataTable(columns: columns, options: config)
```

## Example: High-Density Data

```swift
var config = DataTableConfiguration()

// Compact rows
config.rowHeightMode = .fixed(32)
config.heightForSectionHeader = 36
config.heightForSectionFooter = 36

// Tight spacing
config.heightOfInterRowSpacing = 0

// Narrow minimum
config.minColumnWidth = 50

// Hide search to maximize data area
config.shouldShowSearchSection = false

let dataTable = SwiftDataTable(columns: columns, options: config)
```

## See Also

- <doc:DefaultCellConfiguration>
- ``DataTableConfiguration``
- <doc:RowHeights>
- <doc:ColumnWidths>
- <doc:RowSelection>
