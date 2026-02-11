![Swift DataTables](https://user-images.githubusercontent.com/1791244/43036589-70947a6c-8cfc-11e8-9fe8-37abb78317aa.png)

<p align="center">
    <a href="https://github.com/pavankataria/SwiftDataTables/actions/workflows/ci.yml">
        <img src="https://github.com/pavankataria/SwiftDataTables/actions/workflows/ci.yml/badge.svg" alt="CI Status" />
    </a>
    <a href="https://swift.org/package-manager">
        <img src="https://img.shields.io/badge/SPM-compatible-brightgreen.svg?style=flat" alt="SPM Compatible" />
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
    <a href="https://en.wikipedia.org/wiki/MIT_License">
        <img src="https://img.shields.io/badge/License-MIT-brightgreen.svg?style=flat" />
    </a>
</p>

<h3 align="center">The powerful, flexible data table component that iOS deserves.</h3>

<p align="center">
Display grid-like data with sorting, searching, and smooth animations — all in just a few lines of code.
</p>

<p align="center">
<img src="/Example/SwiftDataTables-Preview.gif" width="60%">
</p>

---

## Shape the Roadmap

**[Vote for features](https://swiftdatatables.pavankataria.com/vote)** — your votes decide what gets built next.

**[See the complete documentation →](https://swiftdatatables.pavankataria.com/docs/quick-start)**

---

## Guides & API Reference

**[Explore the docs](https://swiftdatatables.pavankataria.com/docs/quick-start)** — step-by-step tutorials, real-world patterns, and complete API reference. From first table to production-ready.

---

## Features

| Feature | Description |
|---------|-------------|
| **Type-Safe Columns** | Declarative API with key paths and custom transforms |
| **Animated Diffing** | Smooth updates that calculate exactly what changed |
| **Self-Sizing Cells** | Automatic row heights, efficient for 100k+ rows |
| **928x Faster** | 50,000 rows in 0.25s (was 4+ minutes) |
| **Custom Cells** | Full Auto Layout support via cell providers |
| **Fixed Columns** | Freeze columns on left or right sides |
| **Sorting & Search** | Built-in or native navigation bar search |

---

## Quick Start

```swift
import SwiftDataTables

struct Employee: Identifiable {
    let id: String
    let name: String
    let role: String
}

let columns: [DataTableColumn<Employee>] = [
    .init("Name", \.name),
    .init("Role", \.role)
]

let dataTable = SwiftDataTable(columns: columns)
dataTable.setData(employees, animatingDifferences: true)
```

**[See the full documentation →](https://swiftdatatables.pavankataria.com/docs/quick-start)** — step-by-step tutorials, real-world patterns, and complete API reference. From first table to production-ready.

---

## Install

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/pavankataria/SwiftDataTables", from: "0.9.0")
]
```

Or in Xcode: **File → Add Package Dependencies** → `https://github.com/pavankataria/SwiftDataTables`

---

## Demo App

1. Clone the repo
2. Open `SwiftDataTables.xcodeproj`
3. Select the `DemoSwiftDataTables` scheme
4. Build and Run

---

## Support

**[Sponsor on Open Collective](https://opencollective.com/swiftdatatables)**

---

## Author

**Pavan Kataria** — [@pavan_kataria](https://twitter.com/pavan_kataria)

## License

MIT License. See [LICENSE](LICENSE) for details.
