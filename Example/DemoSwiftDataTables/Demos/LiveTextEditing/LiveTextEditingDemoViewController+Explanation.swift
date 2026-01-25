//
//  LiveTextEditingDemoViewController+Explanation.swift
//  DemoSwiftDataTables
//

import UIKit

extension LiveTextEditingDemoViewController {

    struct ExplanationControls {
        let view: DemoExplanationView
        let noteCountLabel: UILabel
        let logLabel: UILabel
    }

    func makeExplanationControls() -> ExplanationControls {
        // Buttons row
        let buttonsRow = UIStackView(arrangedSubviews: [
            makeButton(title: "+ Add Note", action: #selector(addNote), color: .systemGreen),
            makeButton(title: "Delete First", action: #selector(deleteFirst), color: .systemRed),
            makeButton(title: "Done", action: #selector(dismissKeyboard), color: .systemGray),
        ])
        buttonsRow.axis = .horizontal
        buttonsRow.spacing = 8
        buttonsRow.distribution = .fillEqually

        // Info row
        let noteCountLabel = UILabel()
        noteCountLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .semibold)
        noteCountLabel.textColor = .label
        noteCountLabel.text = "Notes: 0"

        let logLabel = UILabel()
        logLabel.font = UIFont.monospacedSystemFont(ofSize: 11, weight: .regular)
        logLabel.textColor = .secondaryLabel
        logLabel.text = "Tap a content cell to edit"
        logLabel.numberOfLines = 1

        let infoRow = UIStackView(arrangedSubviews: [noteCountLabel, UIView(), logLabel])
        infoRow.axis = .horizontal
        infoRow.spacing = 12

        let explanationView = DemoExplanationView(
            description: "Live editing: Tap the Content column to edit. As you type, row heights update in real-time. Try adding newlines or long text!",
            controls: [buttonsRow, infoRow]
        )

        return ExplanationControls(
            view: explanationView,
            noteCountLabel: noteCountLabel,
            logLabel: logLabel
        )
    }

    func makeButton(title: String, action: Selector, color: UIColor = .systemBlue) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseBackgroundColor = color
        config.baseForegroundColor = .white
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
        config.cornerStyle = .medium
        let button = UIButton(configuration: config)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
}
