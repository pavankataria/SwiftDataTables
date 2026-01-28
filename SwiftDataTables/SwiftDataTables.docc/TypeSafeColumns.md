# Type-Safe Columns

Define columns using Swift's type system for compile-time safety and cleaner code.

## Overview

The typed API uses `DataTableColumn<T>` to define how your model properties map to table columns. This approach provides:

- **Compile-time safety** - Catch typos and type mismatches at build time
- **Clean syntax** - Use key paths instead of manual array conversion
- **Automatic diffing** - Enable smooth animated updates via `Identifiable`

## Defining Columns

### Basic Key Path Columns

For simple properties, use key paths directly:

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
```

### Custom Value Extraction

For computed or formatted values, provide a closure that returns any `DataTableValueConvertible` type:

```swift
let columns: [DataTableColumn<Person>] = [
    .init("Name", \.name),
    .init("Age") { $0.age },                          // Returns Int directly
    .init("Location") { "\($0.city), \($0.country)" } // Returns String directly
]
```

### Formatting Numbers

Format currencies, percentages, and other numbers:

```swift
struct Product: Identifiable {
    let id: String
    let name: String
    let price: Double
    let discount: Double
}

let columns: [DataTableColumn<Product>] = [
    .init("Product", \.name),
    .init("Price") { "$\(String(format: "%.2f", $0.price))" },
    .init("Discount") { "\(Int($0.discount * 100))%" },
    .init("Final") {
        let final = $0.price * (1 - $0.discount)
        return "$\(String(format: "%.2f", final))"
    }
]
```

## Creating the Table

Pass your data and columns to the initializer:

```swift
let people = [
    Person(id: 1, name: "Alice", age: 28, city: "London"),
    Person(id: 2, name: "Bob", age: 34, city: "Paris"),
    Person(id: 3, name: "Carol", age: 25, city: "Berlin")
]

let dataTable = SwiftDataTable(data: people)
```

## The Identifiable Requirement

For animated updates, your model must conform to `Identifiable`:

```swift
struct Employee: Identifiable {
    let id: Int  // Required for Identifiable
    let name: String
    let role: String
}
```

The `id` property enables SwiftDataTables to:
- Track which rows were added, removed, or moved
- Animate changes smoothly
- Preserve selection state during updates

### Custom ID Types

Any `Hashable` type works as an ID:

```swift
struct Document: Identifiable {
    let id: UUID  // UUID works
    let title: String
}

struct User: Identifiable {
    let id: String  // String works
    let email: String
}
```

## Updating Data

Use `setData(_:animatingDifferences:)` to update:

```swift
// Create table with columns (data optional)
let dataTable = SwiftDataTable(columns: columns)

// Later, load data with animation
let employees = await api.fetchEmployees()
dataTable.setData(employees, animatingDifferences: true)
```

Columns are stored at init time, so you only pass data when updating.

### What Gets Animated

When `animatingDifferences` is `true`:
- **Insertions** - New rows slide in
- **Deletions** - Removed rows slide out
- **Moves** - Reordered rows animate to new positions
- **Updates** - Changed cells update in place

### Preserving Scroll Position

Unlike `reload()`, animated updates preserve:
- Current scroll offset
- User's visual context
- Selection state

## DataTableValueType

Under the hood, each cell value is a ``DataTableValueType``:

```swift
public enum DataTableValueType {
    case string(String)
    case int(Int)
    case float(Float)
    case double(Double)
}
```

The type affects **sorting behavior**:
- `.string` values sort alphabetically
- Numeric types sort numerically

### Explicit Type Control

For computed values where you need specific sorting behavior, you can explicitly specify the type:

```swift
// Computed numeric with numeric sorting: 2 < 9 < 10
.init("Total Score") { .int($0.points + $0.bonus) }

// Formatted string with alphabetical sorting: "10" < "2" < "9"
.init("ID") { String($0.id) }
```

> Note: For simple properties, use keypaths instead - they preserve the correct type automatically.

## Best Practices

### 1. Define Columns Once

Store columns as a constant to reuse:

```swift
class EmployeeListVC: UIViewController {
    let columns: [DataTableColumn<Employee>] = [
        .init("Name", \.name),
        .init("Role", \.role)
    ]

    func updateData(_ employees: [Employee]) {
        dataTable.setData(employees, animatingDifferences: true)
    }
}
```

### 2. Use Meaningful Headers

Column headers should be concise but descriptive:

```swift
// Good
.init("Emp. ID", \.employeeId)
.init("Hire Date", \.hireDate)

// Avoid
.init("ID", \.employeeId)  // Ambiguous
.init("The Date When The Employee Was Hired", \.hireDate)  // Too long
```

### 3. Format for Readability

Make numbers easy to scan:

```swift
// Good - formatted strings
.init("Revenue") { "$\($0.revenue.formatted())" }
.init("Growth") { "\(String(format: "%.1f", $0.growth))%" }

// Avoid - raw numbers
.init("Revenue", \.revenue)  // Shows "1234567.89"
```

## See Also

- ``DataTableColumn``
- ``DataTableValueType``
- <doc:AnimatedUpdates>
