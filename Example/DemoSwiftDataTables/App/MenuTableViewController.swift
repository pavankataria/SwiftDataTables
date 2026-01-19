//
//  MenuTableViewController.swift
//  SwiftDataTables_Example
//
//  Created by Pavan Kataria on 13/06/2018.
//  Copyright © 2017 Pavan Kataria. All rights reserved.
//

import Foundation
import UIKit
import SwiftDataTables

struct MenuItem {
    let title: String
    let config: DataTableConfiguration?
    let description: String?

    public init(title: String, config: DataTableConfiguration? = nil, description: String? = nil) {
        self.title = title
        self.config = config
        self.description = description
    }
}

class MenuViewController: UITableViewController {
    private enum Section: Int, CaseIterable {
        case dataInitialization = 0
        case layoutSizing
        case visibilityFloating
        case sortingSelection
        case visualStyling
        case performance

        var title: String {
            switch self {
            case .dataInitialization: return "Data Initialization"
            case .layoutSizing: return "Layout & Sizing"
            case .visibilityFloating: return "Visibility & Floating"
            case .sortingSelection: return "Sorting & Selection"
            case .visualStyling: return "Visual Styling"
            case .performance: return "Performance"
            }
        }
    }

    private let menuItemIdentifier = "MenuItemIdentifier"

    lazy var menuItems: [[MenuItem]] = createMenuItems()

    init() {
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "SwiftDataTables Demos"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: menuItemIdentifier)
        tableView.rowHeight = 56
        tableView.reloadData()
    }

    // MARK: - Menu Item Creation

    private func createMenuItems() -> [[MenuItem]] {
        return [
            // Section 0: Data Initialization
            [
                MenuItem(title: "Static Data Set"),
                MenuItem(title: "Dynamic Data Source"),
                MenuItem(title: "Empty Data Source"),
                MenuItem(title: "Incremental Updates"),
            ],
            // Section 1: Layout & Sizing
            [
                MenuItem(title: "Fixed/Frozen Columns"),
                MenuItem(title: "Column Width Strategies"),
                MenuItem(title: "Row Height + Text Wrap"),
                MenuItem(title: "Custom Cells + Auto Height"),
                MenuItem(title: "Heights Customization"),
            ],
            // Section 2: Visibility & Floating
            [
                MenuItem(title: "Show/Hide Elements"),
                MenuItem(title: "Floating Elements"),
                MenuItem(title: "Search Bar Position"),
            ],
            // Section 3: Sorting & Selection
            [
                MenuItem(title: "Default Sorting"),
                MenuItem(title: "Row Selection"),
            ],
            // Section 4: Visual Styling
            [
                MenuItem(title: "Sort Arrow Styling"),
                MenuItem(
                    title: "Alternating Row Colours",
                    config: configurationAlternatingColours(),
                    description: "Custom rainbow alternating row colours. Set highlightedAlternatingRowColors and unhighlightedAlternatingRowColors."
                ),
            ],
            // Section 5: Performance
            [
                MenuItem(title: "Performance Stress Test"),
            ],
        ]
    }
}

// MARK: - Data Source and Delegate

extension MenuViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return menuItems.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: menuItemIdentifier, for: indexPath)
        cell.textLabel?.text = menuItems[indexPath.section][indexPath.row].title
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionType = Section(rawValue: section) else { return nil }
        return sectionType.title
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let section = Section(rawValue: indexPath.section) else { return }

        switch section {
        case .dataInitialization:
            handleDataInitialization(row: indexPath.row)
        case .layoutSizing:
            handleLayoutSizing(row: indexPath.row)
        case .visibilityFloating:
            handleVisibilityFloating(row: indexPath.row)
        case .sortingSelection:
            handleSortingSelection(row: indexPath.row)
        case .visualStyling:
            handleVisualStyling(row: indexPath.row)
        case .performance:
            handlePerformance(row: indexPath.row)
        }
    }
}

// MARK: - Section Handlers

extension MenuViewController {
    private func handleDataInitialization(row: Int) {
        switch row {
        case 0:
            show(DataTableWithDataSetViewController(), sender: self)
        case 1:
            let instance = DataTableWithDataSourceViewController()
            show(instance, sender: self)
            instance.addDataSourceAfter()
        case 2:
            show(DataTableWithDataSourceViewController(), sender: self)
        case 3:
            show(IncrementalUpdatesDemoViewController(), sender: self)
        default:
            break
        }
    }

    private func handleLayoutSizing(row: Int) {
        switch row {
        case 0:
            show(FixedColumnsDemoViewController(), sender: self)
        case 1:
            show(ColumnWidthStrategyDemoViewController(), sender: self)
        case 2:
            show(RowHeightAndWrapDemoViewController(), sender: self)
        case 3:
            show(CustomCellsAutoHeightDemoViewController(), sender: self)
        case 4:
            show(HeightsCustomizationDemoViewController(), sender: self)
        default:
            break
        }
    }

    private func handleVisibilityFloating(row: Int) {
        switch row {
        case 0:
            show(ShowHideElementsDemoViewController(), sender: self)
        case 1:
            show(FloatingElementsDemoViewController(), sender: self)
        case 2:
            show(NativeSearchDemoViewController(), sender: self)
        default:
            break
        }
    }

    private func handleSortingSelection(row: Int) {
        switch row {
        case 0:
            show(DefaultSortingDemoViewController(), sender: self)
        case 1:
            show(RowSelectionDemoViewController(), sender: self)
        default:
            break
        }
    }

    private func handleVisualStyling(row: Int) {
        switch row {
        case 0:
            show(SortArrowStylingDemoViewController(), sender: self)
        case 1:
            let menuItem = menuItems[Section.visualStyling.rawValue][row]
            if let config = menuItem.config {
                let instance = GenericDataTableViewController(
                    with: config,
                    description: menuItem.description ?? "Visual configuration example."
                )
                instance.title = menuItem.title
                show(instance, sender: self)
            }
        default:
            break
        }
    }

    private func handlePerformance(row: Int) {
        switch row {
        case 0:
            show(PerformanceDemoViewController(), sender: self)
        default:
            break
        }
    }
}

// MARK: - Configuration Helpers

extension MenuViewController {
    private func configurationAlternatingColours() -> DataTableConfiguration {
        var configuration = DataTableConfiguration()
        configuration.highlightedAlternatingRowColors = [
            .init(1, 0.7, 0.7),
            .init(1, 0.7, 0.5),
            .init(1, 1, 0.5),
            .init(0.5, 1, 0.5),
            .init(0.5, 0.7, 1),
            .init(0.5, 0.5, 1),
            .init(1, 0.5, 0.5)
        ]
        configuration.unhighlightedAlternatingRowColors = [
            .init(1, 0.90, 0.90),
            .init(1, 0.90, 0.7),
            .init(1, 1, 0.7),
            .init(0.7, 1, 0.7),
            .init(0.7, 0.9, 1),
            .init(0.7, 0.7, 1),
            .init(1, 0.7, 0.7)
        ]
        return configuration
    }
}

// MARK: - UIColor Extension

extension UIColor {
    public convenience init(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) {
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
