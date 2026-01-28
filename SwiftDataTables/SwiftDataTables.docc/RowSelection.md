# Row Selection

Respond to user taps and manage selection state in your data table.

## Overview

SwiftDataTables provides delegate callbacks for handling row selection. Use these to respond to user taps, navigate to detail views, or trigger actions.

## Setting Up the Delegate

Assign a delegate to receive selection events:

```swift
class MyViewController: UIViewController, SwiftDataTableDelegate {
    var dataTable: SwiftDataTable!

    override func viewDidLoad() {
        super.viewDidLoad()
        dataTable = SwiftDataTable(data: myData, headerTitles: headers)
        dataTable.delegate = self
    }
}
```

## Handling Selection

### Single Selection

Respond when the user taps a row:

```swift
func didSelectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath) {
    let selectedRow = indexPath.section  // Row index
    let selectedColumn = indexPath.item   // Column index

    print("Selected row \(selectedRow), column \(selectedColumn)")

    // Navigate to detail view
    let item = items[selectedRow]
    showDetail(for: item)
}
```

### Deselection

Respond when a row is deselected:

```swift
func didDeselectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath) {
    let deselectedRow = indexPath.section
    print("Deselected row \(deselectedRow)")
}
```

## Understanding IndexPath

In SwiftDataTables, `IndexPath` components map to:

| Component | Meaning |
|-----------|---------|
| `section` | Row index (0-based) |
| `item` | Column index (0-based) |

```swift
func didSelectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath) {
    let row = indexPath.section
    let column = indexPath.item

    // Access your data model
    let selectedItem = items[row]

    // Or access the cell value
    let cellValue = dataTable.data(for: indexPath)
}
```

## Accessing Selected Data

### Get the Cell Value

```swift
func didSelectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath) {
    let value = dataTable.data(for: indexPath)

    switch value {
    case .string(let text):
        print("Selected text: \(text)")
    case .int(let number):
        print("Selected number: \(number)")
    case .float(let f):
        print("Selected float: \(f)")
    case .double(let d):
        print("Selected double: \(d)")
    }
}
```

### Get the Full Row

Access your model directly using the row index:

```swift
struct Employee: Identifiable {
    let id: Int
    let name: String
    let department: String
}

class EmployeeListVC: UIViewController, SwiftDataTableDelegate {
    var employees: [Employee] = []

    func didSelectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath) {
        let employee = employees[indexPath.section]
        showEmployeeDetail(employee)
    }
}
```

## Common Patterns

### Navigate to Detail View

```swift
func didSelectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath) {
    let item = items[indexPath.section]
    let detailVC = DetailViewController(item: item)
    navigationController?.pushViewController(detailVC, animated: true)
}
```

### Show Action Sheet

```swift
func didSelectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath) {
    let item = items[indexPath.section]

    let alert = UIAlertController(
        title: item.name,
        message: "Choose an action",
        preferredStyle: .actionSheet
    )

    alert.addAction(UIAlertAction(title: "Edit", style: .default) { _ in
        self.edit(item)
    })

    alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
        self.delete(item)
    })

    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

    present(alert, animated: true)
}
```

### Toggle Selection State

```swift
class SelectableListVC: UIViewController, SwiftDataTableDelegate {
    var selectedIndices: Set<Int> = []

    func didSelectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath) {
        let row = indexPath.section

        if selectedIndices.contains(row) {
            selectedIndices.remove(row)
        } else {
            selectedIndices.insert(row)
        }

        updateSelectionUI()
    }
}
```

## Row Highlighting

By default, cells highlight on tap. The highlight colors cycle through the configured alternating colors.

### Customize Highlight Colors

```swift
var config = DataTableConfiguration()

// Highlighted column colors (when sorted)
config.highlightedAlternatingRowColors = [
    UIColor.systemBlue.withAlphaComponent(0.1),
    UIColor.systemBlue.withAlphaComponent(0.15)
]

// Unhighlighted column colors
config.unhighlightedAlternatingRowColors = [
    .systemBackground,
    .secondarySystemBackground
]
```

## See Also

- ``SwiftDataTableDelegate``
- ``SwiftDataTable/delegate``
- <doc:Styling>
