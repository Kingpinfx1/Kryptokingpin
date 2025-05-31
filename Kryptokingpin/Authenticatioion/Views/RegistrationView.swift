//
//  RegistrationView.swift
//  Kryptokingpin
//
//  Created by kingpin on 5/31/25.
//

import SwiftUI

struct RegistrationView: View {
    
    @State private var email: String = ""
    @State private var balance: Double = 0.0
    @State private var fullname: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel : AuthViewModel

    
    
    var body: some View {
        NavigationStack{
            ZStack{
                Color.black
                
                RoundedRectangle(cornerSize: CGSize(width: 30, height: 30), style: .continuous)
                    .fill(
                        LinearGradient(colors: [Color.gray, Color.gray.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 1000, height: 400)
                    .rotationEffect(.degrees(135))
                    .offset(y: -350)
                
                VStack(spacing: 20) {
                    Text("Create Account")
                        .foregroundStyle(Color.white)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .offset(x: -50, y: -100)
                    
                    TextField("Email", text: $email)
                        .foregroundStyle(Color.white)
                        .textFieldStyle(.plain)
                        .autocorrectionDisabled()
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .placeholder(when: email.isEmpty) {
                            Text("Email")
                                .foregroundStyle(Color.white)
                                .fontWeight(.bold)
                        }
                        .disabled(viewModel.isLoading)
                    
                    Rectangle()
                        .frame(width: 350, height: 1)
                        .foregroundStyle(.white)
                    
                    TextField("Full name", text: $fullname)
                        .foregroundStyle(Color.white)
                        .textFieldStyle(.plain)
                        .textInputAutocapitalization(.words)
                        .placeholder(when: fullname.isEmpty) {
                            Text("Full name")
                                .foregroundStyle(Color.white)
                                .fontWeight(.bold)
                        }
                        .disabled(viewModel.isLoading)
                    
                    Rectangle()
                        .frame(width: 350, height: 1)
                        .foregroundStyle(.white)
                    
                    SecureField("Password", text: $password)
                        .foregroundStyle(Color.white)
                        .textFieldStyle(.plain)
                        .placeholder(when: password.isEmpty) {
                            Text("Password")
                                .foregroundStyle(Color.white)
                                .fontWeight(.bold)
                        }
                        .disabled(viewModel.isLoading)
                    
                    Rectangle()
                        .frame(width: 350, height: 1)
                        .foregroundStyle(.white)
                    
                    ZStack(alignment: .trailing) {
                        SecureField("Confirm Password", text: $confirmPassword)
                            .foregroundStyle(Color.white)
                            .textFieldStyle(.plain)
                            .placeholder(when: confirmPassword.isEmpty) {
                                Text("Confirm Password")
                                    .foregroundStyle(Color.white)
                                    .fontWeight(.bold)
                            }
                            .disabled(viewModel.isLoading)
                        
                        if !password.isEmpty && !confirmPassword.isEmpty {
                            if password == confirmPassword {
                                Image(systemName: "checkmark.circle.fill")
                                    .imageScale(.large)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.green)
                            } else {
                                Image(systemName: "xmark.circle.fill")
                                    .imageScale(.large)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                    
                    Rectangle()
                        .frame(width: 350, height: 1)
                        .foregroundStyle(.white)
                    
                    Button {
                        Task {
                            await viewModel.createUser(withEmail: email, password: password, fullname: fullname, balance: balance)
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(width: 200, height: 45)
                        } else {
                            Text("Sign up")
                                .bold()
                                .foregroundStyle(.white)
                                .frame(width: 200, height: 45)
                        }
                    }
                    .background(
                        RoundedRectangle(cornerSize: CGSize(width: 30, height: 30), style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.gray, Color.gray.opacity(0.5)],
                                    startPoint: .top,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .disabled(!formIsValid || viewModel.isLoading)
                    .opacity((formIsValid && !viewModel.isLoading) ? 1.0 : 0.5)
                    .padding(.top)
                    .offset(y: 100)
                    
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 3) {
                            Text("Already have an account?")
                            Text("Sign in")
                                .bold()
                        }
                        .foregroundStyle(.white)
                    }
                    .disabled(viewModel.isLoading)
                    .offset(y: 110)
                }
                .frame(width: 350)
            }
            .ignoresSafeArea()
            .alert("Error", isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.alertMessage)
            }
        }
    }
}

#Preview {
    RegistrationView()
}


extension RegistrationView : AuthenticationFormProtocol{
    var formIsValid: Bool {
        return !email.isEmpty && email.contains("@")
        && !password.isEmpty && password.count >= 6
        && confirmPassword == password
        && !fullname.isEmpty
        && fullname.count >= 2
    }
}
