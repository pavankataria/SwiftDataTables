//
//  ColumnSortabilityDemoViewController+Explanation.swift
//  DemoSwiftDataTables
//

import UIKit

extension ColumnSortabilityDemoViewController {

    struct ExplanationControls {
        let view: DemoExplanationView
        let toggles: [UISwitch]
    }

    func makeExplanationControls(columnHeaders: [String]) -> ExplanationControls {
        var toggles: [UISwitch] = []
        var toggleRows: [UIView] = []

        // Create a toggle for each column
        for (index, header) in columnHeaders.enumerated() {
            let (toggle, row) = DemoExplanationView.toggleRow(
                label: header,
                isOn: true,
                target: self,
                action: #selector(toggleChanged(_:))
            )
            toggle.tag = index
            toggles.append(toggle)
            toggleRows.append(row)
        }

        // Group toggles into rows of 2 for compact layout
        let groupedRows = stride(from: 0, to: toggleRows.count, by: 2).map { startIndex -> UIStackView in
            let endIndex = min(startIndex + 2, toggleRows.count)
            let rowViews = Array(toggleRows[startIndex..<endIndex])
            let hStack = UIStackView(arrangedSubviews: rowViews)
            hStack.axis = .horizontal
            hStack.spacing = 20
            hStack.distribution = .fillEqually
            return hStack
        }

        let explanationView = DemoExplanationView(
            description: "Control which columns can be sorted. When a column is not sortable, the sort indicator is hidden and tapping the header has no effect.",
            controls: groupedRows
        )

        return ExplanationControls(
            view: explanationView,
            toggles: toggles
        )
    }
}
