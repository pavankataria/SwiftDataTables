# Search Integration

Add search functionality using the built-in search bar or native iOS navigation search.

## Overview

SwiftDataTables provides two search options:

- **Embedded search bar** - Built into the table header
- **Navigation bar search** - Uses `UISearchController` in the navigation bar

## Embedded Search Bar

Enabled by default. Customize visibility:

```swift
var config = DataTableConfiguration()
config.shouldShowSearchSection = true  // Default
config.shouldSearchHeaderFloat = true  // Stays visible while scrolling

let dataTable = SwiftDataTable(data: myData, headerTitles: headers, options: config)
```

### Hiding the Search Bar

```swift
config.shouldShowSearchSection = false
```

## Navigation Bar Search

For a native iOS look, use `UISearchController`:

```swift
class MyViewController: UIViewController {
    var dataTable: SwiftDataTable!

    override func viewDidLoad() {
        super.viewDidLoad()

        dataTable = SwiftDataTable(data: myData, headerTitles: headers)
        view.addSubview(dataTable)

        // One line to enable navigation bar search
        dataTable.installSearchController(on: self)
    }
}
```

### Custom Search Controller

For more control, create and configure it yourself:

```swift
let searchController = dataTable.makeSearchController()
searchController.searchBar.placeholder = "Search products..."
searchController.obscuresBackgroundDuringPresentation = false
navigationItem.searchController = searchController
navigationItem.hidesSearchBarWhenScrolling = false
```

## Search Behavior

Search filters across all visible columns. A row matches if **any** column contains the search text (case-insensitive).

```
Search: "lon"
Matches: "London", "Barcelona" (contains "lon"), "Longevity"
```

## Customizing Search

### Programmatic Search

Set the search text programmatically:

```swift
// Using navigation search
searchController.searchBar.text = "London"

// This triggers filtering automatically
```

### Search Callback

React to search changes via the configuration callback or delegate.

## See Also

- ``DataTableConfiguration``
- ``SwiftDataTable/installSearchController(on:)``
- ``SwiftDataTable/makeSearchController()``
