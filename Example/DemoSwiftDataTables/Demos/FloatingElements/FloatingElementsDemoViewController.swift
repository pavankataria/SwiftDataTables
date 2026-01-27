//
//  FloatingElementsDemoViewController.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 22/02/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import UIKit
import SwiftDataTables

final class FloatingElementsDemoViewController: UIViewController {

    // MARK: - Data

    var sampleData: [SamplePerson] {
        samplePeople() + samplePeople() + samplePeople()
    }

    let columns: [DataTableColumn<SamplePerson>] = [
        .init("ID", \.id),
        .init("Name", \.name),
        .init("Email", \.email),
        .init("Number", \.phone),
        .init("City", \.city),
        .init("Balance", \.balance)
    ]

    // MARK: - State

    private var floatHeaders = true
    private var floatFooters = true
    private var floatSearch = false

    // MARK: - UI

    private var controls: ExplanationControls!
    private var dataTable: SwiftDataTable?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Floating Elements"
        view.backgroundColor = .systemBackground

        controls = makeExplanationControls()
        installExplanation(controls.view)

        updateSummary()
        rebuildTable()
    }

    // MARK: - Actions

    @objc func toggleChanged(_ sender: UISwitch) {
        switch sender {
        case controls.headersFloatToggle:
            floatHeaders = sender.isOn
        case controls.footersFloatToggle:
            floatFooters = sender.isOn
        case controls.searchFloatToggle:
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
        controls.view.updateSummary(items.joined(separator: " | "))
    }

    private func rebuildTable() {
        dataTable?.removeFromSuperview()

        var config = DataTableConfiguration()
        config.shouldSectionHeadersFloat = floatHeaders
        config.shouldSectionFootersFloat = floatFooters
        config.shouldSearchHeaderFloat = floatSearch

        let table = SwiftDataTable(data: sampleData, columns: columns, options: config)
        table.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)

        addDataTable(table, below: controls.view)
        dataTable = table
    }
}
