//
//  NativeSearchDemoViewController.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 22/02/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import UIKit
import SwiftDataTables

final class NativeSearchDemoViewController: UIViewController {

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

    // MARK: - UI

    private var controls: ExplanationControls!
    private var dataTable: SwiftDataTable?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search Bar Position"
        view.backgroundColor = .systemBackground

        controls = makeExplanationControls()
        installExplanation(controls.view)

        updateSummary()
        rebuildTable()
    }

    // MARK: - Actions

    @objc func positionChanged(_ sender: UISegmentedControl) {
        guard let newPosition = SearchPosition(rawValue: sender.selectedSegmentIndex) else { return }
        selectedPosition = newPosition
        updateSummary()
        rebuildTable()
    }

    // MARK: - UI Updates

    private func updateSummary() {
        controls.view.updateSummary("Mode: \(selectedPosition.title) — \(selectedPosition.description)")
    }

    private func rebuildTable() {
        dataTable?.removeFromSuperview()
        navigationItem.searchController = nil

        var config = DataTableConfiguration()

        switch selectedPosition {
        case .embedded:
            config.shouldShowSearchSection = true
        case .navigationBar:
            config.shouldShowSearchSection = false
        }

        let table = SwiftDataTable(data: sampleData, columns: columns, options: config)
        table.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)

        addDataTable(table, below: controls.view)

        if selectedPosition == .navigationBar {
            table.installSearchController(on: self)
        }

        dataTable = table
    }
}
