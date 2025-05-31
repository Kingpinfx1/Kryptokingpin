//
//  ForgotPasswordView.swift
//  Kryptokingpin
//
//  Created by kingpin on 5/31/25.
//

import SwiftUI

struct ForgotPasswordView: View {
    @State private var email: String = ""
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                
                RoundedRectangle(cornerSize: CGSize(width: 30, height: 30), style: .continuous)
                    .fill(
                        LinearGradient(colors: [Color.gray, Color.gray.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 1000, height: 400)
                    .rotationEffect(.degrees(135))
                    .offset(y: -350)
                
                VStack(spacing: 20) {
                    Text("Reset Password")
                        .foregroundStyle(Color.white)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .offset(x: -50, y: -100)
                    
                    Text("Enter your email address and we'll send you a link to reset your password")
                        .foregroundStyle(Color.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .offset(y: -50)
                    
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
                    
                    Button {
                        Task {
                            await viewModel.resetPassword(withEmail: email)
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(width: 200, height: 45)
                        } else {
                            Text("Send Reset Link")
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
                    .offset(y: 50)
                    
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 3) {
                            Text("Remember your password?")
                            Text("Sign in")
                                .bold()
                        }
                        .foregroundStyle(.white)
                    }
                    .disabled(viewModel.isLoading)
                    .offset(y: 60)
                }
                .frame(width: 350)
            }
            .ignoresSafeArea()
            .alert("Error", isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.alertMessage)
            }
            .alert("Success", isPresented: $viewModel.showSuccessAlert) {
                Button("OK", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text(viewModel.successMessage)
            }
        }
    }
}

extension ForgotPasswordView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty && email.contains("@")
    }
}

#Preview {
    ForgotPasswordView()
}
