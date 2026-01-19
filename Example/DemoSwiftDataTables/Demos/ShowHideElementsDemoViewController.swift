//
//  ShowHideElementsDemoViewController.swift
//  SwiftDataTables
//
//  Interactive demo for showing/hiding table elements.
//

import UIKit
import SwiftDataTables

final class ShowHideElementsDemoViewController: UIViewController {

    // MARK: - Properties

    private var showFooter = true
    private var showSearch = true
    private var showVerticalScrollBar = true
    private var showHorizontalScrollBar = false

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = "Control which elements are visible in the table. Toggle options below and observe the changes."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var footerToggle: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = showFooter
        toggle.addTarget(self, action: #selector(toggleChanged), for: .valueChanged)
        return toggle
    }()

    private lazy var searchToggle: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = showSearch
        toggle.addTarget(self, action: #selector(toggleChanged), for: .valueChanged)
        return toggle
    }()

    private lazy var verticalScrollToggle: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = showVerticalScrollBar
        toggle.addTarget(self, action: #selector(toggleChanged), for: .valueChanged)
        return toggle
    }()

    private lazy var horizontalScrollToggle: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = showHorizontalScrollBar
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
        title = "Show/Hide Elements"
        view.backgroundColor = .systemBackground
        setupViews()
        updateSummary()
        rebuildTable()
    }

    // MARK: - Setup

    private func setupViews() {
        let footerRow = labeledRow(label: "Show Footer", toggle: footerToggle)
        let searchRow = labeledRow(label: "Show Search Bar", toggle: searchToggle)
        let vScrollRow = labeledRow(label: "Vertical Scroll Bar", toggle: verticalScrollToggle)
        let hScrollRow = labeledRow(label: "Horizontal Scroll Bar", toggle: horizontalScrollToggle)

        controlsStack = UIStackView(arrangedSubviews: [
            descriptionLabel,
            footerRow,
            searchRow,
            vScrollRow,
            hScrollRow,
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
        case footerToggle:
            showFooter = sender.isOn
        case searchToggle:
            showSearch = sender.isOn
        case verticalScrollToggle:
            showVerticalScrollBar = sender.isOn
        case horizontalScrollToggle:
            showHorizontalScrollBar = sender.isOn
        default:
            break
        }
        updateSummary()
        rebuildTable()
    }

    // MARK: - UI Updates

    private func updateSummary() {
        var items: [String] = []
        items.append("Footer: \(showFooter ? "visible" : "hidden")")
        items.append("Search: \(showSearch ? "visible" : "hidden")")
        items.append("V-Scroll: \(showVerticalScrollBar ? "visible" : "hidden")")
        items.append("H-Scroll: \(showHorizontalScrollBar ? "visible" : "hidden")")
        configSummaryLabel.text = items.joined(separator: " | ")
    }

    private func rebuildTable() {
        dataTable?.removeFromSuperview()

        var config = DataTableConfiguration()
        config.shouldShowFooter = showFooter
        config.shouldShowSearchSection = showSearch
        config.shouldShowVerticalScrollBars = showVerticalScrollBar
        config.shouldShowHorizontalScrollBars = showHorizontalScrollBar

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
