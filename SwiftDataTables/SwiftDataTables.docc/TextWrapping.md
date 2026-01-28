# Text Wrapping

Enable multi-line text cells when content exceeds column width.

## Overview

By default, text is truncated when it exceeds the column width. Enable text wrapping to display the full content across multiple lines.

## Enabling Text Wrapping

```swift
var config = DataTableConfiguration()
config.textLayout = .wrap
config.rowHeightMode = .automatic(estimated: 60)

let dataTable = SwiftDataTable(columns: columns, options: config)
```

## Text Layout Options

### Single Line (Default)

```swift
config.textLayout = .singleLine(truncation: .byTruncatingTail)
```

Long text is truncated: "This is a very long te..."

### Wrapped

```swift
config.textLayout = .wrap
```

Long text flows to multiple lines:
```
This is a very long
text that wraps to
multiple lines.
```

## Combining with Row Heights

Text wrapping requires automatic row heights:

```swift
config.textLayout = .wrap
config.rowHeightMode = .automatic(estimated: 60)
```

If you use `.fixed` height, wrapped text will be clipped.

## Controlling Column Width

Text wraps when it exceeds the column width. Control this with:

```swift
config.maxColumnWidth = 200  // Force wrapping at 200pt
```

## Example: Notes Table

```swift
struct Note: Identifiable {
    let id: Int
    let title: String
    let content: String  // Can be long
    let date: Date
}

var config = DataTableConfiguration()
config.textLayout = .wrap
config.rowHeightMode = .automatic(estimated: 80)
config.maxColumnWidth = 300  // Prevent super-wide columns

let columns: [DataTableColumn<Note>] = [
    .init("Title", \.title),
    .init("Content", \.content),
    .init("Date") { $0.date.formatted() }
]

let dataTable = SwiftDataTable(data: notes, columns: columns, options: config)
```

## See Also

- <doc:RowHeights>
- <doc:ColumnWidths>
- ``DataTableTextLayout``
