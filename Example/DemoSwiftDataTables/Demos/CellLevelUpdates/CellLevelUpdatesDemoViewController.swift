//
//  CellLevelUpdatesDemoViewController.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 22/02/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import UIKit
import SwiftDataTables

/// Demo proving that only changed cells are updated, not the entire table.
/// Each cell shows a "configure count" - only updated cells see their count increase.
/// Uses a timer to update random cell values every 3 seconds.
final class CellLevelUpdatesDemoViewController: UIViewController {

    // MARK: - Model

    struct StockItem: Identifiable {
        let id: String
        var symbol: String
        var price: Double
        var change: Double
        var status: String

        var changePercent: String {
            let sign = change >= 0 ? "+" : ""
            return "\(sign)\(String(format: "%.2f", change))%"
        }
    }

    // Variable-length status messages to demonstrate row resizing
    private let statusMessages = [
        "OK",
        "Trading",
        "High volume",
        "Breaking: Earnings beat expectations significantly",
        "Alert: Price target raised by analysts",
        "News: Major partnership announced",
        "Halted",
        "Pre-market",
        "After hours: Unusual volume detected",
    ]

    // MARK: - State

    private var dataTable: SwiftDataTable!
    private var stocks: [StockItem] = []
    private var updateTimer: Timer?
    private var updateCount = 0

    /// Tracks how many times each cell has been configured.
    /// Key: "row-column", Value: configure count
    /// This PROVES that only changed cells are reconfigured.
    private var cellConfigureCounts: [String: Int] = [:]
    /// Tracks last displayed value per cell to avoid double-counting reconfigures.
    private var lastCellValues: [String: String] = [:]

    // MARK: - UI

    private var controls: ExplanationControls!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Cell-Level Updates"
        view.backgroundColor = .systemBackground

        controls = makeExplanationControls()
        installExplanation(controls.view)

        setupInitialData()
        setupTable()
        startTimer()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTimer()
    }

    deinit {
        stopTimer()
    }

    // MARK: - Setup

    private func setupInitialData() {
        stocks = [
            StockItem(id: "AAPL", symbol: "AAPL", price: 178.52, change: 1.23, status: "Trading"),
            StockItem(id: "GOOGL", symbol: "GOOGL", price: 141.80, change: -0.45, status: "OK"),
            StockItem(id: "MSFT", symbol: "MSFT", price: 378.91, change: 2.10, status: "High volume"),
            StockItem(id: "AMZN", symbol: "AMZN", price: 178.25, change: -1.05, status: "Trading"),
            StockItem(id: "TSLA", symbol: "TSLA", price: 248.50, change: 3.50, status: "Breaking: Earnings beat expectations significantly"),
            StockItem(id: "NVDA", symbol: "NVDA", price: 875.28, change: 5.20, status: "OK"),
        ]
    }

    private func setupTable() {
        var config = DataTableConfiguration()
        config.shouldShowSearchSection = false
        config.textLayout = .wrap
        config.rowHeightMode = .automatic(estimated: 50)

        // Use custom cells that show configure count
        config.cellSizingMode = .autoLayout(provider: DataTableCustomCellProvider(
            register: { collectionView in
                collectionView.register(ProofCell.self, forCellWithReuseIdentifier: "Cell")
            },
            reuseIdentifierFor: { _ in "Cell" },
            configure: { [weak self] cell, value, indexPath in
                guard let self = self, let proofCell = cell as? ProofCell else { return }

                // Always set content (needed for sizing)
                proofCell.valueLabel.text = value.stringRepresentation

                // Style based on column
                switch indexPath.item {
                case 0: // Symbol
                    proofCell.valueLabel.font = .systemFont(ofSize: 13, weight: .bold)
                    proofCell.valueLabel.numberOfLines = 1
                case 2: // Change
                    let changeValue = self.stocks[safe: indexPath.section]?.change ?? 0
                    proofCell.valueLabel.textColor = changeValue >= 0 ? .systemGreen : .systemRed
                    proofCell.valueLabel.font = .systemFont(ofSize: 13, weight: .semibold)
                    proofCell.valueLabel.numberOfLines = 1
                case 3: // Status - allow wrapping
                    proofCell.valueLabel.font = .systemFont(ofSize: 11, weight: .regular)
                    proofCell.valueLabel.textColor = .secondaryLabel
                    proofCell.valueLabel.numberOfLines = 0
                default:
                    proofCell.valueLabel.font = .systemFont(ofSize: 13, weight: .regular)
                    proofCell.valueLabel.textColor = .label
                    proofCell.valueLabel.numberOfLines = 1
                }

                // Only count and flash for actual display cells (not sizing cells)
                // Sizing cells have no window
                guard proofCell.window != nil else {
                    proofCell.countLabel.text = ""
                    return
                }

                // Increment and show configure count for this cell
                let cellKey = "\(indexPath.section)-\(indexPath.item)"
                let currentValue = value.stringRepresentation
                if self.lastCellValues[cellKey] != currentValue {
                    self.lastCellValues[cellKey] = currentValue
                    let count = (self.cellConfigureCounts[cellKey] ?? 0) + 1
                    self.cellConfigureCounts[cellKey] = count
                    proofCell.countLabel.text = "#\(count)"
                }

                // Flash highlight to show this cell was just configured
                proofCell.showConfigureFlash()
            },
            sizingCellFor: { _ in ProofCell() }
        ))

        let columns: [DataTableColumn<StockItem>] = [
            .init("Symbol", \.symbol),
            .init("Price") { .string(String(format: "$%.2f", $0.price)) },
            .init("Change") { .string($0.changePercent) },
            .init("Status", \.status),
        ]

        let table = SwiftDataTable(data: stocks, columns: columns, options: config)
        table.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(table)

        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: controls.view.bottomAnchor, constant: 12),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        dataTable = table
    }

    // MARK: - Timer

    private func startTimer() {
        guard controls.autoUpdateSwitch.isOn else { return }
        updateTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.performRandomUpdate()
        }
    }

    private func stopTimer() {
        updateTimer?.invalidate()
        updateTimer = nil
    }

    @objc func autoUpdateToggled(_ sender: UISwitch) {
        if sender.isOn {
            startTimer()
            log("Auto-update enabled")
        } else {
            stopTimer()
            log("Auto-update paused")
        }
    }

    @objc func animationToggled(_ sender: UISwitch) {
        log(sender.isOn ? "Animations enabled" : "Animations disabled")
    }

    // MARK: - Updates

    private func performRandomUpdate() {
        guard !stocks.isEmpty else { return }

        let index = Int.random(in: 0..<stocks.count)
        var stock = stocks[index]

        // Randomly update one field
        let updateType = Int.random(in: 0...3)

        switch updateType {
        case 0: // Update price
            let delta = Double.random(in: -5...5)
            stock.price = max(1, stock.price + delta)
            log("\(stock.symbol) price -> $\(String(format: "%.2f", stock.price))")

        case 1: // Update change
            stock.change = Double.random(in: -5...5)
            log("\(stock.symbol) change -> \(stock.changePercent)")

        case 2, 3: // Update status (more likely)
            stock.status = statusMessages.randomElement()!
            let preview = stock.status.prefix(20)
            log("\(stock.symbol) status -> \(preview)...")

        default:
            break
        }

        stocks[index] = stock
        updateCount += 1
        controls.updateCountLabel.text = "Updates: \(updateCount)"

        // Only the changed cell(s) will have their configure count increase
        if controls.animateSwitch.isOn {
            dataTable.setData(stocks, animatingDifferences: true)
        } else {
            UIView.performWithoutAnimation {
                dataTable.setData(stocks, animatingDifferences: true)
            }
        }
    }

    @objc func manualUpdate() {
        performRandomUpdate()
    }

    @objc func resetCounts() {
        cellConfigureCounts.removeAll()
        lastCellValues.removeAll()
        // Remove old table before creating new one
        dataTable?.removeFromSuperview()
        // Force full reconfigure by recreating table
        setupTable()
        log("Reset all configure counts")
    }

    // MARK: - Helpers

    private func log(_ message: String) {
        controls.logLabel.text = message
    }
}

// MARK: - Proof Cell

/// A cell that displays both the value AND a configure count.
/// The count proves that only changed cells are reconfigured.
final class ProofCell: UICollectionViewCell {

    let valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13)
        label.textAlignment = .center
        label.numberOfLines = 0
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
        view.backgroundColor = .systemYellow.withAlphaComponent(0.6)
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
            valueLabel.bottomAnchor.constraint(equalTo: countLabel.topAnchor, constant: -2),

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
        valueLabel.textColor = .label
        valueLabel.font = .systemFont(ofSize: 13)
        valueLabel.numberOfLines = 1
        countLabel.backgroundColor = .systemBlue
    }
}

// MARK: - Safe Array Access

private extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
