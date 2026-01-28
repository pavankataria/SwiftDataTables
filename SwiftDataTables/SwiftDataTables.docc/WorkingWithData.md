# Working with Data

Learn how to provide data to your table using the type-safe API.

## Overview

SwiftDataTables uses a type-safe API with `DataTableColumn<T>` to define your table structure. This approach provides automatic diffing, animated updates, and compile-time safety.

## Basic Usage

Define columns using KeyPaths, then pass your model array:

```swift
struct Person: Identifiable {
    let id: Int
    let name: String
    let age: Int
    let city: String
}

let columns: [DataTableColumn<Person>] = [
    .init("Name", \.name),
    .init("Age", \.age),
    .init("City", \.city)
]

let dataTable = SwiftDataTable(columns: columns)

// Load data later
dataTable.setData(people, animatingDifferences: true)
```

## Dynamic Data Sources

For data without a predefined model (CSV files, JSON responses, database queries), create a wrapper struct:

### CSV Import

```swift
/// Wrapper for CSV row data
struct CSVRow: Identifiable {
    let id: Int          // Row index as ID
    let values: [String] // Column values
}

func loadCSV(from url: URL) {
    let csvData = parseCSV(url)  // Your CSV parser
    let headers = csvData.headers

    // Create columns dynamically
    let columns: [DataTableColumn<CSVRow>] = headers.enumerated().map { index, header in
        .init(header) { row in
            .string(row.values[index])
        }
    }

    // Create rows with index as ID
    let rows = csvData.rows.enumerated().map { index, values in
        CSVRow(id: index, values: values)
    }

    dataTable = SwiftDataTable(columns: columns)
    dataTable.setData(rows, animatingDifferences: false)
}
```

### JSON Response

```swift
/// Wrapper for dynamic JSON objects
struct JSONRow: Identifiable {
    let id: String
    let data: [String: Any]

    func value(for key: String) -> DataTableValueType {
        switch data[key] {
        case let string as String: return .string(string)
        case let int as Int: return .int(int)
        case let double as Double: return .double(double)
        default: return .string("")
        }
    }
}

func loadJSON(_ json: [[String: Any]], keys: [String]) {
    let columns: [DataTableColumn<JSONRow>] = keys.map { key in
        .init(key.capitalized) { row in
            row.value(for: key)
        }
    }

    let rows = json.enumerated().map { index, dict in
        let id = (dict["id"] as? String) ?? "\(index)"
        return JSONRow(id: id, data: dict)
    }

    dataTable = SwiftDataTable(columns: columns)
    dataTable.setData(rows, animatingDifferences: false)
}
```

### Database Query

```swift
/// Wrapper for database result rows
struct QueryRow: Identifiable {
    let id: Int64         // Primary key or row number
    let columns: [String: DataTableValueType]
}

func executeQuery(_ sql: String, columnNames: [String]) async {
    let results = await database.query(sql)

    let columns: [DataTableColumn<QueryRow>] = columnNames.map { name in
        .init(name) { row in
            row.columns[name] ?? .string("")
        }
    }

    let rows = results.enumerated().map { index, record in
        QueryRow(
            id: record.primaryKey ?? Int64(index),
            columns: record.toDictionary()
        )
    }

    dataTable = SwiftDataTable(columns: columns)
    dataTable.setData(rows, animatingDifferences: false)
}
```

## Why Use a Wrapper?

The typed API requires `Identifiable` conformance for diffing. Wrapping dynamic data provides:

| Benefit | Description |
|---------|-------------|
| **Diffing** | Rows can be tracked by ID for animated updates |
| **Type Safety** | Compiler ensures column extractors match the row type |
| **Performance** | Only changed rows update, not the entire table |
| **Consistency** | Same API whether data is static or dynamic |

## Accessing Data

### Get All Models

```swift
if let allPeople: [Person] = dataTable.allModels() {
    print("Total: \(allPeople.count)")
}
```

### Get Specific Row

```swift
if let person: Person = dataTable.model(at: 5) {
    print("Row 5: \(person.name)")
}
```

## Data Transformations

### Formatting Values

Use closures for formatted display:

```swift
let columns: [DataTableColumn<Product>] = [
    .init("Product", \.name),
    .init("Price") { "$\(String(format: "%.2f", $0.price))" },
    .init("In Stock") { $0.inStock ? "Yes" : "No" }
]
```

### Computed Properties

Calculate values on the fly:

```swift
struct Order: Identifiable {
    let id: Int
    let quantity: Int
    let unitPrice: Double
}

let columns: [DataTableColumn<Order>] = [
    .init("Qty") { $0.quantity },
    .init("Unit Price") { "$\($0.unitPrice)" },
    .init("Total") { "$\(Double($0.quantity) * $0.unitPrice)" }
]
```

### Date Formatting

```swift
let dateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateStyle = .medium
    return f
}()

let columns: [DataTableColumn<Event>] = [
    .init("Event", \.name),
    .init("Date") { dateFormatter.string(from: $0.date) }
]
```

## Empty States

Handle empty data gracefully:

```swift
// Create table with columns (no data yet)
let dataTable = SwiftDataTable(columns: columns)

// Later, populate with animation
let items = await fetchItems()
dataTable.setData(items, animatingDifferences: true)
```

## Data Validation

Validate before displaying:

```swift
func setTableData(_ rawItems: [RawItem]) {
    // Filter invalid entries
    let validItems = rawItems.filter { $0.isValid }

    // Transform to display model
    let displayItems = validItems.map { DisplayItem(from: $0) }

    dataTable.setData(displayItems, animatingDifferences: true)
}
```

## See Also

- <doc:TypeSafeColumns>
- <doc:AnimatedUpdates>
- ``DataTableColumn``
