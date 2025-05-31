//
//  LoginView.swift
//  Kryptokingpin
//
//  Created by kingpin on 5/31/25.
//

import SwiftUI

struct LoginView: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showForgotPassword = false
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
                    Text("Welcome")
                        .foregroundStyle(Color.white)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .offset(x: -100, y: -100)
                    
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
                    
                    Button {
                        showForgotPassword = true
                    } label: {
                        Text("Forgot Password?")
                            .foregroundStyle(.white)
                            .font(.footnote)
                    }
                    .disabled(viewModel.isLoading)
                    .offset(x: 100)
                    
                    Button {
                        Task {
                            await viewModel.signIn(withEmail: email, password: password)
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(width: 200, height: 45)
                        } else {
                            Text("Sign in")
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
                    
                    NavigationLink{
                        RegistrationView()
                            .navigationBarBackButtonHidden()
                    } label: {
                        HStack(spacing: 3) {
                            Text("Don't have an account?")
                            Text("Sign up")
                                .bold()
                        }
                        .foregroundStyle(.white)
                    }
                    .disabled(viewModel.isLoading)
                    .offset(y:110)
                    
                }
                .frame(width: 350)
                
            }
            .ignoresSafeArea()
            .alert("Error", isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.alertMessage)
            }
            .sheet(isPresented: $showForgotPassword) {
                ForgotPasswordView()
            }
        }
    }
    
}



#Preview {
    LoginView()
}

extension LoginView : AuthenticationFormProtocol{
    var formIsValid: Bool {
        return !email.isEmpty && email.contains("@") && !password.isEmpty && password.count >= 6
    }
    
    
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
            
            ZStack(alignment: alignment) {
                placeholder().opacity(shouldShow ? 1 : 0)
                self
            }
        }
}
