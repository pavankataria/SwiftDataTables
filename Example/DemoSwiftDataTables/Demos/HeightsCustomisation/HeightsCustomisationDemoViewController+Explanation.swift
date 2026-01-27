//
//  HeightsCustomisationDemoViewController+Explanation.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 22/02/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import UIKit

extension HeightsCustomisationDemoViewController {

    struct ExplanationControls {
        let view: DemoExplanationView
        let headerSlider: UISlider
        let footerSlider: UISlider
        let searchSlider: UISlider
        let spacingSlider: UISlider
        let headerValueLabel: UILabel
        let footerValueLabel: UILabel
        let searchValueLabel: UILabel
        let spacingValueLabel: UILabel
    }

    func makeExplanationControls() -> ExplanationControls {
        let headerValueLabel = DemoExplanationView.valueLabel()
        let footerValueLabel = DemoExplanationView.valueLabel()
        let searchValueLabel = DemoExplanationView.valueLabel()
        let spacingValueLabel = DemoExplanationView.valueLabel()

        let (headerSlider, headerRow) = DemoExplanationView.sliderRow(
            label: "Header Height",
            min: 30, max: 80, value: 44,
            valueLabel: headerValueLabel,
            target: self, action: #selector(sliderChanged(_:))
        )

        let (footerSlider, footerRow) = DemoExplanationView.sliderRow(
            label: "Footer Height",
            min: 30, max: 80, value: 44,
            valueLabel: footerValueLabel,
            target: self, action: #selector(sliderChanged(_:))
        )

        let (searchSlider, searchRow) = DemoExplanationView.sliderRow(
            label: "Search Height",
            min: 40, max: 100, value: 60,
            valueLabel: searchValueLabel,
            target: self, action: #selector(sliderChanged(_:))
        )

        let (spacingSlider, spacingRow) = DemoExplanationView.sliderRow(
            label: "Row Spacing",
            min: 0, max: 10, value: 1,
            valueLabel: spacingValueLabel,
            target: self, action: #selector(sliderChanged(_:))
        )

        let explanationView = DemoExplanationView(
            description: "Customize the heights of headers, footers, search bar, and spacing between rows.",
            controls: [headerRow, footerRow, searchRow, spacingRow]
        )

        return ExplanationControls(
            view: explanationView,
            headerSlider: headerSlider,
            footerSlider: footerSlider,
            searchSlider: searchSlider,
            spacingSlider: spacingSlider,
            headerValueLabel: headerValueLabel,
            footerValueLabel: footerValueLabel,
            searchValueLabel: searchValueLabel,
            spacingValueLabel: spacingValueLabel
        )
    }
}
