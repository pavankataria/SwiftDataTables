//
//  RowSelectionDemoViewController+Explanation.swift
//  DemoSwiftDataTables
//

import UIKit

extension RowSelectionDemoViewController {

    struct ExplanationControls {
        let view: DemoExplanationView
        let selectionLogLabel: UILabel
        let clearButton: UIButton
    }

    func makeExplanationControls() -> ExplanationControls {
        let selectionLogLabel = UILabel()
        selectionLogLabel.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        selectionLogLabel.textColor = .label
        selectionLogLabel.numberOfLines = 5
        selectionLogLabel.text = "Tap a row to see selection events..."

        let logContainer = UIView()
        logContainer.backgroundColor = UIColor.systemGray6
        logContainer.layer.cornerRadius = 8
        logContainer.translatesAutoresizingMaskIntoConstraints = false
        logContainer.addSubview(selectionLogLabel)

        selectionLogLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selectionLogLabel.topAnchor.constraint(equalTo: logContainer.topAnchor, constant: 8),
            selectionLogLabel.leadingAnchor.constraint(equalTo: logContainer.leadingAnchor, constant: 8),
            selectionLogLabel.trailingAnchor.constraint(equalTo: logContainer.trailingAnchor, constant: -8),
            selectionLogLabel.bottomAnchor.constraint(equalTo: logContainer.bottomAnchor, constant: -8),
            logContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),
        ])

        let clearButton = UIButton(type: .system)
        clearButton.setTitle("Clear Log", for: .normal)
        clearButton.addTarget(self, action: #selector(clearLog), for: .touchUpInside)

        let explanationView = DemoExplanationView(
            description: "Tap rows to see selection callbacks. The delegate receives didSelectItem and didDeselectItem events.",
            controls: [logContainer, clearButton]
        )

        return ExplanationControls(
            view: explanationView,
            selectionLogLabel: selectionLogLabel,
            clearButton: clearButton
        )
    }
}
