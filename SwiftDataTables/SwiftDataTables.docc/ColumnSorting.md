# Column Sorting

Control how columns sort when users tap the header.

## Overview

When a user taps a column header, the table sorts by that column. Tap again to reverse the order. The way you define your column determines how it sorts.

## Quick Reference

Here's an overview of all 8 column initializers:

| You write this | Cell shows | Sorts by |
|----------------|------------|----------|
| `.init("Age", \.age)` | 25 | Number (1, 2, 10, 25) |
| `.init("Price", \.price) { "$\($0)" }` | $99.99 | Number (not the $ string) |
| `.init("Location") { "\($0.city), \($0.country)" }` | London, UK | Alphabetically by displayed text |
| `.init("Score") { .int($0.points + $0.bonus) }` | 150 | Number (computed) |
| `DataTableColumn<T>("Actions")` | — | Not sortable |
| `.init("Name", sortedBy: \.lastName) { fullName }` | Alice Smith | By lastName property only |
| `.init("Title", sortedBy: { $0.title.count }) { ... }` | Hello | By computed value (length: 5) |
| `.init("Name", sortedBy: { compare($0, $1) }) { ... }` | alice | By custom comparison logic |

## 1. Simple Property

The simplest case: display a property and sort by its natural type.

```swift
// The backslash-dot syntax (\.name) is called a "key path"
// It tells Swift which property to read from your model

struct Person {
    let name: String
    let age: Int
}

let columns: [DataTableColumn<Person>] = [
    .init("Name", \.name),   // Displays: "Alice"   Sorts: A → Z
    .init("Age", \.age)      // Displays: 25        Sorts: 1 → 100
]
```

**Sorting effect:** Strings sort alphabetically (A-Z). Numbers sort numerically (1, 2, 10 - not 1, 10, 2). Dates sort chronologically.

## 2. Formatted Display, Typed Sort

Show a formatted string but sort by the underlying value. This is crucial for money, dates, and percentages.

```swift
// Without formatting (problem: displays raw number)
.init("Salary", \.salary)  // Displays: 50000.0

// With formatting (solution: displays nicely, sorts correctly)
.init("Salary", \.salary) { value in
    "$\(String(format: "%.2f", value))"
}
// Displays: "$50,000.00"
// Sorts by: 50000.0 (the number, not the string)
```

> Important: If you used a closure alone, "$9.99" would sort AFTER "$100.00" because string "9" > "1". By using the key path + formatter pattern, $9.99 correctly sorts before $100.00.

More examples:

```swift
// Dates: show "Jan 15, 2024", sort chronologically
.init("Created", \.createdAt) { $0.formatted(date: .abbreviated, time: .omitted) }

// Percentages: show "75%", sort by 0.75
.init("Progress", \.progress) { "\(Int($0 * 100))%" }

// File sizes: show "1.2 GB", sort by bytes
.init("Size", \.sizeInBytes) {
    ByteCountFormatter.string(fromByteCount: $0, countStyle: .file)
}
```

## 3. Computed Display (String Sort)

When you use a closure without a key path, the column sorts alphabetically by whatever text is displayed.

```swift
// Combine multiple properties
.init("Location") { "\($0.city), \($0.country)" }
// Displays: "London, UK"
// Sorts alphabetically: "London, UK" comes before "Paris, France"
```

> Warning: String sorting is alphabetical, not numerical. This means "$10" < "$2" (because "1" < "2") and "Item 9" > "Item 10". Only use this pattern when alphabetical order makes sense.

## 4. Computed Value with Explicit Type

When you compute a value from multiple properties and need numeric sorting, wrap it in a type.

```swift
// BAD: sorts as string "150" (alphabetically)
.init("Total") { "\($0.points + $0.bonus)" }

// GOOD: sorts as integer 150 (numerically)
.init("Total") { .int($0.points + $0.bonus) }

// Available types:
// .string("text")  - alphabetical
// .int(42)         - numeric
// .float(3.14)     - numeric
// .double(3.14159) - numeric
```

## 5. Header Only (No Sorting)

For columns that shouldn't sort - like action buttons or custom-rendered content.

```swift
// Just the header, no value extraction, no sorting
DataTableColumn<User>("Actions")

// Tapping this header does nothing
```

## 6. Display One Thing, Sort by Another Property

Show combined text but sort by a specific property.

```swift
struct Person {
    let firstName: String
    let lastName: String
}

// Display full name, but sort by last name only
.init("Name", sortedBy: \.lastName) { person in
    "\(person.firstName) \(person.lastName)"
}

// Displays: "Alice Smith", "Bob Jones", "Carol Adams"
// After sorting: "Carol Adams", "Bob Jones", "Alice Smith"
// (sorted by: Adams, Jones, Smith)
```

Another example:

```swift
// Show product with price, sort by price
.init("Product", sortedBy: \.price) { item in
    "\(item.name) — $\(String(format: "%.2f", item.price))"
}

// Displays: "Widget — $49.99", "Gadget — $29.99"
// After sorting: "Gadget — $29.99", "Widget — $49.99"
// (sorted by price: 29.99, 49.99)
```

## 7. Sort by Computed Value

When the sort value isn't a stored property - you need to calculate it.

```swift
// Sort by string length (shortest titles first)
.init("Title", sortedBy: { $0.title.count }) { $0.title }

// Displays: "Hello", "Hi", "Greetings"
// After sorting: "Hi" (2), "Hello" (5), "Greetings" (9)
```

```swift
// Sort by custom priority order
enum Priority {
    case high, medium, low
    var sortOrder: Int {
        switch self {
        case .high: return 0
        case .medium: return 1
        case .low: return 2
        }
    }
}

.init("Priority", sortedBy: { $0.priority.sortOrder }) { $0.priority.displayName }

// Displays: "High", "Low", "Medium"
// After sorting: "High" (0), "Medium" (1), "Low" (2)
```

## 8. Custom Comparison Logic

Full control over how two items compare. Use when standard sorting isn't enough.

```swift
// Case-insensitive sorting ("alice" and "Alice" treated the same)
.init("Name", sortedBy: { lhs, rhs in
    lhs.name.localizedCaseInsensitiveCompare(rhs.name)
}) { $0.name }

// Displays: "alice", "Bob", "CAROL"
// After sorting: "alice", "Bob", "CAROL" (case ignored)
```

```swift
// Sort nil values to the end
.init("Due Date", sortedBy: { lhs, rhs in
    switch (lhs.dueDate, rhs.dueDate) {
    case (nil, nil): return .orderedSame
    case (nil, _):   return .orderedDescending  // nil goes last
    case (_, nil):   return .orderedAscending   // non-nil goes first
    case (let a?, let b?): return a.compare(b)
    }
}) { $0.dueDate?.formatted() ?? "No date" }

// Displays: "Jan 15", "No date", "Jan 10"
// After sorting: "Jan 10", "Jan 15", "No date"
```

```swift
// Version number sorting ("1.10" > "1.9")
.init("Version", sortedBy: { lhs, rhs in
    lhs.version.compare(rhs.version, options: .numeric)
}) { $0.version }

// Displays: "1.9", "1.10", "1.2"
// After sorting: "1.2", "1.9", "1.10" (not "1.10", "1.2", "1.9")
```

## Disabling Sorting on Specific Columns

Prevent certain columns from being sortable, even if they have values.

```swift
var config = DataTableConfiguration()

// Disable sorting on column index 3 (the 4th column)
config.isColumnSortable = { columnIndex in
    columnIndex != 3
}

// Or disable multiple columns
config.isColumnSortable = { columnIndex in
    ![2, 3, 5].contains(columnIndex)
}
```

## Customizing Sort Indicators

```swift
var config = DataTableConfiguration()

// Change the arrow color
config.sortArrowTintColor = .systemBlue

// Hide sort arrows entirely
config.shouldShowHeaderSortingIndicator = false

// Set initial sort when table loads
config.defaultOrdering = DataTableColumnOrder(index: 1, order: .ascending)
```

## Header Tap Events

Respond to header taps for custom behavior beyond sorting:

```swift
extension MyViewController: SwiftDataTableDelegate {
    func dataTable(_ dataTable: SwiftDataTable, didTapHeaderAt columnIndex: Int) {
        print("Tapped column \(columnIndex)")
        // Show column options, trigger custom sort, analytics, etc.
    }
}
```

This delegate method is called regardless of whether sorting occurs.

## See Also

- ``DataTableConfiguration``
- ``DataTableColumn``
- ``DataTableValueType``
