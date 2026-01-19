//
//  HeightsCustomizationDemoViewController.swift
//  SwiftDataTables
//
//  Interactive demo for customizing header/footer/search heights.
//

import UIKit
import SwiftDataTables

final class HeightsCustomizationDemoViewController: UIViewController {

    // MARK: - Properties

    private var headerHeight: CGFloat = 44
    private var footerHeight: CGFloat = 44
    private var searchHeight: CGFloat = 60
    private var interRowSpacing: CGFloat = 1

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = "Customize the heights of headers, footers, search bar, and spacing between rows."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var headerSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 30
        slider.maximumValue = 80
        slider.value = Float(headerHeight)
        slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
        return slider
    }()

    private lazy var headerValueLabel: UILabel = makeValueLabel()

    private lazy var footerSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 30
        slider.maximumValue = 80
        slider.value = Float(footerHeight)
        slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
        return slider
    }()

    private lazy var footerValueLabel: UILabel = makeValueLabel()

    private lazy var searchSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 40
        slider.maximumValue = 100
        slider.value = Float(searchHeight)
        slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
        return slider
    }()

    private lazy var searchValueLabel: UILabel = makeValueLabel()

    private lazy var spacingSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 10
        slider.value = Float(interRowSpacing)
        slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
        return slider
    }()

    private lazy var spacingValueLabel: UILabel = makeValueLabel()

    private var controlsStack: UIStackView!
    private var dataTable: SwiftDataTable?

    private let headers = ["ID", "Name", "Email", "Number", "City", "Balance"]

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Heights"
        view.backgroundColor = .systemBackground
        setupViews()
        updateLabels()
        rebuildTable()
    }

    // MARK: - Setup

    private func makeValueLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .right
        label.widthAnchor.constraint(equalToConstant: 50).isActive = true
        return label
    }

    private func setupViews() {
        let headerRow = sliderRow(label: "Header Height", slider: headerSlider, valueLabel: headerValueLabel)
        let footerRow = sliderRow(label: "Footer Height", slider: footerSlider, valueLabel: footerValueLabel)
        let searchRow = sliderRow(label: "Search Height", slider: searchSlider, valueLabel: searchValueLabel)
        let spacingRow = sliderRow(label: "Row Spacing", slider: spacingSlider, valueLabel: spacingValueLabel)

        controlsStack = UIStackView(arrangedSubviews: [
            descriptionLabel,
            headerRow,
            footerRow,
            searchRow,
            spacingRow
        ])
        controlsStack.axis = .vertical
        controlsStack.spacing = 10
        controlsStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(controlsStack)

        NSLayoutConstraint.activate([
            controlsStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            controlsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            controlsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }

    private func sliderRow(label: String, slider: UISlider, valueLabel: UILabel) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.text = label
        titleLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true

        let row = UIStackView(arrangedSubviews: [titleLabel, slider, valueLabel])
        row.axis = .horizontal
        row.spacing = 8
        row.alignment = .center
        return row
    }

    // MARK: - Actions

    @objc private func sliderChanged(_ sender: UISlider) {
        switch sender {
        case headerSlider:
            headerHeight = CGFloat(sender.value)
        case footerSlider:
            footerHeight = CGFloat(sender.value)
        case searchSlider:
            searchHeight = CGFloat(sender.value)
        case spacingSlider:
            interRowSpacing = CGFloat(sender.value)
        default:
            break
        }
        updateLabels()
        rebuildTable()
    }

    // MARK: - UI Updates

    private func updateLabels() {
        headerValueLabel.text = "\(Int(headerHeight))pt"
        footerValueLabel.text = "\(Int(footerHeight))pt"
        searchValueLabel.text = "\(Int(searchHeight))pt"
        spacingValueLabel.text = "\(Int(interRowSpacing))pt"
    }

    private func rebuildTable() {
        dataTable?.removeFromSuperview()

        var config = DataTableConfiguration()
        config.heightForSectionHeader = headerHeight
        config.heightForSectionFooter = footerHeight
        config.heightForSearchView = searchHeight
        config.heightOfInterRowSpacing = interRowSpacing

        let table = SwiftDataTable(
            data: makeData(),
            headerTitles: headers,
            options: config
        )
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
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
