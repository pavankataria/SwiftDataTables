# Custom Cells

Create custom cell layouts using Auto Layout for complete visual control.

## Overview

While SwiftDataTables' default cells handle most cases, you may need custom layouts for:

- Complex multi-element cells
- Images or icons alongside text
- Custom fonts and styling
- Interactive elements

## Setting Up Custom Cells

### Step 1: Create Your Cell Class

```swift
class ProductCell: UICollectionViewCell {
    let nameLabel = UILabel()
    let priceLabel = UILabel()
    let statusIndicator = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        // Add subviews
        contentView.addSubview(nameLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(statusIndicator)

        // Configure labels
        nameLabel.font = .systemFont(ofSize: 14, weight: .medium)
        priceLabel.font = .systemFont(ofSize: 14)
        priceLabel.textColor = .secondaryLabel

        statusIndicator.layer.cornerRadius = 4
        statusIndicator.clipsToBounds = true

        // Auto Layout
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        statusIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            statusIndicator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            statusIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            statusIndicator.widthAnchor.constraint(equalToConstant: 8),
            statusIndicator.heightAnchor.constraint(equalToConstant: 8),

            nameLabel.leadingAnchor.constraint(equalTo: statusIndicator.trailingAnchor, constant: 8),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -8),

            priceLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            priceLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -8),
            priceLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    func configure(name: String, price: String, isActive: Bool) {
        nameLabel.text = name
        priceLabel.text = price
        statusIndicator.backgroundColor = isActive ? .systemGreen : .systemRed
    }
}
```

### Step 2: Create a Custom Cell Provider

```swift
let provider = DataTableCustomCellProvider(
    register: { collectionView in
        collectionView.register(ProductCell.self, forCellWithReuseIdentifier: "product")
    },
    reuseIdentifierFor: { indexPath in
        return "product"
    },
    configure: { cell, value, indexPath in
        guard let productCell = cell as? ProductCell else { return }
        // Parse the value and configure
        let text = value.stringRepresentation
        // Your configuration logic
        productCell.configure(name: text, price: "$99", isActive: true)
    },
    sizingCellFor: { reuseIdentifier in
        return ProductCell()  // Off-screen cell for measurement
    }
)
```

### Step 3: Configure the Table

```swift
var config = DataTableConfiguration()
config.cellSizingMode = .autoLayout(provider: provider)
config.rowHeightMode = .automatic(estimated: 60)

let dataTable = SwiftDataTable(columns: columns, options: config)
```

## How Auto Layout Sizing Works

1. **Column widths** are fixed (from `columnWidthMode`)
2. **Row heights** are calculated via `systemLayoutSizeFitting`
3. Your cell's constraints determine the height

### Important Constraints

Your cell must have:
- Constraints from top to bottom of `contentView`
- A clear vertical chain of elements
- `bottomAnchor` constrained (either directly or via content hugging)

```swift
// Good - vertical chain is complete
nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8)
priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2)
priceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)

// Bad - no bottom constraint
nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8)
// Height can't be calculated!
```

## Different Cells for Different Columns

Use `reuseIdentifierFor` to return different cells:

```swift
let provider = DataTableCustomCellProvider(
    register: { collectionView in
        collectionView.register(TextCell.self, forCellWithReuseIdentifier: "text")
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "image")
        collectionView.register(ActionCell.self, forCellWithReuseIdentifier: "action")
    },
    reuseIdentifierFor: { indexPath in
        switch indexPath.section {  // Column index
        case 0: return "image"
        case 4: return "action"
        default: return "text"
        }
    },
    configure: { cell, value, indexPath in
        switch indexPath.section {
        case 0:
            (cell as? ImageCell)?.setImage(named: value.stringRepresentation)
        case 4:
            (cell as? ActionCell)?.setAction(for: indexPath.row)
        default:
            (cell as? TextCell)?.setText(value.stringRepresentation)
        }
    },
    sizingCellFor: { reuseIdentifier in
        switch reuseIdentifier {
        case "image": return ImageCell()
        case "action": return ActionCell()
        default: return TextCell()
        }
    }
)
```

## Performance Tips

### 1. Reuse Sizing Cells

The `sizingCellFor` closure is called once per reuse identifier. The returned cell is cached and reused for measurements.

### 2. Avoid Complex Layouts

Keep cell layouts simple. Deep view hierarchies slow down measurement.

### 3. Use Fixed Heights When Possible

If all custom cells have the same height:

```swift
config.cellSizingMode = .autoLayout(provider: provider)
config.rowHeightMode = .fixed(60)  // Skip measurement
```

### 4. Profile with Instruments

Use the Time Profiler to identify slow `layoutSubviews` or constraint solving.

## Example: Status Badge Cell

```swift
class StatusCell: UICollectionViewCell {
    private let label = UILabel()
    private let badge = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(label)
        contentView.addSubview(badge)

        label.font = .systemFont(ofSize: 13)
        badge.font = .systemFont(ofSize: 11, weight: .medium)
        badge.textColor = .white
        badge.textAlignment = .center
        badge.layer.cornerRadius = 4
        badge.clipsToBounds = true

        label.translatesAutoresizingMaskIntoConstraints = false
        badge.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            badge.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 8),
            badge.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            badge.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -8),
            badge.heightAnchor.constraint(equalToConstant: 18),
            badge.widthAnchor.constraint(greaterThanOrEqualToConstant: 40)
        ])
    }

    func configure(text: String, status: Status) {
        label.text = text
        badge.text = status.rawValue
        badge.backgroundColor = status.color
    }

    enum Status: String {
        case active = "Active"
        case pending = "Pending"
        case inactive = "Inactive"

        var color: UIColor {
            switch self {
            case .active: return .systemGreen
            case .pending: return .systemOrange
            case .inactive: return .systemGray
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}
```

## See Also

- <doc:RowHeights>
- <doc:ColumnWidths>
- ``DataTableCustomCellProvider``
