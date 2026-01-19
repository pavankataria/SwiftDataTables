//
//  RowSelectionDemoViewController.swift
//  SwiftDataTables
//
//  Interactive demo showing row selection callbacks.
//

import UIKit
import SwiftDataTables

final class RowSelectionDemoViewController: UIViewController {

    // MARK: - Properties

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = "Tap rows to see selection callbacks. The delegate receives didSelectItem and didDeselectItem events."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var selectionLogLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 5
        label.text = "Tap a row to see selection events..."
        label.backgroundColor = UIColor.systemGray6
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Clear Log", for: .normal)
        button.addTarget(self, action: #selector(clearLog), for: .touchUpInside)
        return button
    }()

    private var controlsStack: UIStackView!
    private var dataTable: SwiftDataTable?
    private var selectionLog: [String] = []

    private let headers = ["ID", "Name", "Email", "Number", "City", "Balance"]

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Row Selection"
        view.backgroundColor = .systemBackground
        setupViews()
        rebuildTable()
    }

    // MARK: - Setup

    private func setupViews() {
        let logContainer = UIView()
        logContainer.backgroundColor = UIColor.systemGray6
        logContainer.layer.cornerRadius = 8
        logContainer.translatesAutoresizingMaskIntoConstraints = false
        logContainer.addSubview(selectionLogLabel)

        NSLayoutConstraint.activate([
            selectionLogLabel.topAnchor.constraint(equalTo: logContainer.topAnchor, constant: 8),
            selectionLogLabel.leadingAnchor.constraint(equalTo: logContainer.leadingAnchor, constant: 8),
            selectionLogLabel.trailingAnchor.constraint(equalTo: logContainer.trailingAnchor, constant: -8),
            selectionLogLabel.bottomAnchor.constraint(equalTo: logContainer.bottomAnchor, constant: -8),
        ])

        controlsStack = UIStackView(arrangedSubviews: [
            descriptionLabel,
            logContainer,
            clearButton
        ])
        controlsStack.axis = .vertical
        controlsStack.spacing = 12
        controlsStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(controlsStack)

        NSLayoutConstraint.activate([
            controlsStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            controlsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            controlsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            logContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),
        ])
    }

    // MARK: - Actions

    @objc private func clearLog() {
        selectionLog.removeAll()
        updateLogDisplay()
    }

    private func addLogEntry(_ entry: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        selectionLog.insert("[\(timestamp)] \(entry)", at: 0)
        if selectionLog.count > 5 {
            selectionLog.removeLast()
        }
        updateLogDisplay()
    }

    private func updateLogDisplay() {
        if selectionLog.isEmpty {
            selectionLogLabel.text = "Tap a row to see selection events..."
        } else {
            selectionLogLabel.text = selectionLog.joined(separator: "\n")
        }
    }

    private func rebuildTable() {
        dataTable?.removeFromSuperview()

        let config = DataTableConfiguration()

        let table = SwiftDataTable(
            data: makeData(),
            headerTitles: headers,
            options: config
        )
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        table.delegate = self
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

// MARK: - SwiftDataTableDelegate

extension RowSelectionDemoViewController: SwiftDataTableDelegate {
    func didSelectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath) {
        let value = dataTable.data(for: indexPath)
        addLogEntry("Selected row \(indexPath.item): \(value.stringRepresentation)")
    }

    func didDeselectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath) {
        let value = dataTable.data(for: indexPath)
        addLogEntry("Deselected row \(indexPath.item): \(value.stringRepresentation)")
    }
}
