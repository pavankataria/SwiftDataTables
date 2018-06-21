# SwiftDataTables

<!--[![CI Status](http://img.shields.io/travis/pavankataria/SwiftDataTables.svg?style=flat)](https://travis-ci.org/pavankataria/SwiftDataTables)
https://img.shields.io/cocoapods/p/SwiftDataTables.svg
-->
[![Platform](https://img.shields.io/badge/%20%20Platform%20%20-iOS-brightgreen.svg?style=flat)](http://cocoapods.org/pods/SwiftDataTables)
[![Swift Version](https://img.shields.io/badge/%20%20Swift%20Version%20%20-4.2-brightgreen.svg?style=flat)](http://cocoapods.org/pods/SwiftDataTables) <!--[![GitHub issues](https://img.shields.io/github/issues/pavankataria/SwiftDataTables.svg)](https://github.com/pavankataria/SwiftDataTables/issues)--> [![License](https://img.shields.io/badge/%20%20license%20%20-MIT-brightgreen.svg?style=flat)](http://cocoapods.org/pods/SwiftDataTables)
[![Version](https://img.shields.io/cocoapods/v/SwiftDataTables.svg?style=flat)](http://cocoapods.org/pods/SwiftDataTables)
[![CocoaPodsDL](https://img.shields.io/cocoapods/dt/SwiftDataTables.svg)](https://cocoapods.org/pods/SwiftDataTables)


## About

`SwiftDataTables` allows you to display grid-like data sets in a nicely formatted table for iOS. The main goal for the end-user are to be able to obtain useful information from the table as quickly as possible with the following features: ordering, searching, and paging; where as for the developer is to allow for easy implementation with extensible options. 

## Major Features include:
+ Tested on iOS 8.0, 9, 10, 11, and 12 onwards. 
+ Full Swift 4 support
+ Continued support and active development! 
+ Full Datasource and delegate support!
+ Demo project available show casing all types of customisations
+ Or easy plugin configuration object can be passed with default values for your swift data table's visual presentation.
+ Can search through your grid
+ Can filter your datasource by scanning all fields.
+ Can sort various types of data in your grid, smartly, detecting numbers and strings
+ Fully configurable width columns and height rows or fall back on the automatic proportion scaling depending on the content
+ Beautiful alternating colours for rows and column selections.
+ Fully configurable header and footer labels including search view too. 
+ and beautiful clean interface. 

![animation](/Example/SwiftDataTables-Preview.gif)

## Installation

#### <img src="https://koenig-media.raywenderlich.com/uploads/2015/04/twitter-icon.png" width="23" height="23"> [CocoaPods]

[CocoaPods]: http://cocoapods.org

To install it, simply add the following line to your **Podfile**:

```ruby
pod "SwiftDataTables"
```

Then run `pod install` with CocoaPods 1.1.0.beta.1 or newer.

## Demo Project Included

To run the example project do the following:
1. Download or clone the repo (`git clone https://github.com/pavankataria/SwiftDataTables`)
2. Change directory into the `SwiftDataTables/Example` folder (`cd SwiftDataTables/Example`)
3. Install pod files (`pod install`)
4. With Xcode 8 installed, as normal, open the workspace file `SwiftDataTables.xcworkspace`, and not `SwiftDataTables.xcodeproj`
5. Build and Run.

If you have any questions or wish to make any suggestions, please open an issue with the appropriate label, and I'll get back to you right away. Thank you


## Data Source methods. 
This is an optional data source implementation, you can also initialiase your `SwiftDataTable` with a static data set as shown in the Demo project so you can avoid conforming to the data source. But for those who want to show more dynamic content, use the following `SwiftDataTableDataSource` protocol.

```Swift

public protocol SwiftDataTableDataSource: class {
    
    /// The number of columns to display
    ///
    /// - Parameter in: SwiftDataTable
    /// - Returns: the number of columns
    func numberOfColumns(in: SwiftDataTable) -> Int
    
    /// Return the total number of rows that will be displayed in the table
    ///
    /// - Parameter in: SwiftDataTable
    /// - Returns: retuthe number of rows.
    func numberOfRows(in: SwiftDataTable) -> Int
    
    
    /// Return the data for the given row
    ///
    /// - Parameters:
    ///   - dataTable: SwiftDataTable
    ///   - index: the index position of the row wishing to be displayed
    /// - Returns: return an array of the DataTableValueType type so the row can be processed and displayed.
    func dataTable(_ dataTable: SwiftDataTable, dataForRowAt index: NSInteger) -> [DataTableValueType]
    
    /// The header title for the column position to be displayed
    ///
    /// - Parameters:
    ///   - dataTable: SwiftDataTable
    ///   - columnIndex: The column index of the header title at a specific column index
    /// - Returns: the title of the column header.
    func dataTable(_ dataTable: SwiftDataTable, headerTitleForColumnAt columnIndex: NSInteger) -> String
}
```

## Delegate for maximum customisation
An optional delegate for further customisation. Default values will be used retrieved from the SwiftDataTableConfiguration file. This will can be overridden and passed into the SwiftDataTable constructor incase you wish not to use the delegate. 

```Swift

@objc public protocol SwiftDataTableDelegate: class {
    /// Specify custom heights for specific rows. A row height of 0 is valid and will be used.
    ///
    /// - Parameters:
    ///   - dataTable: SwiftDataTable
    ///   - index: the index of the row to specify a custom height for.
    /// - Returns: the desired height for the given row index
    @objc optional func dataTable(_ dataTable: SwiftDataTable, heightForRowAt index: Int) -> CGFloat

    /// Specify custom widths for columns. This method once implemented overrides the automatic width calculation for remaining columns and therefor widths for all columns must be given. This behaviour may change so that custom widths on a single column basis can be given with the automatic width calculation behaviour applied for the remaining columns.
    /// - Parameters:
    ///   - dataTable: SwiftDataTable
    ///   - index: the index of the column to specify the width for
    /// - Returns: the desired width for the given column index
    @objc optional func dataTable(_ dataTable: SwiftDataTable, widthForColumnAt index: Int) -> CGFloat
    
    /// Column Width scaling. If set to true and the column's total width is smaller than the content size then the width of each column will be scaled proprtionately to fill the frame of the table. Otherwise an automatic calculated width size will be used by processing the data within each column.
    /// Defaults to true.
    ///
    /// - Parameter dataTable: SwiftDataTable
    /// - Returns: whether you wish to scale to fill the frame of the table
    @objc optional func shouldContentWidthScaleToFillFrame(in dataTable: SwiftDataTable) -> Bool
    
    /// Section Header floating. If set to true headers can float and remain in view during scroll. Otherwise if set to false the header will be fixed at the top and scroll off view along with the content.
    /// Defaults to true
    ///
    /// - Parameter dataTable: SwiftDataTable
    /// - Returns: whether you wish to float section header views.
    @objc optional func shouldSectionHeadersFloat(in dataTable: SwiftDataTable) -> Bool
    
    /// Section Footer floating. If set to true footers can float and remain in view during scroll. Otherwise if set to false the footer will be fixed at the top and scroll off view along with the content.
    /// Defaults to true.
    ///
    /// - Parameter dataTable: SwiftDataTable
    /// - Returns: whether you wish to float section footer views.
    @objc optional func shouldSectionFootersFloat(in dataTable: SwiftDataTable) -> Bool
    
    
    /// Search View floating. If set to true the search view can float and remain in view during scroll. Otherwise if set to false the search view will be fixed at the top and scroll off view along with the content.
    //  Defaults to true.
    ///
    /// - Parameter dataTable: SwiftDataTable
    /// - Returns: whether you wish to float section footer views.
    @objc optional func shouldSearchHeaderFloat(in dataTable: SwiftDataTable) -> Bool
    
    /// Disable search view. Hide search view. Defaults to true.
    ///
    /// - Parameter dataTable: SwiftDataTable
    /// - Returns: whether or not the search should be hidden
    @objc optional func shouldShowSearchSection(in dataTable: SwiftDataTable) -> Bool
    
    /// The height of the section footer. Defaults to 44.
    ///
    /// - Parameter dataTable: SwiftDataTable
    /// - Returns: the height of the section footer
    @objc optional func heightForSectionFooter(in dataTable: SwiftDataTable) -> CGFloat
    
    /// The height of the section header. Defaults to 44.
    ///
    /// - Parameter dataTable: SwiftDataTable
    /// - Returns: the height of the section header
    @objc optional func heightForSectionHeader(in dataTable: SwiftDataTable) -> CGFloat
    
    
    /// The height of the search view. Defaults to 44.
    ///
    /// - Parameter dataTable: SwiftDataTable
    /// - Returns: the height of the search view
    @objc optional func heightForSearchView(in dataTable: SwiftDataTable) -> CGFloat
    
    
    /// Height of the inter row spacing. Defaults to 1.
    ///
    /// - Parameter dataTable: SwiftDataTable
    /// - Returns: the height of the inter row spacing
    @objc optional func heightOfInterRowSpacing(in dataTable: SwiftDataTable) -> CGFloat
    
    
    /// Control the display of the vertical scroll bar. Defaults to true.
    ///
    /// - Parameter dataTable: SwiftDataTable
    /// - Returns: whether or not the vertical scroll bars should be shown.
    @objc optional func shouldShowVerticalScrollBars(in dataTable: SwiftDataTable) -> Bool
    
    /// Control the display of the horizontal scroll bar. Defaults to true.
    ///
    /// - Parameter dataTable: SwiftDataTable
    /// - Returns: whether or not the horizontal scroll bars should be shown.
    @objc optional func shouldShowHorizontalScrollBars(in dataTable: SwiftDataTable) -> Bool
    
    /// Control the background color for cells in rows intersecting with a column that's highlighted.
    ///
    /// - Parameters:
    ///   - dataTable: SwiftDataTable
    ///   - at: the row index to set the background color
    /// - Returns: the background colour to make the highlighted row
    @objc optional func dataTable(_ dataTable: SwiftDataTable, highlightedColorForRowIndex at: Int) -> UIColor
    
    /// Control the background color for an unhighlighted row.
    ///
    /// - Parameters:
    ///   - dataTable: SwiftDataTable
    ///   - at: the row index to set the background color
    /// - Returns: the background colour to make the unhighlighted row
    @objc optional func dataTable(_ dataTable: SwiftDataTable, unhighlightedColorForRowIndex at: Int) -> UIColor
}
```

## Author

Pavan Kataria

## Contributing

1. Create an issue and describe your idea
2. [Fork it] (https://github.com/pavankataria/SwiftDataTables/fork)
3. Create your feature branch (`git checkout -b my-new-feature`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Publish the branch (`git push origin my-new-feature`)
6. Create a new Pull Request
7. Thank you! :white_check_mark:

Who is using it
---------------
Please let me know if your app is using this library. I'd be glad to put your app on the list :-)
* [WeShop for iOS](https://itunes.apple.com/gb/app/weshop-compare-shop-earn/id1045921951?mt=8)  
WeShop - Make shopping on the go a joy with the WeShop App. Compare millions of products from 100s of top retailers and discover which have been recommended by people you trust. WeShop is the most rewarding place to shop; collect points every time you buy AND when you recommend products you love. Redeem them for cash, or donate them to charity - it pays to be social!


## License

SwiftDataTables is available under the MIT license. See the LICENSE file for more info.
This package was inspired by JQuery's DataTables plugin.

## Follow us

[![Twitter URL](https://img.shields.io/twitter/url/http/shields.io.svg?style=social)](https://twitter.com/intent/tweet?text=https://github.com/pavankataria/SwiftDataTables)
[![Twitter Follow](https://img.shields.io/twitter/follow/pavan_kataria.svg?style=social)](https://twitter.com/pavan_kataria)
