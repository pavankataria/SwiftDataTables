//
//  RapidFireUpdatesDemoViewController+Explanation.swift
//  DemoSwiftDataTables
//

import UIKit

extension RapidFireUpdatesDemoViewController {

    struct ExplanationControls {
        let view: DemoExplanationView
        let runningSwitch: UISwitch
        let rateSlider: UISlider
        let rateValueLabel: UILabel
        let messageCountLabel: UILabel
        let updateCountLabel: UILabel
        let upsLabel: UILabel
        let logLabel: UILabel
    }

    func makeExplanationControls() -> ExplanationControls {
        // Running toggle
        let (runningSwitch, runningRow) = DemoExplanationView.toggleRow(
            label: "Running",
            isOn: false,
            target: self,
            action: #selector(runningToggled(_:))
        )

        // Rate slider (updates per second)
        let rateValueLabel = DemoExplanationView.valueLabel(width: 40)
        rateValueLabel.text = "10/s"

        let (rateSlider, rateRow) = DemoExplanationView.sliderRow(
            label: "Rate",
            min: 1,
            max: 30,
            value: 10,
            valueLabel: rateValueLabel,
            target: self,
            action: #selector(rateChanged(_:))
        )

        // Buttons
        let buttonsRow = UIStackView(arrangedSubviews: [
            makeButton(title: "Burst +10", action: #selector(addBurst), color: .systemOrange),
            makeButton(title: "Clear All", action: #selector(clearAll), color: .systemRed),
        ])
        buttonsRow.axis = .horizontal
        buttonsRow.spacing = 8
        buttonsRow.distribution = .fillEqually

        // Stats row
        let messageCountLabel = UILabel()
        messageCountLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .semibold)
        messageCountLabel.textColor = .label
        messageCountLabel.text = "Msgs: 0"

        let updateCountLabel = UILabel()
        updateCountLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .medium)
        updateCountLabel.textColor = .secondaryLabel
        updateCountLabel.text = "Total: 0"

        let upsLabel = UILabel()
        upsLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .bold)
        upsLabel.textColor = .systemGreen
        upsLabel.text = "0/sec"

        let logLabel = UILabel()
        logLabel.font = UIFont.monospacedSystemFont(ofSize: 10, weight: .regular)
        logLabel.textColor = .tertiaryLabel
        logLabel.text = "Toggle 'Running' to start"
        logLabel.numberOfLines = 1

        let statsRow = UIStackView(arrangedSubviews: [messageCountLabel, updateCountLabel, upsLabel, UIView(), logLabel])
        statsRow.axis = .horizontal
        statsRow.spacing = 12

        let explanationView = DemoExplanationView(
            description: "Rapid-fire: Stress test with up to 30 updates/sec. Messages are added, modified, and deleted randomly. Watch the update rate!",
            controls: [runningRow, rateRow, buttonsRow, statsRow]
        )

        return ExplanationControls(
            view: explanationView,
            runningSwitch: runningSwitch,
            rateSlider: rateSlider,
            rateValueLabel: rateValueLabel,
            messageCountLabel: messageCountLabel,
            updateCountLabel: updateCountLabel,
            upsLabel: upsLabel,
            logLabel: logLabel
        )
    }

    func makeButton(title: String, action: Selector, color: UIColor) -> UIButton {
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
