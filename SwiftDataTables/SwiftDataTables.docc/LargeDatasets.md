# Large Datasets

Handle 100,000+ rows with smooth 60fps scrolling using lazy measurement.

## Overview

SwiftDataTables is optimized for large datasets. With the right configuration, you can display 100,000+ rows while maintaining smooth scrolling performance.

## The Challenge

Large datasets present two problems:

1. **Memory** - Loading all row heights upfront consumes memory
2. **Startup time** - Measuring all rows delays initial display

SwiftDataTables solves both with **lazy measurement**.

## Enabling Large-Scale Mode

```swift
var config = DataTableConfiguration()
config.rowHeightMode = .automatic(estimated: 44, prefetchWindow: 10)

let dataTable = SwiftDataTable(
    data: massiveDataset,  // 100,000+ items
    columns: columns,
    options: config
)
```

## How Lazy Measurement Works

### 1. Estimated Heights

Initially, all rows use the estimated height:

```
Row 0: 44pt (estimated)
Row 1: 44pt (estimated)
...
Row 99,999: 44pt (estimated)
```

This enables instant startup regardless of dataset size.

### 2. On-Demand Measurement

As rows scroll into view, they're measured:

```
Viewport at row 500:
Row 498: 44pt (estimated)
Row 499: 52pt (measured)  ← entering view
Row 500: 48pt (measured)  ← visible
Row 501: 44pt (measured)  ← visible
Row 502: 44pt (estimated)
```

### 3. Prefetch Window

Rows within the prefetch window are measured ahead of time:

```swift
// prefetchWindow: 10 means measure 10 rows ahead
```

This prevents visual "jumping" as rows scroll into view.

### 4. Automatic Anchoring

When estimated heights are replaced with measured heights, the scroll position is preserved:

```
Before: Scroll offset 22,000pt, viewing row 500
Heights above row 500 change by +200pt total
After: Scroll offset 22,200pt, still viewing row 500
```

## Performance Characteristics

### Time Complexity

| Operation | Complexity |
|-----------|------------|
| Initial load | O(1) |
| Scroll to visible | O(viewport) |
| Content size calculation | O(1)* |

*Uses running totals, not full recalculation

### Memory Usage

| Dataset | Lazy Mode | Full Measurement |
|---------|-----------|------------------|
| 10K rows | ~400KB | ~400KB |
| 100K rows | ~4MB | ~4MB |
| 1M rows | ~40MB | ~40MB |

Memory scales with row count, not measurement state.

## Best Practices

### 1. Choose a Good Estimate

The estimated height should match your typical row:

```swift
// Measure a few sample rows to find the average
let sampleHeights = [52, 48, 44, 56, 48]
let average = sampleHeights.reduce(0, +) / sampleHeights.count  // 50

config.rowHeightMode = .automatic(estimated: CGFloat(average), prefetchWindow: 10)
```

### 2. Use Fixed Heights When Possible

If all rows are the same height, use `.fixed`:

```swift
// Fastest option for uniform content
config.rowHeightMode = .fixed(44)
```

### 3. Tune the Prefetch Window

| Scroll Speed | Recommended Window |
|--------------|-------------------|
| Slow/normal | 5-10 |
| Fast/flicking | 15-20 |
| Programmatic jumps | 20+ |

```swift
// For fast scrolling users
config.rowHeightMode = .automatic(estimated: 44, prefetchWindow: 15)
```

### 4. Avoid Frequent Full Reloads

Instead of reloading all data, use `setData` with diffing:

```swift
// Good - only changed rows update
dataTable.setData(newItems, animatingDifferences: false)

// Avoid - reloads everything
dataTable.reload()  // Deprecated
```

## Column Width Optimization

For large datasets, use fast width strategies:

```swift
var config = DataTableConfiguration()

// Fast: estimate from character count
config.columnWidthMode = .fitContentText(strategy: .estimatedAverage(averageCharWidth: 8))

// Or: sample-based (still fast)
config.columnWidthMode = .fitContentText(strategy: .hybrid(sampleSize: 100, averageCharWidth: 7))

// Avoid for large datasets: measure every row
// config.columnWidthMode = .fitContentText(strategy: .maxMeasured)  // Slow!
```

## Example: 100K Row Table

```swift
struct DataPoint: Identifiable {
    let id: Int
    let timestamp: Date
    let value: Double
    let category: String
}

class LargeDatasetVC: UIViewController {
    var data: [DataPoint] = []
    var dataTable: SwiftDataTable!

    let columns: [DataTableColumn<DataPoint>] = [
        .init("ID") { $0.id },
        .init("Time") { $0.timestamp.formatted() },
        .init("Value") { String(format: "%.2f", $0.value) },
        .init("Category", \.category)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        var config = DataTableConfiguration()

        // Large-scale optimizations
        config.rowHeightMode = .automatic(estimated: 44, prefetchWindow: 10)
        config.columnWidthMode = .fitContentText(strategy: .hybrid(sampleSize: 100, averageCharWidth: 8))

        // Fixed heights are even faster if content is uniform
        // config.rowHeightMode = .fixed(44)

        dataTable = SwiftDataTable(data: data, options: config)
        view.addSubview(dataTable)
        dataTable.frame = view.bounds
    }

    func loadData() {
        // Generate 100K rows
        data = (0..<100_000).map { i in
            DataPoint(
                id: i,
                timestamp: Date().addingTimeInterval(Double(i) * 60),
                value: Double.random(in: 0...1000),
                category: ["A", "B", "C"].randomElement()!
            )
        }

        dataTable.setData(data)
    }
}
```

## Monitoring Performance

Use Instruments to verify smooth scrolling:

1. Open **Instruments** → **Core Animation**
2. Scroll through your table
3. Verify frame rate stays near 60fps

Common issues:
- **Frame drops during scroll** - Increase prefetch window
- **Initial delay** - Check column width strategy
- **Memory growth** - Normal for large datasets

## See Also

- <doc:RowHeights>
- <doc:ColumnWidths>
- ``DataTableRowHeightMode``
