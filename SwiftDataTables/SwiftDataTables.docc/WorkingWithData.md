# Working with Data

Learn how to provide data to your table.

## Overview

SwiftDataTables supports two approaches for providing data:

1. **Type-safe API** - Define columns using KeyPaths on your model types. Requires `Identifiable` conformance, enabling animated updates when data changes.

2. **Array-based API** - Pass a 2D array of strings for simple static displays. No model required.

Choose the type-safe API when you have model types and want diffing/animations. Choose the array-based API for quick prototyping or truly static data.

## Static Displays

For simple tables where data doesn't change, use the array-based initializer:

```swift
let data: [[String]] = [
    ["Alice", "Engineering", "Senior"],
    ["Bob", "Marketing", "Manager"],
    ["Carol", "Sales", "Associate"]
]

let headers = ["Name", "Department", "Role"]

let dataTable = SwiftDataTable(data: data, headerTitles: headers)
```

This approach:
- Requires no model types
- Displays data exactly as provided
- Supports sorting and searching
- Does not support animated updates (full reload on changes)

When you need animated updates or want to work with your own model types, use the type-safe API instead.

## Type-Safe API with Models

The type-safe API works directly with your model types. Define columns using KeyPaths, pass your array of models, and the table handles animated updates when data changes.

The key requirement: models must conform to `Identifiable` so SwiftDataTables can track individual rows.

### Making Models Identifiable

If your model already has a unique identifier, conformance is straightforward:

```swift
struct Person: Identifiable {
    let id: Int        // Already have a unique ID? You're done.
    let name: String
    let email: String
    let department: String
}
```

For models without a natural ID, add one:

```swift
struct Product: Identifiable {
    let id = UUID()    // Generate a unique ID
    let name: String
    let price: Double
    let category: String
}
```

> Important: The `id` property enables diffing. Without it, SwiftDataTables can't determine which rows changed, so use the array-based API instead.

### Defining Columns

Use KeyPaths to map model properties to columns:

```swift
let columns: [DataTableColumn<Person>] = [
    .init("Name", \.name),
    .init("Email", \.email),
    .init("Department", \.department)
]

let dataTable = SwiftDataTable(columns: columns)
```

The compiler verifies your KeyPaths at build time - typos are caught immediately.

### Loading and Updating Data

Pass your model array to `setData()`:

```swift
// Initial load
let people = await fetchPeople()
dataTable.setData(people, animatingDifferences: true)

// Later, when data changes
let updatedPeople = await fetchPeople()
dataTable.setData(updatedPeople, animatingDifferences: true)  // Only changed rows animate
```

SwiftDataTables compares the old and new arrays by ID, then:
- Animates insertions and deletions
- Updates changed rows in place
- Leaves unchanged rows alone
- Preserves scroll position

### Data Transformations

#### Formatting Values

Use closures for formatted display:

```swift
let columns: [DataTableColumn<Product>] = [
    .init("Product", \.name),
    .init("Price") { String(format: "£%.2f", $0.price) },
    .init("In Stock") { $0.inStock ? "Yes" : "No" }
]
```

#### Computed Properties

Calculate values on the fly:

```swift
struct Order: Identifiable {
    let id: Int
    let quantity: Int
    let unitPrice: Double
}

let columns: [DataTableColumn<Order>] = [
    .init("Qty") { $0.quantity },
    .init("Unit Price") { "£\($0.unitPrice)" },
    .init("Total") { "£\(Double($0.quantity) * $0.unitPrice)" }
]
```

#### Date Formatting

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

## Data Without Predefined Models

When the schema isn't known at compile time - CSV files, JSON responses, or database queries - create a simple wrapper struct that conforms to `Identifiable`:

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
            row.values[index]
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

    func value(for key: String) -> String {
        switch data[key] {
        case let string as String: return string
        case let int as Int: return "\(int)"
        case let double as Double: return "\(double)"
        default: return ""
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
    let columns: [String: String]
}

func executeQuery(_ sql: String, columnNames: [String]) async {
    let results = await database.query(sql)

    let columns: [DataTableColumn<QueryRow>] = columnNames.map { name in
        .init(name) { row in
            row.columns[name] ?? ""
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

### Why Use a Wrapper?

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
