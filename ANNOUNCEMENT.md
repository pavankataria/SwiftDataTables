# SwiftDataTables v0.9.0 Release Announcement

## Overview

This release represents the most significant update to SwiftDataTables since its inception. I've modernised the entire architecture while maintaining full backwards compatibility with existing code. The highlights include:

- **Type-Safe API** - Work directly with your Swift models using generics and KeyPaths
- **Automatic Diffing** - Animated row insertions, deletions, and updates with a single method call
- **Cell-Level Updates** - Only changed cells are reloaded, not entire rows
- **Self-Sizing Cells** - Full Auto Layout support with custom cell providers
- **Flexible Column Widths** - Multiple strategies from estimated averages to measured maximums
- **Text Wrapping** - Multi-line cell content with automatic height calculation
- **Navigation Bar Search** - Integrate search with UISearchController
- **Performance Optimisations** - Layout calculations improved from O(n²) to O(n)
- **Large-Scale Mode** - Handle 100k+ rows with lazy measurement and prefetching
- **Scroll Anchoring** - Preserves visual position during data updates (no jumps!)
- **Live Cell Editing** - `remeasureRow()` API for real-time height updates without cell reloads
- **Swift 6 Ready** - Full strict concurrency support

---

## Type-Safe API

### The Problem with Raw Arrays

Previously, you had to manually convert your models to nested arrays:

```swift
// Old approach - verbose and error-prone
let data: [[DataTableValueType]] = users.map { user in
    [.string(user.name), .int(user.age), .double(user.score)]
}
let headers = ["Name", "Age", "Score"]
let table = SwiftDataTable(data: data, headerTitles: headers)
```

### The New Typed Approach

Now you can work directly with your model types:

```swift
struct User: Identifiable {
    let id: Int
    let name: String
    let age: Int
    let score: Double
}

let users: [User] = [...]

// New approach - type-safe and concise
let table = SwiftDataTable(data: users, columns: [
    .init("Name", \.name),
    .init("Age", \.age),
    .init("Score", \.score)
])
```

### DataTableColumn

Define columns using KeyPaths or custom closures:

```swift
// KeyPath extraction (automatic type conversion)
DataTableColumn("Name", \.name)
DataTableColumn("Age", \.age)

// Custom extraction for computed values
DataTableColumn("Full Name") { user in
    .string("\(user.firstName) \(user.lastName)")
}

// Header-only for custom cell columns
DataTableColumn<User>("Actions")
```

### Supported Types

The following types automatically convert via `DataTableValueConvertible`:

| Type | Conversion |
|------|------------|
| `String` | `.string(value)` |
| `Int` | `.int(value)` |
| `Float` | `.float(value)` |
| `Double` | `.double(value)` |
| `Optional<T>` | Wrapped value or empty string |

Extend the protocol for custom types:

```swift
extension Date: DataTableValueConvertible {
    public func asDataTableValue() -> DataTableValueType {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return .string(formatter.string(from: self))
    }
}
```

---

## Automatic Diffing with setData

### Animated Updates

Update your table with automatic diffing - the library calculates insertions, deletions, and moves:

```swift
// Modify your data source
users.append(User(id: 4, name: "Diana", age: 28, score: 91.0))
users.removeAll { $0.id == 2 }
users[0] = User(id: 1, name: "Alice Updated", age: 31, score: 96.0)

// Single call to animate all changes
table.setData(users, animatingDifferences: true)
```

The table uses `Identifiable` conformance to track row identity. Rows with the same `id` are considered the same row (enabling content updates), while different IDs trigger insertions/deletions.

### Raw Data API

For non-typed usage, you can still use the raw API with explicit identifiers:

```swift
// Content-based identity (rows with identical content are "same")
table.setData(rawData, animatingDifferences: true)

// Explicit identifiers (recommended for database records)
let ids = records.map { $0.id }
table.setData(rawData, rowIdentifiers: ids, animatingDifferences: true)
```

### Model Access

Retrieve your typed models back from the table:

```swift
// Single row
if let user: User = table.model(at: indexPath.row) {
    print("Selected: \(user.name)")
}

// All models
if let users: [User] = table.allModels() {
    print("Total users: \(users.count)")
}
```

---

## Cell-Level Updates (since 0.8.2)

### Granular Diffing

When row content changes, only the specific cells (columns) that changed are reloaded - not the entire row. This provides:

- **Better performance** - Less re-rendering work for the collection view
- **No flicker** - Unchanged cells remain stable
- **Smoother animations** - Only affected cells animate

### How It Works

```swift
// Before: Row 0 has ["Alice", "25", "Active"]
// After:  Row 0 has ["Alice", "26", "Active"]

table.setData(users, animatingDifferences: true)
// Only the "Age" cell (column 1) is reloaded
// "Name" and "Status" cells remain untouched
```

The diffing algorithm:
1. Compares old and new rows by their `id` (from `Identifiable`)
2. For rows that exist in both snapshots, compares each column value
3. Reloads only the specific `IndexPath`s where values differ

### Visual Proof

The **Cell-Level Updates** demo in the Example app proves this behaviour:
- Each cell displays a "configure count" badge
- A timer updates random cell values every 3 seconds
- Only the changed cell's count increases - neighbouring cells stay at their previous count

This is especially noticeable in wide tables where updating one column no longer causes the entire row to flash.

---

## Self-Sizing Cells & Auto Layout

### Automatic Row Heights

Enable automatic row heights for text wrapping:

```swift
var config = DataTableConfiguration()
config.textLayout = .wrap
config.rowHeightMode = .automatic(estimated: 44)

let table = SwiftDataTable(data: users, columns: columns, options: config)
```

### Custom Cell Provider

For complete control, provide your own cells with Auto Layout:

```swift
var config = DataTableConfiguration()
config.cellSizingMode = .autoLayout(provider: DataTableCustomCellProvider(
    register: { collectionView in
        collectionView.register(UserCardCell.self, forCellWithReuseIdentifier: "UserCard")
        collectionView.register(StatusPillCell.self, forCellWithReuseIdentifier: "Status")
    },
    reuseIdentifierFor: { indexPath in
        indexPath.item == 0 ? "UserCard" : "Status"
    },
    configure: { cell, value, indexPath in
        if let userCell = cell as? UserCardCell {
            userCell.configure(with: value.stringRepresentation)
        } else if let statusCell = cell as? StatusPillCell {
            statusCell.configure(with: value.stringRepresentation)
        }
    },
    sizingCellFor: { reuseId in
        reuseId == "UserCard" ? UserCardCell() : StatusPillCell()
    }
))
```

Your custom cells should use Auto Layout constraints. The library measures each cell to determine row heights.

---

## Column Width Strategies

### Configuration Options

Control how column widths are calculated:

```swift
var config = DataTableConfiguration()

// Global mode for all columns
config.columnWidthMode = .fitContentText(strategy: .maxMeasured)

// Per-column overrides
config.columnWidthModeProvider = { columnIndex in
    switch columnIndex {
    case 0: return .fixed(width: 80)      // Fixed width for ID column
    case 1: return .fitContentText(strategy: .estimatedAverage(averageCharWidth: 8))
    default: return nil                    // Use global mode
    }
}

// Constraints
config.minColumnWidth = 60
config.maxColumnWidth = 300
```

### Available Strategies

| Strategy | Description | Performance |
|----------|-------------|-------------|
| `.estimatedAverage(averageCharWidth:)` | Character count × width estimate | Fastest |
| `.maxMeasured` | Measure every cell, use maximum | Most accurate |
| `.sampledMax(sampleSize:)` | Measure sample, use maximum | Balanced |
| `.percentileMeasured(percentile:, sampleSize:)` | Use nth percentile of sample | Handles outliers |
| `.hybrid(sampleSize:, averageCharWidth:)` | Combine estimation with sampling | Robust |
| `.fixed(width:)` | Explicit pixel width | Instant |

---

## Navigation Bar Search

### UISearchController Integration

Place the search bar in the navigation bar instead of embedded in the table:

```swift
var config = DataTableConfiguration()
config.searchBarPosition = .navigationBar

let table = SwiftDataTable(data: users, columns: columns, options: config)
view.addSubview(table)

// Attach to your view controller - handles UISearchController setup
table.attachSearchToNavigationBar(of: self)
```

### Search Positions

| Position | Behaviour |
|----------|-----------|
| `.embedded` | Search bar within table (default) |
| `.navigationBar` | UISearchController in navigation item |
| `.hidden` | No search bar displayed |

---

## Configuration Reference

### New Properties

```swift
public struct DataTableConfiguration {
    // Column Widths
    var columnWidthMode: DataTableColumnWidthMode
    var minColumnWidth: CGFloat
    var maxColumnWidth: CGFloat?
    var columnWidthModeProvider: ((Int) -> DataTableColumnWidthMode?)?

    // Text & Rows
    var textLayout: DataTableTextLayout        // .singleLine() or .wrap
    var rowHeightMode: DataTableRowHeightMode  // .fixed(CGFloat) or .automatic(estimated:)
    var cellSizingMode: DataTableCellSizingMode // .defaultCell or .autoLayout(provider:)

    // Search
    var searchBarPosition: SearchBarPosition   // .embedded, .navigationBar, or .hidden
}
```

### Text Layout Options

```swift
// Single line with truncation (default)
config.textLayout = .singleLine(truncation: .byTruncatingTail)

// Multi-line wrapping
config.textLayout = .wrap
```

### Row Height Modes

```swift
// Fixed height for all rows
config.rowHeightMode = .fixed(44)

// Automatic with estimated height for scroll performance
config.rowHeightMode = .automatic(estimated: 60)
```

---

## Superseded Patterns

The following patterns still work but have better alternatives:

| Old Pattern | New Alternative | Benefit |
|-------------|-----------------|---------|
| `SwiftDataTable(data: [[DataTableValueType]], headerTitles:)` | `SwiftDataTable(data: [T], columns:)` | Type safety, no manual conversion |
| `table.set(data:headerTitles:)` + `table.reload()` | `table.setData(_:animatingDifferences:)` | Automatic diffing with animations |
| Manual row identity tracking | `Identifiable` conformance | Automatic identity via `id` property |
| `shouldShowSearchSection = false` | `searchBarPosition = .hidden` | Clearer intent, more options |
| Fixed 44pt row heights | `rowHeightMode = .automatic(estimated:)` | Self-sizing rows |
| Hardcoded column widths | `columnWidthMode` strategies | Flexible, content-aware widths |

### Internal Deprecation Fixes

This release also addresses deprecated iOS APIs internally:

- Replaced `UIApplication.willChangeStatusBarOrientationNotification` with `UIDevice.orientationDidChangeNotification`
- Removed `automaticallyAdjustsScrollViewInsets` (obsolete since iOS 11)
- Updated navigation bar appearance configuration for iOS 15+

---

## Migration Guide

### From 0.8.x

**No breaking changes** - your existing code continues to work. The new APIs are additive.

To adopt the typed API:

1. Make your model conform to `Identifiable`
2. Replace manual array conversion with `DataTableColumn` definitions
3. Use the new typed initialiser
4. Replace `reload()` calls with `setData(_:animatingDifferences:)`

### Before

```swift
struct User {
    let id: Int
    let name: String
}

let data = users.map { [DataTableValueType.string($0.name)] }
let table = SwiftDataTable(data: data, headerTitles: ["Name"])

// On data change
users.append(newUser)
let newData = users.map { [DataTableValueType.string($0.name)] }
table.set(data: newData, headerTitles: ["Name"])
table.reload()
```

### After

```swift
struct User: Identifiable {
    let id: Int
    let name: String
}

let table = SwiftDataTable(data: users, columns: [
    .init("Name", \.name)
])

// On data change - animated automatically
users.append(newUser)
table.setData(users, animatingDifferences: true)
```

---

## Large-Scale Mode (100k+ Rows)

For tables with massive datasets, enable large-scale mode for lazy measurement and optimal scroll performance:

```swift
var config = DataTableConfiguration()
config.rowHeightMode = .largeScale(estimatedHeight: 44, prefetchWindow: 10)

let table = SwiftDataTable(data: massiveDataset, columns: columns, options: config)
```

### How It Works

- **Lazy Measurement**: Rows start with estimated heights and are measured on-demand as they scroll into view
- **Prefetch Window**: Rows within the prefetch window are measured ahead of time for smooth scrolling
- **O(viewport) Performance**: Only visible rows are measured, not the entire dataset
- **Automatic Anchoring**: When estimated heights are replaced with measured heights, scroll position is preserved

### When to Use

- Datasets with 10,000+ rows
- When row heights vary significantly
- When initial load time is critical

---

## Scroll Anchoring

Data updates no longer cause visual jumps. The table automatically preserves the user's scroll position:

```swift
// User is viewing row 500
table.setData(newData, animatingDifferences: true)
// After update, user is still viewing row 500 (or its replacement)
```

### Anchoring Behaviour

- **Insertions above viewport**: Content offset adjusts to keep current content in place
- **Deletions above viewport**: Content offset adjusts to prevent jumping
- **Height changes**: Visual position preserved even when row heights change
- **Anchor fallback**: If the anchor row is deleted, the nearest surviving row becomes the anchor

### Automatic During Updates

Anchoring is automatic for all `setData()` calls with `animatingDifferences: true`. No configuration required.

---

## Live Cell Editing with remeasureRow()

For cells with editable content (like text views), use `remeasureRow()` to update heights in real-time without cell reloads:

```swift
func textViewDidChange(_ textView: UITextView) {
    // Update your model
    notes[rowIndex].content = textView.text

    // Remeasure the row - no cell reload, keyboard stays up
    dataTable.remeasureRow(rowIndex)
}
```

### Benefits

- **Preserves First Responder**: Keyboard stays up during text editing
- **No Cell Flicker**: Cell content isn't reloaded, just repositioned
- **Efficient**: Only measures and updates the single row
- **Safe**: Handles partial column visibility by using max(measured, old) to prevent shrinking

### When to Use

- Editable text fields/views in cells
- Real-time content changes that affect row height
- Any scenario where you need height updates without cell reloads

---

## Performance Notes

### Layout Engine Improvements

The layout engine has been completely refactored for optimal scrolling performance with large datasets:

- **On-demand layout calculation**: Layout attributes are now generated only for visible rows using O(log n) binary search, instead of pre-computing all attributes upfront. This means scrolling through 1 million rows is as smooth as scrolling through 100 rows.

- **Cached content size**: `collectionViewContentSize` is now O(1) cached access. Previously, each scroll event triggered O(n) iteration through all rows to recalculate the total height - catastrophic for large datasets.

- **Preserved scroll position**: Appending or inserting rows no longer causes visual jumps. The layout correctly maintains your scroll position during incremental updates.

### Cell-Level Diffing

- **Granular updates**: Only changed cells are reloaded, not entire rows
- **No unnecessary reconfiguration**: Unchanged cells in a row remain untouched
- **Reduced flicker**: Stable cells don't animate when neighbours change
- **Efficient comparison**: Column-by-column value comparison with early exit

### Column Width Calculations

- **Layout optimisation**: Column width calculations reduced from O(n²) to O(n)
- **Sampling strategies**: Use `.sampledMax` or `.hybrid` for large datasets (10k+ rows)
- **Row height caching**: Calculated once per data update, cached until next change
- **Sizing cell reuse**: Custom cells are cached and reused during measurement

---

## Requirements

- iOS 17.0+
- Swift 5.9+
- Xcode 15.0+

---

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/pavankataria/SwiftDataTables.git", from: "0.9.0")
]
```

### CocoaPods

```ruby
pod 'SwiftDataTables', '~> 0.9'
```

---

## Acknowledgements

This release represents months of architectural improvements. Special thanks to all contributors and users who provided feedback.

For questions or issues, please open a GitHub issue or discussion.
