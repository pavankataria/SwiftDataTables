//
//  InstructionsView.swift
//  DemoSwiftDataTables
//
//  Created for SwiftDataTables.
//

import UIKit

/// Reusable instructions panel for demo view controllers
final class InstructionsView: UIStackView {

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    private let configLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .tertiaryLabel
        label.numberOfLines = 0
        return label
    }()

    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    private var controlsStack: UIStackView?

    init(description: String, config: String? = nil, controls: [UIView] = []) {
        super.init(frame: .zero)
        setup(description: description, config: config, controls: controls)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup(description: String, config: String?, controls: [UIView]) {
        axis = .vertical
        spacing = 10
        translatesAutoresizingMaskIntoConstraints = false

        descriptionLabel.text = description
        addArrangedSubview(descriptionLabel)

        if let config = config {
            configLabel.text = config
            addArrangedSubview(configLabel)
        }

        if !controls.isEmpty {
            let stack = UIStackView(arrangedSubviews: controls)
            stack.axis = .vertical
            stack.spacing = 8
            addArrangedSubview(stack)
            controlsStack = stack
        }
    }

    /// Updates the summary text shown below controls
    func updateSummary(_ text: String?) {
        if let text = text {
            summaryLabel.text = text
            if summaryLabel.superview == nil {
                addArrangedSubview(summaryLabel)
            }
        } else {
            summaryLabel.removeFromSuperview()
        }
    }

    /// Adds a labeled row (label + control on the right) for switches/steppers
    static func labeledRow(label: String, control: UIView) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.text = label

        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [titleLabel, spacer, control])
        row.axis = .horizontal
        row.spacing = 8
        row.alignment = .center
        return row
    }

    /// Adds a labeled section (label above, control below) for segmented controls
    static func labeledSection(label: String, control: UIView) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.text = label

        let stack = UIStackView(arrangedSubviews: [titleLabel, control])
        stack.axis = .vertical
        stack.spacing = 6
        return stack
    }

    /// Adds a labeled row with value display (label + value + control) for steppers
    static func labeledRow(label: String, valueLabel: UILabel, control: UIView) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.text = label

        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [titleLabel, spacer, valueLabel, control])
        row.axis = .horizontal
        row.spacing = 8
        row.alignment = .center
        return row
    }
}
