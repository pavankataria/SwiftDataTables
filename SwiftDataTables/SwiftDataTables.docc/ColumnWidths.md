# Column Widths

Control how column widths are calculated to fit your content perfectly.

## Overview

SwiftDataTables offers two approaches for calculating column widths:

1. **Auto Layout** – Uses `systemLayoutSizeFitting` on your cells. Accurate, reliable, works with any cell complexity.
2. **Text Estimation** – Estimates widths from character counts. Faster for large datasets with simple text cells.

## Auto Layout (Recommended)

The standard iOS approach. Your cells define their own width through constraints:

```swift
var config = DataTableConfiguration()
config.columnWidthMode = .fitContentAutoLayout(sample: 50)
```

This samples 50 cells per column and uses the maximum width found. It works with:
- Custom cells with images, buttons, or complex layouts
- Multi-line text with wrapping
- Dynamic Type and accessibility sizes
- Any content that can be measured via Auto Layout

### When to Use Auto Layout

- Custom cell classes with constraints
- Mixed content types (images + text)
- When accuracy matters more than speed
- Datasets under 50,000 rows

## Text Estimation

For simple text-only cells, you can estimate widths from character counts:

```swift
var config = DataTableConfiguration()
config.columnWidthMode = .fitContentText(strategy: .hybrid(sampleSize: 100, averageCharWidth: 7))
```

### Available Strategies

| Strategy | How It Works |
|----------|--------------|
| `.hybrid` | Combines estimation with sampling. Good default. |
| `.estimatedAverage` | `charCount × avgWidth` averaged. Fastest, may clip outliers. |
| `.sampledMax` | Measures a sample, uses maximum. |
| `.maxMeasured` | Measures every row. Most accurate, slowest. |
| `.percentileMeasured` | Uses 95th percentile to ignore extreme outliers. |

### When to Use Text Estimation

- Default text cells (no custom cell class)
- Very large datasets (50,000+ rows) where Auto Layout is too slow
- Uniform text content

## Fixed Width

For columns where you know the exact width needed:

```swift
config.columnWidthMode = .fixed(width: 120)
```

## Per-Column Overrides

Mix strategies for different columns:

```swift
config.columnWidthModeProvider = { columnIndex in
    switch columnIndex {
    case 0:
        return .fixed(width: 60)  // ID column
    case 3:
        return .fitContentAutoLayout(sample: 50)  // Complex cell
    default:
        return nil  // Use global setting
    }
}
```

## Width Constraints

### Minimum Width

Prevent columns from becoming too narrow:

```swift
config.minColumnWidth = 80  // Default: 70
```

### Maximum Width

Cap width to prevent single columns from dominating:

```swift
config.maxColumnWidth = 300  // Default: nil (no cap)
```

> Note: Header width (including sort indicator) always takes precedence.

### Scale to Fill

When total column width is less than table width:

```swift
config.shouldContentWidthScaleToFillFrame = true  // Default
```

## Combining with Row Heights

When columns are capped, text may need to wrap. Enable automatic row heights:

```swift
var config = DataTableConfiguration()
config.maxColumnWidth = 200
config.textLayout = .wrap
config.rowHeightMode = .automatic(estimated: 60)
```

## Example: Mixed Column Types

```swift
var config = DataTableConfiguration()

config.columnWidthModeProvider = { column in
    switch column {
    case 0: return .fixed(width: 50)   // ID
    case 1: return .fitContentAutoLayout(sample: 50)  // User card cell
    case 2: return .fitContentText(strategy: .hybrid(sampleSize: 100, averageCharWidth: 7))  // Plain text
    case 3: return .fixed(width: 80)   // Status badge
    default: return nil
    }
}

config.maxColumnWidth = 250
config.minColumnWidth = 50
```

## See Also

- <doc:RowHeights>
- <doc:TextWrapping>
- <doc:CustomCells>
- ``DataTableColumnWidthMode``
