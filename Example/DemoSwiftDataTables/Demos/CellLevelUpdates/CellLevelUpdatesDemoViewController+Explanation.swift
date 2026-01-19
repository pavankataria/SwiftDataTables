//
//  CellLevelUpdatesDemoViewController+Explanation.swift
//  DemoSwiftDataTables
//

import UIKit

extension CellLevelUpdatesDemoViewController {

    struct ExplanationControls {
        let view: DemoExplanationView
        let autoUpdateSwitch: UISwitch
        let animateSwitch: UISwitch
        let updateCountLabel: UILabel
        let logLabel: UILabel
    }

    func makeExplanationControls() -> ExplanationControls {
        let buttonsRow = UIStackView(arrangedSubviews: [
            makeButton(title: "Update One", action: #selector(manualUpdate)),
            makeButton(title: "Reset Counts", action: #selector(resetCounts)),
        ])
        buttonsRow.axis = .horizontal
        buttonsRow.spacing = 8
        buttonsRow.distribution = .fillEqually

        let (autoUpdateSwitch, autoUpdateRow) = DemoExplanationView.toggleRow(
            label: "Auto-update (3s)", isOn: false,
            target: self, action: #selector(autoUpdateToggled(_:))
        )

        let (animateSwitch, animateRow) = DemoExplanationView.toggleRow(
            label: "Animate", isOn: true,
            target: self, action: #selector(animationToggled(_:))
        )

        let updateCountLabel = UILabel()
        updateCountLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .semibold)
        updateCountLabel.textColor = .label
        updateCountLabel.text = "Updates: 0"

        let logLabel = UILabel()
        logLabel.font = UIFont.monospacedSystemFont(ofSize: 11, weight: .regular)
        logLabel.textColor = .secondaryLabel
        logLabel.text = "Watch the #counts - only changed cells increment"
        logLabel.numberOfLines = 2

        let infoRow = UIStackView(arrangedSubviews: [updateCountLabel, UIView(), logLabel])
        infoRow.axis = .horizontal
        infoRow.spacing = 8

        let explanationView = DemoExplanationView(
            description: "Each cell shows #count of how many times it was configured. Only changed cells see their count increase - proof of cell-level diffing!",
            controls: [buttonsRow, autoUpdateRow, animateRow, infoRow]
        )

        return ExplanationControls(
            view: explanationView,
            autoUpdateSwitch: autoUpdateSwitch,
            animateSwitch: animateSwitch,
            updateCountLabel: updateCountLabel,
            logLabel: logLabel
        )
    }

    func makeButton(title: String, action: Selector) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseBackgroundColor = .systemBlue
        config.baseForegroundColor = .white
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
        config.cornerStyle = .medium
        let button = UIButton(configuration: config)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
}
