# Column Widths

Control how column widths are calculated to prevent clipping and optimize layout.

## Overview

By default, SwiftDataTables calculates column widths from content. This works well for uniform data, but can cause clipping when some rows have much longer content than others.

v0.9.0 introduces **width strategies** that give you fine-grained control over how widths are calculated.

## The Problem

Default width calculation uses **averages**, which can clip outliers:

```
Column: "Name"
─────────────────────
Alice          ✓ Fits
Bob            ✓ Fits
Christopher... ✗ Clipped (longer than average)
```

## Quick Fix: Use Hybrid Strategy

The recommended default prevents clipping while staying fast:

```swift
var config = DataTableConfiguration()
config.columnWidthMode = .fitContentText(
    strategy: .hybrid(sampleSize: 100, averageCharWidth: 7)
)
```

## Width Modes

### Text-Based Width Calculation

For standard text cells, use `.fitContentText` with a strategy:

```swift
config.columnWidthMode = .fitContentText(strategy: .hybrid(sampleSize: 100, averageCharWidth: 7))
```

### Auto Layout Width Calculation

For custom cells with complex layouts:

```swift
config.columnWidthMode = .fitContentAutoLayout(sample: 50)
```

### Fixed Width

For uniform columns:

```swift
config.columnWidthMode = .fixed(width: 120)
```

## Text Measurement Strategies

| Strategy | Description | Speed | Accuracy |
|----------|-------------|-------|----------|
| `.estimatedAverage` | Char count × avg width, averaged | Fastest | May clip |
| `.hybrid` | Max of average + sampled max | Fast | Good |
| `.sampledMax` | Measure sample, take max | Medium | Good |
| `.maxMeasured` | Measure all, take max | Slow | Best |
| `.percentileMeasured` | Use 95th percentile | Medium | Good* |
| `.fixed` | Fixed base width | Fastest | Manual |

### Estimated Average

Best for uniform data where all values are similar length:

```swift
.fitContentText(strategy: .estimatedAverage(averageCharWidth: 8))
```

### Hybrid (Recommended)

Combines speed of estimation with accuracy of sampling:

```swift
.fitContentText(strategy: .hybrid(sampleSize: 100, averageCharWidth: 7))
```

How it works:
1. Calculates estimated average width
2. Measures a sample of rows
3. Takes the **maximum** of both

### Sampled Maximum

Measures a random sample and uses the widest:

```swift
.fitContentText(strategy: .sampledMax(sampleSize: 100))
```

### Maximum Measured

Measures every row - most accurate but slowest:

```swift
.fitContentText(strategy: .maxMeasured)
```

Use for:
- Small datasets (<1000 rows)
- When accuracy is critical
- Columns with highly variable content

### Percentile Measured

Uses a percentile (e.g., 95th) to ignore extreme outliers:

```swift
.fitContentText(strategy: .percentileMeasured(percentile: 0.95, sampleSize: 200))
```

Useful when a few extreme outliers would make columns too wide.

## Per-Column Overrides

Different columns may need different strategies:

```swift
config.columnWidthModeProvider = { columnIndex in
    switch columnIndex {
    case 0:
        // ID column - fixed width
        return .fixed(width: 60)
    case 3:
        // Description column - measure all for accuracy
        return .fitContentText(strategy: .maxMeasured)
    default:
        // Use global setting
        return nil
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

> Note: Header width (including sort indicator) always wins and can exceed `maxColumnWidth` if needed.

### Scale to Fill Frame

When total column width is less than table width, scale proportionally:

```swift
config.shouldContentWidthScaleToFillFrame = true  // Default
```

Set to `false` to keep columns at their calculated widths with empty space on the right.

## Performance Guide

| Dataset Size | Recommended Strategy |
|--------------|---------------------|
| < 1,000 rows | `.maxMeasured` |
| 1,000 - 10,000 | `.hybrid` or `.sampledMax` |
| 10,000 - 100,000 | `.hybrid` or `.estimatedAverage` |
| > 100,000 | `.estimatedAverage` |

### Benchmarks

Approximate times on M1 Mac:

| Strategy | 10K Rows | 50K Rows |
|----------|----------|----------|
| `.estimatedAverage` | ~20ms | ~100ms |
| `.hybrid` | ~50ms | ~200ms |
| `.maxMeasured` | ~500ms | ~2s |

## Combining with Text Wrapping

When columns are capped with `maxColumnWidth`, text may need to wrap:

```swift
var config = DataTableConfiguration()

// Cap column width
config.maxColumnWidth = 200

// Enable wrapping
config.textLayout = .wrap

// Automatic row heights for wrapped content
config.rowHeightMode = .automatic(estimated: 60)
```

## Example: Dashboard Layout

```swift
var config = DataTableConfiguration()

// ID column: narrow, fixed
// Name: medium, accurate
// Description: wider, can truncate outliers
// Status: narrow, fixed

config.columnWidthModeProvider = { column in
    switch column {
    case 0: return .fixed(width: 50)   // ID
    case 1: return .fitContentText(strategy: .maxMeasured)  // Name
    case 2: return .fitContentText(strategy: .percentileMeasured(percentile: 0.95, sampleSize: 100))  // Desc
    case 3: return .fixed(width: 80)   // Status
    default: return nil
    }
}

config.maxColumnWidth = 250
config.minColumnWidth = 50
```

## See Also

- <doc:RowHeights>
- <doc:TextWrapping>
- ``DataTableConfiguration``
- ``DataTableColumnWidthMode``
