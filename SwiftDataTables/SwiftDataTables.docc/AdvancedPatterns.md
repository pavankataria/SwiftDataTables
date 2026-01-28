# Advanced Patterns

Combine SwiftDataTables features for complex real-world scenarios.

## Overview

This guide demonstrates advanced patterns that combine multiple features. These examples show how to build sophisticated data table interfaces.

## Dashboard with Fixed ID Column

Combine fixed columns, sorting, search, and custom widths:

```swift
struct MetricData: Identifiable {
    let id: String
    let name: String
    let value: Double
    let change: Double
    let status: String
    let lastUpdated: Date
}

class DashboardVC: UIViewController, SwiftDataTableDelegate {
    var metrics: [MetricData] = []
    var dataTable: SwiftDataTable!

    let columns: [DataTableColumn<MetricData>] = [
        .init("ID", \.id),
        .init("Metric", \.name),
        .init("Value") { String(format: "%.2f", $0.value) },
        .init("Change") { "\($0.change >= 0 ? "+" : "")\(String(format: "%.1f", $0.change))%" },
        .init("Status", \.status),
        .init("Updated") { $0.lastUpdated.formatted(date: .abbreviated, time: .shortened) }
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        var config = DataTableConfiguration()

        // Fix ID column on left
        config.fixedColumns = DataTableFixedColumnType(leftColumns: 1)

        // Custom widths per column
        config.columnWidthModeProvider = { index in
            switch index {
            case 0: return .fixed(width: 80)   // ID
            case 1: return nil                  // Metric (auto)
            case 2: return .fixed(width: 100)  // Value
            case 3: return .fixed(width: 90)   // Change
            case 4: return .fixed(width: 100)  // Status
            case 5: return nil                  // Updated (auto)
            default: return nil
            }
        }

        // Sort by change descending initially
        config.defaultOrdering = DataTableColumnOrder(index: 3, order: .descending)

        // Floating search
        config.shouldSearchHeaderFloat = true

        // Custom colors for positive/negative
        config.highlightedAlternatingRowColors = [
            UIColor.systemGreen.withAlphaComponent(0.1),
            UIColor.systemGreen.withAlphaComponent(0.15)
        ]

        dataTable = SwiftDataTable(data: metrics, options: config)
        dataTable.delegate = self
        setupLayout()
    }

    func didSelectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath) {
        let metric = metrics[indexPath.section]
        showDetail(for: metric)
    }
}
```

## Real-Time Updates with Polling

Update data periodically while preserving scroll position:

```swift
class LiveDataVC: UIViewController {
    var dataTable: SwiftDataTable!
    var items: [LiveItem] = []
    var updateTimer: Timer?

    let columns: [DataTableColumn<LiveItem>] = [
        .init("Symbol", \.symbol),
        .init("Price") { .double($0.price) },
        .init("Volume") { .int($0.volume) }
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        var config = DataTableConfiguration()
        config.shouldSearchHeaderFloat = true
        config.rowHeightMode = .fixed(36)  // Compact rows

        dataTable = SwiftDataTable(data: items, options: config)
        setupLayout()

        // Start polling
        updateTimer = Timer.scheduledTimer(
            withTimeInterval: 1.0,
            repeats: true
        ) { [weak self] _ in
            self?.refreshData()
        }
    }

    func refreshData() {
        Task {
            let newItems = await fetchLatestData()

            await MainActor.run {
                items = newItems
                // Animated update preserves scroll position
                dataTable.setData(items, animatingDifferences: true)
            }
        }
    }

    deinit {
        updateTimer?.invalidate()
    }
}
```

## Editable Table with Inline Updates

Handle cell editing and refresh individual rows:

```swift
class EditableTableVC: UIViewController, SwiftDataTableDelegate {
    var dataTable: SwiftDataTable!
    var records: [EditableRecord] = []
    var editingIndexPath: IndexPath?

    func didSelectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath) {
        let record = records[indexPath.section]
        let column = indexPath.item

        // Only edit certain columns
        guard column == 1 || column == 2 else { return }

        showEditor(for: record, column: column) { [weak self] updatedValue in
            guard let self = self else { return }

            // Update the model
            switch column {
            case 1: self.records[indexPath.section].name = updatedValue
            case 2: self.records[indexPath.section].value = updatedValue
            default: break
            }

            // Refresh just that row
            self.dataTable.reloadRow(at: indexPath.section)
        }
    }

    func showEditor(for record: EditableRecord, column: Int, completion: @escaping (String) -> Void) {
        let alert = UIAlertController(title: "Edit", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = column == 1 ? record.name : record.value
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            if let text = alert.textFields?.first?.text {
                completion(text)
            }
        })
        present(alert, animated: true)
    }
}
```

## Master-Detail with Navigation

Navigate to detail views on row selection:

```swift
class MasterVC: UIViewController, SwiftDataTableDelegate {
    var dataTable: SwiftDataTable!
    var items: [Item] = []

    let columns: [DataTableColumn<Item>] = [
        .init("Name", \.name),
        .init("Category", \.category),
        .init("Price") { "$\(String(format: "%.2f", $0.price))" }
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        var config = DataTableConfiguration()
        config.shouldShowFooter = false

        dataTable = SwiftDataTable(data: items, options: config)
        dataTable.delegate = self
        setupLayout()
    }

    func didSelectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath) {
        let item = items[indexPath.section]
        let detailVC = DetailVC(item: item)
        detailVC.onUpdate = { [weak self] updatedItem in
            self?.items[indexPath.section] = updatedItem
            self?.dataTable.reloadRow(at: indexPath.section)
        }
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
```

## Filtered Views with Segmented Control

Switch between data subsets:

```swift
class FilteredTableVC: UIViewController {
    var dataTable: SwiftDataTable!
    var allItems: [Task] = []

    let columns: [DataTableColumn<Task>] = [
        .init("Title", \.title),
        .init("Status", \.status),
        .init("Due") { $0.dueDate.formatted(date: .abbreviated, time: .omitted) }
    ]

    enum Filter: Int {
        case all, active, completed
    }

    var currentFilter: Filter = .all {
        didSet { applyFilter() }
    }

    lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["All", "Active", "Completed"])
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
        return control
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = segmentedControl

        dataTable = SwiftDataTable(data: allItems)
        setupLayout()
    }

    @objc func filterChanged() {
        currentFilter = Filter(rawValue: segmentedControl.selectedSegmentIndex) ?? .all
    }

    func applyFilter() {
        let filtered: [Task]
        switch currentFilter {
        case .all:
            filtered = allItems
        case .active:
            filtered = allItems.filter { !$0.isCompleted }
        case .completed:
            filtered = allItems.filter { $0.isCompleted }
        }

        dataTable.setData(filtered, animatingDifferences: true)
    }
}
```

## Large Dataset with Background Loading

Load massive datasets without blocking UI:

```swift
class LargeDatasetVC: UIViewController {
    var dataTable: SwiftDataTable!
    var items: [DataPoint] = []

    let columns: [DataTableColumn<DataPoint>] = [
        .init("ID") { .int($0.id) },
        .init("Value") { .double($0.value) },
        .init("Category", \.category)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        var config = DataTableConfiguration()

        // Optimized for large datasets
        config.rowHeightMode = .automatic(estimated: 44, prefetchWindow: 20)
        config.columnWidthMode = .fitContentText(
            strategy: .hybrid(sampleSize: 500, averageCharWidth: 7)
        )
        config.lockColumnWidthsAfterFirstLayout = true

        dataTable = SwiftDataTable(data: [], options: config)
        setupLayout()

        // Show loading state
        showLoadingIndicator()

        // Load in background
        Task.detached(priority: .userInitiated) {
            let loaded = await self.loadLargeDataset()
            await MainActor.run {
                self.hideLoadingIndicator()
                self.items = loaded
                self.dataTable.setData(loaded, animatingDifferences: false)
            }
        }
    }

    func loadLargeDataset() async -> [DataPoint] {
        // Simulate loading 100K rows
        return (0..<100_000).map { i in
            DataPoint(
                id: i,
                value: Double.random(in: 0...1000),
                category: ["A", "B", "C"].randomElement()!
            )
        }
    }
}
```

## Custom Actions Column

Add action buttons to rows:

```swift
struct Employee: Identifiable {
    let id: Int
    let name: String
    let role: String
}

class EmployeeListVC: UIViewController, SwiftDataTableDelegate {
    var dataTable: SwiftDataTable!
    var employees: [Employee] = []

    let columns: [DataTableColumn<Employee>] = [
        .init("Name", \.name),
        .init("Role", \.role),
        .init("Actions") { _ in "Edit | Delete" }  // Placeholder
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        var config = DataTableConfiguration()

        // Actions column not sortable
        config.isColumnSortable = { $0 != 2 }

        // Fixed width for actions
        config.columnWidthModeProvider = { index in
            index == 2 ? .fixed(width: 120) : nil
        }

        dataTable = SwiftDataTable(data: employees, options: config)
        dataTable.delegate = self
        setupLayout()
    }

    func didSelectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath) {
        let employee = employees[indexPath.section]

        // Check if actions column tapped
        if indexPath.item == 2 {
            showActionsSheet(for: employee, at: indexPath.section)
        } else {
            showDetail(for: employee)
        }
    }

    func showActionsSheet(for employee: Employee, at index: Int) {
        let alert = UIAlertController(title: employee.name, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Edit", style: .default) { [weak self] _ in
            self?.editEmployee(at: index)
        })

        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteEmployee(at: index)
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }

    func deleteEmployee(at index: Int) {
        employees.remove(at: index)
        dataTable.setData(employees, animatingDifferences: true)
    }
}
```

## Accessibility Considerations

Ensure your table is accessible:

```swift
class AccessibleTableVC: UIViewController {
    var dataTable: SwiftDataTable!

    override func viewDidLoad() {
        super.viewDidLoad()

        var config = DataTableConfiguration()

        // Larger tap targets for accessibility
        config.rowHeightMode = .fixed(56)
        config.heightForSectionHeader = 56
        config.heightForSectionFooter = 56

        // High contrast colors
        config.unhighlightedAlternatingRowColors = [
            .systemBackground,
            UIColor.label.withAlphaComponent(0.05)
        ]

        dataTable = SwiftDataTable(columns: columns, options: config)

        // VoiceOver support
        dataTable.isAccessibilityElement = false
        dataTable.accessibilityLabel = "Data table with \(myData.count) rows"

        setupLayout()
    }
}
```

## See Also

- <doc:TypeSafeColumns>
- <doc:AnimatedUpdates>
- <doc:LargeDatasets>
- <doc:RowSelection>
- <doc:ConfigurationReference>
