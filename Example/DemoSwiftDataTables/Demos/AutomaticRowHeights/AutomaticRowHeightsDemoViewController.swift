//
//  AutomaticRowHeightsDemoViewController.swift
//  DemoSwiftDataTables
//
//  Demonstrates automatic row heights with lazy measurement for 100k+ rows.
//  Uses estimated heights and measures rows on-demand as they scroll into view.
//

import UIKit
import SwiftDataTables

/// Demo showcasing automatic row heights with lazy measurement.
/// Load 100k rows instantly using estimated heights, then measure on scroll.
final class AutomaticRowHeightsDemoViewController: UIViewController {

    // MARK: - State

    private var dataTable: SwiftDataTable!
    private var tableData: DataTableContent = []
    private let headers = ["#", "Name", "Description", "Value"]

    private var currentRowCount = 10_000
    private var initTime: TimeInterval = 0

    // MARK: - UI

    private var controls: ExplanationControls!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Automatic Row Heights"
        view.backgroundColor = .systemBackground

        controls = makeExplanationControls()
        installExplanation(controls.view)

        rebuildTable()
    }

    // MARK: - Setup

    private func rebuildTable() {
        dataTable?.removeFromSuperview()

        // Generate data
        let startGen = CFAbsoluteTimeGetCurrent()
        tableData = generateData(count: currentRowCount)
        let genTime = CFAbsoluteTimeGetCurrent() - startGen

        // Create table
        var config = DataTableConfiguration()
        config.shouldShowSearchSection = false

        // Toggle between fixed heights (fast but uniform) and automatic (lazy measurement)
        if controls.automaticHeightsSwitch.isOn {
            // Automatic mode: lazy measurement with scroll anchoring
            // Efficient for any dataset size - measures only visible rows
            config.rowHeightMode = .automatic(estimated: 44, prefetchWindow: 20)
            config.textLayout = .wrap  // Enable wrapping so heights actually vary
            config.maxColumnWidth = 150  // Narrow columns to force wrapping
        } else {
            // Fixed mode: uniform height, no measurement needed
            config.rowHeightMode = .fixed(44)
        }

        let startInit = CFAbsoluteTimeGetCurrent()
        let table = SwiftDataTable(data: tableData, headerTitles: headers, options: config)
        initTime = CFAbsoluteTimeGetCurrent() - startInit

        table.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(table)

        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: controls.view.bottomAnchor, constant: 12),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        dataTable = table

        let mode = controls.automaticHeightsSwitch.isOn ? "Automatic" : "Fixed"
        log("[\(mode)] Gen: \(String(format: "%.0f", genTime * 1000))ms, Init: \(String(format: "%.0f", initTime * 1000))ms")
        updateTimingLabel()
    }

    // MARK: - Actions

    @objc func rowCountChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: currentRowCount = 1_000
        case 1: currentRowCount = 10_000
        case 2: currentRowCount = 50_000
        case 3: currentRowCount = 100_000
        default: break
        }
        controls.rowCountLabel.text = formatRowCount(currentRowCount)
        rebuildTable()
    }

    @objc func modeToggleChanged(_ sender: UISwitch) {
        rebuildTable()
    }

    @objc func scrollToBottom() {
        let collectionView = dataTable.collectionView
        let bottomY = collectionView.contentSize.height - collectionView.bounds.height
        collectionView.setContentOffset(CGPoint(x: 0, y: max(0, bottomY)), animated: true)
        log("Scrolling to bottom...")
    }

    @objc func scrollToTop() {
        let collectionView = dataTable.collectionView
        collectionView.setContentOffset(.zero, animated: true)
        log("Scrolling to top...")
    }

    @objc func scrollToRandom() {
        let collectionView = dataTable.collectionView
        let maxY = collectionView.contentSize.height - collectionView.bounds.height
        let randomY = CGFloat.random(in: 0...max(0, maxY))
        collectionView.setContentOffset(CGPoint(x: 0, y: randomY), animated: true)
        let approxRow = Int(randomY / 44)
        log("Scrolling to ~row \(approxRow)...")
    }

    // MARK: - Data Generation

    private func generateData(count: Int) -> DataTableContent {
        let names = ["Alpha", "Beta", "Gamma", "Delta", "Epsilon", "Zeta", "Eta", "Theta", "Iota", "Kappa"]
        let descriptions = [
            "OK",
            "Short text",
            "A medium description that spans a couple of lines when wrapped properly",
            "This is a longer description that will definitely wrap to multiple lines and create taller row heights to demonstrate the variable height measurement system working correctly",
            "Brief note",
            "Another longer piece of text that should wrap nicely and show how automatic height measurement calculates different heights for different content lengths in the data table",
        ]

        return (0..<count).map { i in
            [
                .int(i + 1),
                .string(names[i % names.count]),
                .string(descriptions[i % descriptions.count]),
                .int(Int.random(in: 100...9999))
            ]
        }
    }

    // MARK: - Helpers

    private func formatRowCount(_ count: Int) -> String {
        if count >= 1000 {
            return "\(count / 1000)k rows"
        }
        return "\(count) rows"
    }

    private func updateTimingLabel() {
        let initMs = String(format: "%.0f", initTime * 1000)
        controls.timingLabel.text = "Init: \(initMs)ms"

        // Color code based on performance
        if initTime < 0.05 {
            controls.timingLabel.textColor = .systemGreen
        } else if initTime < 0.5 {
            controls.timingLabel.textColor = .systemOrange
        } else {
            controls.timingLabel.textColor = .systemRed
        }
    }

    private func log(_ message: String) {
        controls.logLabel.text = message
    }
}
