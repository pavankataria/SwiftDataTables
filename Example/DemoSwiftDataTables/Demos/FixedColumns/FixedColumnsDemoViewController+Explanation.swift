//
//  FixedColumnsDemoViewController+Explanation.swift
//  DemoSwiftDataTables
//

import UIKit

extension FixedColumnsDemoViewController {

    struct ExplanationControls {
        let view: DemoExplanationView
        let leftColumnsStepper: UIStepper
        let rightColumnsStepper: UIStepper
        let leftColumnsLabel: UILabel
        let rightColumnsLabel: UILabel
    }

    func makeExplanationControls(maxColumns: Int) -> ExplanationControls {
        let leftColumnsLabel = DemoExplanationView.valueLabel(width: 30)
        let rightColumnsLabel = DemoExplanationView.valueLabel(width: 30)

        let (leftStepper, leftRow) = DemoExplanationView.stepperRow(
            label: "Frozen left columns",
            min: 0, max: Double(maxColumns - 1), step: 1, value: 1,
            valueLabel: leftColumnsLabel,
            target: self, action: #selector(leftStepperChanged(_:))
        )

        let (rightStepper, rightRow) = DemoExplanationView.stepperRow(
            label: "Frozen right columns",
            min: 0, max: Double(maxColumns - 1), step: 1, value: 1,
            valueLabel: rightColumnsLabel,
            target: self, action: #selector(rightStepperChanged(_:))
        )

        let explanationView = DemoExplanationView(
            description: "Fixed (frozen) columns stay visible while scrolling horizontally. Adjust the number of frozen columns on each side and scroll to see the effect.",
            controls: [leftRow, rightRow]
        )

        return ExplanationControls(
            view: explanationView,
            leftColumnsStepper: leftStepper,
            rightColumnsStepper: rightStepper,
            leftColumnsLabel: leftColumnsLabel,
            rightColumnsLabel: rightColumnsLabel
        )
    }
}
