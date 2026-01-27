# Incremental Updates

Update individual rows or cells without reloading the entire table.

## Overview

While `setData(_:animatingDifferences:)` handles most update scenarios, sometimes you need finer control for:

- Single row updates during editing
- Cell content changes from user interaction
- Performance-critical partial updates

## Single Row Refresh

Reload a specific row after changes:

```swift
// User edited row 5
dataTable.reloadRow(at: 5)
```

## Row Height Remeasurement

When cell content changes (e.g., text editing), update the row height:

```swift
// Text in row 3 changed, height may need adjustment
let heightChanged = dataTable.remeasureRow(3)

if heightChanged {
    // Layout was updated
}
```

This is useful for:
- Live text editing in cells
- Expanding/collapsing content
- Dynamic content updates

## Batch Updates

For multiple changes, use `setData` which batches automatically:

```swift
// Multiple changes at once
items[0].name = "Updated"
items[2].status = "Complete"
items.remove(at: 5)
items.append(newItem)

// One call handles all changes efficiently
dataTable.setData(items, columns: columns, animatingDifferences: true)
```

## When to Use Each Approach

| Scenario | Recommended Approach |
|----------|---------------------|
| Full data refresh | `setData(_:animatingDifferences:)` |
| Multiple row changes | `setData(_:animatingDifferences:)` |
| Single row visual refresh | `reloadRow(at:)` |
| Cell height changed | `remeasureRow(_:)` |
| Real-time typing | `remeasureRow(_:)` |

## See Also

- <doc:AnimatedUpdates>
- ``SwiftDataTable/remeasureRow(_:)``
