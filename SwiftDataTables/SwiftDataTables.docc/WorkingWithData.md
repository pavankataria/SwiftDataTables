# Working with Data

Learn the different ways to provide data to your table.

## Overview

SwiftDataTables supports multiple data formats, from simple string arrays to type-safe model objects. Choose the approach that best fits your needs.

## Data Formats

### String Arrays (Simplest)

For quick prototypes or simple data:

```swift
let data = [
    ["Alice", "28", "London"],
    ["Bob", "34", "Paris"],
    ["Carol", "25", "Berlin"]
]

let dataTable = SwiftDataTable(
    data: data,
    headerTitles: ["Name", "Age", "City"]
)
```

### DataTableValueType Arrays (Typed Values)

For explicit control over sorting behavior:

```swift
let data: [[DataTableValueType]] = [
    [.string("Alice"), .int(28), .string("London")],
    [.string("Bob"), .int(34), .string("Paris")],
    [.string("Carol"), .int(25), .string("Berlin")]
]

let dataTable = SwiftDataTable(
    data: data,
    headerTitles: ["Name", "Age", "City"]
)
```

Using `.int()` instead of `.string("28")` ensures numeric sorting (2, 10, 25) instead of alphabetic ("10", "2", "25").

### Model Objects (Recommended)

For production apps, use your own model types:

```swift
struct Person: Identifiable {
    let id: Int
    let name: String
    let age: Int
    let city: String
}

let people = [
    Person(id: 1, name: "Alice", age: 28, city: "London"),
    Person(id: 2, name: "Bob", age: 34, city: "Paris"),
    Person(id: 3, name: "Carol", age: 25, city: "Berlin")
]

let columns: [DataTableColumn<Person>] = [
    .init("Name", \.name),
    .init("Age", \.age),
    .init("City", \.city)
]

let dataTable = SwiftDataTable(data: people, columns: columns)
```

## Accessing Data

### Get All Data

```swift
// For typed tables
let allPeople: [Person] = dataTable.allModels()

// For array-based tables
let rowCount = dataTable.currentRowCount
```

### Get Specific Row

```swift
// For typed tables
if let person: Person = dataTable.model(at: 5) {
    print("Row 5 is \(person.name)")
}

// For array-based tables
let rowData = dataTable.data(for: 5)  // Returns [DataTableValueType]
```

### Get Filtered Data

After search/filter, access visible rows:

```swift
let visibleCount = dataTable.currentRowCount  // After filtering
```

## Data Transformations

### Formatting Values

Use closures in column definitions:

```swift
let columns: [DataTableColumn<Product>] = [
    .init("Product", \.name),
    .init("Price") { .string("$\(String(format: "%.2f", $0.price))") },
    .init("In Stock") { .string($0.inStock ? "Yes" : "No") }
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
    .init("Qty") { .int($0.quantity) },
    .init("Unit Price") { .string("$\($0.unitPrice)") },
    .init("Total") { .string("$\(Double($0.quantity) * $0.unitPrice)") }
]
```

### Date Formatting

```swift
struct Event: Identifiable {
    let id: Int
    let name: String
    let date: Date
}

let dateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateStyle = .medium
    return f
}()

let columns: [DataTableColumn<Event>] = [
    .init("Event", \.name),
    .init("Date") { .string(dateFormatter.string(from: $0.date)) }
]
```

## Empty States

Handle empty data gracefully:

```swift
var items: [Item] = []

// Table displays with headers but no rows
dataTable.setData(items, columns: columns)

// Later, populate
items = fetchItems()
dataTable.setData(items, columns: columns, animatingDifferences: true)
```

## Data Validation

Validate before displaying:

```swift
func setTableData(_ rawItems: [RawItem]) {
    // Filter invalid entries
    let validItems = rawItems.filter { $0.isValid }

    // Transform to display model
    let displayItems = validItems.map { DisplayItem(from: $0) }

    dataTable.setData(displayItems, columns: columns, animatingDifferences: true)
}
```

## See Also

- <doc:TypeSafeColumns>
- <doc:AnimatedUpdates>
- ``DataTableValueType``
