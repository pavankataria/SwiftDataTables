//
//  DataTableSearchTextField.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 15/03/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import UIKit

/// Custom text field with rounded corners and inset padding.
///
/// `DataTableSearchTextField` provides a styled search text field with:
/// - Rounded corners based on height
/// - Consistent inset padding for text, placeholder, and editing
/// - Clear button always visible
///
/// - Note: This is used internally for the legacy embedded search functionality.
///   The modern search implementation uses `UISearchBar` via `MenuLengthHeader`.
class DataTableSearchTextField: UITextField {
    
    //MARK: - Properties

    //MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        MainActor.assumeIsolated {
            borderStyle = .none
            backgroundColor = UIColor.white
            clearButtonMode = .always
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = (self.bounds.height / 2)-1
    }
    
    let inset: CGFloat = 10
    
    // placeholder position
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: inset , dy: inset)
    }
    
    // text position
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: inset , dy: inset)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: inset, dy: inset)
    }
    
}
