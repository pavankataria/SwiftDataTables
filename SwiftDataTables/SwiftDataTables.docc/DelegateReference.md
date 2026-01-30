# Delegate Reference

Complete reference for all SwiftDataTableDelegate methods.

## Overview

The `SwiftDataTableDelegate` protocol provides callbacks for user interactions and customization points. All methods have default implementations, so you only need to implement the ones you care about.

## Setting Up

Conform your view controller to `SwiftDataTableDelegate` and set it as the delegate:

```swift
class MyViewController: UIViewController, SwiftDataTableDelegate {
    var dataTable: SwiftDataTable!

    override func viewDidLoad() {
        super.viewDidLoad()
        dataTable = SwiftDataTable(data: items, columns: columns)
        dataTable.delegate = self
        view.addSubview(dataTable)
    }
}
```

## Selection Events

Respond to user taps on rows.

### didSelectItem

Called when a user taps a cell. The `indexPath.section` is the row index, `indexPath.item` is the column index.

```swift
func didSelectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath) {
    let row = indexPath.section
    let column = indexPath.item
    let item = items[row]
    // Handle selection - show detail, present action sheet, etc.
}
```

### didDeselectItem

Called when a previously selected cell is deselected.

```swift
func didDeselectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath) {
    // Handle deselection if needed
}
```

## Header and Footer Taps

Respond to taps on column headers and footers. Useful for custom sorting UI, filtering, or showing column options.

### didTapHeaderAt

Called when a user taps a column header. By default, tapping a header triggers sorting - use this to add custom behavior.

```swift
func dataTable(_ dataTable: SwiftDataTable, didTapHeaderAt columnIndex: Int) {
    print("Tapped header for column \(columnIndex)")
    // Show filter options, column settings, etc.
}
```

### didTapFooterAt

Called when a user taps a column footer.

```swift
func dataTable(_ dataTable: SwiftDataTable, didTapFooterAt columnIndex: Int) {
    print("Tapped footer for column \(columnIndex)")
}
```

## Row and Column Sizing

Override default sizing on a per-row or per-column basis.

### heightForRowAt

Return a custom height for a specific row. Return `nil` to use the default height from configuration.

```swift
func dataTable(_ dataTable: SwiftDataTable, heightForRowAt index: Int) -> CGFloat? {
    // Make the first row taller
    return index == 0 ? 60 : nil
}
```

### widthForColumnAt

Return a custom width for a specific column. Return `nil` to use the default width calculation.

```swift
func dataTable(_ dataTable: SwiftDataTable, widthForColumnAt index: Int) -> CGFloat? {
    // Make the first column wider
    return index == 0 ? 200 : nil
}
```

## Section Heights

Customize the height of various table sections.

| Method | Description |
|--------|-------------|
| `heightForSectionHeader(in:)` | Height of column headers row |
| `heightForSectionFooter(in:)` | Height of column footers row |
| `heightForSearchView(in:)` | Height of the search bar section |
| `heightOfInterRowSpacing(in:)` | Spacing between rows |

```swift
func heightForSectionHeader(in dataTable: SwiftDataTable) -> CGFloat? {
    return 50  // Custom header height
}

func heightOfInterRowSpacing(in dataTable: SwiftDataTable) -> CGFloat? {
    return 2  // Add spacing between rows
}
```

## Layout Behavior

Control how elements float, scale, and scroll.

| Method | Description | Default |
|--------|-------------|---------|
| `shouldContentWidthScaleToFillFrame(in:)` | Whether columns expand to fill available width | `true` |
| `shouldSectionHeadersFloat(in:)` | Keep headers visible while scrolling | `true` |
| `shouldSectionFootersFloat(in:)` | Keep footers visible while scrolling | `true` |
| `shouldSearchHeaderFloat(in:)` | Keep search bar visible while scrolling | `true` |
| `shouldShowSearchSection(in:)` | Show/hide the search section | `true` |
| `shouldShowVerticalScrollBars(in:)` | Show vertical scroll indicators | `true` |
| `shouldShowHorizontalScrollBars(in:)` | Show horizontal scroll indicators | `true` |

```swift
func shouldSectionHeadersFloat(in dataTable: SwiftDataTable) -> Bool? {
    return false  // Headers scroll with content
}

func shouldShowSearchSection(in dataTable: SwiftDataTable) -> Bool? {
    return false  // Hide search bar
}
```

## Fixed Columns

Pin columns to the left or right edge so they remain visible while scrolling horizontally.

```swift
func fixedColumns(for dataTable: SwiftDataTable) -> DataTableFixedColumnType? {
    return DataTableFixedColumnType(leftColumns: 1)  // Pin first column
}
```

> Tip: See <doc:FixedColumns> for more details on pinning columns.

## RTL Support

Enable right-to-left layout for languages like Arabic and Hebrew.

```swift
func shouldSupportRightToLeftInterfaceDirection(in dataTable: SwiftDataTable) -> Bool? {
    return true  // Enable RTL support
}
```

## Complete Method Reference

Here's the complete list of all delegate methods:

| Category | Method |
|----------|--------|
| Selection | `didSelectItem(_:indexPath:)` |
| Selection | `didDeselectItem(_:indexPath:)` |
| Header/Footer | `dataTable(_:didTapHeaderAt:)` |
| Header/Footer | `dataTable(_:didTapFooterAt:)` |
| Sizing | `dataTable(_:heightForRowAt:)` |
| Sizing | `dataTable(_:widthForColumnAt:)` |
| Section Heights | `heightForSectionHeader(in:)` |
| Section Heights | `heightForSectionFooter(in:)` |
| Section Heights | `heightForSearchView(in:)` |
| Section Heights | `heightOfInterRowSpacing(in:)` |
| Layout | `shouldContentWidthScaleToFillFrame(in:)` |
| Layout | `shouldSectionHeadersFloat(in:)` |
| Layout | `shouldSectionFootersFloat(in:)` |
| Layout | `shouldSearchHeaderFloat(in:)` |
| Layout | `shouldShowSearchSection(in:)` |
| Scroll Bars | `shouldShowVerticalScrollBars(in:)` |
| Scroll Bars | `shouldShowHorizontalScrollBars(in:)` |
| Fixed Columns | `fixedColumns(for:)` |
| RTL | `shouldSupportRightToLeftInterfaceDirection(in:)` |

> Note: All delegate methods return optionals. Return `nil` to use the default behavior from `DataTableConfiguration`.
