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
   <a href="https://developer.apple.com/swift">
        <img src="https://img.shields.io/badge/Swift-5-orange.svg?style=flat" />
    </a>
  <a href="https://github.com/Carthage/Carthage">
        <img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat" />
   </a>
   <a href="https://cocoapods.org/pods/SwiftDataTables">
        <img src="https://img.shields.io/badge/Cocoapods-compatible-4BC51D.svg?style=flat" />
    </a>
   <a href="https://en.wikipedia.org/wiki/MIT_License">
        <img src="https://img.shields.io/badge/License-MIT-brightgreen.svg?style=flat" />
   </a>
<!--    <img src="https://img.shields.io/cocoapods/dt/SwiftDataTables.svg" />
   <img src="https://img.shields.io/cocoapods/at/SwiftDataTables.svg" />
     -->
   <a href="https://github.com/pavankataria/SwiftDataTables/releases">
        <img src="https://img.shields.io/github/release/pavankataria/SwiftDataTables.svg" />
   </a>
       <a href="https://twitter.com/pavan_kataria">
        <img src="https://img.shields.io/badge/contact-@pavan__kataria-blue.svg?style=flat" alt="Twitter: @pavan_kataria" />
    </a>
</p>
    
<!--[![Version](https://img.shields.io/cocoapods/v/SwiftDataTables.svg?style=flat)](http://cocoapods.org/pods/SwiftDataTables)-->
<!--[![CocoaPodsDL](https://img.shields.io/cocoapods/dt/SwiftDataTables.svg)](https://cocoapods.org/pods/SwiftDataTables)-->

`SwiftDataTables` allows you to display grid-like data sets in a nicely formatted table for iOS. The main goal for the end-user is to be able to obtain useful information from the table as quickly as possible with the following features: ordering, searching, and paging; and to provide an easy implementation with extensible options for the developer. 

## Major Features include:
- [x] Tested on iOS 8.0, 9, 10, 11, and 12 onwards. 
- [x] Full Swift 5 support
- [x] Mobile friendly. Tables adapt to the viewport size.
- [x] Instant search. Filter results by text search.
- [X] Fixed/frozen columns support for both left and right sides.
- [x] Continued support and active development! 
- [x] Full Datasource and delegate support!
- [x] Demo project available show casing all types of customisations
- [x] Or easy plugin configuration object can be passed with default values for your swift data table's visual presentation.
- [x] Can filter your datasource by scanning all fields.
- [x] Can sort various types of data in your grid, smartly, detecting numbers and strings
- [x] Width columns and height rows configurable or fall back to automatic proportion scaling depending on content
- [x] Beautiful alternating colours for rows and column selections.
- [x] Fully configurable header and footer labels including search view too. 
- [x] and beautiful clean presentation. 

<img src="http://g.recordit.co/Mh9PYXB9T4.gif" width="50%"><img src="/Example/SwiftDataTables-Preview.gif" width="50%">

## Install

### [Carthage](https://github.com/Carthage/Carthage)

- Add the following to your Cartfile: `github "pavankataria/SwiftDataTables"`
- Then run `carthage update`
- Follow the current instructions in [Carthage's README][carthage-installation]
for up to date installation instructions.

[carthage-installation]: https://github.com/Carthage/Carthage#adding-frameworks-to-an-application

### [CocoaPods](http://cocoapods.org)

- Add the following to your [Podfile](http://guides.cocoapods.org/using/the-podfile.html): `pod 'SwiftDataTables'`
- You will also need to make sure you're opting into using frameworks: `use_frameworks!`
- Then run `pod install`.

## Demo Project Included

To run the example project do the following:
1. Download or clone the repo (`git clone https://github.com/pavankataria/SwiftDataTables`)
2. Change directory into the `DemoSwiftDataTables/Example` folder (`cd SwiftDataTables/Example`)
4. With Xcode 9 installed, as normal, open the `SwiftDataTables.xcodeproj` project
5. Build and Run.

If you have any questions or wish to make any suggestions, please open an issue with the appropriate label, and I'll get back to you right away. Thank you

## Configuration 
There's a configuration object that can be set on the data table for quick option settings. Or you can use the delegate methods for dynamic option changes.

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

[Sebastien Senechal](https://github.com/altagir)
[Hais Daekin](https://github.com/Hais)


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
