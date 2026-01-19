//
//  DefaultSortingDemoViewController+Explanation.swift
//  DemoSwiftDataTables
//

import UIKit

extension DefaultSortingDemoViewController {

    struct ExplanationControls {
        let view: DemoExplanationView
        let columnPicker: UISegmentedControl
        let orderPicker: UISegmentedControl
    }

    func makeExplanationControls(columnHeaders: [String]) -> ExplanationControls {
        let (columnPicker, columnSection) = DemoExplanationView.segmentedSection(
            label: "Sort by column",
            items: columnHeaders,
            selectedIndex: 1,
            target: self, action: #selector(columnChanged(_:))
        )

        let (orderPicker, orderSection) = DemoExplanationView.segmentedSection(
            label: "Sort order",
            items: ["Ascending", "Descending"],
            selectedIndex: 0,
            target: self, action: #selector(orderChanged(_:))
        )

        let explanationView = DemoExplanationView(
            description: "Set the default sort column and order. The table will be sorted by this column when it loads.",
            controls: [columnSection, orderSection]
        )

        return ExplanationControls(
            view: explanationView,
            columnPicker: columnPicker,
            orderPicker: orderPicker
        )
    }
}
