# Row Heights

Self-sizing rows that adapt to your content automatically.

## Overview

SwiftDataTables supports automatic row heights using the standard iOS `systemLayoutSizeFitting` mechanism. This works with:

- Text wrapping and multi-line content
- Custom cells with Auto Layout constraints
- Dynamic Type and accessibility sizes
- Mixed content types (images, buttons, labels)

## Automatic Heights

Enable self-sizing rows with a single line:

```swift
var config = DataTableConfiguration()
config.rowHeightMode = .automatic(estimated: 60)
```

The `estimated` parameter provides an initial height before measurement. Pick something close to your typical row height for smooth scrolling.

### How It Works

1. **Initial layout** – Rows use the estimated height
2. **Lazy measurement** – As rows scroll into view, they're measured via Auto Layout
3. **Height caching** – Measured heights are cached for reuse
4. **Scroll anchoring** – Scroll position is preserved when heights change

This is the same mechanism UITableView and UICollectionView use for self-sizing cells.

### With Text Wrapping

Combine with text wrapping for multi-line content:

```swift
var config = DataTableConfiguration()
config.textLayout = .wrap
config.rowHeightMode = .automatic(estimated: 60)
config.maxColumnWidth = 250  // Force wrapping by capping width
```

### With Custom Cells

For custom cells, your Auto Layout constraints define the height:

```swift
class ProductCell: UICollectionViewCell {
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        // Setup constraints that define the cell's height
        descriptionLabel.numberOfLines = 0  // Multi-line

        // Vertical stack: image -> title -> description
        // Bottom of description pinned to bottom of cell
        // This allows the cell to calculate its own height
    }
}
```

When using custom cells with `config.cellSizingMode = .autoLayout(provider:)`, the library measures your cells to determine row heights.

## Large Datasets (100k+ rows)

For very large datasets, add a prefetch window:

```swift
config.rowHeightMode = .automatic(estimated: 44, prefetchWindow: 10)
```

The prefetch window measures rows ahead of the visible area for smoother scrolling.

### How Lazy Measurement Works

| Visible Rows | Prefetch Window | Rows Measured |
|--------------|-----------------|---------------|
| 0-20 | 10 | 0-30 |
| 100-120 | 10 | 90-130 |
| Scroll down | 10 | Measures ahead |

Rows outside this window keep their estimated height until they approach the viewport.

## Fixed Height

For uniform rows where all content fits in the same height:

```swift
var config = DataTableConfiguration()
config.rowHeightMode = .fixed(44)
```

Benefits:
- Fastest performance
- Instant scroll calculations
- No measurement overhead

Use when:
- All rows have single-line text
- Content is uniform across rows
- Performance is critical

## Live Height Updates

When cell content changes during editing, update the height without reloading:

```swift
func textViewDidChange(_ textView: UITextView) {
    // Update your model
    notes[rowIndex].content = textView.text

    // Remeasure the row - keyboard stays up, no cell reload
    dataTable.remeasureRow(rowIndex)
}
```

This:
- Preserves first responder (keyboard stays up)
- Avoids cell flicker
- Only affects the single row
- Updates layout smoothly

## Scroll Anchoring

When row heights change, the scroll position is automatically preserved:

```swift
// Before: User viewing row 50
// Heights above row 50 change
// After: User still sees row 50 (scroll offset adjusted)
```

This prevents visual jumping when:
- Estimated heights are replaced with measured heights
- Content changes cause height updates
- Data updates insert/remove rows above the viewport

## Choosing an Estimate

Pick an estimate close to your typical row height:

```swift
// Single line of text
config.rowHeightMode = .automatic(estimated: 44)

// 2-3 lines of text
config.rowHeightMode = .automatic(estimated: 70)

// Variable content - use the median
config.rowHeightMode = .automatic(estimated: 55)
```

A poor estimate causes:
- Visual jumping during initial scroll
- Scroll bar size changes
- More anchoring corrections

## Custom Per-Row Heights

For fine-grained control via delegate:

```swift
class MyViewController: UIViewController, SwiftDataTableDelegate {
    func dataTable(_ dataTable: SwiftDataTable, heightForRowAt index: Int) -> CGFloat {
        if index == 0 {
            return 80  // Header row is taller
        }
        return 44
    }
}
```

> Note: Delegate heights override `rowHeightMode`.

## Example: Notes App

A table with multi-line notes that resize as users type:

```swift
struct Note: Identifiable {
    let id: UUID
    var title: String
    var content: String  // Multi-line
    let date: Date
}

var config = DataTableConfiguration()
config.textLayout = .wrap
config.rowHeightMode = .automatic(estimated: 100)
config.maxColumnWidth = 300

// In your text view delegate:
func textViewDidChange(_ textView: UITextView) {
    notes[editingIndex].content = textView.text
    dataTable.remeasureRow(editingIndex)
}
```

## See Also

- <doc:ColumnWidths>
- <doc:TextWrapping>
- <doc:CustomCells>
- <doc:LargeDatasets>
- ``DataTableRowHeightMode``
