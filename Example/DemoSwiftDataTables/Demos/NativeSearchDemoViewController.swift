//
//  NativeSearchDemoViewController.swift
//  SwiftDataTables
//
//  Interactive demo for search bar positioning options.
//

import UIKit
import SwiftDataTables

final class NativeSearchDemoViewController: UIViewController {

    // MARK: - Properties

    private enum SearchPosition: Int, CaseIterable {
        case embedded = 0
        case navigationBar = 1

        var title: String {
            switch self {
            case .embedded: return "Embedded"
            case .navigationBar: return "Navigation Bar"
            }
        }

        var description: String {
            switch self {
            case .embedded:
                return "Search bar is built into the table header"
            case .navigationBar:
                return "Search bar uses UISearchController in nav bar"
            }
        }
    }

    private var selectedPosition: SearchPosition = .embedded

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = "Choose where the search bar appears. Embedded places it inside the table. Navigation Bar uses iOS's native UISearchController."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var positionSegment: UISegmentedControl = {
        let items = SearchPosition.allCases.map { $0.title }
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = selectedPosition.rawValue
        control.addTarget(self, action: #selector(positionChanged), for: .valueChanged)
        return control
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
        title = "Search Bar Position"
        view.backgroundColor = .systemBackground
        setupViews()
        updateSummary()
        rebuildTable()
    }

    // MARK: - Setup

    private func setupViews() {
        let positionRow = labeledRow(label: "Position", control: positionSegment)

        controlsStack = UIStackView(arrangedSubviews: [
            descriptionLabel,
            positionRow,
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

    private func labeledRow(label: String, control: UIView) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.text = label

        let row = UIStackView(arrangedSubviews: [titleLabel, control])
        row.axis = .horizontal
        row.spacing = 12
        row.alignment = .center
        row.distribution = .fill
        control.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return row
    }

    // MARK: - Actions

    @objc private func positionChanged(_ sender: UISegmentedControl) {
        guard let newPosition = SearchPosition(rawValue: sender.selectedSegmentIndex) else { return }
        selectedPosition = newPosition
        updateSummary()
        rebuildTable()
    }

    // MARK: - UI Updates

    private func updateSummary() {
        configSummaryLabel.text = "Mode: \(selectedPosition.title) — \(selectedPosition.description)"
    }

    private func rebuildTable() {
        // Clean up previous state
        dataTable?.removeFromSuperview()
        navigationItem.searchController = nil

        var config = DataTableConfiguration()

        switch selectedPosition {
        case .embedded:
            config.shouldShowSearchSection = true
        case .navigationBar:
            config.shouldShowSearchSection = false
        }

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

        // Install navigation bar search if that mode is selected
        if selectedPosition == .navigationBar {
            table.installSearchController(on: self)
        }

        dataTable = table
    }

    // MARK: - Data

    private func makeData() -> DataTableContent {
        // Use more data to make scrolling/searching useful
        var data: [[Any]] = []
        for _ in 0..<3 {
            data.append(contentsOf: exampleDataSet())
        }
        return data.map { row in
            row.compactMap { DataTableValueType($0) }
        }
    }
}
