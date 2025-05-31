//
//  AuthGate.swift
//  Kryptokingpin
//
//  Created by kingpin on 5/31/25.
//

import SwiftUI
import FirebaseAuth
import Firebase

struct AuthGate: View {
    
    @EnvironmentObject var viewModel : AuthViewModel

    
    var body: some View {
        if viewModel.userSession != nil{
            MainView()
        } else {
            LoginView()
        }
    }
    

}

#Preview {
    AuthGate()
}
