//
//  FloatingElementsDemoViewController+Explanation.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 22/02/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import UIKit

extension FloatingElementsDemoViewController {

    struct ExplanationControls {
        let view: DemoExplanationView
        let headersFloatToggle: UISwitch
        let footersFloatToggle: UISwitch
        let searchFloatToggle: UISwitch
    }

    func makeExplanationControls() -> ExplanationControls {
        let (headersToggle, headersRow) = DemoExplanationView.toggleRow(
            label: "Headers Float", isOn: true,
            target: self, action: #selector(toggleChanged(_:))
        )
        let (footersToggle, footersRow) = DemoExplanationView.toggleRow(
            label: "Footers Float", isOn: true,
            target: self, action: #selector(toggleChanged(_:))
        )
        let (searchToggle, searchRow) = DemoExplanationView.toggleRow(
            label: "Search Float", isOn: false,
            target: self, action: #selector(toggleChanged(_:))
        )

        let explanationView = DemoExplanationView(
            description: "Control whether headers and footers float (stay visible) or scroll with content. Scroll the table to see the difference.",
            controls: [headersRow, footersRow, searchRow]
        )

        return ExplanationControls(
            view: explanationView,
            headersFloatToggle: headersToggle,
            footersFloatToggle: footersToggle,
            searchFloatToggle: searchToggle
        )
    }
}
