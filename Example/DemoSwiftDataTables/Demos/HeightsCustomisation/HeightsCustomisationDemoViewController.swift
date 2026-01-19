//
//  HeightsCustomisationDemoViewController.swift
//  SwiftDataTables
//
//  Interactive demo for customising header/footer/search heights.
//

import UIKit
import SwiftDataTables

final class HeightsCustomisationDemoViewController: UIViewController {

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

    private var headerHeight: CGFloat = 44
    private var footerHeight: CGFloat = 44
    private var searchHeight: CGFloat = 60
    private var interRowSpacing: CGFloat = 1

    // MARK: - UI (bound from extension)

    private var controls: ExplanationControls!
    private var dataTable: SwiftDataTable?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Heights"
        view.backgroundColor = .systemBackground

        controls = makeExplanationControls()
        installExplanation(controls.view)

        updateLabels()
        rebuildTable()
    }

    // MARK: - Actions

    @objc func sliderChanged(_ sender: UISlider) {
        switch sender {
        case controls.headerSlider:
            headerHeight = CGFloat(sender.value)
        case controls.footerSlider:
            footerHeight = CGFloat(sender.value)
        case controls.searchSlider:
            searchHeight = CGFloat(sender.value)
        case controls.spacingSlider:
            interRowSpacing = CGFloat(sender.value)
        default:
            break
        }
        updateLabels()
        rebuildTable()
    }

    // MARK: - UI Updates

    private func updateLabels() {
        controls.headerValueLabel.text = "\(Int(headerHeight))pt"
        controls.footerValueLabel.text = "\(Int(footerHeight))pt"
        controls.searchValueLabel.text = "\(Int(searchHeight))pt"
        controls.spacingValueLabel.text = "\(Int(interRowSpacing))pt"
    }

    private func rebuildTable() {
        dataTable?.removeFromSuperview()

        var config = DataTableConfiguration()
        config.heightForSectionHeader = headerHeight
        config.heightForSectionFooter = footerHeight
        config.heightForSearchView = searchHeight
        config.heightOfInterRowSpacing = interRowSpacing

        let table = SwiftDataTable(data: sampleData, columns: columns, options: config)
        table.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)

        installDataTable(table, below: controls.view)
        dataTable = table
    }
}
