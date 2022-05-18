//
//  MemeTextFieldDelegate.swift
//  MemeMe 1.0
//
//  Created by Keng Susumpow on 18/5/22.
//

import Foundation
import UIKit

class MemeTextFieldDelegate: NSObject, UITextFieldDelegate {
    
    enum textFieldType: Int {
        case top = 0, bottom
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch(textFieldType(rawValue: textField.tag)!){
        case .top:
            if textField.text == "TOP" {
                textField.text = ""
            }
        case .bottom:
            if textField.text == "BOTTOM" {
                textField.text = ""
            }
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch(textFieldType(rawValue: textField.tag)!){
        case .top:
            if textField.text == "" {
                textField.text = "TOP"
            }
        case .bottom:
            if textField.text == "" {
                textField.text = "BOTTOM"
            }
        }
        
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}
