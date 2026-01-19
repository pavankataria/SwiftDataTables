//
//  PerformanceDemoViewController+Explanation.swift
//  DemoSwiftDataTables
//

import UIKit

extension PerformanceDemoViewController {

    struct ExplanationControls {
        let view: DemoExplanationView
        let rowCountStepper: UIStepper
        let rowCountLabel: UILabel
        let timingLabel: UILabel
        let reloadButton: UIButton
    }

    func makeExplanationControls() -> ExplanationControls {
        let rowCountLabel = DemoExplanationView.valueLabel(width: 70)

        let timingLabel = UILabel()
        timingLabel.font = .monospacedDigitSystemFont(ofSize: 24, weight: .bold)
        timingLabel.textColor = .systemGreen
        timingLabel.textAlignment = .center
        timingLabel.text = "—"

        let (rowCountStepper, rowRow) = DemoExplanationView.stepperRow(
            label: "Rows",
            min: 1000, max: 100000, step: 10000, value: 50000,
            valueLabel: rowCountLabel,
            target: self, action: #selector(stepperChanged(_:))
        )

        let reloadButton = UIButton(type: .system)
        reloadButton.setTitle("Reload Table", for: .normal)
        reloadButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        reloadButton.addTarget(self, action: #selector(reloadTapped), for: .touchUpInside)

        let explanationView = DemoExplanationView(
            description: "This demo showcases SwiftDataTables rendering large datasets. Adjust the row count and tap Reload to measure render time.",
            controls: [timingLabel, rowRow, reloadButton]
        )

        return ExplanationControls(
            view: explanationView,
            rowCountStepper: rowCountStepper,
            rowCountLabel: rowCountLabel,
            timingLabel: timingLabel,
            reloadButton: reloadButton
        )
    }
}
