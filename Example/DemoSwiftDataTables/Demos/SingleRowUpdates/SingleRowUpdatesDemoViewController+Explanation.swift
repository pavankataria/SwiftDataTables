//
//  SingleRowUpdatesDemoViewController+Explanation.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 22/02/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import UIKit

extension SingleRowUpdatesDemoViewController {

    struct ExplanationControls {
        let view: DemoExplanationView
        let animateSwitch: UISwitch
        let updateCountLabel: UILabel
        let logLabel: UILabel
    }

    func makeExplanationControls() -> ExplanationControls {
        let buttonsRow = UIStackView(arrangedSubviews: [
            makeButton(title: "Update One", action: #selector(updateOneRow)),
            makeButton(title: "Reset Counts", action: #selector(resetCounts)),
        ])
        buttonsRow.axis = .horizontal
        buttonsRow.spacing = 8
        buttonsRow.distribution = .fillEqually

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
        logLabel.text = "Tap Update One"
        logLabel.numberOfLines = 2

        let infoRow = UIStackView(arrangedSubviews: [updateCountLabel, UIView(), logLabel])
        infoRow.axis = .horizontal
        infoRow.spacing = 8

        let explanationView = DemoExplanationView(
            description: "The Value column shows a configure count. Update one row to see only that row increment.",
            controls: [buttonsRow, animateRow, infoRow]
        )

        return ExplanationControls(
            view: explanationView,
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
