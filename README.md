<!--[![CI Status](http://img.shields.io/travis/pavankataria/SwiftDataTables.svg?style=flat)](https://travis-ci.org/pavankataria/SwiftDataTables)
https://img.shields.io/cocoapods/p/SwiftDataTables.svg
-->
<!--[![Platform](https://img.shields.io/badge/%20%20Platform%20%20-iOS-brightgreen.svg?style=flat)](http://cocoapods.org/pods/SwiftDataTables)-->
<!--[![Swift Version](https://img.shields.io/badge/%20%20Swift%20Version%20%20-3%20and%204-brightgreen.svg?style=flat)](http://cocoapods.org/pods/SwiftDataTables)-->
<!--[![GitHub issues](https://img.shields.io/github/issues/pavankataria/SwiftDataTables.svg)]
(https://github.com/pavankataria/SwiftDataTables/issues)--> 
<!--[![GitHub contributors](https://img.shields.io/github/contributors/pavankataria/SwiftDataTables.svg)](https://github.com/freshos/Stevia/graphs/contributors)-->
<!--![Platform: iOS 8+](https://img.shields.io/badge/platform-iOS-blue.svg?style=flat)-->

![Swift DataTables](https://user-images.githubusercontent.com/1791244/43036589-70947a6c-8cfc-11e8-9fe8-37abb78317aa.png)

<p align="center">
    <a href="https://github.com/pavankataria/SwiftDataTables/actions/workflows/ci.yml">
        <img src="https://github.com/pavankataria/SwiftDataTables/actions/workflows/ci.yml/badge.svg" alt="CI Status" />
    </a>

<a href="https://swift.org/package-manager">
        <img src="https://img.shields.io/badge/SPM-compatible-brightgreen.svg?style=flat" alt="SPM Compatible" />
    </a>
   <a href="https://en.wikipedia.org/wiki/MIT_License">
        <img src="https://img.shields.io/badge/License-MIT-brightgreen.svg?style=flat" />
   </a>
   <a href="https://github.com/pavankataria/SwiftDataTables/releases">
        <img src="https://img.shields.io/github/release/pavankataria/SwiftDataTables.svg" />
   </a>
<a href="https://developer.apple.com/swift">
        <img src="https://img.shields.io/badge/Swift-5.9-orange.svg?style=flat" alt="Swift 5.9" />
    </a>

<a href="https://developer.apple.com/ios/">
        <img src="https://img.shields.io/badge/iOS-17+-blue.svg?style=flat" alt="iOS 17+" />
    </a>
       <a href="https://opencollective.com/swiftdatatables">
        <img src="https://img.shields.io/badge/Sponsor-Open%20Collective-blue.svg?style=flat" alt="Sponsor" />
    </a>
    <a href="https://twitter.com/pavan_kataria">
        <img src="https://img.shields.io/badge/contact-@pavan__kataria-blue.svg?style=flat" alt="Twitter: @pavan_kataria" />
    </a>
</p>
    
<!--[![Version](https://img.shields.io/cocoapods/v/SwiftDataTables.svg?style=flat)](http://cocoapods.org/pods/SwiftDataTables)-->
<!--[![CocoaPodsDL](https://img.shields.io/cocoapods/dt/SwiftDataTables.svg)](https://cocoapods.org/pods/SwiftDataTables)-->

`SwiftDataTables` allows you to display grid-like data sets in a nicely formatted table for iOS. The main goal for the end-user is to be able to obtain useful information from the table as quickly as possible with the following features: ordering, searching, and paging; and to provide an easy implementation with extensible options for the developer. 

**You can now contribute to this project over at https://opencollective.com/swiftdatatables!**

## Major Features

- **Self-Sizing Cells** - Automatic row heights with lazy measurement, efficient for 100k+ rows
- **Type-Safe Columns** - Declarative API with key paths and custom transforms
- **Animated Diffing** - Smooth updates with `setData(_:animatingDifferences:)`
- **Live Cell Editing** - Edit cells in place with automatic height updates
- **Scroll Anchoring** - Preserve visual position during data changes
- **Custom Cells** - Full Auto Layout support via custom cell providers
- **Flexible Column Widths** - Multiple strategies from fast estimation to precise measurement
- **Fixed Columns** - Freeze columns on left or right sides
- **Sorting** - Tap column headers to sort by any column
- **Searching** - Built-in search bar or native navigation bar search

<!-- <img src="http://g.recordit.co/Mh9PYXB9T4.gif" width="50%"> -->
<img src="/Example/SwiftDataTables-Preview.gif" width="50%">

## Quick Start

```swift
import SwiftDataTables

// Simple array-based table
let data = [
    ["Alice", "Engineer", "London"],
    ["Bob", "Designer", "Paris"],
    ["Carol", "Manager", "Berlin"]
]
let dataTable = SwiftDataTable(
    data: data,
    headerTitles: ["Name", "Role", "City"]
)
view.addSubview(dataTable)
```

Or with type-safe columns:

```swift
struct Employee: Identifiable {
    let id: String
    let name: String
    let role: String
    let salary: Int
}

let columns: [DataTableColumn<Employee>] = [
    .init("Name", \.name),
    .init("Role", \.role),
    .init("Salary") { .string("£\($0.salary)") }
]

let dataTable = SwiftDataTable(data: employees, columns: columns)
```

Update data with animated diffing:

```swift
// Load initial data
var employees: [Employee] = []
dataTable.setData(employees)

// Fetch and update
employees = await api.fetchEmployees()
dataTable.setData(employees, animatingDifferences: true)

// Append new items
employees.append(newEmployee)
dataTable.setData(employees, animatingDifferences: true)
```

## Install

### Swift Package Manager

Add SwiftDataTables to your project via Xcode:
1. File → Add Package Dependencies...
2. Enter the repository URL: `https://github.com/pavankataria/SwiftDataTables`
3. Select your version rules and add to your target

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/pavankataria/SwiftDataTables", from: "0.9.0")
]
```

## Demo Project Included

To run the example project do the following:
1. Download or clone the repo (`git clone https://github.com/pavankataria/SwiftDataTables`)
2. Open the `SwiftDataTables.xcodeproj` project in Xcode
3. Select the `DemoSwiftDataTables` scheme
4. Build and Run

If you have any questions or wish to make any suggestions, please open an issue with the appropriate label, and I'll get back to you right away. Thank you

## Configuration
There's a configuration object that can be set on the data table for quick option settings. Or you can use the delegate methods for dynamic option changes.

---

## Self-Sizing Cells & Layout

SwiftDataTables automatically sizes columns and rows to fit your content. This section explains how to control that behaviour to prevent clipping and achieve the layout you want.

### The Problem This Solves

By default, column widths are calculated using the **average** content width across all rows. This works well for uniform data, but causes clipping when:
- Some rows have empty values while others have long content
- A few outlier rows contain much longer text than typical rows

**v0.9.0 introduces new width strategies** that use the **maximum** width instead of average, ensuring content is never clipped.

### Quick Start: Prevent Clipping

```swift
var config = DataTableConfiguration()

// Use hybrid strategy: fast estimation + sampled maximum (recommended)
config.columnWidthMode = .fitContentText(strategy: .hybrid(sampleSize: 100, averageCharWidth: 7))

// Or use pure maximum measurement (slower but most accurate)
config.columnWidthMode = .fitContentText(strategy: .maxMeasured)
```

### Column Width Modes

Control how column widths are calculated:

```swift
var config = DataTableConfiguration()
config.columnWidthMode = .fitContentText(strategy: .hybrid(sampleSize: 100, averageCharWidth: 7))
config.minColumnWidth = 44
config.maxColumnWidth = 280
```

**Available Modes:**

| Mode | Description | Performance |
|------|-------------|-------------|
| `.fitContentText(strategy:)` | Calculate width from text content | Varies by strategy |
| `.fitContentAutoLayout(sample:)` | Use Auto Layout on custom cells | Slower |
| `.fixed(width:)` | Fixed width for all columns | Fastest |

**Text Measurement Strategies** (for `.fitContentText`):

| Strategy | Description | Best For |
|----------|-------------|----------|
| `.estimatedAverage(averageCharWidth:)` | `charCount × avgWidth` averaged across rows | Large datasets, uniform data |
| `.hybrid(sampleSize:, averageCharWidth:)` | Max of estimated average and sampled measured max | **Recommended default** |
| `.sampledMax(sampleSize:)` | Measure a sample, take the maximum | Balancing accuracy vs speed |
| `.maxMeasured` | Measure every row, take maximum | Small datasets, maximum accuracy |
| `.percentileMeasured(percentile:, sampleSize:)` | Use a percentile (e.g., 95th) of sampled widths | Ignoring extreme outliers |
| `.fixed(width:)` | Fixed base width before padding | Known content widths |

**Per-Column Overrides:**

```swift
config.columnWidthModeProvider = { columnIndex in
    switch columnIndex {
    case 0: return .fixed(width: 60)  // ID column - fixed width
    case 3: return .fitContentText(strategy: .maxMeasured)  // Description - measure all
    default: return nil  // Use global mode
    }
}
```

**Clamping:**

- `minColumnWidth`: Minimum width after calculation (default: 70)
- `maxColumnWidth`: Maximum width cap (default: nil = no cap)
- Header width (including sort indicator) always wins and can exceed `maxColumnWidth`

### Row Heights & Text Wrapping

When column widths are capped, text may need to wrap. Configure this with:

```swift
var config = DataTableConfiguration()

// Enable text wrapping
config.textLayout = .wrap

// Automatic row heights based on content
config.rowHeightMode = .automatic(estimated: 60)
```

**Text Layout Options:**
- `.singleLine(truncation:)` - Single line with truncation (default)
- `.wrap` - Multi-line text wrapping

**Row Height Modes:**
- `.fixed(CGFloat)` - Fixed height for all rows (default: 44)
- `.automatic(estimated:)` - Height varies per row based on content

### Custom Cells with Auto Layout

For complete control, provide your own cell classes with Auto Layout constraints:

```swift
let provider = DataTableCustomCellProvider(
    register: { collectionView in
        collectionView.register(MyCustomCell.self, forCellWithReuseIdentifier: "custom")
    },
    reuseIdentifierFor: { indexPath in
        return "custom"
    },
    configure: { cell, value, indexPath in
        (cell as? MyCustomCell)?.configure(with: value)
    },
    sizingCellFor: { reuseIdentifier in
        return MyCustomCell()  // Off-screen cell for measurement
    }
)

config.cellSizingMode = .autoLayout(provider: provider)
config.rowHeightMode = .automatic(estimated: 60)
```

When using `.autoLayout`:
- Column widths are fixed by `columnWidthMode`
- Row heights are computed via `systemLayoutSizeFitting` using the fixed width
- Your cells must have proper Auto Layout constraints for self-sizing

### Performance Considerations

| Strategy | 10K Rows | 50K Rows | Notes |
|----------|----------|----------|-------|
| `.estimatedAverage` | ~0.02s | ~0.1s | Fastest, may clip outliers |
| `.hybrid` | ~0.05s | ~0.2s | Good balance |
| `.maxMeasured` | ~0.5s | ~2s | Most accurate, measures all |

For large datasets (10K+ rows), `.estimatedAverage` or `.hybrid` are recommended.

---

## Navigation Bar Search

SwiftDataTables supports native iOS navigation bar search via UISearchController. This gives you the standard iOS search experience with minimal code:

```swift
override func viewDidLoad() {
    super.viewDidLoad()

    let dataTable = SwiftDataTable(data: myData, headerTitles: headers)
    view.addSubview(dataTable)

    // One line to enable navigation bar search
    dataTable.installSearchController(on: self)
}
```

The `installSearchController(on:)` method:
- Creates a pre-configured UISearchController
- Attaches it to the view controller's navigation item
- Hides the embedded search bar automatically
- Handles all search filtering for you

For more control, use `makeSearchController()` to get the UISearchController and configure it yourself:

```swift
let searchController = dataTable.makeSearchController()
searchController.searchBar.placeholder = "Find items..."
navigationItem.searchController = searchController
```

---

## Data Source methods. 
This is an optional data source implementation, you can also initialiase your `SwiftDataTable` with a static data set as shown in the Demo project so you can avoid conforming to the data source. But for those who want to show more dynamic content, use the following `SwiftDataTableDataSource` protocol.

```Swift

public protocol SwiftDataTableDataSource: class {
    
    /// The number of columns to display
    func numberOfColumns(in: SwiftDataTable) -> Int
    
    /// Return the total number of rows that will be displayed in the table
    func numberOfRows(in: SwiftDataTable) -> Int
    
    /// Return the data for the given row
    func dataTable(_ dataTable: SwiftDataTable, dataForRowAt index: NSInteger) -> [DataTableValueType]
    
    /// The header title for the column position to be displayed
    func dataTable(_ dataTable: SwiftDataTable, headerTitleForColumnAt columnIndex: NSInteger) -> String
}
```

## Delegate for maximum customisation
An optional delegate for further customisation. Default values will be used retrieved from the SwiftDataTableConfiguration file. This will can be overridden and passed into the SwiftDataTable constructor incase you wish not to use the delegate. 

```Swift

@objc public protocol SwiftDataTableDelegate: class {
    /// Fired when a cell is selected.
    ///
    /// - Parameters:
    ///   - dataTable: SwiftDataTable
    ///   - indexPath: the index path of the row selected
    @objc optional func didSelectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath)

    /// Fired when a cell has been deselected
    ///
    /// - Parameters:
    ///   - dataTable: SwiftDataTable
    ///   - indexPath: the index path of the row deselected
    @objc optional func didDeselectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath)

    /// Specify custom heights for specific rows. A row height of 0 is valid and will be used.
    @objc optional func dataTable(_ dataTable: SwiftDataTable, heightForRowAt index: Int) -> CGFloat

    /// Specify custom widths for columns. This method once implemented overrides the automatic width calculation for remaining columns and therefor widths for all columns must be given. This behaviour may change so that custom widths on a single column basis can be given with the automatic width calculation behaviour applied for the remaining columns.
    @objc optional func dataTable(_ dataTable: SwiftDataTable, widthForColumnAt index: Int) -> CGFloat
    
    /// Column Width scaling. If set to true and the column's total width is smaller than the content size then the width of each column will be scaled proprtionately to fill the frame of the table. Otherwise an automatic calculated width size will be used by processing the data within each column.
    /// Defaults to true.
    @objc optional func shouldContentWidthScaleToFillFrame(in dataTable: SwiftDataTable) -> Bool
    
    /// Section Header floating. If set to true headers can float and remain in view during scroll. Otherwise if set to false the header will be fixed at the top and scroll off view along with the content.
    /// Defaults to true
    @objc optional func shouldSectionHeadersFloat(in dataTable: SwiftDataTable) -> Bool
    
    /// Section Footer floating. If set to true footers can float and remain in view during scroll. Otherwise if set to false the footer will be fixed at the top and scroll off view along with the content.
    /// Defaults to true.
    @objc optional func shouldSectionFootersFloat(in dataTable: SwiftDataTable) -> Bool
    
    
    /// Search View floating. If set to true the search view can float and remain in view during scroll. Otherwise if set to false the search view will be fixed at the top and scroll off view along with the content.
    //  Defaults to true.
    @objc optional func shouldSearchHeaderFloat(in dataTable: SwiftDataTable) -> Bool
    
    /// Disable search view. Hide search view. Defaults to true.
    @objc optional func shouldShowSearchSection(in dataTable: SwiftDataTable) -> Bool
    
    /// The height of the section footer. Defaults to 44.
    @objc optional func heightForSectionFooter(in dataTable: SwiftDataTable) -> CGFloat
    
    /// The height of the section header. Defaults to 44.
    @objc optional func heightForSectionHeader(in dataTable: SwiftDataTable) -> CGFloat
    
    /// The height of the search view. Defaults to 44.
    @objc optional func heightForSearchView(in dataTable: SwiftDataTable) -> CGFloat
    
    /// Height of the inter row spacing. Defaults to 1.
    @objc optional func heightOfInterRowSpacing(in dataTable: SwiftDataTable) -> CGFloat
    
    /// Control the display of the vertical scroll bar. Defaults to true.
    @objc optional func shouldShowVerticalScrollBars(in dataTable: SwiftDataTable) -> Bool
    
    /// Control the display of the horizontal scroll bar. Defaults to true.
    @objc optional func shouldShowHorizontalScrollBars(in dataTable: SwiftDataTable) -> Bool
    
    /// Control the background color for cells in rows intersecting with a column that's highlighted.
    @objc optional func dataTable(_ dataTable: SwiftDataTable, highlightedColorForRowIndex at: Int) -> UIColor
    
    /// Control the background color for an unhighlighted row.
    @objc optional func dataTable(_ dataTable: SwiftDataTable, unhighlightedColorForRowIndex at: Int) -> UIColor

    /// Return the number of fixed columns
    @objc optional func fixedColumns(for dataTable: SwiftDataTable) -> DataTableFixedColumnType
    
    /// Return `true` to support RTL layouts by flipping horizontal scroll on `CollectionViewFlowLayout`, if the current interface direction is RTL.
    @objc optional func shouldSupportRightToLeftInterfaceDirection(in dataTable: SwiftDataTable) -> Bool
}
```

## Getting involved

* If you **want to contribute** please feel free to **submit pull requests**.
* If you **have a feature request** please **open an issue**.
* If you **found a bug** check older issues before submitting an issue.
* If you **need help** or would like to **ask general question**, create an issue.

**Before contribute check the [CONTRIBUTING](CONTRIBUTING.md) file for more info.**

If you use **SwiftDataTables** in your app We would love to hear about it! Drop me a line on [twitter].

## Author

Pavan Kataria

### 👨‍💻 Contributors

**Consider contributing to this project over at https://opencollective.com/swiftdatatables!**

<!--## Contributors 
Thanks to the developers listed below:
<a href="https://github.com/pavankataria/SwiftDataTables/graphs/contributors"><img src="https://opencollective.com/AudioKit/contributors.svg?width=890&button=false" /></a>
Who is using it
---------------
Please let me know if your app is using this library. I'd be glad to put your app on the list :-)
* [WeShop for iOS](https://itunes.apple.com/gb/app/weshop-compare-shop-earn/id1045921951?mt=8)  
WeShop - Make shopping on the go a joy with the WeShop App. Compare millions of products from 100s of top retailers and discover which have been recommended by people you trust. WeShop is the most rewarding place to shop; collect points every time you buy AND when you recommend products you love. Redeem them for cash, or donate them to charity - it pays to be social!
-->

## License

SwiftDataTables is available under the MIT license. See the LICENSE file for more info.
This package was inspired by JQuery's DataTables plugin.
<!--
## Follow us
[![Twitter URL](https://img.shields.io/twitter/url/http/shields.io.svg?style=social)](https://twitter.com/intent/tweet?text=https://github.com/pavankataria/SwiftDataTables)
[![Twitter Follow](https://img.shields.io/twitter/follow/pavan_kataria.svg?style=social)](https://twitter.com/pavan_kataria)
-->
[twitter]: https://twitter.com/pavan_kataria
