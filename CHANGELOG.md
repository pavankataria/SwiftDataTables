# Changelog

All notable changes to SwiftDataTables will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.9.0] - 2026-01-28: Self-Sizing Cells, Auto Layout & Default Cell Configuration

### Summary
This release adds first-class support for **Auto Layout-driven cells** with automatic row heights and text wrapping. Use custom `UICollectionViewCell` subclasses with full constraint-based sizing to build rich, dynamic table layouts.

Also includes: **default cell configuration** for easy styling without custom cells, new column width strategy API, major performance optimizations for large datasets, and bug fixes.

### Column Width Mode API
- Added `DataTableColumnWidthMode` with explicit text-based and Auto Layout-based sizing.
- Added `columnWidthMode` / `columnWidthModeProvider` for per-column overrides.
- `DataTableColumnWidthStrategy` now represents text-only strategies for `.fitContentText`.
- Deterministic sampling remains for repeatable widths across large datasets.
- Clarified header minimum behaviour: header width (incl. sort indicator) is always enforced and can exceed `maxColumnWidth`.
- **Breaking:** removed `columnWidthStrategy` / `columnWidthStrategyProvider` / `useEstimatedColumnWidths` in favour of `columnWidthMode`.

### Row Height + Wrapping
- Added `textLayout` for single-line vs wrapping text.
- Added `rowHeightMode` with automatic sizing (uses estimated height for initial layout).
- Added `cellSizingMode` with Auto Layout-based custom cell sizing (height only).
- **Breaking:** `DataTableCustomCellProvider` now uses dynamic reuse identifiers (`reuseIdentifierFor` / `sizingCellFor`) to align with UICollectionView patterns.

---

### What Was the Problem?

**Large datasets were unusably slow.** A table with 50,000 rows would take over 3 minutes to render on initial load, making the library impractical for anything beyond small datasets.

Two main bottlenecks were identified:

1. **O(n²) Layout Algorithm**: The collection view layout recalculated positions for all cells every time a new cell was added, causing exponential slowdown as row count increased.

2. **Font Measurement for Every Cell**: Column widths were calculated by calling `NSString.size(withAttributes:)` for every single cell value. For 50K rows × 6 columns, that's 300,000 expensive font rendering calculations.

---

### What Changed?

#### 1. O(n) Layout Algorithm (was O(n²))

**Before:**
- Layout used nested loops causing O(n²) complexity
- 50,000 rows took **~232 seconds** (nearly 4 minutes)
- Doubling rows would quadruple render time (2x rows = 4x time)

**After:**
- Single-pass algorithm with pre-computed offsets
- 50,000 rows now take **~1.6 seconds**
- Linear scaling: doubling rows only doubles time (2x rows = 2x time)

**Technical details:**
- Pre-calculate Y-offsets once in O(n)
- Cache column widths and row heights before main loop
- Avoid repeated `heightForRow(index:)` calls

#### 2. Estimated Column Widths (was Font Measurement)

**Before:**
- Every cell value was measured using `NSString.size(withAttributes:)` to calculate column widths
- 50K rows × 6 columns = 300,000+ font rendering calculations
- Font measurement involves Core Text glyph calculations - expensive

**After:**
- Character count estimation: `width = characterCount × 7.0 points`
- Simple integer math instead of font rendering
- Results in visually similar column widths with negligible difference

**What users see:**
- Column widths may differ by a few pixels from font-measured widths
- Overall table appearance remains virtually identical
- Headers and data still align correctly

#### 3. Row Height Caching

**Before:**
- `heightForRow(index:)` was called twice per row during layout preparation
- For 50K rows: 100,000 delegate/computed calls

**After:**
- Row heights calculated once in a single pass
- Stored in array and reused throughout layout

---

### What Users Can Expect

| Scenario | Before v0.9.0 | After v0.9.0 |
|----------|---------------|--------------|
| 1,000 rows | ~2 seconds | Instant (<0.1s) |
| 10,000 rows | ~23 seconds | ~0.25 seconds |
| 50,000 rows | ~232 seconds (4 min) | ~0.25 seconds |
| 100,000 rows | Would timeout/crash | ~0.5 seconds |

**Automatic Benefits:**
- No code changes required - optimizations are enabled by default
- Existing apps will see immediate performance improvement after updating
- Scrolling and interaction remain unchanged

**If You Need Precise Font Widths:**
```swift
var config = DataTableConfiguration()
config.columnWidthMode = .fitContentText(strategy: .maxMeasured) // Use font measurement (slower)
```

---

### Added

- **`DataTableConfiguration.defaultCellConfiguration`** (`DefaultCellConfiguration`)
  - Customise the default `DataCell` appearance without creating custom cell classes
  - Set font, text colour, background colour, alignment, and more per-cell
  - Callback receives `(cell, value, indexPath, isHighlighted)` for conditional styling
  - Perfect for alternating row colours, highlighting negative values, per-column fonts
  - See `DefaultCellConfiguration.md` documentation for examples

- **`DataCell.dataLabel` now public**
  - Access the label directly in `defaultCellConfiguration` to customise font, colour, alignment

- **`DataCell.prepareForReuse()`**
  - Resets label styling on cell reuse to prevent stale styles from persisting

- **`DataTableConfiguration.columnWidthMode`** (`DataTableColumnWidthMode`)
  - Explicitly selects text measurement or Auto Layout measurement for column widths
  - Supports per-column overrides via `columnWidthModeProvider`

- **Simplified closure API for `DataTableColumn`**
  - Closures can now return any `DataTableValueConvertible` type directly
  - No need to wrap values in `.string()`, `.int()`, etc.
  - Before: `.init("Salary") { .string("£\($0.salary)") }`
  - After: `.init("Salary") { "£\($0.salary)" }`
  - Explicit `DataTableValueType` still supported for cases requiring specific sorting behaviour

- **`SwiftDataTableDelegate.dataTable(_:didTapHeaderAt:)`**
  - Notifies when a column header is tapped
  - Called before sorting occurs (if enabled)
  - Use with `isColumnSortable` for custom header tap handling

---

### Deprecated

- **`SwiftDataTableDelegate.dataTable(_:highlightedColorForRowIndex:)`**
  - Use `DataTableConfiguration.defaultCellConfiguration` instead

- **`SwiftDataTableDelegate.dataTable(_:unhighlightedColorForRowIndex:)`**
  - Use `DataTableConfiguration.defaultCellConfiguration` instead

---

### Fixed

- **Header column width calculation bug (unit mismatch)**: When using estimated widths, header titles were compared incorrectly against data widths. "Name" header (4 chars) was compared as `4` against data values measured in points (~35). Now both are in the same unit.

- **Header column width calculation bug (missing arrow space)**: `minimumHeaderColumnWidth` only measured text width, not accounting for sort arrows and padding. Headers like "Name" appeared cramped because the minimum width didn't include the ~30 points needed for sort indicators (separator + image + margin).

- **Redundant String copy**: `DataTableValueType.stringRepresentation` for `.string(let value)` case was returning `String(value)` instead of just `value`, creating an unnecessary copy.

- **Magic numbers in column width calculation**: `SwiftDataTable` hardcoded sort indicator width as `10` (should have been `30`). Now references `DataHeaderFooter.Properties.sortIndicatorWidth` - the actual source of truth. Changed `DataHeaderFooter.Properties` from `private` to `internal` so framework code can share layout constants without duplication.

- **Search bar not hiding when disabled**: Setting `shouldShowSearchSection = false` only set the search bar height to 0 but didn't actually hide it. The search bar would still appear over the column headers. Now properly sets `searchBar.isHidden` based on the configuration.

---

### Performance Benchmarks

**Test Environment:** 50,000 rows × 6 columns on iPhone 15 Pro simulator

| Configuration | Data Gen | Table Layout | Total |
|---------------|----------|--------------|-------|
| O(n²) + Precise Widths | 0.02s | 232s | 232s |
| O(n) + Precise Widths | 0.02s | 1.59s | 1.61s |
| O(n) + Estimated Widths | 0.02s | 0.23s | 0.25s |

**Improvement:** 232s → 0.25s = **928x faster** with all optimizations

---

### Versioning Rationale

**MINOR version bump (0.8.1 → 0.9.0)** because:

- New features: Auto Layout cells, self-sizing rows, text wrapping
- Breaking API changes in column width configuration
- Signals "approaching 1.0" - gather feedback before locking API

---

### Files Modified

| File | Changes |
|------|---------|
| `DataTableConfiguration.swift` | Added `columnWidthMode` / `columnWidthModeProvider` |
| `DataTableColumnWidthStrategy.swift` | Added `DataTableColumnWidthMode` and Auto Layout sampling enum |
| `DataStructureModel.swift` | Strategy-based text width calculation with explicit mode |
| `SwiftDataTable.swift` | Auto Layout width measurement and mode resolver |

---

## [0.8.1] - Previous Release

_Refer to GitHub releases for previous version history._
