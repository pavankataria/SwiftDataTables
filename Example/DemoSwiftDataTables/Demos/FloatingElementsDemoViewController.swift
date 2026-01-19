//
//  FloatingElementsDemoViewController.swift
//  SwiftDataTables
//
//  Interactive demo for floating vs scrolling headers/footers.
//

import UIKit
import SwiftDataTables

final class FloatingElementsDemoViewController: UIViewController {

    // MARK: - Properties

    private var floatHeaders = true
    private var floatFooters = true
    private var floatSearch = false

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = "Control whether headers and footers float (stay visible) or scroll with content. Scroll the table to see the difference."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var headersFloatToggle: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = floatHeaders
        toggle.addTarget(self, action: #selector(toggleChanged), for: .valueChanged)
        return toggle
    }()

    private lazy var footersFloatToggle: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = floatFooters
        toggle.addTarget(self, action: #selector(toggleChanged), for: .valueChanged)
        return toggle
    }()

    private lazy var searchFloatToggle: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = floatSearch
        toggle.addTarget(self, action: #selector(toggleChanged), for: .valueChanged)
        return toggle
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
        title = "Floating Elements"
        view.backgroundColor = .systemBackground
        setupViews()
        updateSummary()
        rebuildTable()
    }

    // MARK: - Setup

    private func setupViews() {
        let headersRow = labeledRow(label: "Headers Float", toggle: headersFloatToggle)
        let footersRow = labeledRow(label: "Footers Float", toggle: footersFloatToggle)
        let searchRow = labeledRow(label: "Search Float", toggle: searchFloatToggle)

        controlsStack = UIStackView(arrangedSubviews: [
            descriptionLabel,
            headersRow,
            footersRow,
            searchRow,
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
        ])
    }

    private func labeledRow(label: String, toggle: UISwitch) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.text = label

        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [titleLabel, spacer, toggle])
        row.axis = .horizontal
        row.spacing = 8
        row.alignment = .center
        return row
    }

    // MARK: - Actions

    @objc private func toggleChanged(_ sender: UISwitch) {
        switch sender {
        case headersFloatToggle:
            floatHeaders = sender.isOn
        case footersFloatToggle:
            floatFooters = sender.isOn
        case searchFloatToggle:
            floatSearch = sender.isOn
        default:
            break
        }
        updateSummary()
        rebuildTable()
    }

    // MARK: - UI Updates

    private func updateSummary() {
        var items: [String] = []
        items.append("Headers: \(floatHeaders ? "float" : "scroll")")
        items.append("Footers: \(floatFooters ? "float" : "scroll")")
        items.append("Search: \(floatSearch ? "float" : "scroll")")
        configSummaryLabel.text = items.joined(separator: " | ")
    }

    private func rebuildTable() {
        dataTable?.removeFromSuperview()

        var config = DataTableConfiguration()
        config.shouldSectionHeadersFloat = floatHeaders
        config.shouldSectionFootersFloat = floatFooters
        config.shouldSearchHeaderFloat = floatSearch

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
        // Use more data to make scrolling more obvious
        var data: [[Any]] = []
        for _ in 0..<3 {
            data.append(contentsOf: exampleDataSet())
        }
        return data.map { row in
            row.compactMap { DataTableValueType($0) }
        }
    }
}
