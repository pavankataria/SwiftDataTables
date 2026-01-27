//
//  ScrollAnchoringDemoViewController+Explanation.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 22/02/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import UIKit

extension ScrollAnchoringDemoViewController {

    struct ExplanationControls {
        let view: DemoExplanationView
        let animationSwitch: UISwitch
        let rowCountLabel: UILabel
        let logLabel: UILabel
    }

    func makeExplanationControls() -> ExplanationControls {
        // Row 1: Insert/Delete above viewport
        let buttonsRow1 = UIStackView(arrangedSubviews: [
            makeButton(title: "+ Above", action: #selector(insertAbove), color: .systemGreen),
            makeButton(title: "- Above", action: #selector(deleteAbove), color: .systemRed),
            makeButton(title: "Batch Above", action: #selector(batchMixAbove), color: .systemOrange),
        ])
        buttonsRow1.axis = .horizontal
        buttonsRow1.spacing = 8
        buttonsRow1.distribution = .fillEqually

        // Row 2: Insert/Delete below viewport + scroll helper
        let buttonsRow2 = UIStackView(arrangedSubviews: [
            makeButton(title: "+ Below", action: #selector(insertBelow), color: .systemBlue),
            makeButton(title: "- Below", action: #selector(deleteBelow), color: .systemBlue),
            makeButton(title: "Scroll to Mid", action: #selector(scrollToMiddle), color: .systemPurple),
        ])
        buttonsRow2.axis = .horizontal
        buttonsRow2.spacing = 8
        buttonsRow2.distribution = .fillEqually

        let (animationSwitch, animationRow) = DemoExplanationView.toggleRow(
            label: "Animate", isOn: true,
            target: self, action: #selector(animationToggleChanged(_:))
        )

        let rowCountLabel = UILabel()
        rowCountLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .semibold)
        rowCountLabel.textColor = .label
        rowCountLabel.text = "Rows: 0"

        let logLabel = UILabel()
        logLabel.font = UIFont.monospacedSystemFont(ofSize: 11, weight: .regular)
        logLabel.textColor = .secondaryLabel
        logLabel.text = "Scroll down, then try Insert/Delete Above"
        logLabel.numberOfLines = 2

        let infoRow = UIStackView(arrangedSubviews: [rowCountLabel, UIView(), logLabel])
        infoRow.axis = .horizontal
        infoRow.spacing = 8

        let explanationView = DemoExplanationView(
            description: "Scroll anchoring: Insert/delete rows ABOVE your scroll position without visual jumps. Try: 1) Tap 'Scroll to Mid' 2) Tap '+ Above' - notice your view doesn't jump!",
            controls: [buttonsRow1, buttonsRow2, animationRow, infoRow]
        )

        return ExplanationControls(
            view: explanationView,
            animationSwitch: animationSwitch,
            rowCountLabel: rowCountLabel,
            logLabel: logLabel
        )
    }

    func makeButton(title: String, action: Selector, color: UIColor = .systemBlue) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseBackgroundColor = color
        config.baseForegroundColor = .white
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8)
        config.cornerStyle = .medium
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            return outgoing
        }
        let button = UIButton(configuration: config)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
}
