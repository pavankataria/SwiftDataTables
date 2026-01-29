# Migrating to 0.9.0

Upgrade from earlier versions with this step-by-step guide.

## Overview

SwiftDataTables 0.9.0 introduces a modern, type-safe API while maintaining backward compatibility. Your existing code will continue to work, but migrating to the new patterns unlocks significant benefits.

## What's New in 0.9.0

- **Type-safe columns** with `DataTableColumn<T>`
- **Animated diffing** via `setData(_:animatingDifferences:)`
- **Self-sizing cells** with lazy measurement
- **Scroll anchoring** during updates
- **Live cell editing** support
- **Default cell configuration** for fonts, colours, and styling without custom cells

## Breaking Changes

**None.** All existing APIs continue to work. New APIs are additive.

## Deprecated APIs

The following are deprecated and will be removed in a future version:

| Deprecated | Replacement | Reason |
|------------|-------------|--------|
| `SwiftDataTableDataSource` protocol | Direct data pattern | Boilerplate-heavy, no diffing |
| `reload()` method | `setData(_:animatingDifferences:)` | Resets scroll, no animations |
| `.largeScale()` | `.automatic(estimated:prefetchWindow:)` | Renamed for clarity |
| `dataTable(_:highlightedColorForRowIndex:)` | `defaultCellConfiguration` | More flexible per-cell styling |
| `dataTable(_:unhighlightedColorForRowIndex:)` | `defaultCellConfiguration` | More flexible per-cell styling |

## Choosing an API

SwiftDataTables offers two approaches:

| Approach | Best For |
|----------|----------|
| **Type-safe API** | Model-backed data, animated updates, dynamic content |
| **Array-based API** | Static displays, quick prototyping, schema-less data |

### Type-Safe API (Recommended for Dynamic Data)

Use when you have model types and want animated updates:

```swift
let columns: [DataTableColumn<Item>] = [
    .init("Name", \.name),
    .init("Age", \.age)
]
let table = SwiftDataTable(columns: columns)
table.setData(items, animatingDifferences: true)
```

Benefits:
- Animated diffing (insertions/deletions animate)
- Type safety (compiler catches errors)
- Scroll position preserved on updates

### Array-Based API (Simple Static Displays)

Use for quick prototyping or truly static data:

```swift
let data = [["Alice", "25"], ["Bob", "30"]]
let table = SwiftDataTable(data: data, headerTitles: ["Name", "Age"])
```

Benefits:
- No model types required
- Minimal setup for simple cases
- Works with any data source

Note: Array-based tables don't support animated diffing - updates replace all content.

For dynamic data without predefined models (CSV, JSON, database queries), see <doc:WorkingWithData>.

## Migration Path

### Step 1: Remove DataSource Protocol

**Before:**

```swift
class MyVC: UIViewController, SwiftDataTableDataSource {
    var items: [Item] = []
    let dataTable = SwiftDataTable()

    override func viewDidLoad() {
        super.viewDidLoad()
        dataTable.dataSource = self
    }

    func numberOfColumns(in: SwiftDataTable) -> Int { 3 }
    func numberOfRows(in: SwiftDataTable) -> Int { items.count }

    func dataTable(_ dataTable: SwiftDataTable, dataForRowAt index: Int) -> [DataTableValueType] {
        let item = items[index]
        return [.string(item.name), .int(item.age), .string(item.city)]
    }

    func dataTable(_ dataTable: SwiftDataTable, headerTitleForColumnAt col: Int) -> String {
        ["Name", "Age", "City"][col]
    }
}
```

**After:**

```swift
class MyVC: UIViewController {
    var items: [Item] = []
    var dataTable: SwiftDataTable!

    let columns: [DataTableColumn<Item>] = [
        .init("Name", \.name),
        .init("Age", \.age),
        .init("City", \.city)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        dataTable = SwiftDataTable(data: items)
    }
}
```

### Step 2: Add Identifiable Conformance

For animated updates, your model needs `Identifiable`:

```swift
// Before
struct Item {
    let name: String
    let age: Int
    let city: String
}

// After
struct Item: Identifiable {
    let id: Int  // Add unique identifier
    let name: String
    let age: Int
    let city: String
}
```

### Step 3: Replace reload() with setData()

**Before:**

```swift
func refresh() {
    items = fetchNewItems()
    dataTable.reload()  // No animation, scroll resets to top
}
```

**After:**

```swift
func refresh() {
    items = fetchNewItems()
    dataTable.setData(items, animatingDifferences: true)
    // ✅ Smooth animation
    // ✅ Scroll position preserved
    // ✅ Only changed cells update
}
```

### Step 4: Update Height Mode (Optional)

If you were using `.largeScale()`:

**Before:**

```swift
config.rowHeightMode = .largeScale(estimatedHeight: 44, prefetchWindow: 10)
```

**After:**

```swift
config.rowHeightMode = .automatic(estimated: 44, prefetchWindow: 10)
```

### Step 5: Replace Delegate Colour Methods (Optional)

If you were using delegate methods to control row colours:

**Before (deprecated):**

```swift
class MyVC: UIViewController, SwiftDataTableDelegate {
    func dataTable(_ dataTable: SwiftDataTable, highlightedColorForRowIndex at: Int) -> UIColor {
        return at % 2 == 0 ? .systemGray6 : .systemGray5
    }

    func dataTable(_ dataTable: SwiftDataTable, unhighlightedColorForRowIndex at: Int) -> UIColor {
        return at % 2 == 0 ? .white : .systemGray6
    }
}
```

**After (recommended):**

```swift
var config = DataTableConfiguration()
config.defaultCellConfiguration = { cell, _, indexPath, isHighlighted in
    let colours: [UIColor] = isHighlighted
        ? [.systemGray6, .systemGray5]
        : [.white, .systemGray6]
    cell.backgroundColor = colours[indexPath.item % colours.count]
}
```

The new approach is more powerful:
- Access the cell directly to change fonts, text colours, alignment
- Conditional styling based on the actual value
- Style specific columns differently
- No delegate conformance required

See <doc:DefaultCellConfiguration> for more examples.

## Migration Checklist

- [ ] Remove `SwiftDataTableDataSource` conformance
- [ ] Add `Identifiable` to your model types
- [ ] Replace protocol methods with `DataTableColumn` definitions
- [ ] Replace `dataTable.reload()` with `dataTable.setData(_:animatingDifferences:)`
- [ ] Update `.largeScale()` to `.automatic(estimated:prefetchWindow:)`
- [ ] (Optional) Replace delegate colour methods with `defaultCellConfiguration`
- [ ] (Optional) Enable text wrapping: `config.textLayout = .wrap`
- [ ] (Optional) Enable auto heights: `config.rowHeightMode = .automatic(estimated: 44)`

## Benefits After Migration

| Aspect | Before (DataSource) | After (Direct Data) |
|--------|---------------------|---------------------|
| Lines of code | ~30+ | ~5 |
| Animated updates | No | Yes |
| Scroll preservation | No | Yes |
| Cell-level diffing | No | Yes |
| Type safety | Manual | Compile-time |

## Gradual Migration

You don't have to migrate everything at once. The old and new APIs coexist:

```swift
// Old tables continue to work
let oldTable = SwiftDataTable()
oldTable.dataSource = self

// New tables use direct data
let newTable = SwiftDataTable(data: items)
```

Migrate screen by screen as you update features.

## Troubleshooting

### Deprecation Warnings

After migration, you'll see warnings for any remaining deprecated usage. Address these by following the replacement suggestions in the warning message.

### Missing Animations

If updates aren't animating:
1. Verify your model conforms to `Identifiable`
2. Ensure you're passing `animatingDifferences: true`
3. Check that IDs are stable between updates

### Compilation Errors

If you see type errors with columns:
1. Ensure the generic type matches your model: `DataTableColumn<YourModel>`
2. Verify key paths point to valid properties
3. For computed values, use the closure initializer

## See Also

- <doc:GettingStarted>
- <doc:TypeSafeColumns>
- <doc:AnimatedUpdates>
- <doc:DefaultCellConfiguration>
