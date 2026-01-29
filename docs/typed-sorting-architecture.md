# Typed Sorting Architecture

## Purpose

Enable proper typed sorting for formatted display values. When a column displays `"$1,234.56"`, it should sort by the underlying `Double`, not alphabetically by the string.

## Current State

**Good news:** KeyPath-based columns already sort by typed value via `DataTableValueType`. The issue is only with closure-based columns that return formatted strings.

| Current API | Sort Behavior |
|-------------|---------------|
| `.init("Price", \.price)` | Numeric (correct) |
| `.init("Price") { "$\($0.price)" }` | Alphabetic (wrong) |

## North Star

Provide flexible initializers that separate **display** from **sorting**, while keeping the API clean and non-breaking.

---

## Initializers

### 1. KeyPath only
**Use when:** Display and sort are the same single property.

```swift
.init("Name", \.name)         // String sorts alphabetically
.init("Age", \.age)           // Int sorts numerically
.init("Price", \.price)       // Double sorts numerically
```

### 2. KeyPath + format
**Use when:** Format a single value but preserve typed sorting.

```swift
// Money: displays "$1,234.56", sorts numerically by 1234.56
.init("Salary", \.salary) { "$\(String(format: "%.2f", $0))" }

// Date: displays "Jan 15, 2024", sorts chronologically
.init("Created", \.createdAt) { $0.formatted(date: .abbreviated, time: .omitted) }

// Percentage: displays "75%", sorts by 0.75
.init("Progress", \.progress) { "\(Int($0 * 100))%" }

// File size: displays "1.2 GB", sorts by bytes
.init("Size", \.bytes) { ByteCountFormatter.string(fromByteCount: $0, countStyle: .file) }
```

### 3. Closure only (display)
**Use when:** Composing multiple properties and alphabetical sort is acceptable (or not sortable).

```swift
// Full address - alphabetical sort of combined string is fine
.init("Location") { "\($0.city), \($0.country)" }

// Static action column - not really sortable anyway
.init("") { _ in "Edit" }
```

### 4. sortedBy keypath + display
**Use when:** Display combines multiple properties but sort by ONE specific property.

```swift
// Show "Alice Smith", sort by last name
.init("Full Name", sortedBy: \.lastName) { "\($0.firstName) \($0.lastName)" }

// Show "Widget ($49.99)", sort by price
.init("Product", sortedBy: \.price) { "\($0.name) ($\(String(format: "%.2f", $0.price)))" }

// Show "Engineering - Alice", sort by employee ID for stable ordering
.init("Employee", sortedBy: \.employeeId) { "\($0.department) - \($0.name)" }

// Show task with assignee, sort by due date
.init("Task", sortedBy: \.dueDate) { "\($0.title) (\($0.assignee))" }
```

### 5. sortedBy extractor + display
**Use when:** Sort value doesn't exist as a property - it's computed.

```swift
// Show title, sort by length (shortest first)
.init("Title", sortedBy: { $0.title.count }) { $0.title }

// Show priority label, sort by custom order (High=0, Medium=1, Low=2)
.init("Priority", sortedBy: { $0.priority.sortOrder }) { $0.priority.displayName }

// Show full name, sort by "lastName, firstName" for proper alphabetical
.init("Name", sortedBy: { "\($0.lastName), \($0.firstName)" }) { "\($0.firstName) \($0.lastName)" }

// Show status, sort by completion percentage (hidden in display)
.init("Status", sortedBy: { $0.completedTasks.count / max($0.totalTasks, 1) }) { $0.statusLabel }
```

### 6. sortedBy comparator + display
**Use when:** Standard comparison isn't enough.

```swift
// Case-insensitive sorting
.init("Name", sortedBy: { $0.name.localizedCaseInsensitiveCompare($1.name) }) { $0.name }

// Nulls last (optional dates)
.init("Due Date", sortedBy: { lhs, rhs in
    switch (lhs.dueDate, rhs.dueDate) {
    case (nil, nil): return .orderedSame
    case (nil, _): return .orderedDescending
    case (_, nil): return .orderedAscending
    case (let a?, let b?): return a.compare(b)
    }
}) { $0.dueDate?.formatted() ?? "No date" }

// Version numbers (semantic versioning)
.init("Version", sortedBy: { lhs, rhs in
    lhs.version.compare(rhs.version, options: .numeric)
}) { $0.version }

// Multi-property tiebreaker (last name, then first name)
.init("Name", sortedBy: { lhs, rhs in
    let lastResult = lhs.lastName.compare(rhs.lastName)
    return lastResult != .orderedSame ? lastResult : lhs.firstName.compare(rhs.firstName)
}) { "\($0.firstName) \($0.lastName)" }
```

---

## API Design

### Internal Storage

All initializers store a type-erased comparator internally:

```swift
public struct DataTableColumn<Row> {
    public let header: String

    // Existing
    let extract: ((Row) -> DataTableValueType)?

    // New
    let compare: ((Row, Row) -> ComparisonResult)?
}
```

### Initializer Signatures

```swift
// 1. KeyPath only (existing - no change needed, already works)
init<V: DataTableValueConvertible>(_ header: String, _ keyPath: KeyPath<Row, V>)

// 2. KeyPath + format (NEW)
init<V: Comparable>(_ header: String, _ keyPath: KeyPath<Row, V>, format: @escaping (V) -> String)

// 3. Closure only (existing - no change needed)
init(_ header: String, _ extract: @escaping (Row) -> String)

// 4. sortedBy keypath + display (NEW)
init<S: Comparable>(_ header: String, sortedBy: KeyPath<Row, S>, display: @escaping (Row) -> String)

// 5. sortedBy extractor + display (NEW)
init<S: Comparable>(_ header: String, sortedBy: @escaping (Row) -> S, display: @escaping (Row) -> String)

// 6. sortedBy comparator + display (NEW)
init(_ header: String, sortedBy: @escaping (Row, Row) -> ComparisonResult, display: @escaping (Row) -> String)
```

---

## Non-Breaking Guarantee

| Existing Code | After Change |
|---------------|--------------|
| `.init("Name", \.name)` | Works unchanged |
| `.init("Salary") { "$\($0.salary)" }` | Works unchanged (still string-sorted) |
| Sorting via header tap | Works unchanged |
| `DataTableValueType` comparison | Still used when no comparator |

**New features are purely additive.** Users opt-in to typed sorting by using the new initializers.

---

## Implementation Plan

### Phase 1: Add `compare` property
- Add optional `compare: ((Row, Row) -> ComparisonResult)?` to `DataTableColumn`
- Existing initializers set `compare = nil`
- Sorting logic: if `compare` exists, use it; otherwise fall back to `DataTableValueType`

### Phase 2: Add new initializers
- KeyPath + format
- sortedBy keypath + display
- sortedBy extractor + display
- sortedBy comparator + display

### Phase 3: Update sorting logic
```swift
func sort(column index: Int, ascending: Bool) {
    if let comparator = columns[index].compare {
        // Use typed comparator
        rows.sort { comparator($0, $1) == (ascending ? .orderedAscending : .orderedDescending) }
    } else {
        // Fall back to existing DataTableValueType comparison
        rows.sort { ... existing logic ... }
    }
}
```

### Phase 4: Documentation
- Update column definition docs
- Add sorting guide with examples
- Migration notes for users wanting typed sorting

---

## Future: Multi-Column Sorting

The comparator architecture enables multi-sort:

```swift
struct SortDescriptor {
    let columnIndex: Int
    let ascending: Bool
}

var sortDescriptors: [SortDescriptor] = []
```

Touch device UX options:
- Long press on header to add to sort stack
- Sort configuration panel
- Programmatic-only (library provides API, developer builds UI)

---

## Summary

| Initializer | Closure Receives | Sort By |
|-------------|------------------|---------|
| KeyPath | — | Typed value |
| KeyPath + format | `V` (single value) | Typed value |
| Closure only | `Row` | String (alphabetic) |
| sortedBy keypath | `Row` | Specified keypath |
| sortedBy extractor | `Row` | Computed value |
| sortedBy comparator | `Row` | Custom logic |

**Key principle:** All variants are additive. Existing code works unchanged. Users opt-in to typed sorting by choosing the appropriate initializer.
