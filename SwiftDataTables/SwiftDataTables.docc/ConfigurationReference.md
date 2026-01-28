# Configuration Reference

Complete reference of all configuration options in DataTableConfiguration.

## Overview

`DataTableConfiguration` provides comprehensive control over SwiftDataTable appearance and behavior. This reference documents every property with examples.

## Creating a Configuration

```swift
var config = DataTableConfiguration()
// Modify properties...
let dataTable = SwiftDataTable(columns: columns, options: config)
```

## Sorting Options

### defaultOrdering

Initial sort column and direction when the table loads.

```swift
// Sort by column 2, descending
config.defaultOrdering = DataTableColumnOrder(index: 2, order: .descending)

// No default sort (user must tap to sort)
config.defaultOrdering = nil  // default
```

### isColumnSortable

Control which columns can be sorted.

```swift
// All columns sortable (default)
config.isColumnSortable = nil

// Disable sorting on specific columns
config.isColumnSortable = { columnIndex in
    columnIndex != 5  // Column 5 is not sortable
}

// Only specific columns sortable
config.isColumnSortable = { [0, 2, 4].contains($0) }
```

### shouldShowHeaderSortingIndicator

Show/hide sort arrows in headers.

```swift
config.shouldShowHeaderSortingIndicator = true   // default
config.shouldShowHeaderSortingIndicator = false  // hide arrows
```

### shouldShowFooterSortingIndicator

Show/hide sort arrows in footers.

```swift
config.shouldShowFooterSortingIndicator = false  // default
config.shouldShowFooterSortingIndicator = true   // show arrows in footer
```

### shouldFooterTriggerSorting

Allow sorting by tapping footer cells.

```swift
config.shouldFooterTriggerSorting = false  // default
config.shouldFooterTriggerSorting = true   // footer taps sort
```

### sortArrowTintColor

Color for sort direction arrows.

```swift
config.sortArrowTintColor = .tintColor     // default (system tint)
config.sortArrowTintColor = .systemBlue
config.sortArrowTintColor = .label
```

## Height Options

### heightForSectionHeader

Height of the column header row.

```swift
config.heightForSectionHeader = 44  // default
config.heightForSectionHeader = 56  // taller header
```

### heightForSectionFooter

Height of the column footer row.

```swift
config.heightForSectionFooter = 44  // default
config.heightForSectionFooter = 0   // minimize (use shouldShowFooter to hide)
```

### heightForSearchView

Height of the search bar section.

```swift
config.heightForSearchView = 60  // default
config.heightForSearchView = 50  // compact search
```

### heightOfInterRowSpacing

Vertical gap between data rows.

```swift
config.heightOfInterRowSpacing = 1  // default (subtle line)
config.heightOfInterRowSpacing = 0  // no gap
config.heightOfInterRowSpacing = 4  // visible separation
```

### rowHeightMode

How row heights are calculated.

```swift
// Fixed height for all rows (fastest)
config.rowHeightMode = .fixed(44)  // default

// Automatic height based on content
config.rowHeightMode = .automatic(estimated: 44, prefetchWindow: 10)
```

| Mode | Use Case |
|------|----------|
| `.fixed(CGFloat)` | Uniform content, maximum performance |
| `.automatic(estimated:prefetchWindow:)` | Variable content, multi-line text |

## Visibility Options

### shouldShowFooter

Display or hide the footer section.

```swift
config.shouldShowFooter = true   // default
config.shouldShowFooter = false  // hide footer
```

### shouldShowSearchSection

Display or hide the search bar.

```swift
config.shouldShowSearchSection = true   // default
config.shouldShowSearchSection = false  // hide search
```

### shouldShowVerticalScrollBars

Show vertical scroll indicator.

```swift
config.shouldShowVerticalScrollBars = true  // default
config.shouldShowVerticalScrollBars = false
```

### shouldShowHorizontalScrollBars

Show horizontal scroll indicator.

```swift
config.shouldShowHorizontalScrollBars = false  // default
config.shouldShowHorizontalScrollBars = true
```

## Floating Behavior

### shouldSectionHeadersFloat

Header sticks to top during scroll.

```swift
config.shouldSectionHeadersFloat = true   // default (sticky)
config.shouldSectionHeadersFloat = false  // scrolls with content
```

### shouldSectionFootersFloat

Footer sticks to bottom during scroll.

```swift
config.shouldSectionFootersFloat = true   // default (sticky)
config.shouldSectionFootersFloat = false  // scrolls with content
```

### shouldSearchHeaderFloat

Search bar sticks to top during scroll.

```swift
config.shouldSearchHeaderFloat = false  // default (scrolls away)
config.shouldSearchHeaderFloat = true   // always visible
```

## Column Width Options

### columnWidthMode

Default width calculation strategy for all columns.

```swift
// Estimate from character count (default, fast)
config.columnWidthMode = .fitContentText(
    strategy: .estimatedAverage(averageCharWidth: 7.0)
)

// Sample rows then estimate (balanced)
config.columnWidthMode = .fitContentText(
    strategy: .hybrid(sampleSize: 100, averageCharWidth: 7.0)
)

// Measure every row (accurate but slower)
config.columnWidthMode = .fitContentText(strategy: .maxMeasured)

// Fixed width for all columns
config.columnWidthMode = .fixed(width: 120)
```

### minColumnWidth

Minimum width any column can be.

```swift
config.minColumnWidth = 70  // default
config.minColumnWidth = 50  // allow narrower columns
```

### maxColumnWidth

Maximum width any column can be.

```swift
config.maxColumnWidth = nil  // default (no limit)
config.maxColumnWidth = 300  // cap width
```

### columnWidthModeProvider

Per-column width customization.

```swift
config.columnWidthModeProvider = { columnIndex in
    switch columnIndex {
    case 0: return .fixed(width: 60)   // ID column
    case 4: return .fixed(width: 120)  // Actions column
    default: return nil  // Use columnWidthMode
    }
}
```

### columnWidthModeProviderVersion

Force width recalculation when provider changes.

```swift
// Increment when changing columnWidthModeProvider
config.columnWidthModeProviderVersion = 1
```

### lockColumnWidthsAfterFirstLayout

Prevent width recalculation after initial layout.

```swift
config.lockColumnWidthsAfterFirstLayout = false  // default
config.lockColumnWidthsAfterFirstLayout = true   // lock widths
```

### shouldContentWidthScaleToFillFrame

Scale columns to fill available width.

```swift
config.shouldContentWidthScaleToFillFrame = true   // default (fill frame)
config.shouldContentWidthScaleToFillFrame = false  // use calculated widths
```

## Color Options

### highlightedAlternatingRowColors

Background colors for cells in the sorted column.

```swift
config.highlightedAlternatingRowColors = [
    DataStyles.Colors.highlightedFirstColor,   // default
    DataStyles.Colors.highlightedSecondColor
]

// Custom colors
config.highlightedAlternatingRowColors = [
    UIColor.systemBlue.withAlphaComponent(0.1),
    UIColor.systemBlue.withAlphaComponent(0.15)
]
```

### unhighlightedAlternatingRowColors

Background colors for cells in non-sorted columns.

```swift
config.unhighlightedAlternatingRowColors = [
    DataStyles.Colors.unhighlightedFirstColor,  // default
    DataStyles.Colors.unhighlightedSecondColor
]

// Custom colors
config.unhighlightedAlternatingRowColors = [
    .systemBackground,
    .secondarySystemBackground
]
```

## Fixed Columns

### fixedColumns

Freeze columns during horizontal scroll.

```swift
// No fixed columns (default)
config.fixedColumns = nil

// Fix left column(s)
config.fixedColumns = DataTableFixedColumnType(leftColumns: 1)

// Fix right column(s)
config.fixedColumns = DataTableFixedColumnType(rightColumns: 2)

// Fix both sides
config.fixedColumns = DataTableFixedColumnType(leftColumns: 1, rightColumns: 1)
```

## Layout Modes

### textLayout

How text is displayed in cells.

```swift
// Single line with truncation (default)
config.textLayout = .singleLine(truncation: .byTruncatingTail)

// Multi-line wrapping
config.textLayout = .multiLine(maxLines: 3)

// Unlimited lines
config.textLayout = .multiLine(maxLines: 0)
```

### cellSizingMode

How cell sizes are calculated.

```swift
// Standard text cells (default)
config.cellSizingMode = .defaultCell

// Custom cells with Auto Layout
config.cellSizingMode = .autoLayout
```

## Internationalization

### shouldSupportRightToLeftInterfaceDirection

Support RTL layouts.

```swift
config.shouldSupportRightToLeftInterfaceDirection = true  // default
config.shouldSupportRightToLeftInterfaceDirection = false
```

## Quick Reference Table

| Property | Default | Purpose |
|----------|---------|---------|
| `defaultOrdering` | `nil` | Initial sort column |
| `isColumnSortable` | `nil` (all sortable) | Per-column sort control |
| `shouldShowHeaderSortingIndicator` | `true` | Header sort arrows |
| `shouldShowFooterSortingIndicator` | `false` | Footer sort arrows |
| `shouldFooterTriggerSorting` | `false` | Footer tap sorts |
| `sortArrowTintColor` | `.tintColor` | Arrow color |
| `heightForSectionHeader` | `44` | Header height |
| `heightForSectionFooter` | `44` | Footer height |
| `heightForSearchView` | `60` | Search bar height |
| `heightOfInterRowSpacing` | `1` | Row gap |
| `rowHeightMode` | `.fixed(44)` | Row height strategy |
| `shouldShowFooter` | `true` | Footer visibility |
| `shouldShowSearchSection` | `true` | Search visibility |
| `shouldSectionHeadersFloat` | `true` | Sticky header |
| `shouldSectionFootersFloat` | `true` | Sticky footer |
| `shouldSearchHeaderFloat` | `false` | Sticky search |
| `columnWidthMode` | `.fitContentText(...)` | Width calculation |
| `minColumnWidth` | `70` | Minimum width |
| `maxColumnWidth` | `nil` | Maximum width |
| `shouldContentWidthScaleToFillFrame` | `true` | Fill frame |
| `fixedColumns` | `nil` | Frozen columns |
| `textLayout` | `.singleLine()` | Text display |
| `cellSizingMode` | `.defaultCell` | Sizing strategy |

## See Also

- ``DataTableConfiguration``
- ``DataTableRowHeightMode``
- ``DataTableColumnWidthMode``
- ``DataTableTextLayout``
- ``DataTableFixedColumnType``
