//
//  IncrementalUpdatesDemoViewController+Explanation.swift
//  DemoSwiftDataTables
//

import UIKit

extension IncrementalUpdatesDemoViewController {

    struct ExplanationControls {
        let view: DemoExplanationView
        let animationSwitch: UISwitch
        let randomInsertSwitch: UISwitch
        let rowCountLabel: UILabel
        let operationLogLabel: UILabel
    }

    func makeExplanationControls() -> ExplanationControls {
        let buttonsRow1 = UIStackView(arrangedSubviews: [
            makeButton(title: "+ 5 Rows", action: #selector(add5Rows)),
            makeButton(title: "- 5 Rows", action: #selector(delete5Rows)),
            makeButton(title: "Randomise", action: #selector(randomiseAll)),
        ])
        buttonsRow1.axis = .horizontal
        buttonsRow1.spacing = 8
        buttonsRow1.distribution = .fillEqually

        let buttonsRow2 = UIStackView(arrangedSubviews: [
            makeButton(title: "Update", action: #selector(updateRow)),
            makeButton(title: "Batch Mix", action: #selector(batchMix)),
            makeButton(title: "Clear All", action: #selector(clearAll)),
        ])
        buttonsRow2.axis = .horizontal
        buttonsRow2.spacing = 8
        buttonsRow2.distribution = .fillEqually

        let (animationSwitch, animationRow) = DemoExplanationView.toggleRow(
            label: "Animate", isOn: true,
            target: self, action: #selector(animationToggleChanged(_:))
        )

        let (randomInsertSwitch, randomInsertRow) = DemoExplanationView.toggleRow(
            label: "Random Insert", isOn: true,
            target: self, action: #selector(animationToggleChanged(_:))
        )

        let rowCountLabel = UILabel()
        rowCountLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .semibold)
        rowCountLabel.textColor = .label
        rowCountLabel.text = "Rows: 0"

        let operationLogLabel = UILabel()
        operationLogLabel.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        operationLogLabel.textColor = .secondaryLabel
        operationLogLabel.text = "Ready"
        operationLogLabel.numberOfLines = 2

        let infoRow = UIStackView(arrangedSubviews: [rowCountLabel, UIView(), operationLogLabel])
        infoRow.axis = .horizontal
        infoRow.spacing = 8

        let explanationView = DemoExplanationView(
            description: "Snapshot diffing: modify data, call setData(), table animates the diff",
            controls: [buttonsRow1, buttonsRow2, animationRow, randomInsertRow, infoRow]
        )

        return ExplanationControls(
            view: explanationView,
            animationSwitch: animationSwitch,
            randomInsertSwitch: randomInsertSwitch,
            rowCountLabel: rowCountLabel,
            operationLogLabel: operationLogLabel
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
