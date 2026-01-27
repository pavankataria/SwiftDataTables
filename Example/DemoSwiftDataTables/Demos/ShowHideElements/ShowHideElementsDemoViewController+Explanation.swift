//
//  ShowHideElementsDemoViewController+Explanation.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 22/02/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import UIKit

extension ShowHideElementsDemoViewController {

    struct ExplanationControls {
        let view: DemoExplanationView
        let footerToggle: UISwitch
        let searchToggle: UISwitch
        let verticalScrollToggle: UISwitch
        let horizontalScrollToggle: UISwitch
    }

    func makeExplanationControls() -> ExplanationControls {
        let (footerToggle, footerRow) = DemoExplanationView.toggleRow(
            label: "Show Footer", isOn: true,
            target: self, action: #selector(toggleChanged(_:))
        )
        let (searchToggle, searchRow) = DemoExplanationView.toggleRow(
            label: "Show Search Bar", isOn: true,
            target: self, action: #selector(toggleChanged(_:))
        )
        let (verticalScrollToggle, verticalRow) = DemoExplanationView.toggleRow(
            label: "Vertical Scroll Bar", isOn: true,
            target: self, action: #selector(toggleChanged(_:))
        )
        let (horizontalScrollToggle, horizontalRow) = DemoExplanationView.toggleRow(
            label: "Horizontal Scroll Bar", isOn: false,
            target: self, action: #selector(toggleChanged(_:))
        )

        let explanationView = DemoExplanationView(
            description: "Control which elements are visible in the table. Toggle options below and observe the changes.",
            controls: [footerRow, searchRow, verticalRow, horizontalRow]
        )

        return ExplanationControls(
            view: explanationView,
            footerToggle: footerToggle,
            searchToggle: searchToggle,
            verticalScrollToggle: verticalScrollToggle,
            horizontalScrollToggle: horizontalScrollToggle
        )
    }
}
