//
//  UIApplication.swift
//  Kryptokingpin
//
//  Created by kingpin on 4/25/25.
//

import Foundation
import SwiftUI

extension UIApplication{
    func endEditing(){
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
