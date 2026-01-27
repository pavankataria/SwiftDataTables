# Row Heights

Configure fixed or automatic row heights based on your content needs.

## Overview

SwiftDataTables supports two row height modes:

- **Fixed** - All rows have the same height (fastest)
- **Automatic** - Row height varies based on content (flexible)

## Fixed Height

Use when all rows have similar content:

```swift
var config = DataTableConfiguration()
config.rowHeightMode = .fixed(44)  // 44 points for all rows
```

Benefits:
- Fastest performance
- Instant scroll position calculations
- Ideal for single-line cells

## Automatic Height

Use when content varies or text wraps:

```swift
var config = DataTableConfiguration()
config.rowHeightMode = .automatic(estimated: 60)
```

The `estimated` parameter provides an initial height before measurement. A good estimate improves scroll performance.

### How It Works

1. Rows start with the estimated height
2. As rows scroll into view, they're measured
3. Measured heights replace estimates
4. Scroll position is automatically anchored

### Enabling Text Wrapping

Automatic heights pair with text wrapping:

```swift
var config = DataTableConfiguration()
config.textLayout = .wrap
config.rowHeightMode = .automatic(estimated: 60)
```

## Large Dataset Optimization

For 10,000+ rows, add a prefetch window:

```swift
config.rowHeightMode = .automatic(estimated: 44, prefetchWindow: 10)
```

The prefetch window measures rows ahead of the visible area for smoother scrolling.

### Performance Characteristics

| Rows | Prefetch | Behavior |
|------|----------|----------|
| < 1,000 | Not needed | All rows measured upfront |
| 1,000 - 50,000 | 5-10 | Lazy measurement |
| 50,000+ | 10-20 | Aggressive lazy measurement |

## Choosing an Estimated Height

Pick an estimate close to your typical row height:

```swift
// Single line of text (~44pt)
config.rowHeightMode = .automatic(estimated: 44)

// 2-3 lines of text (~60-80pt)
config.rowHeightMode = .automatic(estimated: 70)

// Variable content (pick median)
config.rowHeightMode = .automatic(estimated: 55)
```

A poor estimate causes:
- Visual jumping during scroll
- Scroll bar size changes
- Anchoring corrections

## Custom Per-Row Heights

For fine-grained control, implement the delegate:

```swift
class MyViewController: UIViewController, SwiftDataTableDelegate {
    func dataTable(_ dataTable: SwiftDataTable, heightForRowAt index: Int) -> CGFloat {
        // Return custom height for specific rows
        if index == 0 {
            return 80  // Header row is taller
        }
        return 44  // Standard rows
    }
}
```

> Note: Per-row delegate heights override the global `rowHeightMode`.

## Live Cell Editing

When cell content changes (e.g., text editing), remeasure the row:

```swift
// User edited cell content
dataTable.remeasureRow(editedRowIndex)
```

This updates the row height smoothly without reloading.

## Scroll Anchoring

When row heights change, SwiftDataTables anchors the scroll position:

```swift
// Before: User viewing row 50
// Heights above row 50 change
// After: User still sees row 50 (scroll offset adjusted)
```

This happens automatically in `.automatic` mode.

## Example: Multi-Line Description Table

```swift
struct Product: Identifiable {
    let id: Int
    let name: String
    let description: String  // Can be multi-line
    let price: Double
}

var config = DataTableConfiguration()

// Enable wrapping for long descriptions
config.textLayout = .wrap

// Automatic heights
config.rowHeightMode = .automatic(estimated: 80)

// Cap description column width to force wrapping
config.maxColumnWidth = 250

let columns: [DataTableColumn<Product>] = [
    .init("Name", \.name),
    .init("Description", \.description),
    .init("Price") { .string("$\($0.price)") }
]

let dataTable = SwiftDataTable(data: products, columns: columns, options: config)
```

## See Also

- <doc:ColumnWidths>
- <doc:TextWrapping>
- <doc:LargeDatasets>
- ``DataTableRowHeightMode``
