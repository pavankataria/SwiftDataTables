# Default Cell Configuration

Customise the appearance of default cells without creating custom cell classes.

## Overview

The ``DataTableConfiguration/defaultCellConfiguration`` callback provides a simple way to customise fonts, colours, and other properties of the default ``DataCell`` without the boilerplate of a full custom cell provider.

This is ideal when you need to:
- Change the font for all cells
- Apply conditional text colours based on values
- Customise alternating row colours
- Style cells based on their position or content

## Basic Usage

```swift
var config = DataTableConfiguration()
config.defaultCellConfiguration = { cell, value, indexPath, isHighlighted in
    // Customise the cell
    cell.dataLabel.font = UIFont(name: "Avenir-Medium", size: 14)
    cell.dataLabel.textColor = .label
}

let table = SwiftDataTable(data: items, columns: columns, options: config)
```

## Parameters

The callback receives four parameters:

| Parameter | Type | Description |
|-----------|------|-------------|
| `cell` | ``DataCell`` | The cell instance to configure |
| `value` | ``DataTableValueType`` | The data value being displayed |
| `indexPath` | `IndexPath` | Position where `section` = column, `item` = row |
| `isHighlighted` | `Bool` | `true` if the cell is in a sorted column |

## Common Patterns

### Custom Font

```swift
config.defaultCellConfiguration = { cell, _, _, _ in
    cell.dataLabel.font = UIFont(name: "Menlo", size: 12)
}
```

### Alternating Row Colours

```swift
config.defaultCellConfiguration = { cell, _, indexPath, _ in
    cell.backgroundColor = indexPath.item % 2 == 0
        ? .systemGray6
        : .systemBackground
}
```

### Conditional Styling Based on Value

Highlight negative numbers in red:

```swift
config.defaultCellConfiguration = { cell, value, _, _ in
    if let number = value.doubleValue, number < 0 {
        cell.dataLabel.textColor = .systemRed
    } else {
        cell.dataLabel.textColor = .label
    }
}
```

### Highlight Sorted Columns

```swift
config.defaultCellConfiguration = { cell, _, indexPath, isHighlighted in
    if isHighlighted {
        cell.backgroundColor = .systemYellow.withAlphaComponent(0.2)
    } else {
        cell.backgroundColor = indexPath.item % 2 == 0 ? .systemGray6 : .systemBackground
    }
}
```

### Per-Column Styling

Style specific columns differently:

```swift
config.defaultCellConfiguration = { cell, _, indexPath, _ in
    switch indexPath.section {
    case 0:  // First column (e.g., ID)
        cell.dataLabel.font = .monospacedDigitSystemFont(ofSize: 12, weight: .regular)
    case 3:  // Fourth column (e.g., Status)
        cell.dataLabel.textAlignment = .center
    default:
        break
    }
}
```

## Migration from Delegate Methods

The delegate methods `dataTable(_:highlightedColorForRowIndex:)` and `dataTable(_:unhighlightedColorForRowIndex:)` are deprecated. Use `defaultCellConfiguration` instead.

### Before (Deprecated)

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

### After (Recommended)

```swift
var config = DataTableConfiguration()
config.defaultCellConfiguration = { cell, _, indexPath, isHighlighted in
    let colours: [UIColor] = isHighlighted
        ? [.systemGray6, .systemGray5]
        : [.white, .systemGray6]
    cell.backgroundColor = colours[indexPath.item % colours.count]
}
```

## When to Use Custom Cells Instead

For most styling needs—fonts, colours, text alignment, and conditional formatting—`defaultCellConfiguration` is the recommended approach. It keeps your code simple and maintains full control over the default cell's appearance.

If you need more advanced customisation, such as:
- Custom subviews (images, buttons, badges)
- Complex multi-element layouts
- Different cell types per column
- Interactive elements

Then you should create custom cells using ``DataTableCustomCellProvider``. See <doc:CustomCells> for the complete guide on registering and configuring custom cells.

## Important Notes

- This callback is only invoked when ``DataTableConfiguration/cellSizingMode`` is `.defaultCell`
- When using custom cells via ``DataTableCustomCellProvider``, configure them in the provider's `configure` closure instead
- When this callback is set, you are responsible for setting the cell's background colour. The default ``DataTableConfiguration/highlightedAlternatingRowColors`` and ``DataTableConfiguration/unhighlightedAlternatingRowColors`` are not applied automatically.

## See Also

- ``DataTableConfiguration/defaultCellConfiguration``
- ``DataCell``
- <doc:CustomCells>
