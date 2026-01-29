//
//  CellStylingDemoViewController.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 28/01/2026.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import UIKit
import SwiftDataTables

final class CellStylingDemoViewController: UIViewController {

    // MARK: - Data

    let sampleData = samplePeople()

    let columns: [DataTableColumn<SamplePerson>] = [
        .init("ID", \.id),
        .init("Name", \.name),
        .init("Email", \.email),
        .init("Number", \.phone),
        .init("City", \.city),
        .init("Balance", \.balance)
    ]

    // MARK: - State

    private var selectedStyleIndex: Int = 0

    let styleOptions: [String] = [
        "Custom Font",
        "Negative Values Red",
        "Per-Column Styling",
        "Alternating Colours",
        "Combined Styling"
    ]

    // MARK: - UI

    private var controls: ExplanationControls!
    private var dataTable: SwiftDataTable?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Cell Styling"
        view.backgroundColor = .systemBackground

        controls = makeExplanationControls(styleOptions: styleOptions)
        installExplanation(controls.view)

        updateButtonAppearance()
        updateUI()
        rebuildTable()
    }

    // MARK: - Actions

    @objc func styleButtonTapped(_ sender: UIButton) {
        selectedStyleIndex = sender.tag
        updateButtonAppearance()
        updateUI()
        rebuildTable()
    }

    // MARK: - UI Updates

    private func updateButtonAppearance() {
        for (index, button) in controls.styleButtons.enumerated() {
            let isSelected = index == selectedStyleIndex
            button.backgroundColor = isSelected ? .systemBlue : .clear
            button.setTitleColor(isSelected ? .white : .systemBlue, for: .normal)
        }
    }

    private func updateUI() {
        let descriptions = [
            "Custom font applied to all cells using Avenir-Medium.",
            "Balance column shows negative values in red, positive in green.",
            "ID column uses monospaced digits, City column is centered.",
            "Rainbow row colours cycling through 7 colours, with highlight for sorted column.",
            "All styling combined: font, conditional colours, and row striping."
        ]
        controls.view.updateSummary(descriptions[selectedStyleIndex])
    }

    private func rebuildTable() {
        dataTable?.removeFromSuperview()

        var config = DataTableConfiguration()
        config.defaultOrdering = DataTableColumnOrder(index: 5, order: .descending) // Sort by Balance

        // Apply the selected styling
        switch selectedStyleIndex {
        case 0:
            config.defaultCellConfiguration = customFontConfiguration()
        case 1:
            config.defaultCellConfiguration = negativeValuesConfiguration()
        case 2:
            config.defaultCellConfiguration = perColumnConfiguration()
        case 3:
            config.defaultCellConfiguration = alternatingColoursConfiguration()
        case 4:
            config.defaultCellConfiguration = combinedConfiguration()
        default:
            break
        }

        let table = SwiftDataTable(data: sampleData, columns: columns, options: config)
        table.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)

        addDataTable(table, below: controls.view)
        dataTable = table
    }

    // MARK: - Cell Configuration Styles

    private func customFontConfiguration() -> DefaultCellConfiguration {
        return { cell, _, _, _ in
            cell.dataLabel.font = UIFont(name: "Avenir-Medium", size: 14)
        }
    }

    private func negativeValuesConfiguration() -> DefaultCellConfiguration {
        return { cell, value, indexPath, _ in
            // Only apply colour logic to Balance column (index 5)
            if indexPath.section == 5 {
                let balance = value.stringRepresentation
                    .replacingOccurrences(of: "£", with: "")
                    .replacingOccurrences(of: ",", with: "")
                if let number = Double(balance) {
                    if number < 0 {
                        cell.dataLabel.textColor = .systemRed
                        cell.dataLabel.font = .boldSystemFont(ofSize: 14)
                    } else {
                        cell.dataLabel.textColor = .systemGreen
                        cell.dataLabel.font = .systemFont(ofSize: 14)
                    }
                }
            } else {
                cell.dataLabel.textColor = .label
                cell.dataLabel.font = .systemFont(ofSize: 14)
            }
        }
    }

    private func perColumnConfiguration() -> DefaultCellConfiguration {
        return { cell, _, indexPath, _ in
            switch indexPath.section {
            case 0: // ID column - monospaced
                cell.dataLabel.font = .monospacedDigitSystemFont(ofSize: 13, weight: .regular)
                cell.dataLabel.textColor = .secondaryLabel
            case 4: // City column - centered
                cell.dataLabel.font = .systemFont(ofSize: 14, weight: .medium)
                cell.dataLabel.textAlignment = .center
            case 5: // Balance column - right aligned
                cell.dataLabel.font = .monospacedDigitSystemFont(ofSize: 14, weight: .semibold)
                cell.dataLabel.textAlignment = .right
            default:
                cell.dataLabel.font = .systemFont(ofSize: 14)
                cell.dataLabel.textAlignment = .natural
                cell.dataLabel.textColor = .label
            }
        }
    }

    private func alternatingColoursConfiguration() -> DefaultCellConfiguration {
        return { cell, _, indexPath, isHighlighted in
            // Rainbow colours like the classic demo
            let highlightedColours: [UIColor] = [
                UIColor(red: 1, green: 0.7, blue: 0.7, alpha: 1),
                UIColor(red: 1, green: 0.7, blue: 0.5, alpha: 1),
                UIColor(red: 1, green: 1, blue: 0.5, alpha: 1),
                UIColor(red: 0.5, green: 1, blue: 0.5, alpha: 1),
                UIColor(red: 0.5, green: 0.7, blue: 1, alpha: 1),
                UIColor(red: 0.5, green: 0.5, blue: 1, alpha: 1),
                UIColor(red: 1, green: 0.5, blue: 0.5, alpha: 1)
            ]
            let unhighlightedColours: [UIColor] = [
                UIColor(red: 1, green: 0.90, blue: 0.90, alpha: 1),
                UIColor(red: 1, green: 0.90, blue: 0.7, alpha: 1),
                UIColor(red: 1, green: 1, blue: 0.7, alpha: 1),
                UIColor(red: 0.7, green: 1, blue: 0.7, alpha: 1),
                UIColor(red: 0.7, green: 0.9, blue: 1, alpha: 1),
                UIColor(red: 0.7, green: 0.7, blue: 1, alpha: 1),
                UIColor(red: 1, green: 0.7, blue: 0.7, alpha: 1)
            ]

            let colours = isHighlighted ? highlightedColours : unhighlightedColours
            cell.backgroundColor = colours[indexPath.item % colours.count]
        }
    }

    private func combinedConfiguration() -> DefaultCellConfiguration {
        return { cell, value, indexPath, isHighlighted in
            // 1. Alternating row colours
            let highlightedColours: [UIColor] = [
                .systemBlue.withAlphaComponent(0.08),
                .systemBlue.withAlphaComponent(0.12)
            ]
            let unhighlightedColours: [UIColor] = [
                .systemBackground,
                .secondarySystemBackground
            ]
            let colours = isHighlighted ? highlightedColours : unhighlightedColours
            cell.backgroundColor = colours[indexPath.item % colours.count]

            // 2. Per-column styling
            switch indexPath.section {
            case 0: // ID
                cell.dataLabel.font = .monospacedDigitSystemFont(ofSize: 12, weight: .regular)
                cell.dataLabel.textColor = .tertiaryLabel
            case 5: // Balance - conditional colouring
                cell.dataLabel.font = .monospacedDigitSystemFont(ofSize: 14, weight: .semibold)
                let balance = value.stringRepresentation
                    .replacingOccurrences(of: "£", with: "")
                    .replacingOccurrences(of: ",", with: "")
                if let number = Double(balance) {
                    cell.dataLabel.textColor = number < 0 ? .systemRed : .systemGreen
                }
            default:
                cell.dataLabel.font = UIFont(name: "Avenir-Medium", size: 14)
                cell.dataLabel.textColor = .label
            }
        }
    }
}
