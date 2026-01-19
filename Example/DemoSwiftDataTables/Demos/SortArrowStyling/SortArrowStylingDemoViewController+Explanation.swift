//
//  SortArrowStylingDemoViewController+Explanation.swift
//  DemoSwiftDataTables
//

import UIKit

extension SortArrowStylingDemoViewController {

    struct ExplanationControls {
        let view: DemoExplanationView
        let colorButtons: [UIButton]
        let colorPreview: UIView
    }

    func makeExplanationControls(colorOptions: [(name: String, color: UIColor)]) -> ExplanationControls {
        let colorButtons: [UIButton] = colorOptions.enumerated().map { index, option in
            let button = UIButton(type: .system)
            button.setTitle(option.name, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
            button.tag = index
            button.addTarget(self, action: #selector(colorButtonTapped(_:)), for: .touchUpInside)
            button.layer.cornerRadius = 8
            button.layer.borderWidth = 1
            button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
            return button
        }

        let row1 = UIStackView(arrangedSubviews: Array(colorButtons[0..<4]))
        row1.axis = .horizontal
        row1.spacing = 8
        row1.distribution = .fillEqually

        let row2 = UIStackView(arrangedSubviews: Array(colorButtons[4..<8]))
        row2.axis = .horizontal
        row2.spacing = 8
        row2.distribution = .fillEqually

        let buttonStack = UIStackView(arrangedSubviews: [row1, row2])
        buttonStack.axis = .vertical
        buttonStack.spacing = 8

        let colorPreview = UIView()
        colorPreview.layer.cornerRadius = 8
        colorPreview.translatesAutoresizingMaskIntoConstraints = false
        colorPreview.heightAnchor.constraint(equalToConstant: 30).isActive = true
        colorPreview.widthAnchor.constraint(equalToConstant: 60).isActive = true

        let previewLabel = UILabel()
        previewLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        previewLabel.text = "Selected color:"

        let previewRow = UIStackView(arrangedSubviews: [previewLabel, colorPreview])
        previewRow.axis = .horizontal
        previewRow.spacing = 8
        previewRow.alignment = .center

        let explanationView = DemoExplanationView(
            description: "Customize the tint color of sort indicator arrows. Tap a column header to sort and see the arrow color.",
            controls: [buttonStack, previewRow]
        )

        return ExplanationControls(
            view: explanationView,
            colorButtons: colorButtons,
            colorPreview: colorPreview
        )
    }
}
