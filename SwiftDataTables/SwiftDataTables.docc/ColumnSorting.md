# Column Sorting

Enable users to sort data by tapping column headers.

## Overview

Sorting is enabled by default. Users tap a column header to sort ascending, tap again for descending. Subsequent taps toggle between ascending and descending.

## Default Behavior

```swift
let dataTable = SwiftDataTable(columns: columns)
// Sorting is enabled automatically
```

## Sort Indicators

Headers display arrows indicating sort direction:
- **▲** Ascending (A→Z, 1→100)
- **▼** Descending (Z→A, 100→1)

### Customizing Sort Arrow Colors

```swift
var config = DataTableConfiguration()
config.sortArrowTintColor = .systemBlue
```

### Hiding Sort Indicators

```swift
config.shouldShowHeaderSortingIndicator = false
config.shouldShowFooterSortingIndicator = false
```

## Disabling Sorting Per Column

Prevent sorting on specific columns:

```swift
config.isColumnSortable = { columnIndex in
    // Disable sorting on action column (index 4)
    return columnIndex != 4
}
```

### Automatic Sort Disabling for Header-Only Columns

Columns created with only a header (no extraction or comparison logic) automatically have sorting disabled:

```swift
let columns: [DataTableColumn<User>] = [
    .init("Name", \.name),      // Sortable: has extraction
    .init("Actions")            // Not sortable: header-only
]
```

Header-only columns are identified by having both `extract` and `compare` closures set to `nil`.
The sort indicator is hidden and tapping the header has no effect on row order.

### Dynamic Sorting Control

Use state in your closure for conditional sorting:

```swift
class MyViewController: UIViewController {
    var isEditingMode = false

    func setupTable() {
        var config = DataTableConfiguration()
        config.isColumnSortable = { [weak self] columnIndex in
            guard let self else { return true }
            // Disable all sorting during edit mode
            return !self.isEditingMode
        }
    }

    func toggleEditMode() {
        isEditingMode.toggle()
        // Table automatically respects new state on next header tap
    }
}
```

## Header Tap Events

Respond to header taps for custom behavior:

```swift
extension MyViewController: SwiftDataTableDelegate {
    func dataTable(_ dataTable: SwiftDataTable, didTapHeaderAt columnIndex: Int) {
        print("Tapped column \(columnIndex)")
        // Show column options, trigger custom sort, analytics, etc.
    }
}
```

This delegate method is called regardless of whether sorting occurs. Use it with `isColumnSortable` to handle taps on non-sortable columns.

## Default Sort Order

Set an initial sort when the table loads:

```swift
config.defaultSortingColumn = (index: 1, order: .ascending)
```

## Sorting Architecture

### How Sorting Works Internally

When a column header is tapped:

1. **Sort direction toggles**: unspecified → ascending ↔ descending (toggles between asc/desc after first tap)
2. **Sortability check**: The column must be sortable (not hidden)
3. **Comparator selection**:
   - If the column has a `compare` closure, use typed sorting
   - Otherwise, fall back to `DataTableValueType` comparison
4. **Row reordering**: Rows are sorted based on the comparison result
5. **View update**: The collection view reloads to reflect the new order

### Typed Sorting vs. Value-Based Sorting

**Value-based sorting** (default for simple columns) compares `DataTableValueType` values:
- Strings are compared alphabetically
- Numbers are compared numerically
- Mixed types fall back to string comparison

**Typed sorting** (when `compare` closure is present) compares using your custom comparator:
- Enables proper sorting of formatted display values
- Example: "$1,234.56" displays as string but sorts by 1234.56

## Sort Types

Sorting behavior depends on ``DataTableValueType``:

| Type | Sort Behavior |
|------|---------------|
| `.string` | Alphabetical (A, B, C) |
| `.int` | Numeric (1, 2, 10) |
| `.float` | Numeric (1.1, 1.5, 2.0) |
| `.double` | Numeric |

### Ensuring Correct Sort Order

Use keypaths for simple properties - they preserve the correct type automatically:

```swift
// Numeric sorting (via keypath)
.init("Age", \.age)

// Alphabetic sorting (via keypath)
.init("Name", \.name)

// Be careful: "10" < "2" < "9" with strings!
.init("ID", \.id)  // Keypath preserves Int type for numeric sorting
```

For computed values where you need explicit numeric sorting:

```swift
// Computed numeric with explicit type
.init("Total Score") { .int($0.points + $0.bonus) }
```

## Typed Sorting Initializers

SwiftDataTables provides specialized initializers that separate display formatting from sort behavior. This is essential when you want to show formatted values (like "$1,234.56") but sort numerically.

### Understanding Closure Parameter Types

Different initializers provide different closure parameter types. Understanding this is crucial for correct usage:

| Initializer | Display Closure Receives | Sort Behavior |
|-------------|-------------------------|---------------|
| `init("Header", \.property)` | N/A (auto-converted) | Value-based |
| `init("Header") { row in }` | Full Row (`T`) | Value-based (string) |
| `init("Header", \.property) { value in }` | Property Value (`V`) | Typed by property |
| `init("Header", sortedBy: \.property) { row in }` | Full Row (`T`) | Typed by property |
| `init("Header", sortedBy: { extractor }) { row in }` | Full Row (`T`) | Typed by extractor |
| `init("Header", sortedBy: { comparator }) { row in }` | Full Row (`T`) | Custom comparator |

### KeyPath + Format: Single Property Display and Sort

When formatting a single property for display while maintaining typed sorting:

```swift
// The closure receives the PROPERTY VALUE (Double), not the row
.init("Salary", \.salary) { value in
    "$\(String(format: "%.2f", value))"  // value is Double
}
```

**Use when**: You want to format one property and sort by that same property.

**Closure parameter**: The property value (`V`), not the full row.

### SortedBy + Display: Different Sort Property Than Display

When the display combines multiple fields but sorting should use one specific property:

```swift
// The closure receives the FULL ROW (T), not just a property
.init("Full Name", sortedBy: \.lastName) { row in
    "\(row.firstName) \(row.lastName)"  // row is User
}
```

**Use when**: Display needs multiple properties but sort by one property.

**Closure parameter**: The full row (`T`).

### SortedBy Extractor + Display: Computed Sort Values

When the sort value is computed and doesn't exist as a property:

```swift
// The extractor receives the full row to compute a sortable value
// The display closure also receives the full row
.init("Total Value", sortedBy: { $0.price * Double($0.quantity) }) { row in
    "$\(String(format: "%.2f", row.price * Double(row.quantity)))"
}
```

**Use when**: Sort value is computed from multiple properties.

**Closure parameters**:
- Extractor receives full row → returns `Comparable` value
- Display receives full row → returns `String`

### SortedBy Comparator + Display: Full Custom Comparison

When you need complete control over comparison logic:

```swift
// The comparator receives TWO rows and returns ComparisonResult
.init("Name", sortedBy: { lhs, rhs in
    lhs.name.localizedCaseInsensitiveCompare(rhs.name)
}) { row in
    row.name
}

// Nulls-last sorting for optional dates
.init("Due Date", sortedBy: { lhs, rhs in
    switch (lhs.dueDate, rhs.dueDate) {
    case (nil, nil): return .orderedSame
    case (nil, _): return .orderedDescending  // nil goes last
    case (_, nil): return .orderedAscending
    case (let a?, let b?): return a.compare(b)
    }
}) { row in
    row.dueDate?.formatted() ?? "No date"
}
```

**Use when**: Standard comparison isn't sufficient (case-insensitive, nulls-last, semantic versioning, etc.).

**Closure parameters**:
- Comparator receives two rows (`T`, `T`) → returns `ComparisonResult`
- Display receives one row (`T`) → returns `String`

## Choosing the Right Initializer

### Decision Tree

1. **Is sorting needed for this column?**
   - No → Use `init("Header")` (header-only)
   - Yes → Continue

2. **Is the display value the same as the sort value?**
   - Yes, simple property → Use `init("Header", \.property)`
   - Yes, computed → Use `init("Header") { .int($0.computed) }`
   - No → Continue

3. **Does display need the full row or just one property?**
   - Just one property, formatted → Use `init("Header", \.property) { format($0) }`
   - Full row → Continue

4. **Is the sort value a single property?**
   - Yes → Use `init("Header", sortedBy: \.property) { display($0) }`
   - No, it's computed → Use `init("Header", sortedBy: { compute($0) }) { display($0) }`
   - No, need custom logic → Use `init("Header", sortedBy: { compare($0, $1) }) { display($0) }`

### Common Patterns

#### Money/Currency

```swift
// Format: displays "$1,234.56", sorts by 1234.56
.init("Price", \.price) { "$\(String(format: "%.2f", $0))" }
```

#### Dates

```swift
// Format: displays "Jan 15, 2024", sorts chronologically
.init("Created", \.createdAt) { $0.formatted(date: .abbreviated, time: .omitted) }
```

#### Percentages

```swift
// Format: displays "75%", sorts by 0.75
.init("Progress", \.progress) { "\(Int($0 * 100))%" }
```

#### Full Name (Sort by Last Name)

```swift
// Display: "Alice Smith", sort: by "Smith"
.init("Name", sortedBy: \.lastName) { "\($0.firstName) \($0.lastName)" }
```

#### Case-Insensitive Sorting

```swift
.init("Title", sortedBy: { lhs, rhs in
    lhs.title.localizedCaseInsensitiveCompare(rhs.title)
}) { $0.title }
```

#### Computed Values (Total, Average, etc.)

```swift
.init("Total", sortedBy: { $0.price * Double($0.qty) }) {
    "$\(String(format: "%.2f", $0.price * Double($0.qty)))"
}
```

## Sortability Priority

When determining if a column is sortable, the following priority applies:

1. **User override** (`isColumnSortable` closure) takes highest precedence
2. **Column definition** (`isSortable` computed property):
   - `true` if column has `extract` OR `compare`
   - `false` if column is header-only (both `nil`)
3. **Legacy default**: `true` (for backward compatibility)

```swift
// User override forces all columns non-sortable
config.isColumnSortable = { _ in false }

// Or selectively override auto-disable
config.isColumnSortable = { index in
    index != 3  // Column 3 not sortable, others follow auto-detection
}
```

## See Also

- ``DataTableConfiguration``
- ``DataTableSortType``
- ``DataTableColumn``
- ``DataTableValueType``
