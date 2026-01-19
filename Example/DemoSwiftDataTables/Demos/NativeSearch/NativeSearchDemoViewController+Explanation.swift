//
//  NativeSearchDemoViewController+Explanation.swift
//  DemoSwiftDataTables
//

import UIKit

extension NativeSearchDemoViewController {

    struct ExplanationControls {
        let view: DemoExplanationView
        let positionSegment: UISegmentedControl
    }

    func makeExplanationControls() -> ExplanationControls {
        let (positionSegment, positionSection) = DemoExplanationView.segmentedSection(
            label: "Position",
            items: ["Embedded", "Navigation Bar"],
            selectedIndex: 0,
            target: self, action: #selector(positionChanged(_:))
        )

        let explanationView = DemoExplanationView(
            description: "Choose where the search bar appears. Embedded places it inside the table. Navigation Bar uses iOS's native UISearchController.",
            controls: [positionSection]
        )

        return ExplanationControls(
            view: explanationView,
            positionSegment: positionSegment
        )
    }
}
