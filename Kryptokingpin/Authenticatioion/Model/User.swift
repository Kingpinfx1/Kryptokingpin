//
//  User.swift
//  Kryptokingpin
//
//  Created by kingpin on 5/31/25.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    let fullname: String
    let email: String
    var balance: Double?
    
    var initials: String{
        let formatter = PersonNameComponentsFormatter()
        if let commponents = formatter.personNameComponents(from: fullname) {
            formatter.style = .abbreviated
            return formatter.string(from: commponents)
        }
        return ""
    }
    
}
