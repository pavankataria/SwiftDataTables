# Getting Started

Add SwiftDataTables to your project and display your first table in minutes.

## Overview

This guide walks you through installing SwiftDataTables and creating your first data table. By the end, you'll have a working table displaying data with sorting and searching.

## Installation

### Swift Package Manager (Recommended)

Add SwiftDataTables via Xcode:

1. Open your project in Xcode
2. Go to **File → Add Package Dependencies...**
3. Enter the repository URL: `https://github.com/pavankataria/SwiftDataTables`
4. Select your version rules and add to your target

Or add it directly to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/pavankataria/SwiftDataTables", from: "0.9.0")
]
```

## Your First Table

### Step 1: Import the Framework

```swift
import SwiftDataTables
```

### Step 2: Create Sample Data

SwiftDataTables works with simple 2D arrays:

```swift
let data = [
    ["Alice", "Engineer", "London"],
    ["Bob", "Designer", "Paris"],
    ["Carol", "Manager", "Berlin"]
]
let headers = ["Name", "Role", "City"]
```

### Step 3: Create the Table

```swift
let dataTable = SwiftDataTable(
    data: data,
    headerTitles: headers
)
```

### Step 4: Add to Your View

```swift
override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(dataTable)
    dataTable.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
        dataTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        dataTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        dataTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        dataTable.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
}
```

That's it! You now have a fully functional data table with:
- ✅ Column sorting (tap headers)
- ✅ Built-in search bar
- ✅ Automatic column widths
- ✅ Row highlighting on selection

## Next Steps

- <doc:TypeSafeColumns> - Use your own model types with type-safe columns
- <doc:AnimatedUpdates> - Update data with smooth animations
- <doc:ColumnWidths> - Control how column widths are calculated
