//
//  AutoLayoutStressTestDemoViewController.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 22/02/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import UIKit
import SwiftDataTables

/// Stress test demo showing dynamic row height changes with AutoLayout.
/// Cells randomly change their text content, causing height recalculations.
/// Showcases smooth incremental updates without full table reloads.
final class AutoLayoutStressTestDemoViewController: UIViewController {

    // MARK: - Model

    struct DynamicItem: Identifiable {
        let id: String
        var title: String
        var content: String
        var fontSize: CGFloat
        var lineCount: Int // Simulated line count for varying heights

        var displayContent: String {
            // Generate content that will wrap based on lineCount
            let base = content
            if lineCount <= 1 {
                return String(base.prefix(30))
            }
            return (0..<lineCount).map { _ in base }.joined(separator: " ")
        }
    }

    // MARK: - Content Variations

    private let contentVariations = [
        "Quick update.",
        "This is a medium-length piece of text that will span multiple lines when displayed.",
        "Short note here.",
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation.",
        "Alert!",
        "This content dynamically changes to demonstrate how SwiftDataTables handles row height updates smoothly without jarring jumps or full reloads. The incremental update system measures only changed rows.",
        "Status: OK",
        "Important notification that requires attention and spans several lines to ensure the row height adjusts accordingly to fit all the content properly.",
    ]

    private let fontSizes: [CGFloat] = [11, 13, 15, 17, 20, 24]

    // MARK: - State

    private var dataTable: SwiftDataTable!
    private var items: [DynamicItem] = []
    private var updateTimer: Timer?
    private var updateCount = 0
    private var controls: ExplanationControls!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "AutoLayout Stress Test"
        view.backgroundColor = .systemBackground

        controls = makeExplanationControls()
        installExplanation(controls.view)

        setupInitialData()
        setupTable()
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
        items = (0..<20).map { index in
            DynamicItem(
                id: "item-\(index)",
                title: "Item \(index + 1)",
                content: contentVariations[index % contentVariations.count],
                fontSize: 14,
                lineCount: (index % 4) + 1
            )
        }
    }

    private func setupTable() {
        var config = DataTableConfiguration()
        config.shouldShowSearchSection = false
        config.textLayout = .wrap
        config.rowHeightMode = .automatic(estimated: 60)

        // Custom cells with dynamic font sizes
        config.cellSizingMode = .autoLayout(provider: DataTableCustomCellProvider(
            register: { collectionView in
                collectionView.register(DynamicHeightCell.self, forCellWithReuseIdentifier: "DynamicCell")
            },
            reuseIdentifierFor: { _ in "DynamicCell" },
            configure: { [weak self] cell, value, indexPath in
                guard let self = self,
                      let dynamicCell = cell as? DynamicHeightCell,
                      indexPath.section < self.items.count else { return }

                let item = self.items[indexPath.section]
                dynamicCell.contentLabel.text = value.stringRepresentation

                // Apply dynamic font size for content column
                if indexPath.item == 1 {
                    dynamicCell.contentLabel.font = .systemFont(ofSize: item.fontSize)
                    dynamicCell.contentLabel.numberOfLines = 0
                } else {
                    dynamicCell.contentLabel.font = .systemFont(ofSize: 14, weight: .medium)
                    dynamicCell.contentLabel.numberOfLines = 1
                }
            },
            sizingCellFor: { _ in DynamicHeightCell() }
        ))

        let columns: [DataTableColumn<DynamicItem>] = [
            .init("Title", \.title),
            .init("Content", \.displayContent),
        ]

        let table = SwiftDataTable(data: items, columns: columns, options: config)
        table.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(table)

        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: controls.view.bottomAnchor, constant: 12),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        dataTable = table
        updateRowCountLabel()
    }

    // MARK: - Timer Control

    private func startTimer() {
        guard controls.autoUpdateSwitch.isOn else { return }
        let interval = Double(controls.speedSlider.value)
        updateTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.performRandomUpdate()
        }
    }

    private func stopTimer() {
        updateTimer?.invalidate()
        updateTimer = nil
    }

    private func restartTimer() {
        stopTimer()
        startTimer()
    }

    // MARK: - Actions

    @objc func autoUpdateToggled(_ sender: UISwitch) {
        if sender.isOn {
            startTimer()
            log("Auto-update started")
        } else {
            stopTimer()
            log("Auto-update paused")
        }
    }

    @objc func speedChanged(_ sender: UISlider) {
        controls.speedValueLabel.text = String(format: "%.1fs", sender.value)
        if controls.autoUpdateSwitch.isOn {
            restartTimer()
        }
    }

    @objc func manualUpdate() {
        performRandomUpdate()
    }

    @objc func burstUpdate() {
        // Perform 5 rapid updates
        for i in 0..<5 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) { [weak self] in
                self?.performRandomUpdate()
            }
        }
        log("Burst: 5 rapid updates")
    }

    @objc func updateAllRows() {
        // Change every row's content
        for i in 0..<items.count {
            items[i].content = contentVariations.randomElement()!
            items[i].fontSize = fontSizes.randomElement()!
            items[i].lineCount = Int.random(in: 1...5)
        }
        updateCount += items.count
        controls.updateCountLabel.text = "Updates: \(updateCount)"

        if controls.animateSwitch.isOn {
            dataTable.setData(items, animatingDifferences: true)
        } else {
            UIView.performWithoutAnimation {
                dataTable.setData(items, animatingDifferences: true)
            }
        }
        log("Updated all \(items.count) rows")
    }

    @objc func animationToggled(_ sender: UISwitch) {
        log(sender.isOn ? "Animations ON" : "Animations OFF")
    }

    // MARK: - Updates

    private func performRandomUpdate() {
        guard !items.isEmpty else { return }

        // Randomly choose update type
        let updateType = Int.random(in: 0...10)

        switch updateType {
        case 0...5: // Most common: change content
            let index = Int.random(in: 0..<items.count)
            items[index].content = contentVariations.randomElement()!
            items[index].lineCount = Int.random(in: 1...5)
            log("Row \(index): content changed")

        case 6...7: // Change font size
            let index = Int.random(in: 0..<items.count)
            items[index].fontSize = fontSizes.randomElement()!
            log("Row \(index): font → \(Int(items[index].fontSize))pt")

        case 8: // Change multiple rows
            let count = min(3, items.count)
            let indices = (0..<items.count).shuffled().prefix(count)
            for i in indices {
                items[i].content = contentVariations.randomElement()!
                items[i].lineCount = Int.random(in: 1...4)
            }
            log("Updated \(count) rows")

        case 9: // Extreme: very long content
            let index = Int.random(in: 0..<items.count)
            items[index].content = String(repeating: "Long content that wraps. ", count: 10)
            items[index].lineCount = 8
            log("Row \(index): extreme content")

        default: // Shrink content
            let index = Int.random(in: 0..<items.count)
            items[index].content = "Shrunk."
            items[index].lineCount = 1
            log("Row \(index): shrunk")
        }

        updateCount += 1
        controls.updateCountLabel.text = "Updates: \(updateCount)"

        if controls.animateSwitch.isOn {
            dataTable.setData(items, animatingDifferences: true)
        } else {
            UIView.performWithoutAnimation {
                dataTable.setData(items, animatingDifferences: true)
            }
        }
    }

    private func updateRowCountLabel() {
        controls.rowCountLabel.text = "Rows: \(items.count)"
    }

    private func log(_ message: String) {
        controls.logLabel.text = message
    }
}

// MARK: - Dynamic Height Cell

final class DynamicHeightCell: UICollectionViewCell {

    let contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.addSubview(contentLabel)
        NSLayoutConstraint.activate([
            contentLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            contentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            contentLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        contentLabel.text = nil
        contentLabel.font = .systemFont(ofSize: 14)
        contentLabel.numberOfLines = 0
    }
}
