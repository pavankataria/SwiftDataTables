//
//  SortingIndicatorVisibilityDemoViewController+Explanation.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 22/02/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import UIKit

extension SortingIndicatorVisibilityDemoViewController {

    struct ExplanationControls {
        let view: DemoExplanationView
        let headerToggle: UISwitch
        let footerIndicatorToggle: UISwitch
        let footerSortingToggle: UISwitch
    }

    func makeExplanationControls() -> ExplanationControls {
        let (headerToggle, headerRow) = DemoExplanationView.toggleRow(
            label: "Show Header Indicators",
            isOn: true,
            target: self,
            action: #selector(headerIndicatorToggled(_:))
        )

        let (footerIndicatorToggle, footerIndicatorRow) = DemoExplanationView.toggleRow(
            label: "Show Footer Indicators",
            isOn: false,
            target: self,
            action: #selector(footerIndicatorToggled(_:))
        )

        let (footerSortingToggle, footerSortingRow) = DemoExplanationView.toggleRow(
            label: "Footer Triggers Sorting",
            isOn: false,
            target: self,
            action: #selector(footerSortingToggled(_:))
        )

        let explanationView = DemoExplanationView(
            description: "Control sorting indicator visibility independently for headers and footers. When header indicators are hidden, sorting still works by tapping. Optionally enable footer sorting.",
            controls: [headerRow, footerIndicatorRow, footerSortingRow]
        )

        return ExplanationControls(
            view: explanationView,
            headerToggle: headerToggle,
            footerIndicatorToggle: footerIndicatorToggle,
            footerSortingToggle: footerSortingToggle
        )
    }
}
