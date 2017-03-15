//
//  DataTableSearchTextField.swift
//  Pods
//
//  Created by Pavan Kataria on 15/03/2017.
//
//

import UIKit


class DataTableSearchTextField: UITextField {
    
    //MARK: - Properties

    //MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    public func setup(){
        self.borderStyle = .none
        self.backgroundColor = UIColor.white
        self.clearButtonMode = .always
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
