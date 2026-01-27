//
//  SingleRowUpdatesDemoViewController.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 22/02/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import UIKit
import SwiftDataTables

/// Demo proving a single row update only reconfigures that row.
final class SingleRowUpdatesDemoViewController: UIViewController {

    // MARK: - Model

    struct RowItem: DataTableDifferentiable {
        let id: String
        var symbol: String
        var value: Double
        var status: String

        func isContentEqual(to source: RowItem) -> Bool {
            return symbol == source.symbol && value == source.value && status == source.status
        }
    }

    // MARK: - State

    private var dataTable: SwiftDataTable!
    private var rows: [RowItem] = []
    private var updateCount = 0
    private var updateToken = 0
    private var rowConfigureCounts: [String: Int] = [:]
    private var lastConfiguredTokenByRowId: [String: Int] = [:]
    private var lastUpdatedRowId: String?

    // MARK: - UI

    private var controls: ExplanationControls!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Single Row Updates"
        view.backgroundColor = .systemBackground

        controls = makeExplanationControls()
        installExplanation(controls.view)

        setupInitialData()
        setupTable()
    }

    // MARK: - Setup

    private func setupInitialData() {
        let symbols = ["AAPL", "GOOGL", "MSFT", "AMZN", "TSLA", "NVDA", "META", "NFLX"]
        let statuses = ["Stable", "Up", "Down", "Volatile"]
        rows = symbols.enumerated().map { index, symbol in
            RowItem(
                id: "row-\(index)",
                symbol: symbol,
                value: Double.random(in: 50...500),
                status: statuses.randomElement()!
            )
        }
    }

    private func setupTable() {
        var config = DataTableConfiguration()
        config.shouldShowSearchSection = false
        config.textLayout = .singleLine()
        config.rowHeightMode = .automatic(estimated: 44)

        config.cellSizingMode = .autoLayout(provider: DataTableCustomCellProvider(
            register: { collectionView in
                collectionView.register(RowUpdateProofCell.self, forCellWithReuseIdentifier: "RowUpdateProofCell")
            },
            reuseIdentifierFor: { _ in "RowUpdateProofCell" },
            configure: { [weak self] cell, value, indexPath in
                guard let self = self, let proofCell = cell as? RowUpdateProofCell else { return }
                proofCell.valueLabel.text = value.stringRepresentation
                proofCell.countLabel.isHidden = indexPath.item != 1

                guard proofCell.window != nil else {
                    proofCell.countLabel.text = ""
                    return
                }

                guard let rowId = self.rows[safe: indexPath.section]?.id else { return }
                let token = self.updateToken
                if self.lastConfiguredTokenByRowId[rowId] != token {
                    self.lastConfiguredTokenByRowId[rowId] = token
                    let count = (self.rowConfigureCounts[rowId] ?? 0) + 1
                    self.rowConfigureCounts[rowId] = count
                }

                if indexPath.item == 1 {
                    let count = self.rowConfigureCounts[rowId] ?? 0
                    proofCell.countLabel.text = "#\(count)"
                }

                if rowId == self.lastUpdatedRowId {
                    proofCell.showConfigureFlash()
                }
            },
            sizingCellFor: { _ in RowUpdateProofCell() }
        ))

        let columns: [DataTableColumn<RowItem>] = [
            .init("Symbol", \.symbol),
            .init("Value") { .string(String(format: "$%.2f", $0.value)) },
            .init("Status", \.status),
        ]

        let table = SwiftDataTable(data: rows, columns: columns, options: config)
        addDataTable(table, below: controls.view)
        dataTable = table
    }

    // MARK: - Actions

    @objc func animationToggled(_ sender: UISwitch) {
        // No-op, we read the toggle when updating.
    }

    @objc func updateOneRow() {
        guard !rows.isEmpty else { return }

        let index = Int.random(in: 0..<rows.count)
        var row: SingleRowUpdatesDemoViewController.RowItem = rows[index]
        row.value = Double.random(in: 50...500)
        row.status = row.value > 250 ? "Up" : "Down"
        rows[index] = row

        updateCount += 1
        updateToken += 1
        lastUpdatedRowId = row.id
        controls.updateCountLabel.text = "Updates: \(updateCount)"
        controls.logLabel.text = "Updated \(row.symbol)"

        dataTable.setData(rows, animatingDifferences: controls.animateSwitch.isOn)
    }

    @objc func resetCounts() {
        updateCount = 0
        updateToken += 1
        rowConfigureCounts.removeAll()
        lastConfiguredTokenByRowId.removeAll()
        lastUpdatedRowId = nil
        controls.updateCountLabel.text = "Updates: 0"
        controls.logLabel.text = "Counts reset"
        dataTable.setData(rows, animatingDifferences: false)
    }
}

// MARK: - Proof Cell

final class RowUpdateProofCell: UICollectionViewCell {

    let valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textAlignment = .center
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()

    let countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .monospacedDigitSystemFont(ofSize: 9, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = .systemBlue
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        return label
    }()

    private let flashView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.4)
        view.alpha = 0
        view.layer.cornerRadius = 4
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.addSubview(flashView)
        contentView.addSubview(valueLabel)
        contentView.addSubview(countLabel)

        NSLayoutConstraint.activate([
            flashView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 1),
            flashView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 1),
            flashView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -1),
            flashView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -1),

            valueLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            valueLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),

            countLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 4),
            countLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            countLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            countLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 24),
            countLabel.heightAnchor.constraint(equalToConstant: 16),
        ])
    }

    func showConfigureFlash() {
        flashView.alpha = 1
        UIView.animate(withDuration: 0.8, delay: 0.2, options: .curveEaseOut) {
            self.flashView.alpha = 0
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        flashView.alpha = 0
        countLabel.isHidden = false
    }
}

// MARK: - Safe Array Access

private extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
