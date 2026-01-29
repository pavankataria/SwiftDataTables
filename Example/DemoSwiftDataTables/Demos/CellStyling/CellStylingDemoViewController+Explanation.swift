//
//  CellStylingDemoViewController+Explanation.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 28/01/2026.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import UIKit

extension CellStylingDemoViewController {

    struct ExplanationControls {
        let view: DemoExplanationView
        let styleButtons: [UIButton]
    }

    func makeExplanationControls(styleOptions: [String]) -> ExplanationControls {
        let styleButtons: [UIButton] = styleOptions.enumerated().map { index, title in
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
            button.titleLabel?.numberOfLines = 2
            button.titleLabel?.textAlignment = .center
            button.tag = index
            button.addTarget(self, action: #selector(styleButtonTapped(_:)), for: .touchUpInside)
            button.layer.cornerRadius = 8
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.systemBlue.cgColor
            button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            return button
        }

        let row1 = UIStackView(arrangedSubviews: Array(styleButtons[0..<3]))
        row1.axis = .horizontal
        row1.spacing = 8
        row1.distribution = .fillEqually

        let row2 = UIStackView(arrangedSubviews: Array(styleButtons[3..<5]))
        row2.axis = .horizontal
        row2.spacing = 8
        row2.distribution = .fillEqually

        let buttonStack = UIStackView(arrangedSubviews: [row1, row2])
        buttonStack.axis = .vertical
        buttonStack.spacing = 8

        let codeLabel = UILabel()
        codeLabel.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        codeLabel.textColor = .secondaryLabel
        codeLabel.numberOfLines = 0
        codeLabel.text = """
        config.defaultCellConfiguration = { cell, value, indexPath, isHighlighted in
            cell.dataLabel.font = .custom
            cell.dataLabel.textColor = .conditional
            cell.backgroundColor = .alternating
        }
        """

        let explanationView = DemoExplanationView(
            description: """
            Customise default cells without creating custom cell classes. \
            Use defaultCellConfiguration to set font, text colour, background, \
            and more based on value, position, or highlight state.

            This replaces the deprecated delegate methods \
            dataTable(_:highlightedColorForRowIndex:) and \
            dataTable(_:unhighlightedColorForRowIndex:).
            """,
            controls: [buttonStack, codeLabel]
        )

        return ExplanationControls(
            view: explanationView,
            styleButtons: styleButtons
        )
    }
}
