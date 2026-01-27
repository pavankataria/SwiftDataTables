//
//  DemoExplanationView.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 22/02/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import UIKit

// MARK: - DemoExplanationView

final class DemoExplanationView: UIStackView {

    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    init(description: String, controls: [UIView] = []) {
        super.init(frame: .zero)
        setup(description: description, controls: controls)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup(description: String, controls: [UIView]) {
        axis = .vertical
        spacing = 10
        translatesAutoresizingMaskIntoConstraints = false

        let descriptionLabel = UILabel()
        descriptionLabel.font = UIFont.systemFont(ofSize: 13)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = description
        addArrangedSubview(descriptionLabel)

        for control in controls {
            addArrangedSubview(control)
        }
    }

    func updateSummary(_ text: String?) {
        if let text = text {
            summaryLabel.text = text
            if summaryLabel.superview == nil {
                addArrangedSubview(summaryLabel)
            }
        } else {
            summaryLabel.removeFromSuperview()
        }
    }
}

// MARK: - Control Factory

extension DemoExplanationView {

    /// Creates a slider row with label and value display
    static func sliderRow(
        label: String,
        min: Float,
        max: Float,
        value: Float,
        valueLabel: UILabel,
        target: Any,
        action: Selector
    ) -> (slider: UISlider, row: UIStackView) {
        let slider = UISlider()
        slider.minimumValue = min
        slider.maximumValue = max
        slider.value = value
        slider.addTarget(target, action: action, for: .valueChanged)

        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.text = label
        titleLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true

        let row = UIStackView(arrangedSubviews: [titleLabel, slider, valueLabel])
        row.axis = .horizontal
        row.spacing = 8
        row.alignment = .center

        return (slider, row)
    }

    /// Creates a toggle row with label
    static func toggleRow(
        label: String,
        isOn: Bool,
        target: Any,
        action: Selector
    ) -> (toggle: UISwitch, row: UIStackView) {
        let toggle = UISwitch()
        toggle.isOn = isOn
        toggle.addTarget(target, action: action, for: .valueChanged)

        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.text = label

        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [titleLabel, spacer, toggle])
        row.axis = .horizontal
        row.spacing = 8
        row.alignment = .center

        return (toggle, row)
    }

    /// Creates a stepper row with label and value display
    static func stepperRow(
        label: String,
        min: Double,
        max: Double,
        step: Double,
        value: Double,
        valueLabel: UILabel,
        target: Any,
        action: Selector
    ) -> (stepper: UIStepper, row: UIStackView) {
        let stepper = UIStepper()
        stepper.minimumValue = min
        stepper.maximumValue = max
        stepper.stepValue = step
        stepper.value = value
        stepper.addTarget(target, action: action, for: .valueChanged)

        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.text = label

        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [titleLabel, spacer, valueLabel, stepper])
        row.axis = .horizontal
        row.spacing = 8
        row.alignment = .center

        return (stepper, row)
    }

    /// Creates a segmented control section with label above
    static func segmentedSection(
        label: String,
        items: [String],
        selectedIndex: Int,
        target: Any,
        action: Selector
    ) -> (control: UISegmentedControl, section: UIStackView) {
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = selectedIndex
        control.addTarget(target, action: action, for: .valueChanged)

        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.text = label

        let section = UIStackView(arrangedSubviews: [titleLabel, control])
        section.axis = .vertical
        section.spacing = 6

        return (control, section)
    }

    /// Creates a value label for sliders/steppers
    static func valueLabel(width: CGFloat = 50) -> UILabel {
        let label = UILabel()
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .right
        label.widthAnchor.constraint(equalToConstant: width).isActive = true
        return label
    }
}

// MARK: - ViewController Binding

extension UIViewController {

    /// Installs explanation view with standard constraints
    func installExplanation(_ explanationView: DemoExplanationView) {
        view.addSubview(explanationView)
        NSLayoutConstraint.activate([
            explanationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            explanationView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            explanationView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }

    /// Installs data table below explanation view
    func addDataTable(_ table: UIView, below explanationView: DemoExplanationView) {
        table.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(table)
        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: explanationView.bottomAnchor, constant: 12),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}
