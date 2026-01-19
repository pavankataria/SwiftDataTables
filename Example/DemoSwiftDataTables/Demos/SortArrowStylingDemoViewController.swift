//
//  SortArrowStylingDemoViewController.swift
//  SwiftDataTables
//
//  Interactive demo for customizing sort arrow appearance.
//

import UIKit
import SwiftDataTables

final class SortArrowStylingDemoViewController: UIViewController {

    // MARK: - Properties

    private var selectedColorIndex: Int = 0

    private let colorOptions: [(name: String, color: UIColor)] = [
        ("Blue (Default)", .systemBlue),
        ("Red", .systemRed),
        ("Green", .systemGreen),
        ("Orange", .systemOrange),
        ("Purple", .systemPurple),
        ("Teal", .systemTeal),
        ("Pink", .systemPink),
        ("Gray", .systemGray)
    ]

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = "Customize the tint color of sort indicator arrows. Tap a column header to sort and see the arrow color."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var colorButtons: [UIButton] = {
        return colorOptions.enumerated().map { index, option in
            let button = UIButton(type: .system)
            button.setTitle(option.name, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
            button.tag = index
            button.addTarget(self, action: #selector(colorButtonTapped(_:)), for: .touchUpInside)
            button.layer.cornerRadius = 8
            button.layer.borderWidth = 1
            button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
            return button
        }
    }()

    private lazy var colorPreview: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return view
    }()

    private lazy var configSummaryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .tertiaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var controlsStack: UIStackView!
    private var dataTable: SwiftDataTable?

    private let headers = ["ID", "Name", "Email", "Number", "City", "Balance"]

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sort Arrow Styling"
        view.backgroundColor = .systemBackground
        setupViews()
        updateButtonAppearance()
        updateUI()
        rebuildTable()
    }

    // MARK: - Setup

    private func setupViews() {
        // Create rows of buttons (4 per row)
        let row1 = UIStackView(arrangedSubviews: Array(colorButtons[0..<4]))
        row1.axis = .horizontal
        row1.spacing = 8
        row1.distribution = .fillEqually

        let row2 = UIStackView(arrangedSubviews: Array(colorButtons[4..<8]))
        row2.axis = .horizontal
        row2.spacing = 8
        row2.distribution = .fillEqually

        let buttonStack = UIStackView(arrangedSubviews: [row1, row2])
        buttonStack.axis = .vertical
        buttonStack.spacing = 8

        let previewRow = UIStackView(arrangedSubviews: [
            makeLabel("Selected color:"),
            colorPreview
        ])
        previewRow.axis = .horizontal
        previewRow.spacing = 8
        previewRow.alignment = .center

        controlsStack = UIStackView(arrangedSubviews: [
            descriptionLabel,
            buttonStack,
            previewRow,
            configSummaryLabel
        ])
        controlsStack.axis = .vertical
        controlsStack.spacing = 12
        controlsStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(controlsStack)

        NSLayoutConstraint.activate([
            controlsStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            controlsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            controlsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            colorPreview.widthAnchor.constraint(equalToConstant: 60),
        ])
    }

    private func makeLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.text = text
        return label
    }

    // MARK: - Actions

    @objc private func colorButtonTapped(_ sender: UIButton) {
        selectedColorIndex = sender.tag
        updateButtonAppearance()
        updateUI()
        rebuildTable()
    }

    // MARK: - UI Updates

    private func updateButtonAppearance() {
        for (index, button) in colorButtons.enumerated() {
            let isSelected = index == selectedColorIndex
            let color = colorOptions[index].color
            button.backgroundColor = isSelected ? color : .clear
            button.setTitleColor(isSelected ? .white : color, for: .normal)
            button.layer.borderColor = color.cgColor
        }
    }

    private func updateUI() {
        let selected = colorOptions[selectedColorIndex]
        colorPreview.backgroundColor = selected.color
        configSummaryLabel.text = "Sort arrow tint: \(selected.name)"
    }

    private func rebuildTable() {
        dataTable?.removeFromSuperview()

        var config = DataTableConfiguration()
        config.sortArrowTintColor = colorOptions[selectedColorIndex].color
        config.defaultOrdering = DataTableColumnOrder(index: 1, order: .ascending)

        let table = SwiftDataTable(
            data: makeData(),
            headerTitles: headers,
            options: config
        )
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        view.addSubview(table)

        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: controlsStack.bottomAnchor, constant: 12),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        dataTable = table
    }

    // MARK: - Data

    private func makeData() -> DataTableContent {
        return exampleDataSet().map { row in
            row.compactMap { DataTableValueType($0) }
        }
    }
}
