# Advanced Patterns

Real-world recipes showing how to build common data table interfaces.

## Overview

This guide provides copy-paste recipes for common data table scenarios. Each pattern explains the use case, shows the expected result, and provides working code.

## Stock Ticker (Live Updates)

**Use case:** Display data that updates frequently from a server - stock prices, sensor readings, live scores, or any real-time feed.

**What you get:** Data refreshes every second. Changed values animate smoothly. Your scroll position stays put even as data updates around you.

```swift
class StockTickerVC: UIViewController {
    var dataTable: SwiftDataTable!
    var stocks: [Stock] = []
    var timer: Timer?

    let columns: [DataTableColumn<Stock>] = [
        .init("Symbol", \.symbol),
        .init("Price") { String(format: "$%.2f", $0.price) },
        .init("Change") { "\($0.change >= 0 ? "+" : "")\(String(format: "%.2f", $0.change))%" }
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        dataTable = SwiftDataTable(data: stocks, columns: columns)
        // ... layout setup ...

        // Poll every second
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.refresh()
        }
    }

    func refresh() {
        Task {
            let latest = await fetchStockPrices()
            await MainActor.run {
                stocks = latest
                dataTable.setData(stocks, animatingDifferences: true)
            }
        }
    }

    deinit { timer?.invalidate() }
}
```

> Tip: The `animatingDifferences: true` parameter is key - it calculates what changed and animates only those rows, preserving scroll position.

## Task List with Filters

**Use case:** Let users switch between subsets of data - like iOS Reminders with "All", "Active", and "Completed" tabs.

**What you get:** Tap a segment, rows animate in/out as the filter changes. No jarring full-table reload.

```swift
class TaskListVC: UIViewController {
    var dataTable: SwiftDataTable!
    var allTasks: [Task] = []

    let columns: [DataTableColumn<Task>] = [
        .init("Title", \.title),
        .init("Status") { $0.isCompleted ? "Done" : "Pending" },
        .init("Due") { $0.dueDate.formatted(date: .abbreviated, time: .omitted) }
    ]

    lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["All", "Active", "Completed"])
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
        return control
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = segmentedControl
        dataTable = SwiftDataTable(data: allTasks, columns: columns)
        // ... layout setup ...
    }

    @objc func filterChanged() {
        let filtered: [Task]
        switch segmentedControl.selectedSegmentIndex {
        case 1: filtered = allTasks.filter { !$0.isCompleted }
        case 2: filtered = allTasks.filter { $0.isCompleted }
        default: filtered = allTasks
        }
        dataTable.setData(filtered, animatingDifferences: true)
    }
}
```

## Spreadsheet with Fixed First Column

**Use case:** Wide tables where you need the identifier column (ID, name, etc.) to stay visible while scrolling horizontally through other columns.

**What you get:** The first column stays pinned on the left. Scroll right to see more columns while always knowing which row you're looking at.

```swift
let columns: [DataTableColumn<Report>] = [
    .init("ID", \.id),        // This column will be fixed
    .init("Name", \.name),
    .init("Q1") { String(format: "$%.0f", $0.q1) },
    .init("Q2") { String(format: "$%.0f", $0.q2) },
    .init("Q3") { String(format: "$%.0f", $0.q3) },
    .init("Q4") { String(format: "$%.0f", $0.q4) },
    .init("Total") { String(format: "$%.0f", $0.total) }
]

var config = DataTableConfiguration()
config.fixedColumns = DataTableFixedColumnType(leftColumns: 1)

let dataTable = SwiftDataTable(data: reports, columns: columns, options: config)
```

> Note: You can also fix columns on the right with `DataTableFixedColumnType(rightColumns: 1)` or both sides.

## Master-Detail Navigation

**Use case:** Tap a row to navigate to a detail screen, edit the item, then return with updates reflected.

**What you get:** Standard iOS navigation pattern. Changes made in the detail screen animate back into the table when you return.

```swift
class ProductListVC: UIViewController, SwiftDataTableDelegate {
    var dataTable: SwiftDataTable!
    var products: [Product] = []

    let columns: [DataTableColumn<Product>] = [
        .init("Name", \.name),
        .init("Price") { String(format: "$%.2f", $0.price) },
        .init("Stock") { "\($0.quantity) units" }
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        dataTable = SwiftDataTable(data: products, columns: columns)
        dataTable.delegate = self
        // ... layout setup ...
    }

    func didSelectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath) {
        let product = products[indexPath.section]
        let detailVC = ProductDetailVC(product: product)

        detailVC.onSave = { [weak self] updated in
            guard let self else { return }
            self.products[indexPath.section] = updated
            self.dataTable.setData(self.products, animatingDifferences: true)
        }

        navigationController?.pushViewController(detailVC, animated: true)
    }
}
```

## Inline Editing

**Use case:** Let users edit cell values directly by tapping them - spreadsheet-style editing without navigating away.

**What you get:** Tap a cell, an alert appears with a text field, save updates just that row.

```swift
class EditableTableVC: UIViewController, SwiftDataTableDelegate {
    var dataTable: SwiftDataTable!
    var items: [EditableItem] = []

    let columns: [DataTableColumn<EditableItem>] = [
        .init("ID", \.id),           // Column 0 - not editable
        .init("Name", \.name),       // Column 1 - editable
        .init("Value", \.value)      // Column 2 - editable
    ]

    func didSelectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath) {
        let column = indexPath.item
        guard column == 1 || column == 2 else { return }  // Only edit columns 1 and 2

        let item = items[indexPath.section]
        let currentValue = column == 1 ? item.name : item.value

        let alert = UIAlertController(title: "Edit", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.text = currentValue }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self, let newValue = alert.textFields?.first?.text else { return }

            if column == 1 {
                self.items[indexPath.section].name = newValue
            } else {
                self.items[indexPath.section].value = newValue
            }
            self.dataTable.reloadRow(at: indexPath.section)
        })
        present(alert, animated: true)
    }
}
```

> Tip: Use `reloadRow(at:)` for single-row updates instead of `setData()` - it's more efficient when you know exactly which row changed.

## Row Actions via Tap Detection

**Use case:** Add edit/delete actions to each row without using swipe gestures.

**What you get:** An "Actions" column that, when tapped, shows an action sheet with Edit and Delete options.

> Note: SwiftDataTables doesn't support actual buttons in cells. This pattern uses text that looks like actions ("Edit | Delete") and detects which column was tapped to trigger the appropriate behavior.

```swift
class EmployeeListVC: UIViewController, SwiftDataTableDelegate {
    var dataTable: SwiftDataTable!
    var employees: [Employee] = []

    let columns: [DataTableColumn<Employee>] = [
        .init("Name", \.name),
        .init("Role", \.role),
        .init("Actions") { _ in "Edit | Delete" }  // Text that looks like links
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        var config = DataTableConfiguration()
        config.isColumnSortable = { $0 != 2 }  // Actions column not sortable
        config.columnWidthModeProvider = { $0 == 2 ? .fixed(width: 100) : nil }

        dataTable = SwiftDataTable(data: employees, columns: columns, options: config)
        dataTable.delegate = self
        // ... layout setup ...
    }

    func didSelectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath) {
        guard indexPath.item == 2 else { return }  // Only respond to actions column

        let employee = employees[indexPath.section]
        let alert = UIAlertController(title: employee.name, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Edit", style: .default) { [weak self] _ in
            self?.editEmployee(at: indexPath.section)
        })
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.employees.remove(at: indexPath.section)
            self?.dataTable.setData(self!.employees, animatingDifferences: true)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }
}
```

## Large Dataset Loading

**Use case:** Load 10,000+ rows from a database or API without freezing the UI.

**What you get:** A loading indicator while data loads in the background, then the table appears fully populated.

```swift
class LargeDatasetVC: UIViewController {
    var dataTable: SwiftDataTable!
    var records: [Record] = []

    let columns: [DataTableColumn<Record>] = [
        .init("ID") { .int($0.id) },
        .init("Name", \.name),
        .init("Value") { .double($0.value) }
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        var config = DataTableConfiguration()
        // Optimizations for large datasets
        config.rowHeightMode = .automatic(estimated: 44, prefetchWindow: 20)
        config.columnWidthMode = .fitContentText(strategy: .hybrid(sampleSize: 500, averageCharWidth: 7))
        config.lockColumnWidthsAfterFirstLayout = true

        dataTable = SwiftDataTable(data: [], columns: columns, options: config)
        // ... layout setup ...

        // Show loading state
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.startAnimating()
        view.addSubview(spinner)
        spinner.center = view.center

        // Load in background
        Task.detached(priority: .userInitiated) {
            let loaded = await self.fetchLargeDataset()  // Your data loading
            await MainActor.run {
                spinner.removeFromSuperview()
                self.records = loaded
                self.dataTable.setData(loaded, animatingDifferences: false)  // No animation for initial load
            }
        }
    }
}
```

> Tip: Use `animatingDifferences: false` for initial large data loads - animation overhead isn't needed when the table is empty.

## See Also

- <doc:TypeSafeColumns>
- <doc:AnimatedUpdates>
- <doc:LargeDatasets>
- <doc:RowSelection>
- <doc:ConfigurationReference>
