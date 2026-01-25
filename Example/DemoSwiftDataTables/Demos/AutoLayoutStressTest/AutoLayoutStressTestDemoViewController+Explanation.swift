//
//  AutoLayoutStressTestDemoViewController+Explanation.swift
//  DemoSwiftDataTables
//

import UIKit

extension AutoLayoutStressTestDemoViewController {

    struct ExplanationControls {
        let view: DemoExplanationView
        let autoUpdateSwitch: UISwitch
        let animateSwitch: UISwitch
        let speedSlider: UISlider
        let speedValueLabel: UILabel
        let rowCountLabel: UILabel
        let updateCountLabel: UILabel
        let logLabel: UILabel
    }

    func makeExplanationControls() -> ExplanationControls {
        // Buttons row
        let buttonsRow = UIStackView(arrangedSubviews: [
            makeButton(title: "Update 1", action: #selector(manualUpdate)),
            makeButton(title: "Burst 5", action: #selector(burstUpdate)),
            makeButton(title: "All Rows", action: #selector(updateAllRows)),
        ])
        buttonsRow.axis = .horizontal
        buttonsRow.spacing = 8
        buttonsRow.distribution = .fillEqually

        // Auto-update toggle
        let (autoUpdateSwitch, autoUpdateRow) = DemoExplanationView.toggleRow(
            label: "Auto-update",
            isOn: false,
            target: self,
            action: #selector(autoUpdateToggled(_:))
        )

        // Animation toggle
        let (animateSwitch, animateRow) = DemoExplanationView.toggleRow(
            label: "Animate",
            isOn: true,
            target: self,
            action: #selector(animationToggled(_:))
        )

        let togglesRow = UIStackView(arrangedSubviews: [autoUpdateRow, animateRow])
        togglesRow.axis = .horizontal
        togglesRow.spacing = 24
        togglesRow.distribution = .fillEqually

        // Speed slider
        let speedValueLabel = DemoExplanationView.valueLabel(width: 40)
        speedValueLabel.text = "1.0s"

        let (speedSlider, speedRow) = DemoExplanationView.sliderRow(
            label: "Interval",
            min: 0.2,
            max: 3.0,
            value: 1.0,
            valueLabel: speedValueLabel,
            target: self,
            action: #selector(speedChanged(_:))
        )

        // Info row
        let rowCountLabel = UILabel()
        rowCountLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: .semibold)
        rowCountLabel.textColor = .label
        rowCountLabel.text = "Rows: 0"

        let updateCountLabel = UILabel()
        updateCountLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: .semibold)
        updateCountLabel.textColor = .systemBlue
        updateCountLabel.text = "Updates: 0"

        let logLabel = UILabel()
        logLabel.font = UIFont.monospacedSystemFont(ofSize: 11, weight: .regular)
        logLabel.textColor = .secondaryLabel
        logLabel.text = "Tap buttons or enable auto-update"
        logLabel.numberOfLines = 1

        let infoRow = UIStackView(arrangedSubviews: [rowCountLabel, updateCountLabel, UIView(), logLabel])
        infoRow.axis = .horizontal
        infoRow.spacing = 12

        let explanationView = DemoExplanationView(
            description: "Stress test: Random content & font size changes trigger row height recalculations. Watch cells smoothly resize without full table reloads.",
            controls: [buttonsRow, togglesRow, speedRow, infoRow]
        )

        return ExplanationControls(
            view: explanationView,
            autoUpdateSwitch: autoUpdateSwitch,
            animateSwitch: animateSwitch,
            speedSlider: speedSlider,
            speedValueLabel: speedValueLabel,
            rowCountLabel: rowCountLabel,
            updateCountLabel: updateCountLabel,
            logLabel: logLabel
        )
    }

    func makeButton(title: String, action: Selector) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseBackgroundColor = .systemBlue
        config.baseForegroundColor = .white
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10)
        config.cornerStyle = .medium
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
            return outgoing
        }
        let button = UIButton(configuration: config)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
}
