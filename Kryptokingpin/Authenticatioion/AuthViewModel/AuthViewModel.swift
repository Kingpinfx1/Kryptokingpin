//
//  AuthViewModel.swift
//  Kryptokingpin
//
//  Created by kingpin on 5/31/25.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

protocol AuthenticationFormProtocol {
    var formIsValid: Bool {get}
}

enum AuthError: LocalizedError {
    case invalidEmail
    case weakPassword
    case emailAlreadyInUse
    case userNotFound
    case wrongPassword
    case networkError
    case passwordResetFailed
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Please enter a valid email address"
        case .weakPassword:
            return "Password should be at least 6 characters long"
        case .emailAlreadyInUse:
            return "This email is already registered"
        case .userNotFound:
            return "No account found with this email"
        case .wrongPassword:
            return "Incorrect password"
        case .networkError:
            return "Network error. Please check your connection"
        case .passwordResetFailed:
            return "Failed to send password reset email. Please try again"
        case .unknown(let message):
            return message
        }
    }
}

@MainActor
class AuthViewModel: ObservableObject {
    
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var showSuccessAlert: Bool = false
    @Published var successMessage: String = ""

    
    init(){
        self.userSession = Auth.auth().currentUser
        
        Task{
            await fetchUser()
        }
    }
    
    func signIn(withEmail email: String , password : String ) async {
        isLoading = true
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
        } catch let error as NSError {
            handleAuthError(error)
        }
        isLoading = false
    }
    
 

    
    func createUser(withEmail email: String , password : String , fullname :String, balance: Double) async {
        isLoading = true
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = User(id: result.user.uid, fullname: fullname, email: email, balance : balance)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            await fetchUser()
        } catch let error as NSError {
            handleAuthError(error)
        }
        isLoading = false
    }
    
    func signOut(){
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        } catch let error as NSError {
            alertMessage = error.localizedDescription
            showAlert = true
        }
    }
    
//    func deleteAccount() async {
//        guard let user = Auth.auth().currentUser else { return }
//        isLoading = true
//        do {
//            try await user.delete()
//            self.userSession = nil
//            self.currentUser = nil
//        } catch let error as NSError {
//            handleAuthError(error)
//        }
//        isLoading = false
//    }
    
    func deleteAccount() async {
        guard let user = Auth.auth().currentUser else { return }
        isLoading = true

        do {
            try await Firestore.firestore().collection("users").document(user.uid).delete()

            try await user.delete()

            self.userSession = nil
            self.currentUser = nil
        } catch let error as NSError {
            handleAuthError(error)
        }

        isLoading = false
    }

    
    func resetPassword(withEmail email: String) async {
        isLoading = true
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            successMessage = "Password reset email sent. Please check your inbox"
            showSuccessAlert = true
        } catch let error as NSError {
            handleAuthError(error)
        }
        isLoading = false
    }
    
    private func handleAuthError(_ error: NSError) {
        let authError: AuthError
        
        switch error.code {
        case AuthErrorCode.invalidEmail.rawValue:
            authError = .invalidEmail
        case AuthErrorCode.weakPassword.rawValue:
            authError = .weakPassword
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            authError = .emailAlreadyInUse
        case AuthErrorCode.userNotFound.rawValue:
            authError = .userNotFound
        case AuthErrorCode.wrongPassword.rawValue:
            authError = .wrongPassword
        case AuthErrorCode.networkError.rawValue:
            authError = .networkError
        case AuthErrorCode.invalidActionCode.rawValue:
            authError = .passwordResetFailed
        default:
            authError = .unknown(error.localizedDescription)
        }
        
        alertMessage = authError.localizedDescription
        showAlert = true
    }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
            self.currentUser = try snapshot.data(as: User.self)
        } catch {
            alertMessage = "Failed to fetch user data"
            showAlert = true
        }
    }
    
 
    func reloadUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        do {
            let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
            if let data = snapshot.data() {
                let user = try Firestore.Decoder().decode(User.self, from: data)
                self.currentUser = user
            }
        } catch {
            print("Failed to reload user: \(error.localizedDescription)")
        }
    }


}
