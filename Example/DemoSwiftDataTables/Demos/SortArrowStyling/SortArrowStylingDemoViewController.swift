//
//  SortArrowStylingDemoViewController.swift
//  SwiftDataTables
//
//  Interactive demo for customizing sort arrow appearance.
//

import UIKit
import SwiftDataTables

final class SortArrowStylingDemoViewController: UIViewController {

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

    private var selectedColorIndex: Int = 0

    let colorOptions: [(name: String, color: UIColor)] = [
        ("Blue (Default)", .systemBlue),
        ("Red", .systemRed),
        ("Green", .systemGreen),
        ("Orange", .systemOrange),
        ("Purple", .systemPurple),
        ("Teal", .systemTeal),
        ("Pink", .systemPink),
        ("Gray", .systemGray)
    ]

    // MARK: - UI

    private var controls: ExplanationControls!
    private var dataTable: SwiftDataTable?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sort Arrow Styling"
        view.backgroundColor = .systemBackground

        controls = makeExplanationControls(colorOptions: colorOptions)
        installExplanation(controls.view)

        updateButtonAppearance()
        updateUI()
        rebuildTable()
    }

    // MARK: - Actions

    @objc func colorButtonTapped(_ sender: UIButton) {
        selectedColorIndex = sender.tag
        updateButtonAppearance()
        updateUI()
        rebuildTable()
    }

    // MARK: - UI Updates

    private func updateButtonAppearance() {
        for (index, button) in controls.colorButtons.enumerated() {
            let isSelected = index == selectedColorIndex
            let color = colorOptions[index].color
            button.backgroundColor = isSelected ? color : .clear
            button.setTitleColor(isSelected ? .white : color, for: .normal)
            button.layer.borderColor = color.cgColor
        }
    }

    private func updateUI() {
        let selected = colorOptions[selectedColorIndex]
        controls.colorPreview.backgroundColor = selected.color
        controls.view.updateSummary("Sort arrow tint: \(selected.name)")
    }

    private func rebuildTable() {
        dataTable?.removeFromSuperview()

        var config = DataTableConfiguration()
        config.sortArrowTintColor = colorOptions[selectedColorIndex].color
        config.defaultOrdering = DataTableColumnOrder(index: 1, order: .ascending)

        let table = SwiftDataTable(data: sampleData, columns: columns, options: config)
        table.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)

        addDataTable(table, below: controls.view)
        dataTable = table
    }
}
