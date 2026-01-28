# Animated Updates

Update your table data with smooth, scroll-preserving animations.

## Overview

SwiftDataTables uses automatic diffing to animate data changes. When you call `setData(_:animatingDifferences:)`, the table:

1. Compares old and new data using `Identifiable` IDs
2. Calculates the minimal set of changes
3. Animates insertions, deletions, and moves
4. Updates changed cells in place

The result is a smooth user experience where users never lose their place.

## Basic Usage

```swift
var items: [Item] = []
var dataTable: SwiftDataTable!

let columns: [DataTableColumn<Item>] = [
    .init("Name", \.name),
    .init("Status", \.status)
]

override func viewDidLoad() {
    super.viewDidLoad()
    dataTable = SwiftDataTable(data: items)
    view.addSubview(dataTable)
}

func refresh() {
    items = fetchNewItems()
    dataTable.setData(items, animatingDifferences: true)
}
```

## What Gets Animated

### Insertions

New items slide in smoothly:

```swift
// Before: [A, B, C]
// After:  [A, B, X, C]  // X is new

items.insert(newItem, at: 2)
dataTable.setData(items, animatingDifferences: true)
// X slides in between B and C
```

### Deletions

Removed items slide out:

```swift
// Before: [A, B, C]
// After:  [A, C]  // B removed

items.remove(at: 1)
dataTable.setData(items, animatingDifferences: true)
// B slides out, C moves up
```

### Moves

Reordered items animate to new positions:

```swift
// Before: [A, B, C]
// After:  [C, A, B]  // C moved to front

items = [itemC, itemA, itemB]
dataTable.setData(items, animatingDifferences: true)
// C animates to top, A and B shift down
```

### Cell Updates

Changed values update in place without row animation:

```swift
// Same items, but itemA.status changed from "Active" to "Inactive"
dataTable.setData(items, animatingDifferences: true)
// Only the status cell in row A updates
```

## Disabling Animation

For bulk updates where animation would be distracting:

```swift
// No animation - instant update
dataTable.setData(items, animatingDifferences: false)
```

Or use the shorter form:

```swift
dataTable.setData(items)  // Defaults to false
```

## Scroll Position Preservation

Unlike the deprecated `reload()` method, `setData` preserves scroll position:

| Method | Scroll Behavior |
|--------|-----------------|
| `reload()` | Resets to top |
| `setData(..., animatingDifferences: false)` | Preserves position |
| `setData(..., animatingDifferences: true)` | Preserves position + animates |

## Completion Handler

Execute code after the animation completes:

```swift
dataTable.setData(items, animatingDifferences: true) {
    // Animation complete
    self.updateLoadingState()
}
```

## Common Patterns

### Pull to Refresh

```swift
@objc func handleRefresh(_ refreshControl: UIRefreshControl) {
    Task {
        let newItems = await api.fetchItems()
        await MainActor.run {
            items = newItems
            dataTable.setData(items, animatingDifferences: true) {
                refreshControl.endRefreshing()
            }
        }
    }
}
```

### Real-Time Updates

```swift
func observeChanges() {
    database.observe { [weak self] snapshot in
        guard let self else { return }
        self.items = snapshot.items
        self.dataTable.setData(self.items, animatingDifferences: true)
    }
}
```

### Optimistic Updates

```swift
func deleteItem(_ item: Item) {
    // Immediately remove from UI
    items.removeAll { $0.id == item.id }
    dataTable.setData(items, animatingDifferences: true)

    // Then sync with server
    Task {
        do {
            try await api.delete(item)
        } catch {
            // Rollback on failure
            items.append(item)
            dataTable.setData(items, animatingDifferences: true)
            showError(error)
        }
    }
}
```

## Performance Considerations

### Large Batch Updates

For very large changes (1000+ rows), consider:

```swift
if changes.count > 500 {
    // Skip animation for massive updates
    dataTable.setData(items, animatingDifferences: false)
} else {
    dataTable.setData(items, animatingDifferences: true)
}
```

### Diffing Cost

Diffing is O(n) where n is the total row count. For 100k+ rows, this is still fast (<50ms), but if you're updating frequently, consider batching:

```swift
var pendingItems: [Item] = []
var updateTimer: Timer?

func queueUpdate(_ items: [Item]) {
    pendingItems = items
    updateTimer?.invalidate()
    updateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { [weak self] _ in
        self?.applyPendingUpdate()
    }
}

func applyPendingUpdate() {
    dataTable.setData(pendingItems, animatingDifferences: true)
}
```

## Troubleshooting

### Animations Not Working

Ensure your model conforms to `Identifiable`:

```swift
struct Item: Identifiable {  // Required!
    let id: Int
    let name: String
}
```

### Unexpected Full Reloads

If the table reloads entirely instead of animating, check:

1. **ID stability** - IDs shouldn't change between updates
2. **Equality** - If using custom `Equatable`, ensure it's correct

### Scroll Jumping

If scroll position isn't preserved, ensure you're not calling `reload()` (deprecated) instead of `setData()`.

## See Also

- <doc:TypeSafeColumns>
- <doc:IncrementalUpdates>
- ``SwiftDataTable/setData(_:animatingDifferences:completion:)-7kg3f``
