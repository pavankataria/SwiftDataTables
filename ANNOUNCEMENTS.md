# Release Announcement Draft

## Column Width Modes + Performance Improvements
SwiftDataTables now offers an explicit column width mode API (text measurement or Auto Layout), plus major layout performance gains for large datasets.

### Highlights
- New `DataTableColumnWidthMode` with explicit sizing paths: `.fitContentText`, `.fitContentAutoLayout`, `.fixed`.
- New `DataTableConfiguration` options: `columnWidthMode`, `minColumnWidth`, `maxColumnWidth`, and `columnWidthModeProvider` (per-column overrides).
- `DataTableColumnWidthStrategy` remains as the text strategy set when using `.fitContentText`.
- New row height/wrapping API: `textLayout`, `rowHeightMode`, and `cellSizingMode` for Auto Layout custom cells (height only).
- Custom cell provider now uses dynamic reuse identifiers (`reuseIdentifierFor` / `sizingCellFor`) to match UICollectionView patterns.
- Deterministic sampling for stable widths across reloads.
- Header minimum is always enforced (header can exceed `maxColumnWidth`).
- Layout preparation optimized from O(n²) to O(n) with cached row heights.

### Example
```swift
var config = DataTableConfiguration()
config.columnWidthMode = .fitContentText(strategy: .hybrid(sampleSize: 200, averageCharWidth: 7))
config.minColumnWidth = 44
config.maxColumnWidth = 280
config.columnWidthModeProvider = { index in
    if index == 0 { return .fixed(width: 60) }
    return nil
}
```

### Breaking Change
- Replaced `columnWidthStrategy` / `columnWidthStrategyProvider` with `columnWidthMode` / `columnWidthModeProvider`.
- Removed `useEstimatedColumnWidths` (use `.fitContentText(strategy: .maxMeasured)` for full measurement).

### Developer-Facing Updates
- CI migrated to GitHub Actions with updated simulator targets and added unit tests.
- Swift concurrency updates and strict concurrency fixes.
- Project modernized with iOS 17+ minimum target.
