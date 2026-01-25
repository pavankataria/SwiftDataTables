//
//  LargeScaleModeDemoViewController+Explanation.swift
//  DemoSwiftDataTables
//

import UIKit

extension LargeScaleModeDemoViewController {

    struct ExplanationControls {
        let view: DemoExplanationView
        let largeScaleModeSwitch: UISwitch
        let rowCountLabel: UILabel
        let timingLabel: UILabel
        let logLabel: UILabel
    }

    func makeExplanationControls() -> ExplanationControls {
        // Row count selector
        let rowCountSegment = UISegmentedControl(items: ["1k", "10k", "50k", "100k"])
        rowCountSegment.selectedSegmentIndex = 1 // Default to 10k
        rowCountSegment.addTarget(self, action: #selector(rowCountChanged(_:)), for: .valueChanged)

        let rowCountTitleLabel = UILabel()
        rowCountTitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        rowCountTitleLabel.text = "Row Count"

        let rowCountRow = UIStackView(arrangedSubviews: [rowCountTitleLabel, rowCountSegment])
        rowCountRow.axis = .horizontal
        rowCountRow.spacing = 12
        rowCountRow.alignment = .center

        // Large-scale mode toggle
        let (largeScaleModeSwitch, modeRow) = DemoExplanationView.toggleRow(
            label: "Large-Scale Mode (lazy measurement)",
            isOn: true,
            target: self, action: #selector(modeToggleChanged(_:))
        )

        // Scroll controls
        let scrollButtons = UIStackView(arrangedSubviews: [
            makeButton(title: "Top", action: #selector(scrollToTop)),
            makeButton(title: "Random", action: #selector(scrollToRandom)),
            makeButton(title: "Bottom", action: #selector(scrollToBottom)),
        ])
        scrollButtons.axis = .horizontal
        scrollButtons.spacing = 8
        scrollButtons.distribution = .fillEqually

        // Info row
        let rowCountLabel = UILabel()
        rowCountLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .semibold)
        rowCountLabel.textColor = .label
        rowCountLabel.text = "10k rows"

        let timingLabel = UILabel()
        timingLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .bold)
        timingLabel.textColor = .systemGreen
        timingLabel.text = "Init: --ms"

        let logLabel = UILabel()
        logLabel.font = UIFont.monospacedSystemFont(ofSize: 11, weight: .regular)
        logLabel.textColor = .secondaryLabel
        logLabel.text = "Toggle mode to compare init times"
        logLabel.numberOfLines = 2

        let infoRow = UIStackView(arrangedSubviews: [rowCountLabel, timingLabel, UIView(), logLabel])
        infoRow.axis = .horizontal
        infoRow.spacing = 12

        let explanationView = DemoExplanationView(
            description: "Large-scale mode uses estimated heights and measures rows lazily as you scroll. Compare init times: toggle off to see standard mode (measures all rows upfront).",
            controls: [rowCountRow, modeRow, scrollButtons, infoRow]
        )

        return ExplanationControls(
            view: explanationView,
            largeScaleModeSwitch: largeScaleModeSwitch,
            rowCountLabel: rowCountLabel,
            timingLabel: timingLabel,
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
